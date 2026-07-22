extends "res://scripts/classic_runtime/classic_timed_condition_trait.gd"

const name := "t_silenced.gd"
const menuname := "Silenced (T)"

var power: int:
	get:
		return ceili(float(duration_seconds) / SECONDS_PER_ROUND)


func blocks_spellcasting() -> bool:
	return true


func get_info_as_text() -> String:
	return "Silenced for %d rounds" % power
