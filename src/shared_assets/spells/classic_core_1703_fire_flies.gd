extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"


func _init() -> void:
	name = "Fire Flies"
	classic_spell_ids = [1703]
	configure_core_damage_spell(1703)
