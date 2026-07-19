class_name ClassicRuntimeHost
extends Node

signal command_started(command: String, payload: Dictionary)
signal command_finished(command: String, response: Dictionary)
signal playthrough_completed(result: Dictionary)
signal playthrough_stopped(result: Dictionary)

var runtime: ClassicRuntime
var command_adapter: Object
var active := false


func _init() -> void:
	runtime = ClassicRuntime.new()
	add_child(runtime)
	runtime.command_requested.connect(_on_command_requested)
	runtime.trigger_completed.connect(_on_trigger_completed)
	runtime.runtime_stopped.connect(_on_runtime_stopped)


func configure(adapter: Object) -> void:
	command_adapter = adapter


func load_campaign(directory: String) -> bool:
	active = false
	return runtime.load_campaign(directory)


func start_trigger(trigger_id: String, start_slot := 0) -> bool:
	if command_adapter == null or not command_adapter.has_method("execute_command"):
		_stop_with_error("ClassicRuntimeHost requires an execute_command adapter")
		return false
	active = true
	if not runtime.activate_trigger(trigger_id, start_slot):
		active = false
		return false
	return true


func _on_command_requested(command: String, payload: Dictionary) -> void:
	if not active:
		return
	command_started.emit(command, payload)
	var response_value: Variant = await command_adapter.execute_command(command, payload)
	if not active:
		return
	var response: Dictionary = response_value if response_value is Dictionary else {}
	command_finished.emit(command, response)
	if str(response.get("status", "")) == "error":
		_stop_with_error(str(response.get("message", "Classic command adapter failed")), command)
		return
	_resume_after_command(command, payload, response)


func _resume_after_command(command: String, payload: Dictionary, response: Dictionary) -> void:
	match command:
		"choice":
			if not response.has("accepted"):
				_stop_with_error("Choice adapter response is missing 'accepted'", command)
				return
			runtime.answer_choice(bool(response["accepted"]))
		"start_encounter":
			if not response.has("outcome"):
				_stop_with_error("Encounter adapter response is missing 'outcome'", command)
				return
			runtime.finish_encounter(int(response["outcome"]), response)
		"start_battle":
			if bool(payload.get("outcomeBranch", false)):
				if not response.has("coward"):
					_stop_with_error("Battle adapter response is missing 'coward'", command)
					return
				runtime.finish_battle(bool(response["coward"]))
			else:
				runtime.continue_after_command()
		"show_text", "play_sound", "give_treasure", "give_map", "set_map_tile", \
		"set_trigger_percent", "teleport", "set_view_direction", \
		"set_view_mode", "set_map_darkness", "give_battle_loot", \
		"apply_coward_penalty", "eliminate_encounter_option":
			runtime.continue_after_command()
		_:
			_stop_with_error("No ClassicRuntimeHost continuation rule for '%s'" % command, command)


func _on_trigger_completed(result: Dictionary) -> void:
	if not active:
		return
	active = false
	playthrough_completed.emit(result)


func _on_runtime_stopped(result: Dictionary) -> void:
	if not active:
		return
	active = false
	playthrough_stopped.emit(result)


func _stop_with_error(message: String, command := "") -> void:
	active = false
	var result := {
		"status": "error",
		"message": message,
	}
	if not command.is_empty():
		result["command"] = command
	playthrough_stopped.emit(result)
