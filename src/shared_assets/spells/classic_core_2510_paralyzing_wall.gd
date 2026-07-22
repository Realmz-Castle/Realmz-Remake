extends "res://scripts/classic_runtime/classic_core_helpless_spell.gd"


func _init() -> void:
	name = "Paralyzing Wall"
	classic_spell_class = 5
	classic_spell_ids = [2510, 3707]
	classic_spell_save_index = 5
	classic_spell_save_mode = "negate"
	in_field = false
	in_combat = true
	configure_core_helpless_spell(2510, [3707])
	classic_spell_ids = [2510, 3707]
	schools = ["Priest", "Enchanter"]
	school_levels = {"Sorcerer": 0, "Priest": 5, "Enchanter": 7}
	selection_costs = {"Sorcerer": 0, "Priest": 15, "Enchanter": 28}
