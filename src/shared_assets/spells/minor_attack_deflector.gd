extends "res://scripts/classic_runtime/classic_core_attack_deflector.gd"


func _init() -> void:
	name = "Minor Attack Deflector"
	classic_spell_ids = [1406, 2307]
	configure_core_attack_deflector(1406)
	classic_spell_ids = [1406, 2307]
	schools = ["Sorcerer", "Priest", "Enchanter"]
	school_levels = {"Sorcerer": 4, "Priest": 3, "Enchanter": 4}
	selection_costs = {"Sorcerer": 10, "Priest": 6, "Enchanter": 10}
