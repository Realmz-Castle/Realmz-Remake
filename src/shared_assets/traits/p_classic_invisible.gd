const name := "p_classic_invisible.gd"
const menuname := "Invisible (Classic, Permanent)"
const stacks := false
const permanent := true
const trait_types := ["AoO_imm"]
const EVASION_BONUS := 2

var chara
var trait_source := ""


func _init(args: Array) -> void:
	chara = args[0]


func get_saved_variables() -> Array:
	return []


func _on_get_stat(stat_name: String, stat):
	if stat_name in ["EvasionMelee", "EvasionRanged"]:
		return stat + EVASION_BONUS
	return stat


func get_info_as_text() -> String:
	var source_text := "" if trait_source.is_empty() \
		else " (source: %s)" % trait_source
	return "Permanently Invisible%s" % source_text


func equals_args(_traits_array: Array) -> bool:
	return true
