extends "res://scripts/classic_runtime/classic_core_poison_spell.gd"


func _init() -> void:
	name = "Poison"
	classic_spell_ids = [2408]
	configure_core_poison_spell(2408)
