extends "res://scripts/classic_runtime/classic_core_condition_cure_spell.gd"


func _init() -> void:
	name = "Heal Poison"
	classic_spell_ids = [2206]
	configure_core_condition_cure(2206, 9)
