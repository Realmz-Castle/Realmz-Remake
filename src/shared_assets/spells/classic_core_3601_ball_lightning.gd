extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"


func _init() -> void:
	name = "Ball Lightning"
	classic_spell_ids = [3601]
	configure_core_damage_spell(3601)
