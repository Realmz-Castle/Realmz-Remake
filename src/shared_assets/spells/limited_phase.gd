extends "res://scripts/classic_runtime/classic_core_phase_spell.gd"


func _init() -> void:
	name = "Limited Phase"
	classic_spell_ids = [1208, 2305, 3106]
	configure_core_phase_spell(1208, [2305, 3106], true)
