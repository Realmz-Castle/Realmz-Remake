extends "res://scripts/classic_runtime/classic_core_attack_bonus_spell.gd"


func _init() -> void:
	name = "Enchanted Blades"
	classic_spell_ids = [3305]
	configure_core_attack_bonus_spell(3305)
	schools = ["Priest", "Enchanter"]
	school_levels = {"Sorcerer": 0, "Priest": 5, "Enchanter": 3}
	selection_costs = {"Sorcerer": 0, "Priest": 15, "Enchanter": 6}
