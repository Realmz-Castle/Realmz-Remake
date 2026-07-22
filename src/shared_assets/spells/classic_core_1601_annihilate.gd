extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"


func _init() -> void:
	name = "Annihilate"
	classic_spell_ids = [1601]
	configure_core_damage_spell(1601)
