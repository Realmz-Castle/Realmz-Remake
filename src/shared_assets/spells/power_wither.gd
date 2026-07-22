extends "res://scripts/classic_runtime/classic_core_energy_drain_spell.gd"


func _init() -> void:
	name = "Power Wither"
	classic_spell_ids = [1511]
	configure_core_energy_drain_spell(1511)
	schools = ["Sorcerer", "Enchanter"]
	school_levels = {"Sorcerer": 5, "Priest": 0, "Enchanter": 5}
	selection_costs = {"Sorcerer": 15, "Priest": 0, "Enchanter": 15}
