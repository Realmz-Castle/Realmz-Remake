class_name ScenarioInventoryHandler
extends ClassicOpcodeHandler


func _init() -> void:
	configure(
		"core.inventory",
		PackedInt32Array([6, 10, 21, 22, 32, 33, 36, 49, 51, 60, 65, 73, 91])
	)
