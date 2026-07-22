extends "res://scripts/classic_runtime/classic_core_silence_spell.gd"


func _init() -> void:
	name = "Silence"
	classic_spell_ids = [2211, 3110]
	configure_core_silence_spell(2211)
	name = "Silence"
	classic_spell_ids = [2211, 3110]
	schools = ["Sorcerer", "Priest", "Enchanter"]
	school_levels = {"Sorcerer": 4, "Priest": 2, "Enchanter": 1}
	selection_costs = {"Sorcerer": 10, "Priest": 3, "Enchanter": 1}
