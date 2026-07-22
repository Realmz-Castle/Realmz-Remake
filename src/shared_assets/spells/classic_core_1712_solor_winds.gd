extends "res://scripts/classic_runtime/classic_core_queued_area_spell.gd"


func _init() -> void:
	name = "Solor Winds"
	classic_spell_ids = [1712]
	configure_core_queued_area_spell(1712, 1)
