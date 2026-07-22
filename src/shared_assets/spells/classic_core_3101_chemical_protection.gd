extends "res://scripts/classic_runtime/classic_core_protection_spell.gd"


func _init() -> void:
	name = "Chemical Protection"
	classic_spell_ids = [3101]
	configure_core_protection_spell(3101)
