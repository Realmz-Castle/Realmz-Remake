extends "res://scripts/classic_runtime/classic_core_attack_deflector.gd"


func _init() -> void:
	name = "Major Attack Deflector"
	classic_spell_ids = [1606]
	configure_core_attack_deflector(1606)
	classic_spell_ids = [1606]
	schools = ["Sorcerer", "Priest", "Enchanter"]
	school_levels = {"Sorcerer": 6, "Priest": 5, "Enchanter": 6}
	selection_costs = {"Sorcerer": 21, "Priest": 15, "Enchanter": 21}
