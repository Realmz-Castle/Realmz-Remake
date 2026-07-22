class_name ClassicCoreSpellDeflector
extends "res://scripts/classic_runtime/classic_core_timed_condition_spell.gd"

const ReflectionTrait = preload("res://shared_assets/traits/t_reflect_spells.gd")


func configure_core_spell_deflector(spell_id: int) -> bool:
	return configure_core_timed_condition_spell(
		spell_id,
		31,
		ReflectionTrait,
		["p_reflect_spells.gd"],
		[0, 5],
		[4],
		"Reflects eligible spells to their caster 33% of the time",
		["Spell Reflection"]
	)


func uses_classic_group_effect() -> bool:
	# Each selected target is a separate resolvespell.c call and may reflect the
	# deflector itself before its condition is applied.
	return false
