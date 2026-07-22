extends "res://scripts/classic_runtime/classic_core_identify_spell.gd"


func _init() -> void:
	name = "Identify Objects"
	classic_spell_class = 8
	classic_spell_ids = [1106, 3307]
	classic_spell_save_index = -1
	classic_spell_save_mode = "none"
	in_field = true
	in_combat = false
	configure_core_identify_spell(1106, [3307])
	classic_spell_ids = [1106, 3307]
