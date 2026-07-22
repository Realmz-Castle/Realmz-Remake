extends "res://scripts/classic_runtime/classic_core_lethal_spell.gd"


func _init() -> void:
	name = "Death"
	classic_spell_ids = [2701]
	configure_core_lethal_spell(2701)
