extends "res://scripts/classic_runtime/classic_core_queued_area_spell.gd"


func _init() -> void:
	name = "Cloud of Cleavers"
	classic_spell_ids = [2501]
	configure_core_queued_area_spell(2501, 8)
