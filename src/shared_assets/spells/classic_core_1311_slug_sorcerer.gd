extends "res://scripts/classic_runtime/classic_core_slow_spell.gd"


func _init() -> void:
	name = "Classic Slug Sorcerer"
	classic_spell_class = 7
	classic_spell_ids = [1311]
	classic_spell_save_index = 7
	classic_spell_save_mode = "negate"
	in_field = false
	in_combat = true
	configure_core_slow_spell(1311)
	name = "Classic Slug Sorcerer"
