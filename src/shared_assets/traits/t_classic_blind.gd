extends "res://scripts/classic_runtime/classic_timed_condition_trait.gd"

const name := "t_classic_blind.gd"
const menuname := "Blind (Classic)"


func _on_get_stat(stat_name: String, stat: Variant) -> Variant:
	# Classic Blind changes physical attack and defense by fifteen percentage points.
	if stat_name in [
		"AccuracyMelee",
		"AccuracyRanged",
		"EvasionMelee",
		"EvasionRanged",
	]:
		return stat - 3
	return stat


func get_info_as_text() -> String:
	return "Blind for %d rounds" % ceili(
		float(duration_seconds) / SECONDS_PER_ROUND
	)
