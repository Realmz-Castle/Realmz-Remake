extends "res://scripts/classic_runtime/classic_core_rogue_encounter_spell.gd"


func _init() -> void:
	name = "Destroy Trap"
	classic_spell_ids = [3605]
	configure_core_rogue_encounter_spell(3605, 65)
