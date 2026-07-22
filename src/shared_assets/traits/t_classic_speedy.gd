extends "res://scripts/classic_runtime/classic_timed_condition_trait.gd"

const name := "t_classic_speedy.gd"
const menuname := "Speedy (Classic)"
const ACTION_BONUS := 2


func _on_get_stat(stat_name: String, stat):
	if stat_name == "MaxMovement":
		return stat * 2
	if stat_name == "MaxActions":
		# Classic adds four half-attacks, which equals two Remake actions.
		return stat + ACTION_BONUS
	return stat


func get_info_as_text() -> String:
	return "Speedy for %d rounds" % ceili(
		float(duration_seconds) / SECONDS_PER_ROUND
	)
