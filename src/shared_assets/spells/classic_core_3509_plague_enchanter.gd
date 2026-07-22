extends "res://scripts/classic_runtime/classic_core_queued_area_spell.gd"


func _init() -> void:
	classic_spell_ids = [3509]
	configure_core_queued_area_spell(3509, 7)
	name = "Classic Plague Enchanter"
