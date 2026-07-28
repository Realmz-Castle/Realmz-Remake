class_name ScenarioCharacterHandler
extends ClassicOpcodeHandler


func _init() -> void:
	configure(
		"core.character",
		PackedInt32Array([
			11, 14, 15, 16, 17, 18, 30, 31, 40, 43, 50, 52, 53, 68, 69, 81,
			87, 88, 89, 90, 102, 105, 108,
		])
	)
