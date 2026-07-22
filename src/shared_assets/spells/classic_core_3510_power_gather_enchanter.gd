extends "res://scripts/classic_runtime/classic_core_power_gather_spell.gd"


func _init() -> void:
	classic_spell_ids = [3510]
	configure_core_power_gather_spell(3510)
	name = "Classic Power Gather Enchanter"
	schools = []
	school_levels = {}
	selection_costs = {}
