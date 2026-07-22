extends "res://scripts/classic_runtime/classic_core_healing_spell.gd"


func _init() -> void:
	name = "Heal Small Wounds"
	classic_spell_ids = [1506, 2105]
	configure_core_healing_spell(1506)
	classic_spell_ids = [1506, 2105]
	schools = ["Sorcerer", "Priest"]
	school_levels = {"Sorcerer": 5, "Priest": 1, "Enchanter": 0}
	selection_costs = {"Sorcerer": 15, "Priest": 1, "Enchanter": 0}
