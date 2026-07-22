extends "res://scripts/classic_runtime/classic_core_party_condition_spell.gd"


func _init() -> void:
	name = "Wizard Eye"
	description = "Wizard Eye: Reveals the normal exploration radius through sight-blocking terrain."
	classic_spell_ids = [1512]
	configure_core_party_condition_spell(1512)
