extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"


func _init() -> void:
	name = "Acid Bath"
	classic_spell_ids = [3501]
	configure_core_damage_spell(3501)
