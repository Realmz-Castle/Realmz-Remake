extends "res://scripts/classic_runtime/classic_core_queued_area_spell.gd"


func _init() -> void:
	name = "Fire Storm"
	classic_spell_ids = [3607]
	configure_core_queued_area_spell(3607, 1)
