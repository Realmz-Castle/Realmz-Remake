extends "res://scripts/classic_runtime/classic_core_petrification_spell.gd"


func _init() -> void:
	name = "Statue"
	classic_spell_ids = [2608]
	configure_core_petrification_spell(2608)
