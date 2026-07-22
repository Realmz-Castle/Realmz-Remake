extends "res://scripts/classic_runtime/classic_timed_condition_trait.gd"

const name := "t_classic_strong.gd"
const menuname := "Strong (Classic)"
const ACCURACY_BONUS := 3
const DAMAGE_BONUS := 3


func _on_get_stat(stat_name: String, stat):
	# Remake turns each accuracy-stat point into five percentage points.
	if stat_name in ["AccuracyMelee", "AccuracyRanged"]:
		return stat + ACCURACY_BONUS
	if stat_name == "Bonus_Physical_dmg":
		return stat + DAMAGE_BONUS
	return stat


func get_info_as_text() -> String:
	return "Strong for %d rounds" % ceili(float(duration_seconds) / SECONDS_PER_ROUND)
