extends "res://scripts/classic_runtime/classic_core_lethal_spell.gd"


func _init() -> void:
	name = "Finger of Death"
	classic_spell_ids = [3606]
	configure_core_lethal_spell(3606)
