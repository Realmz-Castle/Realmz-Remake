extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"


func _init() -> void:
	name = "Static Discharge"
	classic_spell_ids = [3710]
	configure_core_damage_spell(3710)
