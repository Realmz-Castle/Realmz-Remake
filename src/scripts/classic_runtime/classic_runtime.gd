class_name ClassicRuntime
extends Node

signal command_requested(command: String, payload: Dictionary)
signal trigger_completed(result: Dictionary)
signal runtime_stopped(result: Dictionary)

var bundle := ClassicCampaignBundle.new()
var runtime_state := ClassicRuntimeState.new()
var interpreter := ClassicActionInterpreter.new()
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
	_publish(interpreter.run_until_yield())


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


func finish_ally_check(present: bool) -> void:
	_publish(interpreter.resume_ally_check(present))


func finish_combat_monster_check(present: bool) -> void:
	_publish(interpreter.resume_combat_monster_check(present))


func finish_battle_round_macro() -> void:
	_publish(interpreter.resume_battle_round_macro())


func finish_random_branch_presentation() -> void:
	_publish(interpreter.resume_random_branch())


func snapshot() -> Dictionary:
	return runtime_state.snapshot()


func restore(saved_state: Dictionary) -> void:
	runtime_state.restore(saved_state)


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
