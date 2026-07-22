extends "res://scripts/classic_runtime/classic_core_queued_area_spell.gd"


func _init() -> void:
	name = "Plane of Force"
	classic_spell_ids = [1309]
	configure_core_queued_area_spell(1309, "Orb", 6)
