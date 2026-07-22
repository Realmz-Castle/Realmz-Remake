extends "res://scripts/classic_runtime/classic_core_curse_removal_spell.gd"


func _init() -> void:
	name = "Remove Items"
	classic_spell_ids = [2309]
	configure_core_curse_removal_spell(2309)
