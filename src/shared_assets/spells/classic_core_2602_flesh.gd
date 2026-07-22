extends "res://scripts/classic_runtime/classic_core_condition_cure_spell.gd"


func _init() -> void:
	name = "Flesh"
	classic_spell_ids = [2602]
	configure_core_condition_cure(2602, 26)
