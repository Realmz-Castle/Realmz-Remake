extends "res://scripts/classic_runtime/classic_core_encounter_response_spell.gd"


func _init() -> void:
	name = "Leap"
	classic_spell_ids = [1107]
	configure_core_encounter_response_spell(1107)
