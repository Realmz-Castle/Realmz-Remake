extends "res://scripts/classic_runtime/classic_core_encounter_response_spell.gd"


func _init() -> void:
	name = "Superfly"
	classic_spell_ids = [1112]
	configure_core_encounter_response_spell(1112)
