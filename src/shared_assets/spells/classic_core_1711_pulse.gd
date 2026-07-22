extends "res://scripts/classic_runtime/classic_core_queued_area_spell.gd"


func _init() -> void:
	name = "Pulse"
	classic_spell_ids = [1711]
	configure_core_queued_area_spell(1711, 5)
