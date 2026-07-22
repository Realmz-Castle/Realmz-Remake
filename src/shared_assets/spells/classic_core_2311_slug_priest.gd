extends "res://scripts/classic_runtime/classic_core_slow_spell.gd"


func _init() -> void:
	name = "Slug"
	classic_spell_class = 7
	classic_spell_ids = [2311]
	classic_spell_save_index = 7
	classic_spell_save_mode = "negate"
	in_field = false
	in_combat = true
	configure_core_slow_spell(2311)
