extends "res://scripts/classic_runtime/classic_core_lethal_spell.gd"


func _init() -> void:
	name = "Poison Cloud"
	classic_spell_ids = [3609]
	configure_core_lethal_spell(3609)
