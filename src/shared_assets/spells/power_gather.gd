extends "res://scripts/classic_runtime/classic_core_power_gather_spell.gd"


func _init() -> void:
	name = "Power Gather"
	classic_spell_ids = [1510]
	configure_core_power_gather_spell(1510)
	schools = ["Sorcerer", "Enchanter"]
	school_levels = {"Sorcerer": 5, "Priest": 0, "Enchanter": 5}
	selection_costs = {"Sorcerer": 15, "Priest": 0, "Enchanter": 15}
