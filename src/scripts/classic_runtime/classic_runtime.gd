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
	return bundle.get_triggers_at(level_type, level_index, x, y)


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
