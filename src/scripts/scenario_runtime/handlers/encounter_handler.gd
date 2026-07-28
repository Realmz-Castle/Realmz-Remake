class_name ScenarioEncounterHandler
extends ClassicOpcodeHandler


func _init() -> void:
	configure("core.encounters", PackedInt32Array([3, 4, 5]))
