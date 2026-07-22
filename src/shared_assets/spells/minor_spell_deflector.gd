extends "res://scripts/classic_runtime/classic_core_spell_deflector.gd"


func _init() -> void:
	name = "Minor Spell Deflector"
	classic_spell_ids = [1508]
	configure_core_spell_deflector(1508)
	classic_spell_ids = [1508]
	schools = ["Sorcerer", "Priest", "Enchanter"]
	school_levels = {"Sorcerer": 5, "Priest": 4, "Enchanter": 5}
	selection_costs = {"Sorcerer": 15, "Priest": 10, "Enchanter": 15}
