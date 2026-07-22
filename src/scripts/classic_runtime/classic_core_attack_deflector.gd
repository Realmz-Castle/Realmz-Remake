class_name ClassicCoreAttackDeflector
extends "res://scripts/classic_runtime/classic_core_timed_condition_spell.gd"

const AttackReflectionTrait = preload("res://shared_assets/traits/t_reflect_melee.gd")


func configure_core_attack_deflector(spell_id: int) -> bool:
	return configure_core_timed_condition_spell(
		spell_id,
		32,
		AttackReflectionTrait,
		["p_reflect_melee.gd"],
		[0, 5],
		[4],
		"Redirects a successful melee attack to its attacker 33% of the time",
		["Attack Reflection"]
	)


func uses_classic_group_effect() -> bool:
	# Each selected target may reflect the deflector spell before this condition
	# is applied, so targets must finish the normal resolution pipeline first.
	return false
