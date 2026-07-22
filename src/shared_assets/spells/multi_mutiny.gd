extends "res://scripts/classic_runtime/classic_core_charm_spell.gd"


func _init() -> void:
	name = "Multi Mutiny"
	classic_spell_class = 0
	classic_spell_ids = [2707]
	classic_spell_save_index = -1
	classic_spell_save_mode = "none"
	in_field = false
	in_combat = true
	configure_core_charm_spell(2707)
