extends "res://scripts/classic_runtime/classic_core_party_condition_spell.gd"


func _init() -> void:
	name = "Discover Secret"
	description = "Discover Secret: Increases the chance the party will detect a secret area."
	classic_spell_ids = [1202, 2202, 3203]
	configure_core_party_condition_spell(1202, [2202, 3203])
