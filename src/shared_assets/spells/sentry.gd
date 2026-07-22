extends "res://scripts/classic_runtime/classic_core_party_condition_spell.gd"


func _init() -> void:
	name = "Sentry"
	description = "Sentry: Prevents wandering battles; scripted encounters still occur."
	classic_spell_ids = [3611]
	configure_core_party_condition_spell(3611)
