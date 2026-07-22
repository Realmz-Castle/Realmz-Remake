extends "res://scripts/classic_runtime/classic_core_summon_spell.gd"


func _init() -> void:
	name = "Minor Summons"
	classic_spell_ids = [2604]
	configure_core_summon_spell(2604)
