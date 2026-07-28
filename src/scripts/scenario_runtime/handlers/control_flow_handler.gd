class_name ScenarioControlFlowHandler
extends ClassicOpcodeHandler


func _init() -> void:
	configure(
		"core.control-flow",
		PackedInt32Array([
			-23, -14, 0, 7, 8, 24, 25, 34, 35, 38, 39, 41, 42, 44, 46, 55,
			56, 58, 64, 67, 72, 76, 77, 78, 84, 85, 86, 98, 99, 107, 111, 112,
		])
	)
