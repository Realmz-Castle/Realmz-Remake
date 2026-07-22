extends "res://scripts/classic_runtime/classic_core_healing_spell.gd"


func _init() -> void:
	name = "Heal Large Wounds"
	classic_spell_ids = [2404]
	configure_core_healing_spell(2404)
