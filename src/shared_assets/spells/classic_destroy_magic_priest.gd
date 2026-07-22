extends "res://scripts/classic_runtime/classic_core_dispel_spell.gd"


func _init() -> void:
	name = "Classic Destroy Magic Priest"
	classic_spell_ids = [2302]
	configure_core_dispel_spell(2302)
