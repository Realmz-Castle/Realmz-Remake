extends "res://scripts/classic_runtime/classic_timed_condition_trait.gd"

const name := "t_hindered_def.gd"
const menuname := "Hindered Evasion (T)"


func _on_get_stat(stat_name: String, stat: int) -> int:
	if stat_name in ["EvasionMelee", "EvasionRanged"]:
		return stat - ceili(float(duration_seconds) / SECONDS_PER_ROUND)
	return stat


func get_info_as_text() -> String:
	var remaining := ceili(float(duration_seconds) / SECONDS_PER_ROUND)
	return "Melee and ranged evasion -%d for %d rounds" % [
		remaining,
		remaining,
	]
