extends "res://scripts/classic_runtime/classic_core_party_condition_spell.gd"


func _init() -> void:
	name = "Classic Sentry Priest"
	description = "Sentry: Prevents wandering battles; scripted encounters still occur."
	classic_spell_ids = [2710]
	configure_core_party_condition_spell(2710)
