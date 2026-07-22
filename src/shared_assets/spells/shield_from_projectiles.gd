extends "res://scripts/classic_runtime/classic_core_projectile_protection_spell.gd"


func _init() -> void:
	name = "Shield from Projectiles"
	classic_spell_ids = [2210]
	configure_core_projectile_protection_spell(2210)
	classic_spell_ids = [2210]
	name = "Shield from Projectiles"
	schools = ["Priest"]
	school_levels = {"Sorcerer": 0, "Priest": 2, "Enchanter": 0}
	selection_costs = {"Sorcerer": 0, "Priest": 3, "Enchanter": 0}
