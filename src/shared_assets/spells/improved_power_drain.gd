extends "res://scripts/classic_runtime/classic_core_spell_point_drain_spell.gd"


func _init() -> void:
	name = "Improved Power Drain"
	classic_spell_ids = [2703]
	configure_core_spell_point_drain(2703)
