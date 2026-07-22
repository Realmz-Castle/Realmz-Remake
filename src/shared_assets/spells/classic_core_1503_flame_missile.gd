extends "res://scripts/classic_runtime/classic_core_missile_spell.gd"


func _init() -> void:
	name = "Flame Missile"
	classic_spell_ids = [1503]
	configure_core_missile_spell(1503)
