extends "res://scripts/classic_runtime/classic_core_queued_area_spell.gd"


func _init() -> void:
	name = "Plane of Fog"
	classic_spell_ids = [3210]
	configure_core_queued_area_spell(3210, 4)
