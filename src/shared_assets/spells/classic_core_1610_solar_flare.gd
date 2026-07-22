extends "res://scripts/classic_runtime/classic_core_queued_area_spell.gd"


func _init() -> void:
	name = "Solar Flare"
	classic_spell_ids = [1610]
	configure_core_queued_area_spell(1610, 1)
