extends "res://scripts/classic_runtime/classic_core_timed_condition_spell.gd"

const AuraTrait = preload("res://shared_assets/traits/t_aura.gd")


func _init() -> void:
	name = "Magic Aura"
	classic_spell_ids = [2106]
	configure_core_timed_condition_spell(
		2106,
		5,
		AuraTrait,
		["p_aura.gd"],
		[9],
		[3],
		"Adds five percentage points to physical attack and defense",
		["Enhancement", "Physical Accuracy", "Physical Evasion"]
	)
