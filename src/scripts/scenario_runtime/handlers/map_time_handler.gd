class_name ScenarioMapTimeHandler
extends ClassicOpcodeHandler


func _init() -> void:
	configure(
		"core.map-time",
		PackedInt32Array([
			12, 13, 20, 23, 28, 29, 37, 45, 54, 57, 61, 63, 66, 70, 92, 93,
			94, 95, 96, 97, 101, 103, 104, 106,
		])
	)
