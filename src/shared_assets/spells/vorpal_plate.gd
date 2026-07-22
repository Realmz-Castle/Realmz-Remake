extends "res://scripts/classic_runtime/classic_core_shield_from_hits_spell.gd"


func _init() -> void:
	name = "Vorpal Plate"
	classic_spell_ids = [2112]
	configure_core_shield_from_hits_spell(2112)
	classic_spell_ids = [2112]
	name = "Vorpal Plate"
	schools = ["Priest"]
	school_levels = {"Sorcerer": 0, "Priest": 1, "Enchanter": 0}
	selection_costs = {"Sorcerer": 0, "Priest": 1, "Enchanter": 0}
