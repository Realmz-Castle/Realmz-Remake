const name := "p_classic_strong.gd"
const menuname := "Strong (Classic, Permanent)"
const stacks := false
const permanent := true
const trait_types: Array = []
const ACCURACY_BONUS := 3
const DAMAGE_BONUS := 3

var chara
var trait_source := ""


func _init(args: Array) -> void:
	chara = args[0]


func get_saved_variables() -> Array:
	return []


func _on_get_stat(stat_name: String, stat):
	if stat_name in ["AccuracyMelee", "AccuracyRanged"]:
		return stat + ACCURACY_BONUS
	if stat_name == "Bonus_Physical_dmg":
		return stat + DAMAGE_BONUS
	return stat


func get_info_as_text() -> String:
	var source_text := "" if trait_source.is_empty() \
		else " (source: %s)" % trait_source
	return "Permanently Strong%s" % source_text


func equals_args(_traits_array: Array) -> bool:
	return true
