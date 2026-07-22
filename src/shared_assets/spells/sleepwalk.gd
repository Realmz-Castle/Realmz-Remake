extends "res://scripts/classic_runtime/classic_core_fatigue_spell.gd"


func _init() -> void:
	name = "Sleepwalk"
	classic_spell_ids = [1412]
	configure_core_fatigue_spell(1412)
