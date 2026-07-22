extends "res://scripts/classic_runtime/classic_core_condition_cure_spell.gd"


func _init() -> void:
	name = "Heal Disease"
	classic_spell_ids = [2205]
	configure_core_condition_cure(2205, 28)
