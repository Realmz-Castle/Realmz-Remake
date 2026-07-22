extends "res://scripts/classic_runtime/classic_core_arcanic_bubble_spell.gd"


func _init() -> void:
	name = "Arcanic Bubble"
	classic_spell_ids = [1301]
	configure_core_arcanic_bubble_spell(1301)
	schools = ["Sorcerer", "Enchanter"]
	school_levels = {"Sorcerer": 3, "Priest": 0, "Enchanter": 3}
	selection_costs = {"Sorcerer": 6, "Priest": 0, "Enchanter": 6}
