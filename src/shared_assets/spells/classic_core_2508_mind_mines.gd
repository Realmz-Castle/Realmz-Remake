extends "res://scripts/classic_runtime/classic_core_queued_area_spell.gd"


func _init() -> void:
	name = "Mind Mines"
	classic_spell_ids = [2508]
	configure_core_queued_area_spell(2508, 5)
