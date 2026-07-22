extends "res://scripts/classic_runtime/classic_timed_condition_trait.gd"

const name := "t_classic_attack_bonus.gd"
const menuname := "Classic Attack Bonus (T)"


func _on_get_stat(stat_name: String, stat: int) -> int:
	if stat_name == "Bonus_Physical_dmg":
		return stat + ceili(float(duration_seconds) / SECONDS_PER_ROUND)
	return stat


func get_info_as_text() -> String:
	return "Classic physical damage bonus +%d" % ceili(
		float(duration_seconds) / SECONDS_PER_ROUND
	)
