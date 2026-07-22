extends "res://scripts/classic_runtime/classic_core_hindered_defense_spell.gd"


func _init() -> void:
	name = "Shrink Foe"
	classic_spell_ids = [3109]
	configure_core_hindered_defense_spell(3109)
	classic_spell_ids = [3109]
	schools = ["Enchanter"]
	school_levels = {"Sorcerer": 0, "Priest": 0, "Enchanter": 1}
	selection_costs = {"Sorcerer": 0, "Priest": 0, "Enchanter": 1}
