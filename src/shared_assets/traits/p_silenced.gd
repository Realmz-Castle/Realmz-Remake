const name := "p_silenced.gd"
const menuname := "Silenced (P)"
const stacks := false
const permanent := true
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


func blocks_spellcasting() -> bool:
	return true


func get_info_as_text() -> String:
	var source_text := "" if trait_source.is_empty() else " (source: %s)" % trait_source
	return "Permanently silenced%s" % source_text
