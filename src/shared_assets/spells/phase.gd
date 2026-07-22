extends "res://scripts/classic_runtime/classic_core_phase_spell.gd"


func _init() -> void:
	name = "Phase"
	classic_spell_ids = [1509, 2511, 3309]
	configure_core_phase_spell(1509, [2511, 3309], false)
