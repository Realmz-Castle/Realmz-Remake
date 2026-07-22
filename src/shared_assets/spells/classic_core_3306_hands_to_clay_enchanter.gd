extends "res://scripts/classic_runtime/classic_core_encounter_response_spell.gd"


func _init() -> void:
	name = "Classic Hands to Clay Enchanter"
	classic_spell_ids = [3306]
	configure_core_encounter_response_spell(3306, [], false)
