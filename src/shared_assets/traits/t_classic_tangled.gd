extends "res://scripts/classic_runtime/classic_timed_condition_trait.gd"

const name := "t_classic_tangled.gd"
const menuname := "Tangled (T)"


func _on_get_stat(stat_name: String, stat: Variant) -> Variant:
	var remaining := ceili(float(duration_seconds) / SECONDS_PER_ROUND)
	if stat_name in ["AccuracyMelee", "AccuracyRanged", "EvasionMelee", "EvasionRanged"]:
		return float(stat) - 0.2 * remaining
	if stat_name == "MaxMovement":
		var minimum := 2 if _is_player_character() else 0
		return maxi(minimum, int(stat) - remaining)
	return stat


func get_info_as_text() -> String:
	var remaining := ceili(float(duration_seconds) / SECONDS_PER_ROUND)
	return "Tangled for %d rounds" % remaining


func _is_player_character() -> bool:
	return chara is PlayerCharacter or bool(chara.get("is_player_controlled"))
