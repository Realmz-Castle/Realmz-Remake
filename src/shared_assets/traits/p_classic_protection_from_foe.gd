const name := "p_classic_protection_from_foe.gd"
const menuname := "Protection from Foe (Classic, Permanent)"
const stacks := false
const permanent := true
const trait_types: Array = []

var chara
var trait_source := ""


func _init(args: Array) -> void:
	chara = args[0]


func get_saved_variables() -> Array:
	return []


func get_info_as_text() -> String:
	var source_text := "" if trait_source.is_empty() \
		else " (source: %s)" % trait_source
	return "Permanent protection from evil foes%s" % source_text


func equals_args(_traits_array: Array) -> bool:
	return true
