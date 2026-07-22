extends "res://scripts/classic_runtime/classic_timed_condition_trait.gd"

const name := "t_pro_hits.gd"
const menuname := "Protection from Hits (T)"


func _on_get_stat(stat_name: String, stat: Variant) -> Variant:
	if stat_name == "EvasionMelee":
		# One native evasion point changes hit chance by five percentage points.
		return float(stat) + 0.4 * _remaining_condition()
	return stat


func get_info_as_text() -> String:
	var remaining := _remaining_condition()
	return "Melee hit chance -%d%% for %d rounds" % [
		2 * remaining,
		remaining,
	]


func _remaining_condition() -> int:
	return ceili(float(duration_seconds) / SECONDS_PER_ROUND)
