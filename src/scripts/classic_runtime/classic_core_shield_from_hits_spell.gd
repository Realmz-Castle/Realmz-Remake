class_name ClassicCoreShieldFromHitsSpell
extends "res://scripts/classic_runtime/classic_core_timed_condition_spell.gd"

const ShieldFromHitsTrait = preload(
	"res://shared_assets/traits/t_pro_hits.gd"
)


func configure_core_shield_from_hits_spell(spell_id: int) -> bool:
	return configure_core_timed_condition_spell(
		spell_id,
		8,
		ShieldFromHitsTrait,
		["p_pro_hits.gd"],
		[3, 5, 9],
		[4],
		"Reduces melee hit chance by two percentage points per remaining condition point",
		["Defense", "Melee Protection"]
	)
