extends "res://scripts/classic_runtime/classic_timed_condition_trait.gd"

const name := "t_aura.gd"
const menuname := "Magic Aura (T)"
const NATIVE_ACCURACY_BONUS := 1

var power: int:
	get:
		return ceili(float(duration_seconds) / SECONDS_PER_ROUND)


func _on_get_stat(stat_name: String, stat):
	# One native accuracy point is five percentage points in Remake's opposed roll.
	if stat_name in [
		"EvasionMelee", "EvasionRanged", "AccuracyMelee", "AccuracyRanged",
	]:
		return stat + NATIVE_ACCURACY_BONUS
	return stat


func get_info_as_text() -> String:
	return "Aura for %d rounds" % power
