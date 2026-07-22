extends "res://scripts/classic_runtime/classic_core_healing_spell.gd"


func _init() -> void:
	name = "Heal Medium Wounds"
	classic_spell_ids = [2207]
	configure_core_healing_spell(2207)
