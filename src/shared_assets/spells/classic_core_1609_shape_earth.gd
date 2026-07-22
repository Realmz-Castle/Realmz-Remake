extends "res://scripts/classic_runtime/classic_core_encounter_response_spell.gd"


func _init() -> void:
	name = "Shape Earth"
	classic_spell_ids = [1609, 3709]
	configure_core_encounter_response_spell(1609, [3709])
