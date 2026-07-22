extends "res://scripts/classic_runtime/classic_core_healing_spell.gd"


func _init() -> void:
	name = "Heal Wounds"
	classic_spell_ids = [2505]
	configure_core_healing_spell(2505)
