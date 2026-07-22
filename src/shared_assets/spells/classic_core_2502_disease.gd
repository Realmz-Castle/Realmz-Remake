extends "res://scripts/classic_runtime/classic_core_disease_spell.gd"


func _init() -> void:
	name = "Disease"
	classic_spell_ids = [2502]
	configure_core_disease_spell(2502)
