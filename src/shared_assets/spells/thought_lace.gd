extends "res://scripts/classic_runtime/classic_core_party_condition_spell.gd"


func _init() -> void:
	name = "Thought Lace"
	description = "Thought Lace: Gives party members a +50 bonus on charm saves."
	classic_spell_ids = [1612]
	configure_core_party_condition_spell(1612)
