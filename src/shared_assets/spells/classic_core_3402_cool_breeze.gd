extends "res://scripts/classic_runtime/classic_core_protection_spell.gd"


func _init() -> void:
	name = "Cool Breeze"
	classic_spell_ids = [3402]
	configure_core_protection_spell(3402)
