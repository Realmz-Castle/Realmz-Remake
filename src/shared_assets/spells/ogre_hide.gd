extends "res://scripts/classic_runtime/classic_core_party_condition_spell.gd"


func _init() -> void:
	name = "Ogre Hide"
	description = "Ogre Hide: Reduces incoming physical attack damage by 5, to a minimum of 1."
	classic_spell_ids = [3107]
	configure_core_party_condition_spell(3107)
