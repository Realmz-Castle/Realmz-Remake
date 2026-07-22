extends "res://scripts/classic_runtime/classic_core_queued_area_spell.gd"


func _init() -> void:
	name = "Hail Storm"
	classic_spell_ids = [1704]
	configure_core_queued_area_spell(1704, 2)
