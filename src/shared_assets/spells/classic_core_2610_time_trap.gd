extends "res://scripts/classic_runtime/classic_core_helpless_spell.gd"


func _init() -> void:
	name = "Time Trap"
	classic_spell_class = 7
	classic_spell_ids = [2610]
	classic_spell_save_index = 7
	classic_spell_save_mode = "negate"
	in_field = false
	in_combat = true
	configure_core_helpless_spell(2610)
