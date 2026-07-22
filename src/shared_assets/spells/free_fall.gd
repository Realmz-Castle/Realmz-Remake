extends "res://scripts/classic_runtime/classic_core_party_condition_spell.gd"


func _init() -> void:
	name = "Free Fall"
	description = "Free Fall: Allows the party to descend pits and cliffs without injury."
	classic_spell_ids = [1105, 2104]
	configure_core_party_condition_spell(1105, [2104])
