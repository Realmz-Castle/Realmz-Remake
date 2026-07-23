const name := "p_classic_attack_bonus.gd"
const menuname := "Classic Attack Bonus (Permanent)"
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


func _on_get_stat(stat_name: String, stat: int) -> int:
	if stat_name == "Bonus_Physical_dmg":
		return stat + power
	return stat


func get_info_as_text() -> String:
	var source_text := "" if trait_source.is_empty() \
		else " (source: %s)" % trait_source
	return "Permanent physical damage bonus +%d%s" % [power, source_text]


func equals_args(traits_array: Array) -> bool:
	return int(traits_array[1]) == power
