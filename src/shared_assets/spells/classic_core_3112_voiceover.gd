extends "res://scripts/classic_runtime/classic_core_encounter_response_spell.gd"


func _init() -> void:
	name = "Voiceover"
	classic_spell_ids = [3112]
	configure_core_encounter_response_spell(3112)
