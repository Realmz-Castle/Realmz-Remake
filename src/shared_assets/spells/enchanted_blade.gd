extends "res://scripts/classic_runtime/classic_core_attack_bonus_spell.gd"


func _init() -> void:
	name = "Enchanted Blade"
	classic_spell_ids = [1102]
	configure_core_attack_bonus_spell(1102)
	schools = ["Sorcerer", "Enchanter"]
	school_levels = {"Sorcerer": 1, "Priest": 0, "Enchanter": 1}
	selection_costs = {"Sorcerer": 1, "Priest": 0, "Enchanter": 1}
