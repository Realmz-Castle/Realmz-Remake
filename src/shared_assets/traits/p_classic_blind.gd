const name := "p_classic_blind.gd"
const menuname := "Blind (P)"
const stacks := false
const trait_types: Array = []
const permanent := true

var chara
var trait_source := ""


func _init(args: Array) -> void:
	chara = args[0]


func get_saved_variables() -> Array:
	return []


func _on_get_stat(stat_name: String, stat: Variant) -> Variant:
	# Remake stat points are five percentage points in its combat chance formula.
	if stat_name in ["AccuracyMelee", "AccuracyRanged", "EvasionMelee", "EvasionRanged"]:
		return stat - 3
	return stat


func get_info_as_text() -> String:
	return "Permanently Blind (source: %s)" % trait_source


func equals_args(_traits_array: Array) -> bool:
	return true
