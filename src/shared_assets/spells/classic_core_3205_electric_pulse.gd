extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"


func _init() -> void:
	name = "Electric Pulse"
	classic_spell_ids = [3205]
	configure_core_damage_spell(3205)
