extends "res://scripts/classic_runtime/classic_core_encounter_response_spell.gd"


func _init() -> void:
	name = "Splinters"
	classic_spell_ids = [3111]
	configure_core_encounter_response_spell(3111)
