class_name ClassicCoreHinderedDefenseSpell
extends "res://scripts/classic_runtime/classic_core_timed_condition_spell.gd"

const HinderedDefenseTrait = preload(
	"res://shared_assets/traits/t_hindered_def.gd"
)


func configure_core_hindered_defense_spell(spell_id: int) -> bool:
	return configure_core_timed_condition_spell(
		spell_id,
		38,
		HinderedDefenseTrait,
		["p_classic_hindered_def.gd", "p_hindered_def.gd"],
		[4],
		[3],
		"Reduces melee and ranged evasion by its remaining percentage points",
		["Defense Hindrance"],
		7,
		7,
		false
	)
