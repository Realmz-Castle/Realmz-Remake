extends "res://scripts/classic_runtime/classic_core_revive_spell.gd"


func _init() -> void:
	name = "Revive Dead"
	classic_spell_ids = [2606, 3708]
	configure_core_revive_spell(2606)
	classic_spell_ids = [2606, 3708]
	schools = ["Priest", "Enchanter"]
	school_levels = {"Sorcerer": 0, "Priest": 6, "Enchanter": 7}
	selection_costs = {"Sorcerer": 0, "Priest": 21, "Enchanter": 28}
