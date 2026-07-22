extends "res://scripts/classic_runtime/classic_core_regeneration_spell.gd"


func _init() -> void:
	name = "Multi Regenerate Stamina"
	classic_spell_ids = [3706]
	configure_core_regeneration_spell(3706)
