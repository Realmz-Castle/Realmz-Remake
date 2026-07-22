extends "res://scripts/classic_runtime/classic_core_rogue_encounter_spell.gd"


func _init() -> void:
	name = "Open Lock"
	classic_spell_ids = [1109]
	configure_core_rogue_encounter_spell(1109, 70)
