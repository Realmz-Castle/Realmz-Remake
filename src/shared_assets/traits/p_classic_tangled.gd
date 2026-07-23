const name := "p_classic_tangled.gd"
const menuname := "Tangled (Classic, Permanent)"
const stacks := false
const permanent := true
const trait_types: Array = []

var chara
var power: int
var trait_source := ""


func _init(args: Array) -> void:
	chara = args[0]
	power = maxi(1, absi(int(args[1])))


func get_saved_variables() -> Array:
	return [power]


func _on_get_stat(stat_name: String, stat: Variant) -> Variant:
	if stat_name in ["AccuracyMelee", "AccuracyRanged", "EvasionMelee", "EvasionRanged"]:
		return float(stat) - 0.2 * power
	if stat_name == "MaxMovement":
		var minimum := 2 if _is_player_character() else 0
		return maxi(minimum, int(stat) - power)
	return stat


func get_info_as_text() -> String:
	var source_text := "" if trait_source.is_empty() \
		else " (source: %s)" % trait_source
	return "Permanently Tangled by %d%s" % [power, source_text]


func equals_args(traits_array: Array) -> bool:
	return int(traits_array[1]) == power


func _is_player_character() -> bool:
	return chara is PlayerCharacter or bool(chara.get("is_player_controlled"))
