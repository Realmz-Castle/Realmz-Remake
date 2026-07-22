extends "res://scripts/classic_runtime/classic_core_queued_area_spell.gd"


func _init() -> void:
	name = "Plane of Ice"
	classic_spell_ids = [1407]
	configure_core_queued_area_spell(1407, 2)
