extends "res://scripts/classic_runtime/classic_core_protection_spell.gd"


func _init() -> void:
	name = "Psi Shield"
	classic_spell_ids = [2308]
	configure_core_protection_spell(2308)
