extends "res://scripts/classic_runtime/classic_core_dispel_spell.gd"


func _init() -> void:
	name = "Classic Destroy Magic Enchanter"
	classic_spell_ids = [3503]
	configure_core_dispel_spell(3503)
