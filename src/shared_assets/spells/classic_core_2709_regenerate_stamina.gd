extends "res://scripts/classic_runtime/classic_core_regeneration_spell.gd"


func _init() -> void:
	name = "Regenerate Stamina"
	classic_spell_ids = [2709]
	configure_core_regeneration_spell(2709)
