extends "res://scripts/classic_runtime/classic_core_party_condition_spell.gd"


func _init() -> void:
	name = "Waterworld"
	description = "Waterworld: Gives the party the Waterworld condition for 3-5 rounds per power."
	classic_spell_ids = [1312]
	configure_core_party_condition_spell(1312)
