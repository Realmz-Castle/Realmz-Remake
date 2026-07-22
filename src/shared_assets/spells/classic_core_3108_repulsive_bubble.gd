extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"


func _init() -> void:
	name = "Repulsive Bubble"
	classic_spell_ids = [3108]
	configure_core_damage_spell(3108)
