class_name ClassicActionInterpreter
extends RefCounted

const MAX_INTERNAL_STEPS := 256
const MAX_CALL_STACK_DEPTH := 20

var bundle: ClassicCampaignBundle
var runtime_state: ClassicRuntimeState
var current_trigger: Dictionary = {}
var current_action_index := 0
var call_stack: Array = []
var gosub_active := false
var pending_choice: Dictionary = {}
var pending_encounter: Dictionary = {}
var pending_battle: Dictionary = {}
var encounter_origins: Array = []
var trace: Array = []
var last_error := ""
var halted := false


func configure(campaign_bundle: ClassicCampaignBundle, state: ClassicRuntimeState) -> void:
	bundle = campaign_bundle
	runtime_state = state
	reset_execution()


func reset_execution() -> void:
	current_trigger = {}
	current_action_index = 0
	call_stack.clear()
	gosub_active = false
	pending_choice.clear()
	pending_encounter.clear()
	pending_battle.clear()
	encounter_origins.clear()
	trace.clear()
	last_error = ""
	halted = false


func begin_trigger(trigger_id: String, start_slot := 0) -> bool:
	reset_execution()
	if bundle == null or runtime_state == null:
		last_error = "ClassicActionInterpreter must be configured before execution"
		return false
	var trigger := bundle.get_trigger(trigger_id)
	if trigger.is_empty():
		last_error = "Unknown classic trigger: %s" % trigger_id
		return false
	_set_cursor(trigger, start_slot)
	return true


func run_until_yield() -> Dictionary:
	if halted:
		return _error_result(last_error if not last_error.is_empty() else "Interpreter is halted")
	if not pending_choice.is_empty():
		return _error_result("A classic choice must be resumed before execution can continue")
	if not pending_encounter.is_empty():
		return _error_result("A classic encounter must be resumed before execution can continue")
	if not pending_battle.is_empty():
		return _error_result("A classic battle outcome must be resumed before execution can continue")

	for _step: int in MAX_INTERNAL_STEPS:
		if current_trigger.is_empty():
			return _completed_result("action-point-ended")

		var actions: Variant = current_trigger.get("actions", [])
		if not (actions is Array):
			return _halt_with_error("Trigger %s has no action array" % _current_trigger_id())
		if current_action_index >= actions.size():
			_clear_control_flow()
			return _completed_result("action-point-ended")

		var action: Variant = actions[current_action_index]
		current_action_index += 1
		if not (action is Dictionary):
			return _halt_with_error("Trigger %s contains a non-object action" % _current_trigger_id())
		_update_gosub_state(action)
		trace.append({
			"triggerId": _current_trigger_id(),
			"slot": int(action.get("slot", -1)),
			"code": int(action.get("code", 0)),
		})
		var result := _execute_action(action)
		if str(result.get("status", "")) == "continue":
			continue
		return result

	return _halt_with_error("Classic action execution exceeded %d internal steps" % MAX_INTERNAL_STEPS)


func resume_choice(accepted: bool) -> Dictionary:
	if pending_choice.is_empty():
		return _error_result("No classic choice is waiting for a response")
	var choice := pending_choice
	pending_choice = {}
	var values: Array = choice["values"]
	var inverted := int(values[0]) != 0
	var apply_result := accepted != inverted
	if not apply_result:
		return run_until_yield()

	match int(values[1]):
		0:
			_clear_control_flow()
			return _completed_result("choice-exit")
		1:
			var branch_result := _branch_to_extra_action_point(
				int(values[2]),
				bool(choice.get("gosub", false)),
				0
			)
			if str(branch_result.get("status", "")) != "continue":
				return branch_result
			return run_until_yield()
		2, 3:
			return _execute_encounter(
				"simple" if int(values[1]) == 2 else "complex",
				int(values[2])
			)
		4:
			return _yield_result("eliminate_encounter_option", {})
		_:
			return _halt_with_error("Choice references unsupported branch mode %d" % int(values[1]))


func resume_encounter(outcome: int) -> Dictionary:
	if pending_encounter.is_empty():
		return _error_result("No classic encounter is waiting for a result")
	var encounter_context := pending_encounter
	pending_encounter = {}
	if outcome == 0:
		_clear_control_flow()
		encounter_origins.clear()
		return _completed_result("encounter-cancelled")
	if outcome < 1 or outcome > 4:
		return _halt_with_error("Classic encounter outcome must be between 0 and 4")

	var encounter: Dictionary = encounter_context["encounter"]
	var outcome_trigger := _encounter_outcome_trigger(
		str(encounter_context["encounterKind"]),
		int(encounter_context["encounterId"]),
		encounter,
		outcome
	)
	if outcome_trigger.is_empty():
		return _halt_with_error("Classic encounter has no action array")
	_set_cursor(outcome_trigger, 0)
	return run_until_yield()


func resume_battle(coward: bool) -> Dictionary:
	if pending_battle.is_empty():
		return _error_result("No classic battle is waiting for an outcome")
	var battle_context := pending_battle
	pending_battle = {}
	if not coward:
		return _yield_result("give_battle_loot", {
			"extraCodeId": int(battle_context["extraCodeId"]),
			"lootMode": 0,
		})

	var coward_macro_id := int(battle_context["cowardMacroId"])
	if coward_macro_id == -1:
		_clear_control_flow()
		return _yield_result("apply_coward_penalty", {
			"experiencePerLevel": 2000,
			"soundId": 26260,
			"warningIds": [118, 124],
			"backUpParty": true,
		})
	var branch_result := _branch_to_extra_action_point(
		coward_macro_id,
		bool(battle_context.get("gosub", false)),
		0
	)
	if str(branch_result.get("status", "")) != "continue":
		return branch_result
	return run_until_yield()


func _execute_action(action: Dictionary) -> Dictionary:
	var code := int(action.get("code", 0))
	var record_id := int(action.get("id", 0))
	match code:
		0:
			return _continue_result()
		1:
			return _yield_result("show_text", {
				"messageId": record_id,
				"message": bundle.get_message(record_id),
			})
		2:
			return _execute_battle(record_id)
		3:
			return _execute_choice(record_id, gosub_active)
		4:
			return _execute_encounter("simple", record_id)
		5:
			return _execute_encounter("complex", record_id)
		9:
			return _yield_result("play_sound", {"soundId": record_id})
		10:
			return _execute_treasure(record_id)
		12:
			return _execute_tile_mutation(record_id)
		13:
			return _execute_trigger_mutation(record_id)
		20, 45:
			return _execute_teleport(record_id, code == 20)
		24:
			_clear_control_flow()
			return _completed_result("keep-codes")
		39:
			# Classic's Extend Door Codes replaces the active AP without pushing,
			# even when its raw opcode is negative.
			return _branch_to_extra_action_point(record_id, false, 0)
		56:
			return _execute_battle_outcome(record_id, gosub_active)
		46:
			return _execute_quest_branch(record_id, gosub_active)
		47:
			runtime_state.set_quest_flag(record_id)
			return _continue_result()
		111:
			if call_stack.is_empty():
				_clear_control_flow()
				return _completed_result("return-with-empty-stack")
			_restore_call_frame()
			return _continue_result()
		112:
			if not call_stack.is_empty():
				call_stack.pop_back()
			return _continue_result()
		34:
			return _break_encounter()
		_:
			if bundle.is_dispatcher_noop(current_trigger, action):
				return _continue_result()
			halted = true
			return {
				"status": "unsupported",
				"opcode": code,
				"action": action,
				"triggerId": _current_trigger_id(),
			}


func _execute_battle(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error("Battle action references missing Extra Code row %d" % extra_code_id)
	var first_battle_id := int(values[0])
	var last_battle_id := int(values[1]) if int(values[1]) != 0 else first_battle_id
	return _yield_result("start_battle", {
		"extraCodeId": extra_code_id,
		"battleIdRange": [abs(first_battle_id), abs(last_battle_id)],
		"surprise": first_battle_id < 0,
		"soundId": int(values[2]),
		"messageId": int(values[3]),
		"message": bundle.get_message(int(values[3])),
		"lootMode": int(values[4]),
		"battle": bundle.get_battle(first_battle_id),
	})


func _execute_encounter(encounter_kind: String, encounter_id: int, start_slot := 0) -> Dictionary:
	var encounter := bundle.get_encounter(encounter_kind, encounter_id)
	if encounter.is_empty():
		return _halt_with_error(
			"Missing %s encounter record %d" % [encounter_kind, encounter_id]
		)
	encounter_origins.append({
		"trigger": current_trigger,
		"actionIndex": current_action_index,
		"callStack": call_stack.duplicate(true),
	})
	var prompt_id := int(encounter.get("prompt", 0))
	var prompt_message := bundle.get_message(prompt_id)
	pending_encounter = {
		"encounterKind": encounter_kind,
		"encounterId": encounter_id,
		"encounter": encounter,
		"promptMessage": prompt_message,
		"startSlot": start_slot,
	}
	return _yield_result("start_encounter", {
		"encounterKind": encounter_kind,
		"encounterId": encounter_id,
		"encounter": encounter,
		"promptMessage": prompt_message,
		"startSlot": start_slot,
	})


func _execute_treasure(treasure_id: int) -> Dictionary:
	var treasure := bundle.get_treasure(treasure_id)
	if treasure.is_empty():
		return _halt_with_error("Missing treasure record %d" % treasure_id)
	return _yield_result("give_treasure", {
		"treasureId": treasure_id,
		"treasure": treasure,
		"lootMode": 1,
	})


func _execute_tile_mutation(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error("Tile mutation references missing Extra Code row %d" % extra_code_id)
	var level_kind := "dungeon" if int(values[4]) != 0 else "land"
	var tile_x := int(values[2]) if level_kind == "dungeon" else int(values[1])
	var tile_y := int(values[1]) if level_kind == "dungeon" else int(values[2])
	var map_level := int(values[0])
	var tile_value := int(values[3])
	runtime_state.set_tile(level_kind, map_level, tile_x, tile_y, tile_value)
	return _yield_result("set_map_tile", {
		"extraCodeId": extra_code_id,
		"levelType": level_kind,
		"levelIndex": map_level,
		"x": tile_x,
		"y": tile_y,
		"tileValue": tile_value,
	})


func _execute_trigger_mutation(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Trigger mutation references missing Extra Code row %d" % extra_code_id
		)
	var range_start_with_sign := int(values[3])
	var level_kind := runtime_state.level_type
	if range_start_with_sign < 0:
		level_kind = "dungeon"
	elif range_start_with_sign > 0:
		level_kind = "land"
	var map_level := int(values[0])
	var percent := int(values[2])
	var trigger_ids: Array = []
	var single_trigger_id := int(values[1])
	if single_trigger_id != 0:
		trigger_ids.append(single_trigger_id)
	if range_start_with_sign != 0:
		var range_start: int = abs(range_start_with_sign)
		var range_end: int = abs(int(values[4]))
		for trigger_id: int in range(range_start, range_end + 1):
			if not trigger_ids.has(trigger_id):
				trigger_ids.append(trigger_id)
	for trigger_id: int in trigger_ids:
		runtime_state.set_trigger_percent(level_kind, map_level, trigger_id, percent)
	return _yield_result("set_trigger_percent", {
		"extraCodeId": extra_code_id,
		"levelType": level_kind,
		"levelIndex": map_level,
		"triggerIds": trigger_ids,
		"percent": percent,
	})


func _execute_battle_outcome(extra_code_id: int, gosub: bool) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Battle outcome branch references missing Extra Code row %d" % extra_code_id
		)
	var first_battle_id := int(values[0])
	var last_battle_id := int(values[1]) if int(values[1]) != 0 else first_battle_id
	pending_battle = {
		"extraCodeId": extra_code_id,
		"cowardMacroId": int(values[2]),
		"gosub": gosub,
	}
	return _yield_result("start_battle", {
		"extraCodeId": extra_code_id,
		"battleIdRange": [abs(first_battle_id), abs(last_battle_id)],
		"soundId": int(values[3]),
		"messageId": int(values[4]),
		"message": bundle.get_message(int(values[4])),
		"lootMode": 0,
		"battle": bundle.get_battle(first_battle_id),
		"outcomeBranch": true,
		"cowardMacroId": int(values[2]),
	})


func _execute_choice(extra_code_id: int, gosub: bool) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error("Choice action references missing Extra Code row %d" % extra_code_id)
	pending_choice = {
		"values": values,
		"gosub": gosub,
	}
	return _yield_result("choice", {
		"extraCodeId": extra_code_id,
		"yesMessageId": int(values[3]),
		"yesMessage": bundle.get_message(int(values[3])),
		"noMessageId": int(values[4]),
		"noMessage": bundle.get_message(int(values[4])),
	})


func _execute_teleport(extra_code_id: int, recheck_destination: bool) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error("Teleport action references missing Extra Code row %d" % extra_code_id)
	runtime_state.set_position(int(values[0]), int(values[1]), int(values[2]))
	return _yield_result("teleport", {
		"extraCodeId": extra_code_id,
		"levelType": runtime_state.level_type,
		"levelIndex": runtime_state.level_index,
		"x": runtime_state.x,
		"y": runtime_state.y,
		"soundId": int(values[3]),
		"messageId": int(values[4]),
		"message": bundle.get_message(int(values[4])),
		"recheckDestination": recheck_destination,
	})


func _execute_quest_branch(extra_code_id: int, gosub: bool) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error("Quest branch references missing Extra Code row %d" % extra_code_id)
	var quest_is_set := runtime_state.is_quest_set(int(values[0]))
	var condition := int(values[1])
	var should_branch := condition == 2 or (condition == 1 and quest_is_set) or (condition == 0 and not quest_is_set)
	if not should_branch:
		return _continue_result()
	return _branch_from_extra_code(values, gosub)


func _branch_from_extra_code(values: Array, gosub: bool) -> Dictionary:
	if gosub:
		var push_result := _push_call_frame()
		if str(push_result.get("status", "")) != "continue":
			return push_result
	match int(values[2]):
		-1:
			current_trigger = {}
			return _completed_result("dropout")
		0:
			return _branch_to_extra_action_point(int(values[3]), false, 0)
		1, 2:
			return _execute_encounter(
				"simple" if int(values[2]) == 1 else "complex",
				int(values[3]),
				int(values[4])
			)
		3:
			_clear_control_flow()
			return _completed_result("keep-codes")
		_:
			return _halt_with_error("Unsupported classic branch mode %d" % int(values[2]))


func _branch_to_extra_action_point(record_id: int, gosub: bool, start_slot: int) -> Dictionary:
	var target := bundle.get_extra_action_point(record_id)
	if target.is_empty():
		return _halt_with_error("Missing Data ED3 action point %d" % record_id)
	if gosub:
		var push_result := _push_call_frame()
		if str(push_result.get("status", "")) != "continue":
			return push_result
	_set_cursor(target, start_slot)
	return _continue_result()


func _push_call_frame() -> Dictionary:
	if call_stack.size() >= MAX_CALL_STACK_DEPTH:
		return _halt_with_error(
			"Classic GOSUB stack exceeded %d frames" % MAX_CALL_STACK_DEPTH
		)
	call_stack.append({
		"trigger": current_trigger,
		"actionIndex": current_action_index,
	})
	return _continue_result()


func _set_cursor(trigger: Dictionary, start_slot: int) -> void:
	current_trigger = trigger
	current_action_index = 0
	var actions: Variant = trigger.get("actions", [])
	if not (actions is Array):
		return
	while current_action_index < actions.size():
		var action: Variant = actions[current_action_index]
		if action is Dictionary and int(action.get("slot", -1)) >= start_slot:
			break
		current_action_index += 1


func _encounter_outcome_trigger(
	encounter_kind: String,
	encounter_id: int,
	encounter: Dictionary,
	outcome: int
) -> Dictionary:
	var encounter_actions: Variant = encounter.get("actions", [])
	if not (encounter_actions is Array):
		return {}
	var first_slot := (outcome - 1) * 8
	var actions: Array = []
	for action_value: Variant in encounter_actions:
		if not (action_value is Dictionary):
			continue
		var slot := int(action_value.get("slot", -1))
		if slot < first_slot or slot >= first_slot + 8:
			continue
		var action: Dictionary = action_value.duplicate(true)
		var raw_code := int(action.get("rawCode", 0))
		action["code"] = abs(raw_code) if raw_code < 0 and raw_code not in [-14, -23] else raw_code
		action["gosub"] = raw_code < 0 and raw_code not in [-14, -23]
		action["slot"] = slot - first_slot
		actions.append(action)
	return {
		"id": "%s encounter:%d:outcome:%d" % [encounter_kind, encounter_id, outcome],
		"source": "Data ED" if encounter_kind == "simple" else "Data ED2",
		"recordIndex": encounter_id,
		"actions": actions,
	}


func _break_encounter() -> Dictionary:
	if encounter_origins.is_empty():
		return _halt_with_error("Break encounter loop has no active encounter")
	var origin: Dictionary = encounter_origins.pop_back()
	current_trigger = origin["trigger"]
	current_action_index = int(origin["actionIndex"])
	call_stack = origin["callStack"]
	return _continue_result()


func _restore_call_frame() -> void:
	var frame: Dictionary = call_stack.pop_back()
	current_trigger = frame["trigger"]
	current_action_index = int(frame["actionIndex"])


func _update_gosub_state(action: Dictionary) -> void:
	# Classic keeps GOSUB active across positive actions while a call frame exists.
	if bool(action.get("gosub", false)):
		gosub_active = true
	elif call_stack.is_empty():
		gosub_active = false


func _clear_control_flow() -> void:
	current_trigger = {}
	current_action_index = 0
	call_stack.clear()
	gosub_active = false


func _extra_code_values(record_id: int) -> Array:
	var row := bundle.get_extra_code(record_id)
	if row.is_empty():
		return []
	var values: Variant = row.get("values", [])
	if not (values is Array) or values.size() < 5:
		return []
	return values


func _current_trigger_id() -> String:
	return str(current_trigger.get("id", ""))


func _continue_result() -> Dictionary:
	return {"status": "continue"}


func _yield_result(command: String, payload: Dictionary) -> Dictionary:
	return {
		"status": "yield",
		"command": command,
		"payload": payload,
		"triggerId": _current_trigger_id(),
	}


func _completed_result(reason: String) -> Dictionary:
	return {
		"status": "completed",
		"reason": reason,
	}


func _error_result(message: String) -> Dictionary:
	return {
		"status": "error",
		"message": message,
	}


func _halt_with_error(message: String) -> Dictionary:
	last_error = message
	halted = true
	return _error_result(message)
