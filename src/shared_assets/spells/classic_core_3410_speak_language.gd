extends "res://scripts/classic_runtime/classic_core_encounter_response_spell.gd"


func _init() -> void:
	name = "Speak Language"
	classic_spell_ids = [3410]
	configure_core_encounter_response_spell(3410)
