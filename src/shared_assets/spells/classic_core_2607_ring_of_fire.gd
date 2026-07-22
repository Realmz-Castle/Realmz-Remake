extends "res://scripts/classic_runtime/classic_core_queued_area_spell.gd"


func _init() -> void:
	name = "Ring of Fire"
	classic_spell_ids = [2607]
	configure_core_queued_area_spell(2607, 1)
