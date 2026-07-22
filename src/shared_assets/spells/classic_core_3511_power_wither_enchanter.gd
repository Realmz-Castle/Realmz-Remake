extends "res://scripts/classic_runtime/classic_core_energy_drain_spell.gd"


func _init() -> void:
	classic_spell_ids = [3511]
	configure_core_energy_drain_spell(3511)
	name = "Classic Power Wither Enchanter"
	schools = []
	school_levels = {}
	selection_costs = {}
