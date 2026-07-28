class_name ScenarioEncounterHandler
extends ClassicOpcodeHandler


func _init() -> void:
	configure("core.encounters", PackedInt32Array([3, 4, 5]))


func execute_on_runtime(instruction: Dictionary, runtime: Object) -> Dictionary:
	var code := int(instruction.get("code", 0))
	var record_id := int(instruction.get("id", 0))
	match code:
		3:
			return _invoke(
				runtime,
				"_execute_choice",
				[record_id, bool(runtime.gosub_active)]
			)
		4:
			return _invoke(runtime, "_execute_encounter", ["simple", record_id])
		5:
			return _invoke(runtime, "_execute_encounter", ["complex", record_id])
	return _unsupported(instruction)
