extends "res://scripts/classic_runtime/classic_core_protection_spell.gd"


func _init() -> void:
	name = "Protection from Cold"
	classic_spell_ids = [2107]
	configure_core_protection_spell(2107)
