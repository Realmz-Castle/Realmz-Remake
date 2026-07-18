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
	runtime_state = ClassicRuntimeState.new()
	runtime_state.configure_from_bundle(bundle)
	interpreter.configure(bundle, runtime_state)
	last_result = {}
	return true


func triggers_at(level_type: String, level_index: int, x: int, y: int) -> Array:
	var triggers: Array = []
	var included_ids: Dictionary = {}
	for trigger_value: Variant in bundle.get_triggers_at(level_type, level_index, x, y):
		if not (trigger_value is Dictionary):
			continue
		var trigger := runtime_state.get_effective_action_point(trigger_value)
		triggers.append(trigger)
		included_ids[str(trigger.get("id", ""))] = true
	for override_value: Variant in runtime_state.action_point_overrides.values():
		if not (override_value is Dictionary):
			continue
		var trigger_id := str(override_value.get("id", ""))
		var coordinate: Variant = override_value.get("coordinate")
		if included_ids.has(trigger_id) or not (coordinate is Dictionary):
			continue
		if (
			str(override_value.get("levelType", "")) == level_type
			and int(override_value.get("levelIndex", -1)) == level_index
			and int(coordinate.get("x", -1)) == x
			and int(coordinate.get("y", -1)) == y
		):
			triggers.append(runtime_state.get_effective_action_point(override_value))
	return triggers


func activate_trigger(trigger_id: String, start_slot := 0) -> bool:
	if not interpreter.begin_trigger(trigger_id, start_slot):
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


func answer_choice(accepted: bool) -> void:
	_publish(interpreter.resume_choice(accepted))


func finish_encounter(outcome: int) -> void:
	_publish(interpreter.resume_encounter(outcome))


func finish_battle(coward: bool) -> void:
	_publish(interpreter.resume_battle(coward))


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
