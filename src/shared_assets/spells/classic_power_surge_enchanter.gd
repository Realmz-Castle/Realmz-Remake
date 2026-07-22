extends "res://scripts/classic_runtime/classic_core_spell_point_surge_spell.gd"


func _init() -> void:
	name = "Classic Power Surge Enchanter"
	classic_spell_ids = [3312]
	configure_core_spell_point_surge(3312)
