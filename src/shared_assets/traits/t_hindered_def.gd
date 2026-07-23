extends "res://scripts/classic_runtime/classic_timed_condition_trait.gd"

const name := "t_hindered_def.gd"
const menuname := "Hindered Evasion (T)"


func _on_get_stat(stat_name: String, stat: Variant) -> Variant:
	if stat_name in ["EvasionMelee", "EvasionRanged"]:
		var remaining := ceili(float(duration_seconds) / SECONDS_PER_ROUND)
		return float(stat) - 0.2 * remaining
	return stat


func get_info_as_text() -> String:
	var remaining := ceili(float(duration_seconds) / SECONDS_PER_ROUND)
	return "Melee and ranged evasion -%d percentage points for %d rounds" % [
		remaining,
		remaining,
	]
