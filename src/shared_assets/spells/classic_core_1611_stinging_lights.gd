extends "res://scripts/classic_runtime/classic_core_queued_area_spell.gd"


func _init() -> void:
	name = "Stinging Lights"
	classic_spell_ids = [1611]
	configure_core_queued_area_spell(1611, 6)
