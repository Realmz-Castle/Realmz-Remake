extends "res://scripts/classic_runtime/classic_core_protection_spell.gd"


func _init() -> void:
	name = "Warmth"
	classic_spell_ids = [3412]
	configure_core_protection_spell(3412)
