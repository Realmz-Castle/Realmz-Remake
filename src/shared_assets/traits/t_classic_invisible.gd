extends "res://scripts/classic_runtime/classic_timed_condition_trait.gd"

const name := "t_classic_invisible.gd"
const menuname := "Invisible (Classic)"
const EVASION_BONUS := 2


func _init(args: Array) -> void:
	super(args)
	trait_types = ["AoO_imm"]


func _on_get_stat(stat_name: String, stat):
	# Remake turns each evasion-stat point into five percentage points.
	if stat_name in ["EvasionMelee", "EvasionRanged"]:
		return stat + EVASION_BONUS
	return stat


func get_info_as_text() -> String:
	return "Invisible for %d rounds" % ceili(
		float(duration_seconds) / SECONDS_PER_ROUND
	)
