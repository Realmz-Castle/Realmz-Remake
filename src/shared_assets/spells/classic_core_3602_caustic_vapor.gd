extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"


func _init() -> void:
	name = "Caustic Vapor"
	classic_spell_ids = [3602]
	configure_core_damage_spell(3602)
