extends "res://scripts/classic_runtime/classic_core_hindered_attack_spell.gd"


func _init() -> void:
	name = "Itching Skin"
	classic_spell_ids = [1207, 2209]
	configure_core_hindered_attack_spell(1207)
	classic_spell_ids = [1207, 2209]
	schools = ["Sorcerer", "Priest"]
	school_levels = {"Sorcerer": 2, "Priest": 2, "Enchanter": 0}
	selection_costs = {"Sorcerer": 3, "Priest": 3, "Enchanter": 0}
