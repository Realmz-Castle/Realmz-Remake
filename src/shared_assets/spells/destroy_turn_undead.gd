extends "res://scripts/classic_runtime/classic_core_undead_turning_spell.gd"


func _init() -> void:
	name = "Destroy / Turn Undead"
	classic_spell_ids = [3504]
	configure_core_undead_turning_spell(3504)
