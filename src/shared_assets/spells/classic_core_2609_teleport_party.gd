extends "res://scripts/classic_runtime/classic_core_encounter_response_spell.gd"


func _init() -> void:
	name = "Teleport Party"
	classic_spell_ids = [2609]
	configure_core_encounter_response_spell(2609)
