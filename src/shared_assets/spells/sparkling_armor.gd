extends "res://scripts/classic_runtime/classic_core_shield_from_hits_spell.gd"


func _init() -> void:
	name = "Sparkling Armor"
	classic_spell_ids = [1111]
	configure_core_shield_from_hits_spell(1111)
	classic_spell_ids = [1111]
	name = "Sparkling Armor"
	schools = ["Sorcerer"]
	school_levels = {"Sorcerer": 1, "Priest": 0, "Enchanter": 0}
	selection_costs = {"Sorcerer": 1, "Priest": 0, "Enchanter": 0}
