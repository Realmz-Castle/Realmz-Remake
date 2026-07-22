extends "res://scripts/classic_runtime/classic_core_disease_spell.gd"


func _init() -> void:
	name = "Festering Wounds"
	classic_spell_ids = [2304]
	classic_spell_save_index = 4
	classic_spell_save_mode = "negate"
	configure_core_disease_spell(2304)
