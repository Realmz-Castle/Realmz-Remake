extends "res://scripts/classic_runtime/classic_core_projectile_protection_spell.gd"


func _init() -> void:
	name = "Missile Screen"
	classic_spell_ids = [3508]
	configure_core_projectile_protection_spell(3508)
	classic_spell_ids = [3508]
	name = "Missile Screen"
	schools = ["Enchanter"]
	school_levels = {"Sorcerer": 0, "Priest": 0, "Enchanter": 5}
	selection_costs = {"Sorcerer": 0, "Priest": 0, "Enchanter": 15}
