extends "res://scripts/classic_runtime/classic_core_encounter_response_spell.gd"


func _init() -> void:
	name = "Fantastic Wings"
	classic_spell_ids = [1305, 3404]
	configure_core_encounter_response_spell(1305, [3404])
