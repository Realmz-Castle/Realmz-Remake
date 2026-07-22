extends "res://scripts/classic_runtime/classic_core_spellcasting_block_spell.gd"


func _init() -> void:
	name = "Dumbstruck"
	classic_spell_class = 5
	classic_spell_ids = [2203]
	classic_spell_save_index = 5
	classic_spell_save_mode = "negate"
	in_field = false
	in_combat = true
	configure_core_spellcasting_block_spell(2203)
