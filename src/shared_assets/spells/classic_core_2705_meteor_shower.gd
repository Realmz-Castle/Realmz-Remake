extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"


func _init() -> void:
	name = "Meteor Shower"
	classic_spell_ids = [2705]
	configure_core_damage_spell(2705)
