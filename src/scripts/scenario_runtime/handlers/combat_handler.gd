class_name ScenarioCombatHandler
extends ClassicOpcodeHandler


func _init() -> void:
	configure(
		"core.combat",
		PackedInt32Array([
			2, 48, 82, 83, 100, 119, 120, 121, 122, 123, 124, 125, 126, 127,
		])
	)
