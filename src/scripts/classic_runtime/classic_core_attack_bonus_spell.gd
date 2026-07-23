class_name ClassicCoreAttackBonusSpell
extends "res://scripts/classic_runtime/classic_core_timed_condition_spell.gd"

const AttackBonusTrait = preload(
	"res://shared_assets/traits/t_classic_attack_bonus.gd"
)


func configure_core_attack_bonus_spell(spell_id: int) -> bool:
	return configure_core_timed_condition_spell(
		spell_id,
		33,
		AttackBonusTrait,
		["p_classic_attack_bonus.gd"],
		[0, 1, 9],
		[4],
		"Adds its remaining duration to physical attack damage",
		["Attack Bonus"]
	)
