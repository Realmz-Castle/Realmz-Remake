extends "res://scripts/classic_runtime/classic_core_dispel_spell.gd"


func _init() -> void:
	name = "Destroy Magic"
	classic_spell_ids = [1304]
	configure_core_dispel_spell(1304)
