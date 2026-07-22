extends "res://scripts/classic_runtime/classic_timed_condition_trait.gd"

const name := "t_classic_protection_from_foe.gd"
const menuname := "Protection from Foe (Classic)"


func get_info_as_text() -> String:
	return "Protection from evil foes for %d rounds" % ceili(
		float(duration_seconds) / SECONDS_PER_ROUND
	)
