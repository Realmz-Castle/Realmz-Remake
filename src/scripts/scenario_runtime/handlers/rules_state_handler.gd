class_name ScenarioRulesStateHandler
extends ClassicOpcodeHandler


func _init() -> void:
	configure("core.rules-state", PackedInt32Array([47]))


func execute_on_runtime(instruction: Dictionary, runtime: Object) -> Dictionary:
	var record_id := int(instruction.get("id", 0))
	runtime.runtime_state.set_quest_flag(record_id)
	return _invoke(runtime, "_continue_result")
