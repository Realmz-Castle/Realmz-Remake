extends "res://scripts/classic_runtime/classic_timed_condition_trait.gd"

const name := "t_reflect_spells.gd"
const menuname := "Spell Reflection (T)"
const ReflectionRules = preload(
	"res://scripts/classic_runtime/classic_spell_reflection.gd"
)


func _on_classic_spell_targeted(
	_attacker,
	spell,
	power: int,
	roll: int
) -> Array:
	return ReflectionRules.resolve_target(chara, _attacker, spell, power, roll)


func _on_evasion_check(
	_creature,
	_evasion_stats_used: Array,
	attacker,
	spell,
	power: int
) -> Array:
	if ReflectionRules.is_classic_spell(spell):
		return [true, []]
	return ReflectionRules.resolve_target(
		chara,
		attacker,
		spell,
		power,
		randi_range(1, 100)
	)


func get_info_as_text() -> String:
	return "Spell Reflection (33%%) for %d rounds" % ceili(
		float(duration_seconds) / SECONDS_PER_ROUND
	)
