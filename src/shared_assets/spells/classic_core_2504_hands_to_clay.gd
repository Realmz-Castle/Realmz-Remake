extends "res://scripts/classic_runtime/classic_core_encounter_response_spell.gd"


func _init() -> void:
	name = "Hands to Clay"
	classic_spell_ids = [2504]
	configure_core_encounter_response_spell(2504)
