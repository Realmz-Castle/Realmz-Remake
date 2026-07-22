extends "res://scripts/classic_runtime/classic_core_protection_spell.gd"


func _init() -> void:
	name = "Protection from Heat"
	classic_spell_ids = [2108]
	configure_core_protection_spell(2108)
