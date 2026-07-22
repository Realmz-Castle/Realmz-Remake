extends "res://scripts/classic_runtime/classic_core_curse_removal_spell.gd"


func _init() -> void:
	name = "Remove Item"
	classic_spell_ids = [1410]
	configure_core_curse_removal_spell(1410)
