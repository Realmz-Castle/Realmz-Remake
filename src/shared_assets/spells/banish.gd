extends "res://scripts/classic_runtime/classic_core_lethal_spell.gd"


func _init() -> void:
	name = "Banish"
	classic_spell_ids = [2601]
	configure_core_lethal_spell(2601)
