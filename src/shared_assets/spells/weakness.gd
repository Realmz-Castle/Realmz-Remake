extends "res://scripts/classic_runtime/classic_core_spell_point_drain_spell.gd"


func _init() -> void:
	name = "Weakness"
	classic_spell_ids = [2612]
	configure_core_spell_point_drain(2612, true)
