const name := "p_classic_hindered_atk.gd"
const menuname := "Hindered Attack (Classic, Permanent)"
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
	if stat_name in ["AccuracyMelee", "AccuracyRanged"]:
		return float(stat) - 0.2 * power
	return stat


func get_info_as_text() -> String:
	var source_text := "" if trait_source.is_empty() \
		else " (source: %s)" % trait_source
	return "Permanent attack accuracy -%d percentage points%s" % [
		power,
		source_text,
	]


func equals_args(traits_array: Array) -> bool:
	return int(traits_array[1]) == power
