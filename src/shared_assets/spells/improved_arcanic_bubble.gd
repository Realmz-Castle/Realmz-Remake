extends "res://scripts/classic_runtime/classic_core_arcanic_bubble_spell.gd"


func _init() -> void:
	name = "Improved Arcanic Bubble"
	classic_spell_ids = [1403]
	configure_core_arcanic_bubble_spell(1403)
	schools = ["Sorcerer", "Priest"]
	school_levels = {"Sorcerer": 4, "Priest": 7, "Enchanter": 0}
	selection_costs = {"Sorcerer": 10, "Priest": 28, "Enchanter": 0}
