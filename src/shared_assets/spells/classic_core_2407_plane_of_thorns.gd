extends "res://scripts/classic_runtime/classic_core_queued_area_spell.gd"


func _init() -> void:
	name = "Plane of Thorns"
	classic_spell_ids = [2407]
	configure_core_queued_area_spell(2407, 7)
