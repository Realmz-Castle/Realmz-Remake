extends "res://scripts/classic_runtime/classic_core_protection_from_foe_spell.gd"


func _init() -> void:
	name = "Protection from Foe"
	classic_spell_ids = [1210]
	configure_core_protection_from_foe_spell(1210)
