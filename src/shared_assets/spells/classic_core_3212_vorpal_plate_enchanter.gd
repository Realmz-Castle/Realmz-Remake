extends "res://scripts/classic_runtime/classic_core_shield_from_hits_spell.gd"


func _init() -> void:
	classic_spell_ids = [3212]
	configure_core_shield_from_hits_spell(3212)
	classic_spell_ids = [3212]
	name = "Classic Vorpal Plate Enchanter"
	schools = []
	school_levels = {}
	selection_costs = {}
