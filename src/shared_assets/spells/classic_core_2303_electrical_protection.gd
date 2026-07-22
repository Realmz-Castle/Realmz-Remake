extends "res://scripts/classic_runtime/classic_core_protection_spell.gd"


func _init() -> void:
	name = "Electrical Protection"
	classic_spell_ids = [2303]
	configure_core_protection_spell(2303)
