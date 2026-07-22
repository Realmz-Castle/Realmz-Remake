extends "res://scripts/classic_runtime/classic_core_transformation_spell.gd"


func _init() -> void:
	name = "Transmute Other"
	classic_spell_ids = [3612]
	configure_core_transformation_spell(3612)
