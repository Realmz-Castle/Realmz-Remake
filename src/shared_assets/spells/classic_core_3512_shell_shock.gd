extends "res://scripts/classic_runtime/classic_core_queued_area_spell.gd"


func _init() -> void:
	name = "Shell Shock"
	classic_spell_ids = [3512]
	configure_core_queued_area_spell(3512, 3)
