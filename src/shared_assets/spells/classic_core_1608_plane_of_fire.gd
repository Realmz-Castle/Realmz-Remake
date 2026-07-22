extends "res://scripts/classic_runtime/classic_core_queued_area_spell.gd"


func _init() -> void:
	name = "Plane of Fire"
	classic_spell_ids = [1608]
	configure_core_queued_area_spell(1608, 1)
