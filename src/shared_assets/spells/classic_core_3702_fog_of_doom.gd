extends "res://scripts/classic_runtime/classic_core_queued_area_spell.gd"


func _init() -> void:
	name = "Fog of Doom"
	classic_spell_ids = [3702]
	configure_core_queued_area_spell(3702, 4)
