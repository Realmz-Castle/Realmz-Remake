class_name ClassicActionInterpreter
extends RefCounted

const MAX_INTERNAL_STEPS := 256

var bundle: ClassicCampaignBundle
var runtime_state: ClassicRuntimeState
var current_trigger: Dictionary = {}
var current_action_index := 0
var call_stack: Array = []
var pending_choice: Dictionary = {}
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
	pending_choice.clear()
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

	for _step: int in MAX_INTERNAL_STEPS:
		if current_trigger.is_empty():
			if call_stack.is_empty():
				return _completed_result("action-point-ended")
			_restore_call_frame()

		var actions: Variant = current_trigger.get("actions", [])
		if not (actions is Array):
			return _halt_with_error("Trigger %s has no action array" % _current_trigger_id())
		if current_action_index >= actions.size():
			current_trigger = {}
			continue

		var action: Variant = actions[current_action_index]
		current_action_index += 1
		if not (action is Dictionary):
			return _halt_with_error("Trigger %s contains a non-object action" % _current_trigger_id())
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
			current_trigger = {}
			call_stack.clear()
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
			return _yield_result("start_encounter", {
				"encounterKind": "simple" if int(values[1]) == 2 else "complex",
				"encounterId": int(values[2]),
				"startSlot": 0,
			})
		4:
			return _yield_result("eliminate_encounter_option", {})
		_:
			return _halt_with_error("Choice references unsupported branch mode %d" % int(values[1]))


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
			return _execute_choice(record_id, bool(action.get("gosub", false)))
		20, 45:
			return _execute_teleport(record_id, code == 20)
		24:
			current_trigger = {}
			call_stack.clear()
			return _completed_result("keep-codes")
		39:
			return _branch_to_extra_action_point(record_id, bool(action.get("gosub", false)), 0)
		46:
			return _execute_quest_branch(record_id, bool(action.get("gosub", false)))
		47:
			runtime_state.set_quest_flag(record_id)
			return _continue_result()
		111:
			if call_stack.is_empty():
				current_trigger = {}
				return _completed_result("return-with-empty-stack")
			_restore_call_frame()
			return _continue_result()
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
	match int(values[2]):
		-1:
			current_trigger = {}
			return _completed_result("dropout")
		0:
			return _branch_to_extra_action_point(int(values[3]), gosub, 0)
		1, 2:
			return _yield_result("start_encounter", {
				"encounterKind": "simple" if int(values[2]) == 1 else "complex",
				"encounterId": int(values[3]),
				"startSlot": int(values[4]),
			})
		3:
			current_trigger = {}
			call_stack.clear()
			return _completed_result("keep-codes")
		_:
			return _halt_with_error("Unsupported classic branch mode %d" % int(values[2]))


func _branch_to_extra_action_point(record_id: int, gosub: bool, start_slot: int) -> Dictionary:
	var target := bundle.get_extra_action_point(record_id)
	if target.is_empty():
		return _halt_with_error("Missing Data ED3 action point %d" % record_id)
	if gosub:
		call_stack.append({
			"trigger": current_trigger,
			"actionIndex": current_action_index,
		})
	_set_cursor(target, start_slot)
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


func _restore_call_frame() -> void:
	var frame: Dictionary = call_stack.pop_back()
	current_trigger = frame["trigger"]
	current_action_index = int(frame["actionIndex"])


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
