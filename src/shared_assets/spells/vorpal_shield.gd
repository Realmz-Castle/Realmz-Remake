extends "res://scripts/classic_runtime/classic_core_party_condition_spell.gd"


func _init() -> void:
	name = "Vorpal Shield"
	description = "Vorpal Shield: Reduces incoming physical attack damage by 5, to a minimum of 1."
	classic_spell_ids = [2312]
	configure_core_party_condition_spell(2312)
