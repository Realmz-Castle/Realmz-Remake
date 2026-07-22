extends "res://scripts/classic_runtime/classic_core_condition_cure_spell.gd"


func _init() -> void:
	name = "Heal Blindness"
	classic_spell_ids = [2204, 3206]
	configure_core_condition_cure(2204, 27)
	classic_spell_ids = [2204, 3206]
	schools = ["Priest", "Enchanter"]
	school_levels = {"Sorcerer": 0, "Priest": 2, "Enchanter": 2}
	selection_costs = {"Sorcerer": 0, "Priest": 3, "Enchanter": 3}
