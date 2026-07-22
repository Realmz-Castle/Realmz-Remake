extends "res://scripts/classic_runtime/classic_core_summon_spell.gd"


func _init() -> void:
	name = "Creature Summon 1"
	classic_spell_ids = [1502]
	configure_core_summon_spell(1502)
