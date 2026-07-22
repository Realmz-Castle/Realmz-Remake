extends "res://scripts/classic_runtime/classic_core_encounter_response_spell.gd"


func _init() -> void:
	name = "Classic Teleport Party Enchanter"
	classic_spell_ids = [3711]
	configure_core_encounter_response_spell(3711, [], false)
