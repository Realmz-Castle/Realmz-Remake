extends "res://scripts/classic_runtime/classic_core_shield_from_hits_spell.gd"


func _init() -> void:
	name = "Major Vorpal Plate"
	classic_spell_ids = [3406]
	configure_core_shield_from_hits_spell(3406)
	classic_spell_ids = [3406]
	name = "Major Vorpal Plate"
	schools = ["Enchanter"]
	school_levels = {"Sorcerer": 0, "Priest": 0, "Enchanter": 4}
	selection_costs = {"Sorcerer": 0, "Priest": 0, "Enchanter": 10}
