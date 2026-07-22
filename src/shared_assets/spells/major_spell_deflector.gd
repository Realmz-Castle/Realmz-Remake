extends "res://scripts/classic_runtime/classic_core_spell_deflector.gd"


func _init() -> void:
	name = "Major Spell Deflector"
	classic_spell_ids = [1707]
	configure_core_spell_deflector(1707)
	classic_spell_ids = [1707]
	schools = ["Sorcerer", "Priest", "Enchanter"]
	school_levels = {"Sorcerer": 7, "Priest": 6, "Enchanter": 7}
	selection_costs = {"Sorcerer": 28, "Priest": 21, "Enchanter": 28}
