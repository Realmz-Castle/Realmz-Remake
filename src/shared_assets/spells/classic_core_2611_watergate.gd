extends "res://scripts/classic_runtime/classic_core_encounter_response_spell.gd"


func _init() -> void:
	name = "Watergate"
	classic_spell_ids = [2611]
	configure_core_encounter_response_spell(2611)
