extends "res://scripts/classic_runtime/classic_core_helpless_spell.gd"


func _init() -> void:
	name = "Noxious Cloud"
	classic_spell_class = 4
	classic_spell_ids = [3209]
	classic_spell_save_index = 4
	classic_spell_save_mode = "negate"
	in_field = false
	in_combat = true
	configure_core_helpless_spell(3209)
