extends "res://scripts/classic_runtime/classic_core_party_condition_spell.gd"


func _init() -> void:
	name = "Hover"
	description = "Hover: Allows the party to float over a pit or chasm."
	classic_spell_ids = [1205]
	configure_core_party_condition_spell(1205)
