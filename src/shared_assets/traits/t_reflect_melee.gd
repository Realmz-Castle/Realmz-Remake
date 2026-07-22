extends "res://scripts/classic_runtime/classic_timed_condition_trait.gd"

const name := "t_reflect_melee.gd"
const menuname := "Melee Reflection (T)"
const AttackReflection = preload(
	"res://scripts/classic_runtime/classic_attack_reflection.gd"
)


func _on_melee_reflection_check(attacker, _weapon: Dictionary, roll: int) -> bool:
	return AttackReflection.should_reflect(chara, attacker, roll)


func get_info_as_text() -> String:
	return "Melee Reflection (33%%) for %d rounds" % ceili(
		float(duration_seconds) / SECONDS_PER_ROUND
	)
