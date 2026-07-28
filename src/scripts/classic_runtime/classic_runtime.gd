class_name ClassicRuntime
extends Node

signal command_requested(command: String, payload: Dictionary)
signal trigger_completed(result: Dictionary)
signal runtime_stopped(result: Dictionary)

const CONTINUATION_SCHEMA_VERSION := 1
const REPLAYABLE_COMMANDS := [
	"show_text",
	"choice",
	"start_encounter",
	"start_battle",
	"wait_for_click",
	"present_random_branch",
	"set_priest_turning",
]

var bundle := ClassicCampaignBundle.new()
var runtime_state := ClassicRuntimeState.new()
var interpreter := ScenarioInterpreter.new()
var last_result: Dictionary = {}


func load_campaign(directory: String) -> bool:
	if not bundle.load_from_directory(directory):
		last_result = {
			"status": "error",
			"message": bundle.last_error,
		}
		runtime_stopped.emit(last_result)
		return false
	var loaded_state := ClassicRuntimeState.new()
	loaded_state.configure_from_bundle(bundle)
	use_shared_campaign(bundle, loaded_state)
	return true


func use_shared_campaign(
	campaign_bundle: ClassicCampaignBundle,
	shared_state: ClassicRuntimeState
) -> void:
	bundle = campaign_bundle
	runtime_state = shared_state
	interpreter.configure(bundle, runtime_state)
	last_result = {}


func triggers_at(level_type: String, level_index: int, x: int, y: int) -> Array:
	return runtime_state.get_effective_triggers_at(
		bundle,
		level_type,
		level_index,
		x,
		y
	)


func has_trigger(trigger_id: String) -> bool:
	return (
		not runtime_state.get_action_point_override(trigger_id).is_empty()
		or not bundle.get_trigger(trigger_id).is_empty()
	)


func is_trigger_active(trigger_id: String) -> bool:
	var trigger := runtime_state.get_action_point_override(trigger_id)
	if trigger.is_empty():
		trigger = bundle.get_trigger(trigger_id)
	if trigger.is_empty():
		return false
	return bool(runtime_state.get_effective_action_point(trigger).get("active", true))


func timed_encounters() -> Array:
	var encounters: Array = []
	var encounter_ids: Array = bundle.timed_encounters_by_id.keys()
	encounter_ids.sort()
	for encounter_id: Variant in encounter_ids:
		encounters.append(runtime_state.get_effective_timed_encounter(
			bundle.get_timed_encounter(int(encounter_id))
		))
	return encounters


func get_timed_encounter(encounter_id: int) -> Dictionary:
	return runtime_state.get_effective_timed_encounter(bundle.get_timed_encounter(encounter_id))


func set_difficulty(difficulty: int) -> void:
	runtime_state.set_difficulty(difficulty)


func activate_trigger(trigger_id: String, start_slot := 0, context := {}) -> bool:
	if has_trigger(trigger_id) and not is_trigger_active(trigger_id):
		_publish({
			"status": "completed",
			"reason": "inactive-action-point",
			"triggerId": trigger_id,
		})
		return true
	if not interpreter.begin_trigger(trigger_id, start_slot, context):
		last_result = {
			"status": "error",
			"message": interpreter.last_error,
		}
		runtime_stopped.emit(last_result)
		return false
	_publish(interpreter.run_until_yield())
	return true


func continue_after_command() -> void:
	_publish(interpreter.resume_command({}))


func finish_command(response: Dictionary) -> void:
	_publish(interpreter.resume_command(response))


func finish_teleport() -> void:
	_publish(interpreter.resume_teleport())


func answer_choice(accepted: bool) -> void:
	_publish(interpreter.resume_choice(accepted))


func finish_encounter(outcome: int, encounter_state := {}) -> void:
	_publish(interpreter.resume_encounter(outcome, encounter_state))


func finish_battle(coward: bool) -> void:
	_publish(interpreter.resume_battle(coward))


func finish_selective_battle(survivor_count: int) -> void:
	_publish(interpreter.resume_selective_battle(survivor_count))


func finish_forced_battle_end() -> void:
	_publish(interpreter.resume_forced_battle_end())


func finish_forced_battle_at_slot(resume_slot: int) -> void:
	_publish(interpreter.resume_forced_battle_at_slot(resume_slot))


func finish_item_check(possessed: bool) -> void:
	_publish(interpreter.resume_item_check(possessed))


func finish_wealth_payment(paid: bool) -> void:
	_publish(interpreter.resume_wealth_payment(paid))


func finish_party_condition_check(active: bool) -> void:
	_publish(interpreter.resume_party_condition_check(active))


func finish_character_ability_check(passed: bool) -> void:
	_publish(interpreter.resume_character_ability_check(passed))


func finish_misc_branch(matched: bool) -> void:
	_publish(interpreter.resume_misc_branch(matched))


func finish_ally_check(present: bool) -> void:
	_publish(interpreter.resume_ally_check(present))


func finish_combat_monster_check(present: bool) -> void:
	_publish(interpreter.resume_combat_monster_check(present))


func finish_combat_revival(party_revived: bool) -> void:
	_publish(interpreter.resume_combat_revival(party_revived))


func finish_battle_round_macro() -> void:
	_publish(interpreter.resume_battle_round_macro())


func finish_random_branch_presentation() -> void:
	_publish(interpreter.resume_random_branch())


func finish_back_up_party() -> void:
	_publish(interpreter.resume_back_up_party())


func finish_time_mutation(response: Dictionary) -> void:
	_publish(interpreter.resume_time_mutation(response))


func finish_exploration_status(response: Dictionary) -> void:
	_publish(interpreter.resume_exploration_status(response))


func snapshot() -> Dictionary:
	return runtime_state.snapshot()


func restore(saved_state: Dictionary) -> void:
	runtime_state.restore(saved_state)


func make_continuation_snapshot() -> Dictionary:
	if last_result.is_empty() or str(last_result.get("status", "")) == "completed":
		return {
			"status": "ok",
			"snapshot": {
				"schemaVersion": CONTINUATION_SCHEMA_VERSION,
				"state": "idle",
			},
		}
	if str(last_result.get("status", "")) != "yield":
		return _continuation_error("A stopped Classic action point cannot be saved")
	var command := str(last_result.get("command", ""))
	if not REPLAYABLE_COMMANDS.has(command):
		return _continuation_error(
			"Finish the current Classic '%s' action before saving" % command
		)
	if not _pending_state_matches(command):
		return _continuation_error(
			"Classic '%s' continuation state is incomplete" % command
		)
	var execution_result := interpreter.make_execution_snapshot()
	if str(execution_result.get("status", "")) != "ok":
		return execution_result
	return {
		"status": "ok",
		"snapshot": {
			"schemaVersion": CONTINUATION_SCHEMA_VERSION,
			"state": "suspended",
			"yieldedResult": last_result.duplicate(true),
			"executionState": execution_result["snapshot"],
		},
	}


func restore_continuation(snapshot: Variant) -> Dictionary:
	var validation := validate_continuation_snapshot(snapshot)
	if str(validation.get("status", "")) != "ok":
		return validation
	var saved: Dictionary = snapshot
	if str(saved.get("state", "")) == "idle":
		interpreter.reset_execution()
		last_result.clear()
		return {"status": "ok"}
	var execution_result := interpreter.restore_execution_snapshot(saved["executionState"])
	if str(execution_result.get("status", "")) != "ok":
		return execution_result
	last_result = saved["yieldedResult"].duplicate(true)
	if not _pending_state_matches(str(last_result.get("command", ""))):
		interpreter.reset_execution()
		last_result.clear()
		return _continuation_error("Classic continuation does not match its pending action")
	return {"status": "ok"}


func replay_continuation() -> Dictionary:
	if str(last_result.get("status", "")) != "yield":
		return _continuation_error("No Classic action is waiting to resume")
	_publish(last_result.duplicate(true))
	return {"status": "ok"}


static func validate_continuation_snapshot(snapshot: Variant) -> Dictionary:
	if not (snapshot is Dictionary):
		return _continuation_error("Classic continuation is not a dictionary")
	if int(snapshot.get("schemaVersion", 0)) != CONTINUATION_SCHEMA_VERSION:
		return _continuation_error("Classic continuation schema is not supported")
	var state := str(snapshot.get("state", ""))
	if state == "idle":
		return {"status": "ok"}
	if state != "suspended":
		return _continuation_error("Classic continuation has an invalid state")
	var yielded_result: Variant = snapshot.get("yieldedResult")
	if not (yielded_result is Dictionary) \
			or str(yielded_result.get("status", "")) != "yield":
		return _continuation_error("Classic continuation has no yielded command")
	var command := str(yielded_result.get("command", ""))
	if not REPLAYABLE_COMMANDS.has(command):
		return _continuation_error("Classic continuation command '%s' is not replayable" % command)
	if not (yielded_result.get("payload", {}) is Dictionary):
		return _continuation_error("Classic continuation command has an invalid payload")
	var execution_result := ScenarioInterpreter.validate_execution_snapshot(
		snapshot.get("executionState")
	)
	if str(execution_result.get("status", "")) != "ok":
		return execution_result
	if snapshot["executionState"].get("currentTrigger", {}).is_empty():
		return _continuation_error("Classic continuation has no active action list")
	return {"status": "ok"}


func _pending_state_matches(command: String) -> bool:
	match command:
		"choice":
			return not interpreter.pending_choice.is_empty()
		"start_encounter":
			return not interpreter.pending_encounter.is_empty()
		"start_battle":
			return not interpreter.pending_battle.is_empty() \
				or not interpreter.pending_selective_battle.is_empty()
		"present_random_branch":
			return not interpreter.pending_random_branch.is_empty()
		_:
			return true


static func _continuation_error(message: String) -> Dictionary:
	return {"status": "error", "message": message}


func _publish(result: Dictionary) -> void:
	last_result = result
	match str(result.get("status", "")):
		"yield":
			command_requested.emit(
				str(result.get("command", "")),
				result.get("payload", {})
			)
		"completed":
			trigger_completed.emit(result)
		"unsupported", "error":
			runtime_stopped.emit(result)
		_:
			last_result = {
				"status": "error",
				"message": "Classic interpreter returned an invalid result",
				"result": result,
			}
			runtime_stopped.emit(last_result)
