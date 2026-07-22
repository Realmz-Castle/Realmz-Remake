extends "res://scripts/classic_runtime/classic_core_attack_bonus_spell.gd"


func _init() -> void:
	classic_spell_ids = [2503]
	configure_core_attack_bonus_spell(2503)
	name = "Classic Enchanted Blades Priest"
	schools = []
	school_levels = {}
	selection_costs = {}
