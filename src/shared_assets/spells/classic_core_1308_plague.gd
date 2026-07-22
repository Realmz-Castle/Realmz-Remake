extends "res://scripts/classic_runtime/classic_core_queued_area_spell.gd"


func _init() -> void:
	name = "Plague"
	classic_spell_ids = [1308, 2512]
	configure_core_queued_area_spell(1308, 7)
	classic_spell_ids = [1308, 2512]
	schools = ["Sorcerer", "Priest"]
	school_levels = {"Sorcerer": 3, "Priest": 5, "Enchanter": 0}
	selection_costs = {"Sorcerer": 6, "Priest": 15, "Enchanter": 0}
