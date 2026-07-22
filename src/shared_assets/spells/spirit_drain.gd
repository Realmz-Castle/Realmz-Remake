extends "res://scripts/classic_runtime/classic_core_energy_drain_spell.gd"


func _init() -> void:
	name = "Spirit Drain"
	classic_spell_ids = [2711]
	configure_core_energy_drain_spell(2711)
	schools = ["Priest"]
	school_levels = {"Sorcerer": 0, "Priest": 7, "Enchanter": 0}
	selection_costs = {"Sorcerer": 0, "Priest": 28, "Enchanter": 0}
