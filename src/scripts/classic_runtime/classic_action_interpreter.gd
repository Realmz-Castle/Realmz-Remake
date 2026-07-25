class_name ClassicActionInterpreter
extends RefCounted

const MapBridgeScript = preload("res://scripts/classic_runtime/classic_map_bridge.gd")
const MAX_INTERNAL_STEPS := 256
const MAX_CALL_STACK_DEPTH := 20
const MAX_RANDOM_RECTANGLES := 20
const EXECUTION_SNAPSHOT_SCHEMA_VERSION := 1
const HANDLED_OPCODES := [
	-23, -14,
	0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
	10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
	20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
	30, 32, 33, 34, 35, 36, 37, 38, 39,
	40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
	50, 51, 52, 54, 56, 57, 58,
	60, 61, 63, 64, 65, 66, 69, 72, 73, 76, 77, 78, 82, 83, 84, 85, 86, 87, 88, 89,
	90, 93, 94, 95, 96, 97, 98,
	99, 100, 101, 103, 104, 105, 106, 111, 112,
	121, 123, 124, 125, 126, 127,
]
const PRIEST_TURNING_ENABLED_MESSAGE := \
	"You regain your ability to turn undead and nether spawn."
const PRIEST_TURNING_DISABLED_MESSAGE := \
	"You may not use your ability to turn undead or nether spawn."
const NO_SELECTIVE_BATTLE_SURVIVORS_MESSAGE := \
	"There is nobody left to collect any treasure."
const PARTY_CONDITION_NAMES := [
	"Torch Lit",
	"Waterworld",
	"Dragon Hide",
	"Discover Secret",
	"Wizard Eye",
	"Search",
	"Free Fall",
	"Sentry",
	"Charm Resistance",
	"Unused",
]

var bundle: ClassicCampaignBundle
var runtime_state: ClassicRuntimeState
var current_trigger: Dictionary = {}
var current_action_index := 0
var origin_action_point: Dictionary = {}
var active_action_point_header: Dictionary = {}
var suppress_action_point_destination := false
var remove_action_point := false
var removal_x := 0
var removal_y := 0
var call_stack: Array = []
var gosub_active := false
var pending_choice: Dictionary = {}
var pending_encounter: Dictionary = {}
var pending_battle: Dictionary = {}
var pending_selective_battle: Dictionary = {}
var pending_item_check: Dictionary = {}
var pending_wealth_payment: Dictionary = {}
var pending_party_condition_check: Dictionary = {}
var pending_misc_branch: Dictionary = {}
var pending_ally_check: Dictionary = {}
var pending_combat_monster_check: Dictionary = {}
var pending_battle_round_macro: Dictionary = {}
var pending_random_branch: Dictionary = {}
var pending_time_mutation: Dictionary = {}
var pending_exploration_status: Dictionary = {}
var pending_teleport: Dictionary = {}
var execution_context: Dictionary = {}
var encounter_origins: Array = []
var loaded_simple_encounter_id := -1
var loaded_complex_encounter_id := -1
var percent_roll_provider: Callable
var trace: Array = []
var last_error := ""
var halted := false


func configure(campaign_bundle: ClassicCampaignBundle, state: ClassicRuntimeState) -> void:
	bundle = campaign_bundle
	runtime_state = state
	loaded_simple_encounter_id = -1
	loaded_complex_encounter_id = -1
	reset_execution()


func set_percent_roll_provider(provider: Callable) -> void:
	percent_roll_provider = provider


static func normalize_opcode(raw_code: int) -> int:
	return abs(raw_code) if raw_code < 0 and raw_code not in [-14, -23] else raw_code


static func handles_opcode(code: int) -> bool:
	return HANDLED_OPCODES.has(code)


func reset_execution() -> void:
	current_trigger = {}
	current_action_index = 0
	origin_action_point.clear()
	active_action_point_header.clear()
	suppress_action_point_destination = false
	remove_action_point = false
	removal_x = 0
	removal_y = 0
	call_stack.clear()
	gosub_active = false
	pending_choice.clear()
	pending_encounter.clear()
	pending_battle.clear()
	pending_selective_battle.clear()
	pending_item_check.clear()
	pending_wealth_payment.clear()
	pending_party_condition_check.clear()
	pending_misc_branch.clear()
	pending_ally_check.clear()
	pending_combat_monster_check.clear()
	pending_battle_round_macro.clear()
	pending_random_branch.clear()
	pending_time_mutation.clear()
	pending_exploration_status.clear()
	pending_teleport.clear()
	execution_context.clear()
	encounter_origins.clear()
	trace.clear()
	last_error = ""
	halted = false


func make_execution_snapshot() -> Dictionary:
	if halted:
		return _snapshot_error("A stopped Classic action point cannot be saved")
	var snapshot := {
		"schemaVersion": EXECUTION_SNAPSHOT_SCHEMA_VERSION,
		"currentTrigger": current_trigger.duplicate(true),
		"currentActionIndex": current_action_index,
		"originActionPoint": origin_action_point.duplicate(true),
		"activeActionPointHeader": active_action_point_header.duplicate(true),
		"suppressActionPointDestination": suppress_action_point_destination,
		"removeActionPoint": remove_action_point,
		"removalX": removal_x,
		"removalY": removal_y,
		"callStack": call_stack.duplicate(true),
		"gosubActive": gosub_active,
		"pendingChoice": pending_choice.duplicate(true),
		"pendingEncounter": pending_encounter.duplicate(true),
		"pendingBattle": pending_battle.duplicate(true),
		"pendingSelectiveBattle": pending_selective_battle.duplicate(true),
		"pendingItemCheck": pending_item_check.duplicate(true),
		"pendingWealthPayment": pending_wealth_payment.duplicate(true),
		"pendingPartyConditionCheck": pending_party_condition_check.duplicate(true),
		"pendingMiscBranch": pending_misc_branch.duplicate(true),
		"pendingAllyCheck": pending_ally_check.duplicate(true),
		"pendingCombatMonsterCheck": pending_combat_monster_check.duplicate(true),
		"pendingBattleRoundMacro": pending_battle_round_macro.duplicate(true),
		"pendingRandomBranch": pending_random_branch.duplicate(true),
		"pendingTimeMutation": pending_time_mutation.duplicate(true),
		"pendingExplorationStatus": pending_exploration_status.duplicate(true),
		"pendingTeleport": pending_teleport.duplicate(true),
		"executionContext": execution_context.duplicate(true),
		"encounterOrigins": encounter_origins.duplicate(true),
		"loadedSimpleEncounterId": loaded_simple_encounter_id,
		"loadedComplexEncounterId": loaded_complex_encounter_id,
	}
	if not _is_snapshot_value(snapshot):
		return _snapshot_error(
			"Classic continuation contains runtime-only values and cannot be saved"
		)
	return {"status": "ok", "snapshot": snapshot}


func restore_execution_snapshot(snapshot: Variant) -> Dictionary:
	var validation := validate_execution_snapshot(snapshot)
	if str(validation.get("status", "")) != "ok":
		return validation
	var saved: Dictionary = snapshot
	reset_execution()
	current_trigger = saved["currentTrigger"].duplicate(true)
	current_action_index = int(saved["currentActionIndex"])
	origin_action_point = saved["originActionPoint"].duplicate(true)
	active_action_point_header = saved["activeActionPointHeader"].duplicate(true)
	suppress_action_point_destination = bool(saved.get(
		"suppressActionPointDestination",
		false
	))
	remove_action_point = bool(saved["removeActionPoint"])
	removal_x = int(saved["removalX"])
	removal_y = int(saved["removalY"])
	call_stack = saved["callStack"].duplicate(true)
	gosub_active = bool(saved["gosubActive"])
	pending_choice = saved["pendingChoice"].duplicate(true)
	pending_encounter = saved["pendingEncounter"].duplicate(true)
	pending_battle = saved["pendingBattle"].duplicate(true)
	pending_selective_battle = saved["pendingSelectiveBattle"].duplicate(true)
	pending_item_check = saved["pendingItemCheck"].duplicate(true)
	pending_wealth_payment = saved["pendingWealthPayment"].duplicate(true)
	pending_party_condition_check = saved["pendingPartyConditionCheck"].duplicate(true)
	pending_misc_branch = saved.get("pendingMiscBranch", {}).duplicate(true)
	pending_ally_check = saved["pendingAllyCheck"].duplicate(true)
	pending_combat_monster_check = saved["pendingCombatMonsterCheck"].duplicate(true)
	pending_battle_round_macro = saved["pendingBattleRoundMacro"].duplicate(true)
	pending_random_branch = saved["pendingRandomBranch"].duplicate(true)
	pending_time_mutation = saved.get("pendingTimeMutation", {}).duplicate(true)
	pending_exploration_status = saved.get("pendingExplorationStatus", {}).duplicate(true)
	pending_teleport = saved["pendingTeleport"].duplicate(true)
	execution_context = saved["executionContext"].duplicate(true)
	encounter_origins = saved["encounterOrigins"].duplicate(true)
	loaded_simple_encounter_id = int(saved["loadedSimpleEncounterId"])
	loaded_complex_encounter_id = int(saved["loadedComplexEncounterId"])
	return {"status": "ok"}


static func validate_execution_snapshot(snapshot: Variant) -> Dictionary:
	if not (snapshot is Dictionary):
		return _snapshot_error("Classic continuation execution state is not a dictionary")
	if int(snapshot.get("schemaVersion", 0)) != EXECUTION_SNAPSHOT_SCHEMA_VERSION:
		return _snapshot_error("Classic continuation execution schema is not supported")
	for field_name: String in [
		"currentTrigger",
		"originActionPoint",
		"activeActionPointHeader",
		"pendingChoice",
		"pendingEncounter",
		"pendingBattle",
		"pendingSelectiveBattle",
		"pendingItemCheck",
		"pendingWealthPayment",
		"pendingPartyConditionCheck",
		"pendingAllyCheck",
		"pendingCombatMonsterCheck",
		"pendingBattleRoundMacro",
		"pendingRandomBranch",
		"pendingTeleport",
		"executionContext",
	]:
		if not (snapshot.get(field_name) is Dictionary):
			return _snapshot_error("Classic continuation has invalid %s" % field_name)
	if snapshot.has("pendingMiscBranch") \
			and not (snapshot.get("pendingMiscBranch") is Dictionary):
		return _snapshot_error("Classic continuation has invalid pendingMiscBranch")
	if snapshot.has("pendingTimeMutation") \
			and not (snapshot.get("pendingTimeMutation") is Dictionary):
		return _snapshot_error("Classic continuation has invalid pendingTimeMutation")
	if snapshot.has("pendingExplorationStatus") \
			and not (snapshot.get("pendingExplorationStatus") is Dictionary):
		return _snapshot_error("Classic continuation has invalid pendingExplorationStatus")
	for field_name: String in ["callStack", "encounterOrigins"]:
		if not (snapshot.get(field_name) is Array):
			return _snapshot_error("Classic continuation has invalid %s" % field_name)
	if int(snapshot.get("currentActionIndex", -1)) < 0:
		return _snapshot_error("Classic continuation has an invalid action index")
	if snapshot["callStack"].size() > MAX_CALL_STACK_DEPTH:
		return _snapshot_error("Classic continuation exceeds the GOSUB stack limit")
	for field_name: String in ["removeActionPoint", "gosubActive"]:
		if not (snapshot.get(field_name) is bool):
			return _snapshot_error("Classic continuation has invalid %s" % field_name)
	if snapshot.has("suppressActionPointDestination") \
			and not (snapshot.get("suppressActionPointDestination") is bool):
		return _snapshot_error(
			"Classic continuation has invalid suppressActionPointDestination"
		)
	for field_name: String in [
		"removalX",
		"removalY",
		"loadedSimpleEncounterId",
		"loadedComplexEncounterId",
	]:
		var field_value: Variant = snapshot.get(field_name)
		if not (field_value is int or field_value is float):
			return _snapshot_error("Classic continuation has invalid %s" % field_name)
	for frame_value: Variant in snapshot["callStack"]:
		if not (frame_value is Dictionary) \
				or not (frame_value.get("trigger") is Dictionary) \
				or not (frame_value.get("actionPointHeader") is Dictionary) \
				or not (frame_value.get("actionIndex") is int or frame_value.get("actionIndex") is float):
			return _snapshot_error("Classic continuation has an invalid GOSUB frame")
	for origin_value: Variant in snapshot["encounterOrigins"]:
		if not (origin_value is Dictionary) \
				or not (origin_value.get("trigger") is Dictionary) \
				or not (origin_value.get("callStack") is Array) \
				or not (origin_value.get("actionPointHeader") is Dictionary):
			return _snapshot_error("Classic continuation has an invalid encounter frame")
	if not _is_snapshot_value(snapshot):
		return _snapshot_error("Classic continuation contains invalid runtime values")
	return {"status": "ok"}


static func _is_snapshot_value(value: Variant) -> bool:
	if value == null or value is bool or value is int or value is float or value is String:
		return true
	if value is Array:
		for child_value: Variant in value:
			if not _is_snapshot_value(child_value):
				return false
		return true
	if value is Dictionary:
		for key: Variant in value:
			if not (key is String) or not _is_snapshot_value(value[key]):
				return false
		return true
	return false


static func _snapshot_error(message: String) -> Dictionary:
	return {"status": "error", "message": message}


func begin_trigger(trigger_id: String, start_slot := 0, context := {}) -> bool:
	reset_execution()
	if bundle == null or runtime_state == null:
		last_error = "ClassicActionInterpreter must be configured before execution"
		return false
	if not (context is Dictionary):
		last_error = "Classic action execution context must be a dictionary"
		return false
	execution_context = context.duplicate(true)
	var trigger := runtime_state.get_action_point_override(trigger_id)
	if trigger.is_empty():
		trigger = bundle.get_trigger(trigger_id)
	if trigger.is_empty():
		last_error = "Unknown classic trigger: %s" % trigger_id
		return false
	trigger = runtime_state.get_effective_action_point(trigger)
	if _is_map_action_point(trigger):
		origin_action_point = trigger.duplicate(true)
	active_action_point_header = trigger.duplicate(true)
	active_action_point_header.erase("actions")
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
	if not pending_selective_battle.is_empty():
		return _error_result("A classic selective battle must be resumed before execution can continue")
	if not pending_item_check.is_empty():
		return _error_result("A classic item check must be resumed before execution can continue")
	if not pending_wealth_payment.is_empty():
		return _error_result("A classic wealth payment must be resumed before execution can continue")
	if not pending_party_condition_check.is_empty():
		return _error_result("A classic party-condition check must be resumed before execution can continue")
	if not pending_misc_branch.is_empty():
		return _error_result("A classic party identity check must be resumed before execution can continue")
	if not pending_ally_check.is_empty():
		return _error_result("A classic ally check must be resumed before execution can continue")
	if not pending_combat_monster_check.is_empty():
		return _error_result("A classic combat-monster check must be resumed before execution can continue")
	if not pending_battle_round_macro.is_empty():
		return _error_result("A classic battle-round macro must be resumed before execution can continue")
	if not pending_random_branch.is_empty():
		return _error_result("A classic random branch presentation must finish before execution can continue")
	if not pending_time_mutation.is_empty():
		return _error_result("A classic time mutation must finish before execution can continue")
	if not pending_exploration_status.is_empty():
		return _error_result(
			"A classic exploration-status action must finish before execution can continue"
		)
	if not pending_teleport.is_empty():
		return _error_result("A classic teleport must finish before execution can continue")

	for _step: int in MAX_INTERNAL_STEPS:
		if current_trigger.is_empty():
			return _completed_result("action-point-ended")

		var actions: Variant = current_trigger.get("actions", [])
		if not (actions is Array):
			return _halt_with_error("Trigger %s has no action array" % _current_trigger_id())
		if current_action_index >= actions.size():
			return _finish_action_point("action-point-ended", true)

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


func resume_encounter(outcome: int, encounter_state := {}) -> Dictionary:
	if pending_encounter.is_empty():
		return _error_result("No classic encounter is waiting for a result")
	var encounter_context := pending_encounter
	pending_encounter = {}
	if not (encounter_state is Dictionary):
		return _halt_with_error("Classic encounter state must be a dictionary")
	if outcome < 0 or outcome > 4:
		return _halt_with_error("Classic encounter outcome must be between 0 and 4")
	var state_result := _apply_encounter_state(encounter_context, encounter_state)
	if not state_result.is_empty():
		return state_result
	var door_action_point_id := int(encounter_state.get("doorActivationActionPointId", 0))
	if door_action_point_id != 0:
		if door_action_point_id < 0:
			return _halt_with_error("Classic door item returned an invalid action point")
		# Door items leave the encounter and enter their Data ED3 record as a
		# fresh action point, just as Classic's newland() handoff does.
		_clear_control_flow()
		var door_result := _branch_to_extra_action_point(door_action_point_id, false, 0)
		if str(door_result.get("status", "")) != "continue":
			return door_result
		return run_until_yield()
	if outcome == 0:
		_clear_control_flow()
		return _completed_result("encounter-cancelled")
	# Classic sends Result 4 through Result 3 on a complex encounter's final try.
	if not encounter_origins.is_empty():
		var encounter_loop: Dictionary = encounter_origins[-1]
		if (
			str(encounter_context.get("encounterKind", "")) == "complex"
			and outcome == 4
			and int(encounter_loop.get("remainingAttempts", 1)) == 1
			and int(encounter_loop.get("maxAttempts", 1)) > 1
		):
			outcome = 3

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
			"levelType": runtime_state.level_type,
			"backUpParty": runtime_state.level_type == "land",
		})
	var branch_result := _branch_to_extra_action_point(
		coward_macro_id,
		bool(battle_context.get("gosub", false)),
		0
	)
	if str(branch_result.get("status", "")) != "continue":
		return branch_result
	return run_until_yield()


func resume_selective_battle(survivor_count: int) -> Dictionary:
	if pending_selective_battle.is_empty():
		return _error_result("No classic selective battle is waiting for an outcome")
	if survivor_count < 0:
		return _error_result("Classic selective battle returned an invalid survivor count")
	var battle_context := pending_selective_battle
	pending_selective_battle = {}
	if survivor_count == 0:
		return _yield_result("show_text", {
			"messageId": 0,
			"message": {
				"id": 0,
				"text": NO_SELECTIVE_BATTLE_SURVIVORS_MESSAGE,
			},
		})
	var treasure_id := int(battle_context.get("treasureId", 0))
	if treasure_id != 0:
		return _execute_treasure(treasure_id)
	return run_until_yield()


func resume_forced_battle_end() -> Dictionary:
	_clear_control_flow()
	return _completed_result("battle-ended")


func resume_forced_battle_at_slot(resume_slot: int) -> Dictionary:
	if resume_slot != 8:
		return _error_result("Classic forced battle resume slot must be 8")
	pending_battle.clear()
	pending_selective_battle.clear()
	_set_cursor(current_trigger, resume_slot)
	return run_until_yield()


func resume_teleport() -> Dictionary:
	if pending_teleport.is_empty():
		return _error_result("No classic teleport is waiting to finish")
	var teleport := pending_teleport
	pending_teleport = {}
	if not bool(teleport.get("recheckDestination", false)):
		return run_until_yield()

	var destination_triggers := runtime_state.get_effective_triggers_at(
		bundle,
		runtime_state.level_type,
		runtime_state.level_index,
		runtime_state.x,
		runtime_state.y
	)
	if destination_triggers.is_empty():
		if teleport.has("completionReason"):
			var completion_reason := str(teleport["completionReason"])
			_clear_control_flow()
			return _completed_result(completion_reason)
		return run_until_yield()
	var destination: Variant = destination_triggers[0]
	if not (destination is Dictionary):
		return _halt_with_error("Classic teleport destination has an invalid action point")
	var percent := int(destination.get("percent", 0))
	if percent < 1 or _roll_percent() > percent:
		_clear_control_flow()
		return _completed_result("teleport-destination-percent-miss")

	# newland() replaces the current door without pushing it. Existing GOSUB
	# frames remain available if the destination explicitly returns to them.
	origin_action_point = destination.duplicate(true)
	active_action_point_header = destination.duplicate(true)
	active_action_point_header.erase("actions")
	suppress_action_point_destination = true
	_set_cursor(destination, 0)
	return run_until_yield()


func resume_item_check(possessed: bool) -> Dictionary:
	if pending_item_check.is_empty():
		return _error_result("No classic item check is waiting for a response")
	var item_check := pending_item_check
	pending_item_check = {}
	var values: Array = item_check["values"]
	match str(item_check.get("kind", "")):
		"possession_branch":
			if possessed:
				var possessed_result := _branch_item_possession_target(
					values,
					int(values[3]),
					bool(item_check.get("gosub", false))
				)
				if str(possessed_result.get("status", "")) != "continue":
					return possessed_result
				return run_until_yield()
			match int(values[2]):
				0:
					var missing_result := _branch_item_possession_target(
						values,
						int(values[4]),
						bool(item_check.get("gosub", false))
					)
					if str(missing_result.get("status", "")) != "continue":
						return missing_result
					return run_until_yield()
				1:
					return run_until_yield()
				2:
					_clear_control_flow()
					return _yield_result("show_text", {
						"messageId": int(values[4]),
						"message": bundle.get_message(int(values[4])),
					})
				_:
					return _halt_with_error(
						"Item possession branch has invalid failure mode %d" % int(values[2])
					)
		"result_branch":
			var test_mode := int(values[1])
			if not [0, 1].has(test_mode):
				return _halt_with_error(
					"Item result branch has invalid test mode %d" % test_mode
				)
			var should_branch := (test_mode == 0 and not possessed) \
				or (test_mode == 1 and possessed)
			if not should_branch:
				return run_until_yield()
			var branch_result := _branch_from_extra_code(values, false)
			if str(branch_result.get("status", "")) != "continue":
				return branch_result
			return run_until_yield()
		_:
			return _halt_with_error("Classic item check has an invalid continuation")


func resume_wealth_payment(paid: bool) -> Dictionary:
	if pending_wealth_payment.is_empty():
		return _error_result("No classic wealth payment is waiting for a response")
	var payment := pending_wealth_payment
	pending_wealth_payment = {}
	var values: Array = payment["values"]
	if not paid and int(values[1]) == -1:
		_set_cursor(current_trigger, 7)
		return run_until_yield()
	var test_mode := int(values[1])
	var should_branch := test_mode == 2 \
		or (test_mode == 0 and not paid) \
		or (test_mode == 1 and paid)
	if not should_branch:
		return run_until_yield()
	var branch_result := _branch_from_extra_code(values, false)
	if str(branch_result.get("status", "")) != "continue":
		return branch_result
	return run_until_yield()


func resume_party_condition_check(active: bool) -> Dictionary:
	if pending_party_condition_check.is_empty():
		return _error_result("No classic party-condition check is waiting for a response")
	var condition_check := pending_party_condition_check
	pending_party_condition_check = {}
	var values: Array = condition_check["values"]
	var required_state := int(values[0])
	var should_branch := (required_state == 1 and active) or (required_state == 2 and not active)
	if not should_branch:
		return run_until_yield()
	var branch_mode := int(values[1])
	if branch_mode < 1 or branch_mode > 3:
		_set_cursor(current_trigger, 8)
		return run_until_yield()
	var branch_result := _branch_to_action_or_encounter(
		branch_mode - 1,
		int(values[2]),
		bool(condition_check.get("gosub", false))
	)
	if str(branch_result.get("status", "")) != "continue":
		return branch_result
	return run_until_yield()


func resume_misc_branch(matched: bool) -> Dictionary:
	if pending_misc_branch.is_empty():
		return _error_result("No classic party identity check is waiting for a response")
	var branch := pending_misc_branch
	pending_misc_branch = {}
	var values: Array = branch["values"]
	var target_id := int(values[3]) if matched else int(values[4])
	if target_id == 0:
		return run_until_yield()
	var branch_result := _branch_to_action_or_encounter(
		int(values[2]),
		target_id,
		bool(branch.get("gosub", false))
	)
	if str(branch_result.get("status", "")) != "continue":
		return branch_result
	return run_until_yield()


func resume_ally_check(present: bool) -> Dictionary:
	if pending_ally_check.is_empty():
		return _error_result("No classic ally check is waiting for a response")
	var ally_check := pending_ally_check
	pending_ally_check = {}
	var values: Array = ally_check["values"]
	if present:
		return _resume_ally_branch(values, int(values[3]), ally_check)
	match int(values[2]):
		0:
			return _resume_ally_branch(values, int(values[4]), ally_check)
		1:
			return run_until_yield()
		2:
			_clear_control_flow()
			return _yield_result("show_text", {
				"messageId": int(values[4]),
				"message": bundle.get_message(int(values[4])),
			})
		_:
			return _halt_with_error(
				"Ally branch has invalid absent mode %d" % int(values[2])
			)


func resume_combat_monster_check(present: bool) -> Dictionary:
	if pending_combat_monster_check.is_empty():
		return _error_result("No classic combat-monster check is waiting for a response")
	pending_combat_monster_check.clear()
	if present:
		return run_until_yield()
	_clear_control_flow()
	return _completed_result("required-combat-monster-absent")


func resume_battle_round_macro() -> Dictionary:
	if pending_battle_round_macro.is_empty():
		return _error_result("No classic battle-round macro is waiting for activation")
	var target_macro_id := int(pending_battle_round_macro["targetMacroId"])
	pending_battle_round_macro.clear()
	var branch_result := _branch_to_extra_action_point(target_macro_id, false, 0)
	if str(branch_result.get("status", "")) != "continue":
		return branch_result
	return run_until_yield()


func resume_random_branch() -> Dictionary:
	if pending_random_branch.is_empty():
		return _error_result("No classic random branch is waiting for presentation")
	var random_branch := pending_random_branch
	pending_random_branch = {}
	return _apply_random_branch(random_branch)


func resume_back_up_party() -> Dictionary:
	# Classic returns from newland immediately after reversing a land move, so
	# neither later slots nor the action point's ordinary destination can run.
	_clear_control_flow()
	return _completed_result("back-up-party")


func resume_time_mutation(response: Dictionary) -> Dictionary:
	if pending_time_mutation.is_empty():
		return _error_result("No classic time mutation is waiting for a response")
	for field_name: String in ["scenarioDay", "scenarioHour", "scenarioMinute"]:
		if not response.has(field_name):
			return _error_result("Classic time mutation response is missing %s" % field_name)
		execution_context[field_name] = int(response[field_name])
	pending_time_mutation.clear()
	return run_until_yield()


func resume_exploration_status(response: Dictionary) -> Dictionary:
	if pending_exploration_status.is_empty():
		return _error_result("No classic exploration-status action is waiting for a response")
	if not response.has("skipRemaining"):
		return _error_result(
			"Classic exploration-status response is missing skipRemaining"
		)
	pending_exploration_status.clear()
	if bool(response["skipRemaining"]):
		var actions: Variant = current_trigger.get("actions", [])
		if actions is Array:
			current_action_index = actions.size()
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
		6:
			return _execute_load_shop(record_id)
		7:
			return _execute_action_data_patch(record_id)
		8:
			return _execute_same_as_other_action_point(record_id)
		9:
			return _yield_result("play_sound", {
				"soundId": record_id,
				"sound": bundle.get_sound(record_id),
			})
		10:
			return _execute_treasure(record_id)
		11:
			return _yield_result("give_experience", {"experience": record_id})
		12:
			return _execute_tile_mutation(record_id)
		13:
			return _execute_trigger_mutation(record_id)
		-14, 14:
			return _execute_character_pick(record_id, code == -14)
		15:
			return _execute_selected_health_effect(record_id)
		16:
			return _execute_party_health_effect(record_id)
		17, 18:
			return _execute_spell_effect(record_id, code == 18)
		19:
			return _execute_random_text(record_id)
		20, 45:
			return _execute_teleport(record_id, code == 20)
		21:
			return _execute_item_possession_branch(record_id, gosub_active)
		22:
			return _execute_item_mutation(record_id)
		-23, 23:
			return _execute_random_rectangle_mutation(record_id, code == -23)
		24:
			return _finish_action_point("keep-codes", false)
		25:
			return _remove_current_action_point()
		26:
			return _yield_result("wait_for_click", {
				"prompt": "Click Mouse",
				"soundId": 30005,
			})
		27:
			return _yield_result("show_picture", {
				"pictureId": abs(record_id),
				"picture": bundle.get_picture(record_id),
			})
		28:
			return _yield_result("redraw_map", {})
		29:
			return _execute_player_map(record_id)
		30:
			return _execute_character_check_selection(record_id)
		32:
			return _yield_result("offer_temple", {
				"costPercent": record_id,
				"soundId": 10105,
			})
		33:
			return _execute_take_gold(record_id)
		34:
			return _break_encounter()
		35:
			return _eliminate_current_simple_option(record_id)
		36:
			return _yield_result("store_party_equipment", {
				"capture": record_id != 0,
				"storageId": record_id,
			})
		37:
			return _execute_dungeon_move(record_id)
		38:
			return _execute_item_result_branch(record_id)
		39:
			# Classic's Extend Door Codes replaces the active AP without pushing,
			# even when its raw opcode is negative.
			return _branch_to_extra_action_point(record_id, false, 0)
		40:
			return _execute_party_condition_branch(record_id, gosub_active)
		41:
			return _eliminate_simple_option_from_extra_code(record_id)
		42:
			return _execute_percent_branch(record_id)
		43:
			return _execute_give_condition(record_id)
		44:
			return _eliminate_complex_result(record_id)
		56:
			return _execute_battle_outcome(record_id, gosub_active)
		46:
			return _execute_quest_branch(record_id, gosub_active)
		47:
			runtime_state.set_quest_flag(record_id)
			return _continue_result()
		48:
			return _execute_selective_battle(record_id)
		49:
			return _yield_result("enable_banking", {
				"soundId": 128,
				"warningId": 106,
			})
		50:
			return _execute_identity_character_selection(record_id)
		51:
			return _execute_shop_mutation(record_id)
		52:
			return _execute_misc_character_selection(record_id)
		54:
			return _execute_timed_encounter_mutation(record_id)
		57:
			return _execute_landlook(record_id)
		58:
			return _execute_difficulty_branch(record_id)
		60:
			return _execute_currency_clear(record_id)
		61:
			return _execute_position_shift(record_id)
		63:
			return _execute_time_mutation(record_id)
		64:
			return _execute_time_branch(record_id, gosub_active)
		65:
			return _execute_random_items(record_id)
		66:
			return _yield_result("set_camping_permission", {
				"disabled": record_id != 0,
				"soundId": 6001,
			})
		69:
			return _execute_spellcasting_flags(record_id)
		72:
			return _execute_quest_range_branch(record_id, gosub_active)
		73:
			return _execute_restricted_shop(record_id)
		76:
			return _execute_quest_value_mutation(record_id, gosub_active)
		77:
			return _execute_quest_value_branch(record_id, gosub_active)
		78:
			return _execute_tile_parameter_branch(record_id, gosub_active)
		82, 83:
			return _execute_priest_turning(code == 83)
		85:
			return _execute_random_branch(record_id, gosub_active)
		86:
			return _execute_misc_branch(record_id, gosub_active)
		87:
			return _execute_ally_branch(record_id, gosub_active)
		88:
			return _execute_remove_ally(record_id)
		89:
			return _execute_add_ally(record_id)
		90:
			return _execute_experience_loss(record_id)
		93, 94:
			return _execute_compass(code == 93)
		95:
			return _execute_look_direction(record_id)
		96, 97:
			return _execute_map_view_mode(code == 97)
		84, 98, 99:
			# The open-source Classic dispatcher disables every registration gate.
			return _continue_result()
		100:
			return _yield_result("end_classic_battle", {
				"outcome": "won",
				"lootMode": 5,
				"rewardMode": "experience_only",
				"resumeSlot": 8,
			})
		101:
			if runtime_state.level_type == "dungeon":
				return _continue_result()
			return _yield_result("back_up_party", {
				"levelType": runtime_state.level_type,
			})
		103:
			return _execute_exploration_status(record_id)
		104:
			runtime_state.random_encounters_enabled = record_id != 0
			return _continue_result()
		105:
			runtime_state.allies_suspended = record_id != 0
			return _continue_result()
		106:
			return _execute_darkland(record_id)
		111:
			if call_stack.is_empty():
				if remove_action_point:
					return _continue_result()
				_clear_control_flow()
				return _completed_result("return-with-empty-stack")
			_restore_call_frame()
			return _continue_result()
		112:
			if not call_stack.is_empty():
				call_stack.pop_back()
			return _continue_result()
		121:
			return _execute_deanimate_lower_undead(record_id)
		123:
			return _execute_combat_rout(record_id)
		124:
			return _execute_spawn_combat_monsters(record_id)
		125:
			return _execute_destroy_combat_monsters(record_id)
		126:
			return _execute_battle_round_macro(record_id)
		127:
			return _execute_combat_monster_check(record_id)
		_:
			if bundle.is_dispatcher_noop(current_trigger, action):
				return _continue_result()
			halted = true
			last_error = "Unsupported Classic opcode %d at %s record %d slot %d" % [
				code,
				str(current_trigger.get("source", "unknown source")),
				int(current_trigger.get("recordIndex", -1)),
				int(action.get("slot", -1)),
			]
			return {
				"status": "unsupported",
				"message": last_error,
				"opcode": code,
				"action": action,
				"triggerId": _current_trigger_id(),
			}


func _execute_combat_monster_check(monster_name_id: int) -> Dictionary:
	pending_combat_monster_check = {"monsterNameId": abs(monster_name_id)}
	return _yield_result("check_combat_monster", {
		"monsterNameId": abs(monster_name_id),
	})


func _execute_take_gold(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Take Gold action references missing Extra Code row %d" % extra_code_id
		)
	var authored_amount := int(values[0])
	pending_wealth_payment = {
		"extraCodeId": extra_code_id,
		"values": values,
	}
	return _yield_result("take_party_wealth", {
		"extraCodeId": extra_code_id,
		"currency": 0 if authored_amount > 0 else 1,
		"amount": abs(authored_amount),
		"warningId": 50,
	})


func _execute_give_condition(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Give Condition action references missing Extra Code row %d" % extra_code_id
		)
	var target_mode := int(values[0])
	if target_mode < 0 or target_mode > 2:
		return _halt_with_error(
			"Give Condition action has invalid target mode %d" % target_mode
		)
	var condition_index := int(values[1])
	if condition_index < 0 or condition_index >= 40:
		return _halt_with_error(
			"Give Condition action has invalid condition index %d" % condition_index
		)
	return _yield_result("give_character_condition", {
		"extraCodeId": extra_code_id,
		"targetMode": ["party", "selected", "living"][target_mode],
		"conditionIndex": condition_index,
		"duration": int(values[2]),
		"soundId": int(values[3]),
	})


func _execute_destroy_combat_monsters(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Destroy-combat-monsters action references missing Extra Code row %d" \
				% extra_code_id
		)
	var monster_name_id := int(values[0])
	var max_matches := int(values[1])
	if max_matches == 0:
		max_matches = 100
	return _yield_result("destroy_combat_monsters", {
		"extraCodeId": extra_code_id,
		"monsterNameId": monster_name_id,
		"maxMatches": max_matches,
		"includeAllFactions": int(values[4]) != 0,
	})


func _execute_deanimate_lower_undead(extra_code_id: int) -> Dictionary:
	var monster_ids: Array = []
	for monster_value: Variant in bundle.monsters_by_id.values():
		if not (monster_value is Dictionary):
			continue
		var type_flags: Variant = monster_value.get("typeFlags", [])
		if not (type_flags is Array) or type_flags.size() <= 5:
			continue
		if int(type_flags[1]) == 0 or int(type_flags[5]) != 0:
			continue
		monster_ids.append(int(monster_value.get("id", -1)))
	monster_ids.sort()
	return _yield_result("deanimate_lower_undead", {
		"extraCodeId": extra_code_id,
		"monsterIds": monster_ids,
	})


func _execute_combat_rout(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Combat-rout action references missing Extra Code row %d" % extra_code_id
		)
	var monster_ids: Array = []
	var monsters: Array = []
	for value: Variant in values:
		var monster_id := int(value)
		if monster_id == 0 or monster_ids.has(monster_id):
			continue
		monster_ids.append(monster_id)
		monsters.append(bundle.get_monster(monster_id))
	var payload := {
		"extraCodeId": extra_code_id,
		"monsterIds": monster_ids,
		"monsters": monsters,
		"sameFactionAsActor": true,
		"permanent": true,
		"surrenderPercent": 50,
	}
	if execution_context.has("actorFaction"):
		payload["actorFaction"] = execution_context["actorFaction"]
	return _yield_result("rout_combat_monsters", payload)


func _execute_spawn_combat_monsters(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Combat spawn action references missing Extra Code row %d" % extra_code_id
		)
	var authored_count := int(values[2])
	var spawn_count := randi_range(1, abs(authored_count)) \
		if authored_count < 0 else authored_count
	if spawn_count <= 0:
		return _continue_result()
	var monster_id := int(values[1])
	var monster := bundle.get_monster(monster_id)
	if monster.is_empty():
		return _halt_with_error("Missing combat spawn monster %d" % monster_id)
	var faction_override := int(values[4])
	var queued_macro := bool(execution_context.get("queuedMacro", false))
	var battle_macro := int(execution_context.get("battleMacro", 0))
	var payload := {
		"extraCodeId": extra_code_id,
		"monsterId": monster_id,
		"monster": monster,
		"authoredCount": authored_count,
		"spawnCount": spawn_count,
		"soundId": int(values[3]),
		"factionOverride": faction_override,
		"inheritActorFaction": faction_override == 0 and (queued_macro or battle_macro == 0),
	}
	for context_key: String in ["actorPosition", "actorFaction"]:
		if execution_context.has(context_key):
			payload[context_key] = execution_context[context_key]
	return _yield_result("spawn_combat_monsters", payload)


func _execute_battle_round_macro(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Battle-round macro action references missing Extra Code row %d" % extra_code_id
		)
	if int(execution_context.get("battleMacro", -1)) > 0:
		_clear_control_flow()
		return _completed_result("legacy-battle-macro-disabled")
	if not execution_context.has("combatRound"):
		return _halt_with_error("Battle-round macro requires the current combat round")
	var combat_round := int(execution_context["combatRound"])
	if combat_round < 1:
		return _halt_with_error("Battle-round macro requires a one-based combat round")
	# Classic tests the number of completed rounds, not its one-based combat round.
	var round_index := combat_round - 1
	var trigger_mode := int(values[0])
	var trigger_value := int(values[1])
	var chance_roll := -1
	var activates := true
	if trigger_mode == 1:
		chance_roll = _roll_percent()
		activates = chance_roll <= trigger_value
	elif trigger_mode == 0:
		activates = round_index == trigger_value
	if not activates:
		_clear_control_flow()
		return _completed_result("battle-round-macro-skipped")

	var target_mode := int(values[2])
	var first_target := int(values[3])
	var last_target := int(values[4]) if target_mode == 2 else first_target
	if last_target < first_target:
		return _halt_with_error(
			"Battle-round macro target range %d-%d is reversed" % [first_target, last_target]
		)
	var target_macro_id := randi_range(first_target, last_target)
	if bundle.get_extra_action_point(target_macro_id).is_empty():
		return _halt_with_error("Missing battle-round target macro %d" % target_macro_id)
	pending_battle_round_macro = {"targetMacroId": target_macro_id}
	return _yield_result("activate_battle_round_macro", {
		"extraCodeId": extra_code_id,
		"combatRound": combat_round,
		"roundIndex": round_index,
		"triggerMode": trigger_mode,
		"triggerValue": trigger_value,
		"chanceRoll": chance_roll,
		"repeat": target_mode == 1,
		"randomTarget": target_mode == 2,
		"targetRange": [first_target, last_target],
		"targetMacroId": target_macro_id,
		"disableSchedule": target_mode != 1,
	})


func _execute_load_shop(signed_shop_id: int, accept_ranges: Array = []) -> Dictionary:
	var shop_id: int = abs(signed_shop_id)
	var shop: Dictionary = bundle.get_shop(shop_id)
	if shop.is_empty():
		return _halt_with_error("Shop action references missing shop %d" % shop_id)
	shop = runtime_state.get_effective_shop(shop)
	var item_texts: Array = []
	if accept_ranges.is_empty():
		var seen_item_ids: Dictionary = {}
		for item_id_value: Variant in shop.get("itemIds", []):
			var item_id: int = abs(int(item_id_value))
			if item_id == 0 or seen_item_ids.has(item_id):
				continue
			seen_item_ids[item_id] = true
			var item_text: Dictionary = bundle.get_item_text(item_id)
			if not item_text.is_empty():
				item_texts.append(item_text)
	else:
		item_texts.assign(bundle.item_texts_by_id.values())
	var shop_accept_ranges := [0, 0, 0, 0] if accept_ranges.is_empty() \
		else accept_ranges.duplicate()
	return _yield_result("load_shop", {
		"shopId": shop_id,
		"shop": shop,
		"itemTexts": item_texts,
		"openImmediately": signed_shop_id < 0,
		"acceptRanges": shop_accept_ranges,
	})


func _execute_shop_mutation(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Shop mutation references missing Extra Code row %d" % extra_code_id
		)
	var shop_id := int(values[0])
	var shop := bundle.get_shop(shop_id)
	if shop.is_empty():
		return _halt_with_error("Shop mutation references missing shop %d" % shop_id)
	var inflation_delta := int(values[1])
	var item_id := int(values[2])
	var quantity_delta := int(values[3])
	var effective := runtime_state.alter_shop(
		shop,
		inflation_delta,
		item_id,
		quantity_delta
	)
	return _yield_result("alter_shop", {
		"extraCodeId": extra_code_id,
		"shopId": shop_id,
		"shop": effective,
		"inflationDelta": inflation_delta,
		"itemId": item_id,
		"quantityDelta": quantity_delta,
	})


func _execute_restricted_shop(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Restricted shop action references missing Extra Code row %d" % extra_code_id
		)
	return _execute_load_shop(int(values[0]), [
		int(values[1]),
		int(values[2]),
		int(values[3]),
		int(values[4]),
	])


func _execute_item_possession_branch(extra_code_id: int, gosub: bool) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Item possession branch references missing Extra Code row %d" % extra_code_id
		)
	pending_item_check = {
		"kind": "possession_branch",
		"values": values,
		"gosub": gosub,
	}
	return _yield_result("check_party_item", {
		"extraCodeId": extra_code_id,
		"itemId": abs(int(values[0])),
		"itemTexts": _item_texts_for_ids([values[0]]),
	})


func _execute_item_mutation(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Item mutation references missing Extra Code row %d" % extra_code_id
		)
	return _yield_result("alter_party_items", {
		"extraCodeId": extra_code_id,
		"itemId": abs(int(values[0])),
		"maxMatches": int(values[1]),
		"operation": int(values[2]),
		"chargeDelta": int(values[3]),
		"replacementItemId": abs(int(values[4])),
		"itemTexts": _item_texts_for_ids([values[0], values[4]]),
	})


func _execute_item_result_branch(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Item result branch references missing Extra Code row %d" % extra_code_id
		)
	var test_mode := int(values[1])
	if not [0, 1, 2].has(test_mode):
		return _halt_with_error(
			"Item result branch has invalid test mode %d" % test_mode
		)
	if test_mode == 2:
		return _branch_from_extra_code(values, false)
	pending_item_check = {
		"kind": "result_branch",
		"values": values,
	}
	return _yield_result("check_party_item", {
		"extraCodeId": extra_code_id,
		"itemId": abs(int(values[0])),
		"itemTexts": _item_texts_for_ids([values[0]]),
	})


func _branch_item_possession_target(values: Array, target: int, gosub: bool) -> Dictionary:
	match int(values[1]):
		0:
			return _branch_to_extra_action_point(target, gosub, 0)
		1, 2:
			if gosub:
				var push_result := _push_call_frame()
				if str(push_result.get("status", "")) != "continue":
					return push_result
			return _execute_encounter("simple" if int(values[1]) == 1 else "complex", target)
		_:
			return _halt_with_error(
				"Item possession branch has invalid target mode %d" % int(values[1])
			)


func _item_texts_for_ids(item_ids: Array) -> Array:
	var item_texts: Array = []
	var included_ids: Dictionary = {}
	for item_id_value: Variant in item_ids:
		var item_id: int = abs(int(item_id_value))
		if item_id == 0 or included_ids.has(item_id):
			continue
		included_ids[item_id] = true
		var item_text := bundle.get_item_text(item_id)
		if not item_text.is_empty():
			item_texts.append(item_text)
	return item_texts


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
		"priestTurningEnabled": runtime_state.priest_turning_enabled,
	})


func _execute_selective_battle(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Selective battle action references missing Extra Code row %d" % extra_code_id
		)
	var first_battle_id := int(values[0])
	var last_battle_id := int(values[1]) if int(values[1]) != 0 else first_battle_id
	pending_selective_battle = {
		"extraCodeId": extra_code_id,
		"treasureId": int(values[4]),
	}
	return _yield_result("start_battle", {
		"extraCodeId": extra_code_id,
		"battleIdRange": [abs(first_battle_id), abs(last_battle_id)],
		"surprise": first_battle_id < 0,
		"soundId": int(values[2]),
		"messageId": int(values[3]),
		"message": bundle.get_message(int(values[3])),
		"lootMode": 0,
		"treasureId": int(values[4]),
		"battle": bundle.get_battle(first_battle_id),
		"priestTurningEnabled": runtime_state.priest_turning_enabled,
		"participantMode": "selected",
	})


func _execute_encounter(encounter_kind: String, encounter_id: int, start_slot := 0) -> Dictionary:
	var encounter := bundle.get_encounter(encounter_kind, encounter_id)
	if encounter.is_empty():
		return _halt_with_error(
			"Missing %s encounter record %d" % [encounter_kind, encounter_id]
		)
	if encounter_kind == "simple":
		loaded_simple_encounter_id = encounter_id
		encounter = runtime_state.get_effective_simple_encounter(encounter)
	elif encounter_kind == "complex":
		loaded_complex_encounter_id = encounter_id
		encounter = runtime_state.get_effective_complex_encounter(encounter)
	var max_attempts := maxi(1, int(encounter.get("maxTimes", 1)))
	encounter_origins.append({
		"trigger": current_trigger,
		"actionIndex": current_action_index,
		"callStack": call_stack.duplicate(true),
		"actionPointHeader": active_action_point_header.duplicate(true),
		"encounterKind": encounter_kind,
		"encounterId": encounter_id,
		"maxAttempts": max_attempts,
		"remainingAttempts": max_attempts,
	})
	return _yield_encounter(encounter_kind, encounter_id, start_slot)


func _yield_encounter(encounter_kind: String, encounter_id: int, start_slot: int) -> Dictionary:
	var encounter := bundle.get_encounter(encounter_kind, encounter_id)
	if encounter_kind == "simple":
		encounter = runtime_state.get_effective_simple_encounter(encounter)
	elif encounter_kind == "complex":
		encounter = runtime_state.get_effective_complex_encounter(encounter)
	var prompt_id := int(encounter.get("prompt", 0))
	var prompt_message := bundle.get_message(prompt_id)
	var encounter_payload := {
		"encounterKind": encounter_kind,
		"encounterId": encounter_id,
		"encounter": encounter,
		"promptMessage": prompt_message,
		"startSlot": start_slot,
	}
	if not encounter_origins.is_empty():
		encounter_payload["maxAttempts"] = int(encounter_origins[-1].get("maxAttempts", 1))
		encounter_payload["remainingAttempts"] = int(
			encounter_origins[-1].get("remainingAttempts", 1)
		)
	if encounter_kind == "complex":
		encounter_payload["itemTexts"] = _encounter_item_texts(encounter)
		encounter_payload["scenarioItems"] = _scenario_items()
	if encounter_kind == "complex" and bool(encounter.get("thief", false)):
		var thief_encounter_id := int(encounter.get("thiefSuccess", 0))
		var thief_encounter := bundle.get_thief_encounter(thief_encounter_id)
		if thief_encounter.is_empty():
			return _halt_with_error(
				"Missing Data TD2 rogue encounter %d" % thief_encounter_id
			)
		var effective_thief_encounter := \
			runtime_state.get_effective_thief_encounter(thief_encounter)
		encounter_payload["thiefEncounter"] = effective_thief_encounter
		encounter_payload["thiefMessages"] = _thief_messages(effective_thief_encounter)
	pending_encounter = encounter_payload.duplicate(true)
	return _yield_result("start_encounter", encounter_payload)


func _encounter_item_texts(encounter: Dictionary) -> Array:
	var item_texts: Array = []
	var item_ids: Variant = encounter.get("itemIds", [])
	if not (item_ids is Array):
		return item_texts
	for item_id_value: Variant in item_ids:
		var item_id: int = abs(int(item_id_value))
		if item_id == 0:
			continue
		var item_text := bundle.get_item_text(item_id)
		if not item_text.is_empty():
			item_texts.append(item_text)
	return item_texts


func _scenario_items() -> Array:
	var scenario_items: Array = []
	var item_ids: Array = bundle.scenario_items_by_id.keys()
	item_ids.sort()
	for item_id_value: Variant in item_ids:
		scenario_items.append(bundle.scenario_items_by_id[item_id_value])
	return scenario_items


func _apply_encounter_state(encounter_context: Dictionary, encounter_state: Dictionary) -> Dictionary:
	if str(encounter_context.get("encounterKind", "")) != "complex":
		return {}
	var thief_value: Variant = encounter_state.get("thiefEncounter", {})
	if not (thief_value is Dictionary) or thief_value.is_empty():
		return {}
	var encounter: Dictionary = encounter_context["encounter"]
	var expected_id := int(encounter.get("thiefSuccess", 0))
	if int(thief_value.get("id", -1)) != expected_id:
		return _halt_with_error("Classic encounter returned the wrong Data TD2 record")
	runtime_state.set_thief_encounter_override(expected_id, thief_value)
	return {}


func _thief_messages(thief_encounter: Dictionary) -> Array:
	var messages: Array = []
	var included_ids: Dictionary = {}
	for field_name: String in ["successText", "failureText"]:
		var ids: Variant = thief_encounter.get(field_name, [])
		if not (ids is Array):
			continue
		for id_value: Variant in ids:
			var message_id: int = abs(int(id_value))
			if message_id == 0 or included_ids.has(message_id):
				continue
			included_ids[message_id] = true
			messages.append(bundle.get_message(message_id))
	var prompts: Variant = thief_encounter.get("prompts", [])
	if prompts is Array and not prompts.is_empty():
		var prompt_id: int = abs(int(prompts[0]))
		if prompt_id != 0 and not included_ids.has(prompt_id):
			messages.append(bundle.get_message(prompt_id))
	return messages


func _eliminate_current_simple_option(option_index: int) -> Dictionary:
	if encounter_origins.is_empty():
		return _halt_with_error("Simple option mutation has no active encounter")
	var encounter_loop: Dictionary = encounter_origins[-1]
	if str(encounter_loop.get("encounterKind", "")) != "simple":
		return _halt_with_error("Simple option mutation is outside a simple encounter")
	var encounter_id := int(encounter_loop.get("encounterId", -1))
	var mutation_result := _eliminate_simple_encounter_option(encounter_id, option_index)
	if not mutation_result.is_empty():
		return mutation_result
	# Opcode 35 reopens the current encounter immediately without using an attempt.
	return _yield_encounter("simple", encounter_id, 0)


func _eliminate_simple_option_from_extra_code(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.size() < 2:
		return _halt_with_error(
			"Simple option mutation references missing Extra Code row %d" % extra_code_id
		)
	var mutation_result := _eliminate_simple_encounter_option(
		int(values[0]),
		int(values[1])
	)
	return _continue_result() if mutation_result.is_empty() else mutation_result


func _eliminate_simple_encounter_option(encounter_id: int, option_index: int) -> Dictionary:
	if option_index < 1 or option_index > 4:
		return _halt_with_error("Simple encounter option index must be between 1 and 4")
	var encounter := bundle.get_encounter("simple", encounter_id)
	if encounter.is_empty():
		return _halt_with_error("Missing simple encounter record %d" % encounter_id)
	encounter = runtime_state.get_effective_simple_encounter(encounter)
	var choice_results: Variant = encounter.get("choiceResults", [])
	if not (choice_results is Array) or choice_results.size() < option_index:
		return _halt_with_error("Simple encounter %d has no option %d" % [
			encounter_id,
			option_index,
		])
	var updated_results: Array = choice_results.duplicate()
	updated_results[option_index - 1] = 0
	encounter["choiceResults"] = updated_results
	runtime_state.set_simple_encounter_override(encounter_id, encounter)
	return {}


func _eliminate_complex_result(result_index: int) -> Dictionary:
	if encounter_origins.is_empty():
		return _halt_with_error("Complex result mutation has no active encounter")
	var encounter_loop: Dictionary = encounter_origins[-1]
	if str(encounter_loop.get("encounterKind", "")) != "complex":
		return _halt_with_error("Complex result mutation is outside a complex encounter")
	if result_index < 1 or result_index > 4:
		return _halt_with_error("Complex result mutation index must be between 1 and 4")
	var encounter_id := int(encounter_loop.get("encounterId", -1))
	var encounter := runtime_state.get_effective_complex_encounter(
		bundle.get_encounter("complex", encounter_id)
	)
	var source_actions: Variant = encounter.get("actions", [])
	if not (source_actions is Array):
		return _halt_with_error("Complex encounter has no action array to mutate")
	var first_slot := (result_index - 1) * 8
	var actions: Array = []
	for action_value: Variant in source_actions:
		if not (action_value is Dictionary):
			continue
		var slot := int(action_value.get("slot", -1))
		if slot < first_slot or slot >= first_slot + 8:
			actions.append(action_value.duplicate(true))
	actions.append({"id": 0, "rawCode": 24, "slot": first_slot + 7})
	actions.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("slot", -1)) < int(b.get("slot", -1))
	)
	encounter["actions"] = actions
	runtime_state.set_complex_encounter_override(encounter_id, encounter)
	return _continue_result()


func _execute_treasure(treasure_id: int) -> Dictionary:
	var treasure := bundle.get_treasure(treasure_id)
	if treasure.is_empty():
		return _halt_with_error("Missing treasure record %d" % treasure_id)
	var item_texts: Array = []
	var item_ids: Variant = treasure.get("itemIds", [])
	if item_ids is Array:
		for item_id_value: Variant in item_ids:
			var item_id: int = abs(int(item_id_value))
			if item_id == 0:
				continue
			var item_text := bundle.get_item_text(item_id)
			if not item_text.is_empty():
				item_texts.append(item_text)
	return _yield_result("give_treasure", {
		"treasureId": treasure_id,
		"treasure": treasure,
		"itemTexts": item_texts,
		"lootMode": 1,
	})


func _execute_currency_clear(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Currency-clear action references missing Extra Code row %d" % extra_code_id
		)
	var currency := int(values[0]) - 1
	if currency < 0 or currency > 2:
		return _halt_with_error(
			"Currency-clear action has invalid currency %d" % int(values[0])
		)
	return _yield_result("clear_party_currency", {
		"extraCodeId": extra_code_id,
		"currency": currency,
		"selectedOnly": int(values[1]) != 0,
	})


func _execute_random_items(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Random-item action references missing Extra Code row %d" % extra_code_id
		)
	var authored_count := int(values[0])
	var count := randi_range(1, absi(authored_count)) if authored_count < 0 \
		else authored_count
	var first_item_id := int(values[1])
	var last_item_id := int(values[2])
	if count < 0 or count > 20:
		return _halt_with_error("Random-item action count must be between 0 and 20")
	if first_item_id <= 0 or last_item_id < first_item_id:
		return _halt_with_error("Random-item action has an invalid item range")
	var item_ids: Array[int] = []
	var item_texts: Array = []
	var seen_texts: Dictionary = {}
	for _item_index: int in range(count):
		var item_id := randi_range(first_item_id, last_item_id)
		item_ids.append(item_id)
		var item_text := bundle.get_item_text(item_id)
		if not item_text.is_empty() and not seen_texts.has(item_id):
			seen_texts[item_id] = true
			item_texts.append(item_text)
	return _yield_result("give_treasure", {
		"extraCodeId": extra_code_id,
		"treasureId": -1,
		"treasure": {
			"id": -1,
			"itemIds": item_ids,
			"exp": 0,
			"gold": 0,
			"gems": 0,
			"jewelry": 0,
		},
		"itemTexts": item_texts,
		"lootMode": 1,
		"randomItemCount": count,
		"randomItemRange": [first_item_id, last_item_id],
	})


func _execute_spellcasting_flags(extra_code_id: int) -> Dictionary:
	# Classic explicitly leaves all three flags unchanged when opcode 69 has ID 0.
	if extra_code_id == 0:
		return _continue_result()
	var values := _extra_code_values(extra_code_id)
	if values.size() < 3:
		return _halt_with_error(
			"Spellcasting-flags action references malformed Extra Code row %d"
			% extra_code_id
		)
	runtime_state.set_spellcasting_flags(
		int(values[0]) != 0,
		int(values[1]) != 0,
		int(values[2]) != 0
	)
	return _continue_result()


func _execute_character_pick(record_id: int, invert: bool) -> Dictionary:
	var count: int = abs(record_id)
	if count < 1:
		return _halt_with_error("Character-pick action requests no characters")
	return _yield_result("pick_characters", {
		"count": count,
		"allowDead": record_id < 0,
		"invert": invert,
	})


func _execute_character_check_selection(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Character-check action references missing Extra Code row %d" % extra_code_id
		)
	var candidate_mode := "selected"
	if int(values[2]) == 1:
		candidate_mode = "party"
	elif int(values[2]) == 2:
		candidate_mode = "alive"
	return _yield_result("filter_selected_characters", {
		"extraCodeId": extra_code_id,
		"checkIndex": abs(int(values[0])),
		"modifier": int(values[1]),
		"candidateMode": candidate_mode,
		"checkType": "attribute" if int(values[3]) != 0 else "special",
		"selectOnFailure": int(values[0]) < 0,
	})


func _execute_identity_character_selection(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Race/caste character selector references missing Extra Code row %d" \
			% extra_code_id
		)
	var selector_index := int(values[0])
	var selector := ""
	var value_index := 2
	match selector_index:
		0:
			selector = "race"
		1:
			selector = "gender"
			value_index = 1
		2:
			selector = "caste"
		3:
			selector = "race_class"
		4:
			selector = "caste_class"
		_:
			return _halt_with_error(
				"Race/caste character selector %d is not supported" \
				% selector_index
			)
	return _yield_result("select_characters_by_identity", {
		"extraCodeId": extra_code_id,
		"selector": selector,
		"selectorIndex": selector_index,
		"value": abs(int(values[value_index])),
		"livingOnly": int(values[4]) != 0,
	})


func _execute_misc_character_selection(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Miscellaneous character selector references missing Extra Code row %d" \
			% extra_code_id
		)
	var selector_index := int(values[0])
	var selector := ""
	match selector_index:
		0:
			selector = "movement_below"
		1:
			selector = "position_before"
		2:
			selector = "has_item"
		3:
			selector = "percent"
		4:
			selector = "attribute_save_failure"
		5:
			selector = "spell_save_failure"
		6:
			selector = "focused_character"
		7:
			selector = "wearing_item"
		8:
			selector = "exact_position"
		_:
			return _halt_with_error(
				"Miscellaneous character selector %d is not supported" % selector_index
			)
	var candidate_mode := "party"
	match int(values[2]):
		0:
			pass
		1:
			candidate_mode = "alive"
		2:
			candidate_mode = "selected"
		_:
			return _halt_with_error(
				"Miscellaneous character selector has invalid source set %d" % int(values[2])
			)
	var value := int(values[1])
	var item_texts: Array = []
	if selector == "has_item" or selector == "wearing_item":
		var item_text := bundle.get_item_text(abs(value))
		if not item_text.is_empty():
			item_texts.append(item_text)
	return _yield_result("select_characters_by_misc", {
		"extraCodeId": extra_code_id,
		"selector": selector,
		"selectorIndex": selector_index,
		"value": value,
		"candidateMode": candidate_mode,
		"itemTexts": item_texts,
	})


func _execute_selected_health_effect(extra_code_id: int) -> Dictionary:
	return _execute_health_effect(extra_code_id, "change_selected_health")


func _execute_party_health_effect(extra_code_id: int) -> Dictionary:
	return _execute_health_effect(extra_code_id, "change_party_health")


func _execute_spell_effect(extra_code_id: int, target_party: bool) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Spell action references missing Extra Code row %d" % extra_code_id
		)
	return _yield_result("cast_classic_spell", {
		"extraCodeId": extra_code_id,
		"spellId": int(values[0]),
		"power": int(values[1]),
		"saveAdjustment": int(values[2]),
		"forceAffect": int(values[3]) != 0,
		"targetMode": "party" if target_party else "selected",
	})


func _execute_health_effect(extra_code_id: int, command: String) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Health action references missing Extra Code row %d" % extra_code_id
		)
	var low_roll := int(values[1])
	var high_roll := int(values[2])
	if high_roll < low_roll:
		return _halt_with_error("Health action has an invalid roll range")
	var message_id := int(values[4])
	return _yield_result(command, {
		"extraCodeId": extra_code_id,
		"multiplier": int(values[0]),
		"rollRange": [low_roll, high_roll],
		"soundId": int(values[3]),
		"messageId": message_id,
		"message": bundle.get_message(message_id) if message_id != 0 else {},
	})


func _execute_player_map(signed_map_id: int) -> Dictionary:
	var map_id: int = abs(signed_map_id)
	var map_record: Dictionary = bundle.get_player_map(map_id)
	if map_record.is_empty():
		return _halt_with_error("Missing player map record %d" % map_id)
	runtime_state.set_map_owned(map_id)
	return _yield_result("give_map", {
		"mapId": map_id,
		"display": signed_map_id < 0,
		"mapRecord": map_record,
		"currentPosition": {
			"levelType": runtime_state.level_type,
			"levelIndex": runtime_state.level_index,
			"x": runtime_state.x,
			"y": runtime_state.y,
		},
	})


func _execute_random_rectangle_mutation(extra_code_id: int, dungeon: bool) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Random rectangle mutation references missing Extra Code row %d" % extra_code_id
		)
	var level_kind := "dungeon" if dungeon else "land"
	var map_level := int(values[0])
	var rect_index := int(values[1])
	if rect_index < 0 or rect_index >= MAX_RANDOM_RECTANGLES:
		return _halt_with_error("Random rectangle index must be between 0 and 19")
	if bundle.get_random_level(level_kind, map_level).is_empty():
		return _halt_with_error("Missing %s random-level record %d" % [
			level_kind,
			map_level,
		])
	var baseline := bundle.get_random_rectangle(level_kind, map_level, rect_index)
	if baseline.is_empty():
		baseline = {
			"rectIndex": rect_index,
			"percent": 0,
			"battleRange": [0, 0],
		}
	var previous := runtime_state.get_random_rectangle(
		level_kind,
		map_level,
		rect_index,
		baseline
	)
	var rectangle: Dictionary = previous.duplicate(true)
	rectangle["rectIndex"] = rect_index
	rectangle["percent"] = int(values[2])
	var battle_range := [0, 0]
	var previous_range: Variant = previous.get("battleRange", [])
	if previous_range is Array:
		if previous_range.size() > 0:
			battle_range[0] = int(previous_range[0])
		if previous_range.size() > 1:
			battle_range[1] = int(previous_range[1])
	if int(values[3]) > -1:
		battle_range[0] = int(values[3])
	if int(values[4]) > -1:
		battle_range[1] = int(values[4])
	rectangle["battleRange"] = battle_range
	runtime_state.set_random_rectangle(level_kind, map_level, rect_index, rectangle)
	return _yield_result("set_random_encounter_rect", {
		"extraCodeId": extra_code_id,
		"levelType": level_kind,
		"levelIndex": map_level,
		"rectIndex": rect_index,
		"previousRectangle": previous,
		"rectangle": rectangle,
	})


func _execute_action_data_patch(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Action data patch references missing Extra Code row %d" % extra_code_id
		)
	var source_id := int(values[2])
	var source := bundle.get_extra_action_point(source_id)
	if source.is_empty():
		return _halt_with_error("Action data patch references missing Data ED3 row %d" % source_id)
	match int(values[0]):
		-1:
			return _patch_encounter_result("simple", int(values[1]), int(values[4]), source)
		-2:
			return _patch_encounter_result("complex", int(values[1]), int(values[4]), source)
		_:
			return _patch_map_action_point(values, source)


func _execute_timed_encounter_mutation(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Timed encounter mutation references missing Extra Code row %d" % extra_code_id
		)
	var encounter_id := int(values[0])
	var encounter := bundle.get_timed_encounter(encounter_id)
	if encounter.is_empty():
		return _halt_with_error(
			"Timed encounter mutation references missing encounter %d" % encounter_id
		)
	encounter = runtime_state.get_effective_timed_encounter(encounter)
	if int(values[1]) > -1:
		encounter["percent"] = int(values[1])
	if int(values[2]) > -1:
		encounter["increment"] = int(values[2])
	if int(values[3]) != 0:
		var scenario_day: Variant = execution_context.get("scenarioDay")
		if not (scenario_day is int or scenario_day is float) \
			or not is_equal_approx(float(scenario_day), float(int(scenario_day))) \
			or int(scenario_day) < 0:
			return _halt_with_error(
				"Timed encounter reset requires a non-negative scenarioDay execution context"
			)
		encounter["day"] = int(scenario_day)
	if int(values[4]) > -1:
		encounter["day"] = int(encounter.get("day", 0)) + int(values[4])
	runtime_state.set_timed_encounter_override(encounter_id, encounter)
	return _continue_result()


func _patch_map_action_point(values: Array, source: Dictionary) -> Dictionary:
	var level_kind := runtime_state.level_type
	var level_selector := int(values[3])
	if level_selector != 0:
		level_kind = "land" if level_selector == 1 else "dungeon"
	var map_level := int(values[0])
	var record_index := int(values[1])
	var target := _effective_map_action_point(level_kind, map_level, record_index)
	if target.is_empty():
		return _halt_with_error("Missing %s map action point %d:%d" % [
			level_kind,
			map_level,
			record_index,
		])
	target["actions"] = source.get("actions", []).duplicate(true)
	runtime_state.set_action_point_override(str(target.get("id", "")), target)
	return _continue_result()


func _patch_encounter_result(
	encounter_kind: String,
	encounter_id: int,
	result_index: int,
	source: Dictionary
) -> Dictionary:
	if result_index < 0 or result_index > 3:
		return _halt_with_error("Classic encounter result index must be between 0 and 3")
	var encounter := bundle.get_encounter(encounter_kind, encounter_id)
	if encounter.is_empty():
		return _halt_with_error("Missing %s encounter record %d" % [
			encounter_kind,
			encounter_id,
		])
	if encounter_kind == "simple":
		encounter = runtime_state.get_effective_simple_encounter(encounter)
	else:
		encounter = runtime_state.get_effective_complex_encounter(encounter)
	var encounter_actions: Variant = encounter.get("actions", [])
	var source_actions: Variant = source.get("actions", [])
	if not (encounter_actions is Array) or not (source_actions is Array):
		return _halt_with_error("Action data patch source or target has no action array")
	encounter["actions"] = _replace_encounter_result_actions(
		encounter_actions,
		source_actions,
		result_index
	)
	if encounter_kind == "simple":
		runtime_state.set_simple_encounter_override(encounter_id, encounter)
	else:
		runtime_state.set_complex_encounter_override(encounter_id, encounter)
	return _continue_result()


func _replace_encounter_result_actions(
	encounter_actions: Array,
	source_actions: Array,
	result_index: int
) -> Array:
	var first_slot := result_index * 8
	var actions: Array = []
	for action_value: Variant in encounter_actions:
		if not (action_value is Dictionary):
			continue
		var slot := int(action_value.get("slot", -1))
		if slot < first_slot or slot >= first_slot + 8:
			actions.append(action_value.duplicate(true))
	for action_value: Variant in source_actions:
		if not (action_value is Dictionary):
			continue
		var action: Dictionary = action_value.duplicate(true)
		action["slot"] = first_slot + int(action.get("slot", 0))
		actions.append(action)
	actions.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("slot", -1)) < int(b.get("slot", -1))
	)
	return actions


func _execute_same_as_other_action_point(record_index: int) -> Dictionary:
	var target := _effective_map_action_point(
		runtime_state.level_type,
		runtime_state.level_index,
		record_index
	)
	if target.is_empty():
		return _halt_with_error("Missing same-map action point %d" % record_index)
	var percent := int(active_action_point_header.get(
		"percent",
		current_trigger.get("percent", 0)
	))
	# Classic copies only the other door's CODE/ID slots, then re-enters moveon
	# with the active door's header and percentage still in place.
	var replacement := current_trigger.duplicate(true)
	replacement["actions"] = target.get("actions", []).duplicate(true)
	_set_cursor(replacement, 0)
	if percent < 1 or _roll_percent() > percent:
		_clear_control_flow()
		return _completed_result("same-door-percent-miss")
	return _continue_result()


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


func _execute_random_text(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error("Random text action references missing Extra Code row %d" % extra_code_id)
	var first_message_id := int(values[0])
	var last_message_id := int(values[1])
	var message_id := randi_range(first_message_id, last_message_id)
	return _yield_result("show_text", {
		"extraCodeId": extra_code_id,
		"messageRange": [first_message_id, last_message_id],
		"messageId": message_id,
		"message": bundle.get_message(message_id),
	})


func _execute_priest_turning(enabled: bool) -> Dictionary:
	runtime_state.set_priest_turning_enabled(enabled)
	var message := PRIEST_TURNING_ENABLED_MESSAGE if enabled \
		else PRIEST_TURNING_DISABLED_MESSAGE
	return _yield_result("set_priest_turning", {
		"enabled": enabled,
		"soundId": 20004 if enabled else 10105,
		"messageId": 0,
		"message": {"id": 0, "text": message},
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
		"priestTurningEnabled": runtime_state.priest_turning_enabled,
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
		"yesLabelId": int(values[3]),
		"yesLabel": bundle.get_option_label(int(values[3])),
		"noLabelId": int(values[4]),
		"noLabel": bundle.get_option_label(int(values[4])),
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
	active_action_point_header["landid"] = runtime_state.level_index
	active_action_point_header["targetX"] = runtime_state.x
	active_action_point_header["targetY"] = runtime_state.y
	pending_teleport = {
		"recheckDestination": recheck_destination,
	}
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


func _execute_dungeon_move(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error("Dungeon Move action references missing Extra Code row %d" % extra_code_id)
	var destination_type := "dungeon" if int(values[0]) == 0 else "land"
	runtime_state.set_location(
		destination_type,
		int(values[1]),
		int(values[2]),
		int(values[3])
	)
	var payload := {
		"extraCodeId": extra_code_id,
		"levelType": runtime_state.level_type,
		"levelIndex": runtime_state.level_index,
		"x": runtime_state.x,
		"y": runtime_state.y,
		"recheckDestination": false,
		"dungeonMove": true,
	}
	if destination_type == "dungeon":
		runtime_state.set_dungeon_view(int(values[4]), int(values[4]) >= 0)
		payload["heading"] = runtime_state.heading
		payload["multiView"] = runtime_state.multi_view
		payload["viewType"] = runtime_state.view_type

	# Loading another map returns from newland immediately; later AP slots and
	# any saved GOSUB frames do not resume after the host completes the transfer.
	var result := _yield_result("teleport", payload)
	_clear_control_flow()
	return result


func _execute_look_direction(requested_heading: int) -> Dictionary:
	var randomized := requested_heading < 1 or requested_heading > 4
	var new_heading := randi_range(1, 4) if randomized else requested_heading
	runtime_state.set_heading(new_heading)
	return _yield_result("set_view_direction", {
		"heading": runtime_state.heading,
		"requestedHeading": requested_heading,
		"randomized": randomized,
	})


func _execute_compass(enabled: bool) -> Dictionary:
	var previous := runtime_state.compass_enabled
	runtime_state.set_compass_enabled(enabled)
	return _yield_result("set_view_mode", {
		"compassEnabled": enabled,
		"multiView": runtime_state.multi_view,
		"viewType": runtime_state.view_type,
		"warningId": (98 if enabled else 99) if previous != enabled else 0,
		"redraw": "walls",
	})


func _execute_map_view_mode(allow_map: bool) -> Dictionary:
	var previous_multi_view := runtime_state.multi_view
	var previous_view_type := runtime_state.view_type
	if allow_map:
		runtime_state.allow_full_map()
	else:
		runtime_state.require_3d_view()
	return _yield_result("set_view_mode", {
		"compassEnabled": runtime_state.compass_enabled,
		"multiView": runtime_state.multi_view,
		"viewType": runtime_state.view_type,
		"previousViewType": previous_view_type,
		"warningId": (
			96 if allow_map and not previous_multi_view
			else 97 if not allow_map and previous_multi_view
			else 0
		),
		"redraw": "window" if not allow_map or runtime_state.view_type == 1 else "none",
	})


func _execute_darkland(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Set Darkland action references missing Extra Code row %d" % extra_code_id
		)
	var random_level := bundle.get_random_level(
		runtime_state.level_type,
		runtime_state.level_index
	)
	var fallback := 1 if bool(random_level.get("isDark", false)) else 0
	var previous := runtime_state.get_darkland(
		runtime_state.level_type,
		runtime_state.level_index,
		fallback
	)
	var darkness := int(values[0]) - 1
	if int(values[1]) != 0 and previous == darkness:
		_clear_control_flow()
		return _completed_result("darkland-unchanged")
	runtime_state.set_darkland(
		runtime_state.level_type,
		runtime_state.level_index,
		darkness
	)
	return _yield_result("set_map_darkness", {
		"extraCodeId": extra_code_id,
		"levelType": runtime_state.level_type,
		"levelIndex": runtime_state.level_index,
		"previousDarkness": previous,
		"darkness": darkness,
		"dark": darkness != 0,
	})


func _execute_landlook(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Change Land Look action references missing Extra Code row %d" % extra_code_id
		)
	var map_level := int(values[2])
	var random_level := bundle.get_random_level("land", map_level)
	if random_level.is_empty():
		return _halt_with_error("Missing land random-level record %d" % map_level)
	var previous_landlook := runtime_state.get_landlook(
		"land",
		map_level,
		int(random_level.get("landlook", 0))
	)
	var previous_darkness := runtime_state.get_darkland(
		"land",
		map_level,
		1 if bool(random_level.get("isDark", false)) else 0
	)
	var landlook := int(values[0])
	var darkness := int(values[1])
	runtime_state.set_landlook("land", map_level, landlook)
	runtime_state.set_darkland("land", map_level, darkness)
	return _yield_result("set_land_look", {
		"extraCodeId": extra_code_id,
		"levelType": "land",
		"levelIndex": map_level,
		"previousLandlook": previous_landlook,
		"landlook": landlook,
		"previousDarkness": previous_darkness,
		"darkness": darkness,
		"dark": darkness != 0,
		"redraw": "center" if runtime_state.level_type == "land" else "none",
	})


func _execute_position_shift(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Position shift references missing Extra Code row %d" % extra_code_id
		)
	var delta_x := int(values[1])
	var delta_y := int(values[2])
	var randomized := int(values[3]) != 0
	if randomized:
		if delta_x <= 0 or delta_y <= 0:
			return _halt_with_error(
				"Random position shift %d requires positive X and Y ranges" % extra_code_id
			)
		delta_x = randi_range(1, delta_x) * (-1 if randi_range(0, 1) == 0 else 1)
		delta_y = randi_range(1, delta_y) * (-1 if randi_range(0, 1) == 0 else 1)

	var map_id := "%s:%d" % [runtime_state.level_type, runtime_state.level_index]
	var map_record := bundle.get_map(map_id)
	var width := int(map_record.get("width", 0))
	var height := int(map_record.get("height", 0))
	var target_x := runtime_state.x + delta_x
	var target_y := runtime_state.y + delta_y
	if (
		map_record.is_empty()
		or width <= 0
		or height <= 0
		or target_x < 0
		or target_y < 0
		or target_x >= width
		or target_y >= height
	):
		return _halt_with_error(
			"Position shift %d leaves Classic map %s at %d,%d" % [
				extra_code_id,
				map_id,
				target_x,
				target_y,
			]
		)
	var previous_position := Vector2i(runtime_state.x, runtime_state.y)
	runtime_state.set_position(runtime_state.level_index, target_x, target_y)
	return _yield_result("shift_party_position", {
		"extraCodeId": extra_code_id,
		"levelType": runtime_state.level_type,
		"levelIndex": runtime_state.level_index,
		"x": target_x,
		"y": target_y,
		"delta": Vector2i(delta_x, delta_y),
		"fromPosition": previous_position,
		"randomized": randomized,
	})


func _execute_time_mutation(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Game-time mutation references missing Extra Code row %d" % extra_code_id
		)
	var mode := int(values[0])
	if mode not in [1, 2]:
		return _halt_with_error("Game-time mutation %d has invalid mode %d" % [
			extra_code_id,
			mode,
		])
	if (
		mode == 1
		and (
			int(values[1]) < -1
			or int(values[2]) < -1
			or int(values[2]) > 23
			or int(values[3]) < -1
			or int(values[3]) > 59
		)
	):
		return _halt_with_error(
			"Set game-time row %d has an invalid day, hour, or minute" % extra_code_id
		)
	pending_time_mutation = {"extraCodeId": extra_code_id}
	return _yield_result("alter_game_time", {
		"extraCodeId": extra_code_id,
		"mode": "set" if mode == 1 else "offset",
		"day": int(values[1]),
		"hour": int(values[2]),
		"minute": int(values[3]),
	})


func _execute_time_branch(extra_code_id: int, gosub: bool) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Game-time branch references missing Extra Code row %d" % extra_code_id
		)
	if not execution_context.has("scenarioDay") \
			or not execution_context.has("scenarioHour"):
		return _halt_with_error(
			"Game-time branch %d requires the current scenario day and hour" % extra_code_id
		)
	var day := int(execution_context["scenarioDay"])
	var hour := int(execution_context["scenarioHour"])
	var latest_day := int(values[0])
	var latest_hour := int(values[1])
	if latest_day < -1 or latest_hour < -1 or latest_hour > 23:
		return _halt_with_error(
			"Game-time branch %d has an invalid day or hour limit" % extra_code_id
		)
	var within_time := (latest_day == -1 or day <= latest_day) \
		and (latest_hour == -1 or hour <= latest_hour)
	return _branch_to_extra_action_point(
		int(values[3] if within_time else values[4]),
		gosub,
		0
	)


func _execute_exploration_status(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Exploration-status action references missing Extra Code row %d" % extra_code_id
		)
	for value_index: int in 3:
		if int(values[value_index]) not in [0, 1, 2]:
			return _halt_with_error(
				"Exploration-status row %d has invalid field %d" % [
					extra_code_id,
					value_index,
				]
			)
	pending_exploration_status = {"extraCodeId": extra_code_id}
	return _yield_result("update_exploration_status", {
		"extraCodeId": extra_code_id,
		"boatTest": int(values[0]),
		"campTest": int(values[1]),
		"boatChange": int(values[2]),
	})


func _remove_current_action_point() -> Dictionary:
	remove_action_point = true
	removal_x = runtime_state.x
	removal_y = runtime_state.y
	call_stack.clear()
	gosub_active = false
	encounter_origins.clear()
	return _continue_result()


func _finish_action_point(reason: String, consume_codes: bool) -> Dictionary:
	if reason == "action-point-ended" and not remove_action_point:
		var repeated_encounter := _repeat_encounter_after_fallthrough()
		if not repeated_encounter.is_empty():
			return repeated_encounter
	if remove_action_point and not origin_action_point.is_empty():
		_persist_removed_action_point(consume_codes)
	elif consume_codes and not origin_action_point.is_empty():
		_set_origin_action_point_percent(-1)
	var destination_result := _action_point_destination_result(reason)
	if not destination_result.is_empty():
		return destination_result
	_clear_control_flow()
	return _completed_result(reason)


func _action_point_destination_result(reason: String) -> Dictionary:
	if origin_action_point.is_empty() or suppress_action_point_destination:
		return {}
	var source_level := int(origin_action_point.get(
		"levelIndex",
		runtime_state.level_index
	))
	var source_coordinate: Variant = origin_action_point.get("coordinate", {})
	var source_x := runtime_state.x
	var source_y := runtime_state.y
	if source_coordinate is Dictionary:
		source_x = int(source_coordinate.get("x", source_x))
		source_y = int(source_coordinate.get("y", source_y))
	var destination_level := int(active_action_point_header.get("landid", source_level))
	var destination_x := int(active_action_point_header.get("targetX", source_x))
	var destination_y := int(active_action_point_header.get("targetY", source_y))
	if destination_level == source_level \
			and destination_x == source_x \
			and destination_y == source_y:
		return {}
	if destination_level == runtime_state.level_index \
			and destination_x == runtime_state.x \
			and destination_y == runtime_state.y:
		return {}

	runtime_state.set_position(destination_level, destination_x, destination_y)
	pending_teleport = {
		"recheckDestination": true,
		"completionReason": reason,
	}
	return _yield_result("teleport", {
		"levelType": runtime_state.level_type,
		"levelIndex": runtime_state.level_index,
		"x": runtime_state.x,
		"y": runtime_state.y,
		"soundId": 0,
		"messageId": 0,
		"message": {},
		"recheckDestination": true,
		"actionPointDestination": true,
	})


func _repeat_encounter_after_fallthrough() -> Dictionary:
	if encounter_origins.is_empty():
		return {}
	var encounter_loop: Dictionary = encounter_origins[-1]
	encounter_loop["remainingAttempts"] = int(
		encounter_loop.get("remainingAttempts", 1)
	) - 1
	encounter_origins[-1] = encounter_loop
	if int(encounter_loop["remainingAttempts"]) <= 0:
		return {}
	# Classic repeats only when a result block falls through. Opcodes 24 and 25
	# clear the encounter flag before reaching this point and therefore terminate.
	return _yield_encounter(
		str(encounter_loop.get("encounterKind", "")),
		int(encounter_loop.get("encounterId", -1)),
		0
	)


func _persist_removed_action_point(consume_codes: bool) -> void:
	var level_kind := str(origin_action_point.get("levelType", runtime_state.level_type))
	var record_index := int(origin_action_point.get("recordIndex", -1))
	if consume_codes and record_index >= 0:
		_set_origin_action_point_percent(-1)

	var destination_level := int(active_action_point_header.get("landid", runtime_state.level_index))
	var destination_x := int(active_action_point_header.get("targetX", runtime_state.x))
	var destination_y := int(active_action_point_header.get("targetY", runtime_state.y))
	var changes_position := (
		destination_level != runtime_state.level_index
		or destination_x != runtime_state.x
		or destination_y != runtime_state.y
	)
	if not changes_position or record_index < 0:
		return

	# Classic loads the destination map before writing door[doornum], so a
	# cross-level removal replaces the same record slot on that map.
	runtime_state.set_position(destination_level, destination_x, destination_y)
	var replacement := active_action_point_header.duplicate(true)
	replacement["actions"] = current_trigger.get("actions", []).duplicate(true)
	replacement["targetX"] = removal_x
	replacement["targetY"] = removal_y
	replacement["source"] = "Data DDD" if level_kind == "dungeon" else "Data DD"
	replacement["levelType"] = level_kind
	replacement["levelIndex"] = destination_level
	replacement["recordIndex"] = record_index
	replacement["id"] = _map_action_point_id(level_kind, destination_level, record_index)
	replacement["coordinate"] = _coordinate_from_door_id(
		int(replacement.get("doorid", 0)),
		destination_level
	)
	replacement["active"] = (
		int(replacement.get("percent", 0)) >= 1
		and replacement.get("coordinate") is Dictionary
	)
	if consume_codes:
		runtime_state.set_trigger_percent(level_kind, destination_level, record_index, -1)
	runtime_state.set_action_point_override(str(replacement["id"]), replacement)


func _set_origin_action_point_percent(percent: int) -> void:
	if origin_action_point.is_empty():
		return
	var record_index := int(origin_action_point.get("recordIndex", -1))
	if record_index < 0:
		return
	var level_kind := str(origin_action_point.get("levelType", runtime_state.level_type))
	var source_level := int(origin_action_point.get("levelIndex", runtime_state.level_index))
	runtime_state.set_trigger_percent(level_kind, source_level, record_index, percent)
	active_action_point_header["percent"] = percent


func _map_action_point_id(level_kind: String, level: int, record_index: int) -> String:
	var source := "Data DDD" if level_kind == "dungeon" else "Data DD"
	return "%s:%d:%d" % [source, level, record_index]


func _effective_map_action_point(level_kind: String, level: int, record_index: int) -> Dictionary:
	var trigger_id := _map_action_point_id(level_kind, level, record_index)
	var action_point := runtime_state.get_action_point_override(trigger_id)
	if action_point.is_empty():
		action_point = bundle.get_trigger(trigger_id)
	return runtime_state.get_effective_action_point(action_point) if not action_point.is_empty() else {}


func _coordinate_from_door_id(door_id: int, level: int) -> Variant:
	if door_id <= 0 or floori(float(door_id) / 10000.0) != level:
		return null
	var packed_position := door_id % 10000
	return {
		"x": packed_position % 100,
		"y": floori(float(packed_position) / 100.0),
	}


func _is_map_action_point(action_point: Dictionary) -> bool:
	return str(action_point.get("source", "")) in ["Data DD", "Data DDD"]


func _execute_party_condition_branch(extra_code_id: int, gosub: bool) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Party-condition branch references missing Extra Code row %d" % extra_code_id
		)
	var required_state := int(values[0])
	if required_state not in [1, 2]:
		return _halt_with_error(
			"Party-condition branch has invalid state test %d" % required_state
		)
	var condition_index := int(values[3])
	if condition_index < 0 or condition_index >= PARTY_CONDITION_NAMES.size():
		return _halt_with_error(
			"Party-condition branch has invalid condition index %d" % condition_index
		)
	pending_party_condition_check = {
		"values": values,
		"gosub": gosub,
	}
	return _yield_result("check_party_condition", {
		"extraCodeId": extra_code_id,
		"conditionIndex": condition_index,
		"conditionName": PARTY_CONDITION_NAMES[condition_index],
		"requiredActive": required_state == 1,
		"branchMode": int(values[1]),
		"targetId": int(values[2]),
	})


func _execute_misc_branch(extra_code_id: int, gosub: bool) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Party identity branch references missing Extra Code row %d" \
			% extra_code_id
		)
	var selector_index := int(values[0])
	var selectors := [
		"caste",
		"race",
		"gender",
		"in_boat",
		"in_camp",
		"caste_class",
		"race_class",
		"party_level_above",
		"selected_level_above",
	]
	if selector_index < 0 or selector_index >= selectors.size():
		return _halt_with_error(
			"Party identity branch selector %d is not supported" % selector_index
		)
	var branch_mode := int(values[2])
	if branch_mode < 0 or branch_mode > 2:
		return _halt_with_error(
			"Party identity branch has invalid target mode %d" % branch_mode
		)
	var authored_value := int(values[1])
	pending_misc_branch = {
		"values": values,
		"gosub": gosub,
	}
	return _yield_result("check_party_misc", {
		"extraCodeId": extra_code_id,
		"selector": selectors[selector_index],
		"selectorIndex": selector_index,
		"value": abs(authored_value),
		"selectedOnly": (
			authored_value < 0
			and selector_index in [0, 1, 2, 5, 6]
		),
		"branchMode": branch_mode,
		"matchTargetId": int(values[3]),
		"missTargetId": int(values[4]),
	})


func _execute_ally_branch(extra_code_id: int, gosub: bool) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error("Ally branch references missing Extra Code row %d" % extra_code_id)
	var monster_name_id := int(values[0])
	var matching_monsters: Array = bundle.get_monsters_by_name_id(monster_name_id)
	var monster: Dictionary = matching_monsters[0] if not matching_monsters.is_empty() else {}
	pending_ally_check = {
		"values": values,
		"gosub": gosub,
	}
	return _yield_result("check_party_ally", {
		"extraCodeId": extra_code_id,
		"monsterNameId": monster_name_id,
		"monster": monster,
	})


func _execute_remove_ally(monster_name_id: int) -> Dictionary:
	var normalized_name_id := absi(monster_name_id)
	var matching_monsters: Array = bundle.get_monsters_by_name_id(normalized_name_id)
	var monster: Dictionary = matching_monsters[0] if not matching_monsters.is_empty() else {}
	return _yield_result("remove_party_ally", {
		"monsterNameId": normalized_name_id,
		"monster": monster,
	})


func _execute_add_ally(monster_id: int) -> Dictionary:
	var monster := bundle.get_monster(monster_id)
	if monster.is_empty():
		return _halt_with_error("Add-ally action references missing monster %d" % monster_id)
	return _yield_result("add_party_ally", {
		"monsterId": abs(monster_id),
		"monster": monster,
	})


func _resume_ally_branch(values: Array, target_id: int, ally_check: Dictionary) -> Dictionary:
	var branch_result := _branch_to_action_or_encounter(
		int(values[1]),
		target_id,
		bool(ally_check.get("gosub", false))
	)
	if str(branch_result.get("status", "")) != "continue":
		return branch_result
	return run_until_yield()


func _execute_random_branch(extra_code_id: int, gosub: bool) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Random branch references missing Extra Code row %d" % extra_code_id
		)
	var target_mode := int(values[0])
	if target_mode < 0 or target_mode > 2:
		return _halt_with_error("Random branch has invalid target mode %d" % target_mode)
	var first_target := int(values[1])
	var last_target := int(values[2])
	if last_target < first_target:
		return _halt_with_error(
			"Random branch target range %d-%d is reversed" % [first_target, last_target]
		)
	var random_branch := {
		"targetMode": target_mode,
		"targetId": randi_range(first_target, last_target),
		"gosub": gosub,
	}
	var sound_id := int(values[3])
	var message_id := int(values[4])
	if sound_id == 0 and message_id == 0:
		return _apply_random_branch(random_branch)
	pending_random_branch = random_branch
	return _yield_result("present_random_branch", {
		"extraCodeId": extra_code_id,
		"targetMode": target_mode,
		"targetRange": [first_target, last_target],
		"targetId": int(random_branch["targetId"]),
		"soundId": sound_id,
		"messageId": message_id,
		"message": bundle.get_message(message_id),
	})


func _apply_random_branch(random_branch: Dictionary) -> Dictionary:
	var branch_result := _branch_to_action_or_encounter(
		int(random_branch["targetMode"]),
		int(random_branch["targetId"]),
		bool(random_branch.get("gosub", false))
	)
	if str(branch_result.get("status", "")) != "continue":
		return branch_result
	return run_until_yield()


func _branch_to_action_or_encounter(target_mode: int, target_id: int, gosub: bool) -> Dictionary:
	match target_mode:
		0:
			return _branch_to_extra_action_point(target_id, gosub, 0)
		1, 2:
			if gosub:
				var push_result := _push_call_frame()
				if str(push_result.get("status", "")) != "continue":
					return push_result
			return _execute_encounter("simple" if target_mode == 1 else "complex", target_id)
		_:
			return _halt_with_error("Unsupported classic branch target mode %d" % target_mode)


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


func _execute_quest_value_mutation(extra_code_id: int, gosub: bool) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Quest-value mutation references missing Extra Code row %d" % extra_code_id
		)
	var quest_id := int(values[0])
	if quest_id < 0 or quest_id >= 100:
		return _halt_with_error("Classic quest index %d is outside 0 through 99" % quest_id)
	var quest_value := runtime_state.adjust_quest_value(quest_id, int(values[1]))
	var threshold := int(values[3])
	if threshold == 0 or quest_value < threshold:
		return _continue_result()
	var target_mode := int(values[2]) - 1
	if target_mode < 0 or target_mode > 2:
		return _halt_with_error(
			"Quest-value mutation has invalid branch mode %d" % int(values[2])
		)
	return _branch_to_action_or_encounter(
		target_mode,
		int(values[4]),
		gosub
	)


func _execute_quest_value_branch(extra_code_id: int, gosub: bool) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Quest-value branch references missing Extra Code row %d" % extra_code_id
		)
	var quest_id := int(values[0])
	if quest_id < 0 or quest_id >= 100:
		return _halt_with_error("Classic quest index %d is outside 0 through 99" % quest_id)
	var threshold_met := runtime_state.get_quest_value(quest_id) >= int(values[1])
	var target_id := int(values[4] if threshold_met else values[3])
	if target_id == 0:
		return _continue_result()
	var target_mode := int(values[2])
	if target_mode < 0 or target_mode > 2:
		return _halt_with_error(
			"Quest-value branch has invalid branch mode %d" % target_mode
		)
	return _branch_to_action_or_encounter(target_mode, target_id, gosub)


func _execute_quest_range_branch(extra_code_id: int, gosub: bool) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.size() < 5:
		return _halt_with_error(
			"Quest-range branch references malformed Extra Code row %d"
			% extra_code_id
		)
	var first_quest := int(values[0])
	var last_quest := int(values[1])
	if first_quest < 0 or last_quest < first_quest or last_quest >= 100:
		return _halt_with_error(
			"Quest-range branch has invalid range %d through %d"
			% [first_quest, last_quest]
		)
	for quest_id: int in range(first_quest, last_quest + 1):
		if not runtime_state.is_quest_set(quest_id):
			return _continue_result()
	var target_mode := int(values[3])
	if target_mode < 0 or target_mode > 2:
		return _halt_with_error(
			"Quest-range branch has invalid target mode %d" % target_mode
		)
	return _branch_to_action_or_encounter(
		target_mode,
		int(values[4]),
		gosub
	)


func _execute_tile_parameter_branch(extra_code_id: int, gosub: bool) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Tile-parameter branch references missing Extra Code row %d" % extra_code_id
		)
	var selector := int(values[0])
	var look_offset: Variant = execution_context.get("lookOffset", {})
	var look_x := int(look_offset.get("x", 0)) if look_offset is Dictionary else 0
	var look_y := int(look_offset.get("y", 0)) if look_offset is Dictionary else 0
	var tile_x := runtime_state.x + look_x
	var tile_y := runtime_state.y + look_y
	var tile_record := bundle.get_map_tile(
		runtime_state.level_type,
		runtime_state.level_index,
		tile_x,
		tile_y
	)
	if tile_record.is_empty():
		return _halt_with_error(
			"Tile-parameter branch cannot resolve the current map field"
		)
	var raw_tile := runtime_state.get_tile(
		runtime_state.level_type,
		runtime_state.level_index,
		tile_x,
		tile_y,
		int(tile_record.get("value", 0))
	)
	var tile_id := MapBridgeScript.normalize_tile_parameter_id(raw_tile)
	var matches := tile_id == int(values[1]) if selector == 7 else false
	var landlook := -1
	var attribute: Dictionary = {}
	if selector >= 1 and selector <= 6:
		var map: Dictionary = tile_record.get("map", {})
		var render: Variant = map.get("render", {})
		var baseline_landlook := int(render.get("landlook", -1)) \
			if render is Dictionary else -1
		landlook = runtime_state.get_landlook(
			runtime_state.level_type,
			runtime_state.level_index,
			baseline_landlook
		)
		attribute = bundle.get_land_tile_attribute(landlook, tile_id)
		if attribute.is_empty():
			return _halt_with_error(
				"Tile-parameter branch cannot resolve tile %d attributes for landlook %d"
				% [tile_id, landlook]
			)
		matches = _tile_parameter_is_set(attribute, selector)
	var target_id := int(values[4] if matches else values[3])
	if target_id == 0:
		return _continue_result()
	var target_mode := int(values[2])
	if target_mode < 0 or target_mode > 2:
		return _halt_with_error(
			"Tile-parameter branch has invalid branch mode %d" % target_mode
		)
	return _branch_to_action_or_encounter(target_mode, target_id, gosub)


func _tile_parameter_is_set(attribute: Dictionary, selector: int) -> bool:
	match selector:
		1:
			return int(attribute.get("shore", 0)) != 0
		2:
			return int(attribute.get(
				"boatRequirement",
				attribute.get("needBoat", 0)
			)) != 0
		3:
			return int(attribute.get("pathFlag", attribute.get("isPath", 0))) != 0
		4:
			return int(attribute.get("blocksLos", attribute.get("los", 0))) != 0
		5:
			return int(attribute.get(
				"flyFloatRequired",
				attribute.get("flyFloat", 0)
			)) != 0
		6:
			return int(attribute.get("forestType", attribute.get("forest", 0))) != 0
	return false


func _execute_experience_loss(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Experience-loss action references missing Extra Code row %d" % extra_code_id
		)
	var source_mode := int(values[1])
	var mode := "each"
	if source_mode == 1:
		mode = "selected"
	elif source_mode == 2:
		mode = "spread"
	return _yield_result("remove_experience", {
		"extraCodeId": extra_code_id,
		"experience": int(values[0]),
		"mode": mode,
		"sourceMode": source_mode,
	})


func _execute_percent_branch(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Percent branch references missing Extra Code row %d" % extra_code_id
		)
	var roll := _roll_percent()
	if roll < 1 or roll > 100:
		return _halt_with_error("Percent roll provider returned %d; expected 1 through 100" % roll)
	if roll > int(values[0]):
		return _continue_result()
	return _apply_force_branch_success(values)


func _execute_difficulty_branch(extra_code_id: int) -> Dictionary:
	var values := _extra_code_values(extra_code_id)
	if values.is_empty():
		return _halt_with_error(
			"Difficulty branch references missing Extra Code row %d" % extra_code_id
		)
	if runtime_state.difficulty < int(values[0]):
		return _continue_result()
	return _apply_force_branch_success(values)


func _apply_force_branch_success(values: Array) -> Dictionary:
	match int(values[1]):
		-2:
			return _finish_conditional_branch("dropout-and-erase", true)
		1:
			# Percent and difficulty branches do not push GOSUB in Classic.
			return _branch_from_extra_code(values, false)
		2:
			return _finish_conditional_branch("keep-codes", false)
		_:
			return _continue_result()


func _roll_percent() -> int:
	if percent_roll_provider.is_valid():
		return int(percent_roll_provider.call())
	return randi_range(1, 100)


func _finish_conditional_branch(reason: String, consume_codes: bool) -> Dictionary:
	var in_encounter := not encounter_origins.is_empty()
	if consume_codes and not in_encounter:
		_set_origin_action_point_percent(-1)
	if in_encounter:
		var repeated_encounter := _repeat_encounter_after_fallthrough()
		if not repeated_encounter.is_empty():
			return repeated_encounter
	_clear_control_flow()
	return _completed_result(reason)


func _branch_from_extra_code(values: Array, gosub: bool) -> Dictionary:
	if gosub:
		var push_result := _push_call_frame()
		if str(push_result.get("status", "")) != "continue":
			return push_result
	match int(values[2]):
		-1:
			_set_cursor(current_trigger, 7)
			return _continue_result()
		0:
			return _branch_to_extra_action_point(int(values[3]), false, 0)
		1, 2:
			return _branch_to_loaded_encounter_result(
				"simple" if int(values[2]) == 1 else "complex",
				int(values[3]),
				int(values[4])
			)
		3:
			return _finish_action_point("keep-codes", false)
		_:
			return _halt_with_error("Unsupported classic branch mode %d" % int(values[2]))


func _branch_to_loaded_encounter_result(
	encounter_kind: String,
	result_index: int,
	start_slot: int
) -> Dictionary:
	if result_index < 0 or result_index > 3:
		return _halt_with_error("Classic encounter result index must be between 0 and 3")
	# Classic keeps the most recently loaded simple and complex records in
	# separate buffers. A nested encounter can therefore branch back into its
	# enclosing record without starting another encounter.
	var encounter_id := (
		loaded_simple_encounter_id
		if encounter_kind == "simple"
		else loaded_complex_encounter_id
	)
	if encounter_id < 0:
		# Both Classic buffers are zeroed before their first load.
		_set_cursor({
			"id": "%s encounter:unloaded:outcome:%d" % [encounter_kind, result_index + 1],
			"actions": [],
		}, start_slot)
		return _continue_result()
	var encounter := bundle.get_encounter(encounter_kind, encounter_id)
	if encounter.is_empty():
		return _halt_with_error(
			"Missing loaded %s encounter record %d" % [encounter_kind, encounter_id]
		)
	if encounter_kind == "simple":
		encounter = runtime_state.get_effective_simple_encounter(encounter)
	else:
		encounter = runtime_state.get_effective_complex_encounter(encounter)
	var target := _encounter_outcome_trigger(
		encounter_kind,
		encounter_id,
		encounter,
		result_index + 1
	)
	if target.is_empty():
		return _halt_with_error("Classic encounter has no action array")
	_set_cursor(target, start_slot)
	return _continue_result()


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
		"actionPointHeader": active_action_point_header.duplicate(true),
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
		action["code"] = normalize_opcode(raw_code)
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
	active_action_point_header = origin["actionPointHeader"]
	return _continue_result()


func _restore_call_frame() -> void:
	var frame: Dictionary = call_stack.pop_back()
	current_trigger = frame["trigger"]
	current_action_index = int(frame["actionIndex"])
	active_action_point_header = frame["actionPointHeader"]


func _update_gosub_state(action: Dictionary) -> void:
	# Classic keeps GOSUB active across positive actions while a call frame exists.
	if bool(action.get("gosub", false)):
		gosub_active = true
	elif call_stack.is_empty():
		gosub_active = false


func _clear_control_flow() -> void:
	current_trigger = {}
	current_action_index = 0
	origin_action_point.clear()
	active_action_point_header.clear()
	suppress_action_point_destination = false
	remove_action_point = false
	removal_x = 0
	removal_y = 0
	call_stack.clear()
	gosub_active = false
	encounter_origins.clear()


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
