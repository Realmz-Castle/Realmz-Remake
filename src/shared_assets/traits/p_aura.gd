const name := "p_aura.gd"
const menuname := "Magic Aura (P)"
const stacks := false
const permanent := true
const NATIVE_ACCURACY_BONUS := 1
const trait_types: Array = []

var chara
var power := 1
var trait_source := ""

func _init(args: Array) -> void:
	chara = args[0]
	if args.size() > 1:
		power = maxi(1, int(args[1]))

func get_saved_variables() -> Array:
	return [power]

func _on_get_stat(stat_name: String, stat):
	if stat_name in [
		"EvasionMelee", "EvasionRanged", "AccuracyMelee", "AccuracyRanged",
	]:
		return stat + NATIVE_ACCURACY_BONUS
	return stat

func get_info_as_text() -> String:
	var source_text := "" if trait_source.is_empty() else " (source: %s)" % trait_source
	return "Permanent Magic Aura%s" % source_text

func equals_args(_traits_array: Array) -> bool:
	return true
