extends "res://scripts/classic_runtime/classic_core_queued_area_spell.gd"


func _init() -> void:
	classic_spell_ids = [3310]
	configure_core_queued_area_spell(3310, 7)
	name = "Classic Plane of Force Enchanter"
