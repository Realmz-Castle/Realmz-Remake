const name := "p_hindered_def.gd"
const menuname := "Hindered Evasion (P)"
const stacks := false
const permanent := true
const trait_types: Array = []

var chara
var power: int
var trait_source := ""


func _init(args: Array) -> void:
	chara = args[0]
	power = int(args[1])
	UI.ow_hud.creatureRect.logrect.log_other_text(
		chara,
		"'s evasion is permanently hindered!",
		null,
		""
	)


func get_saved_variables() -> Array:
	return [power]


func _on_get_stat(stat_name: String, stat: int) -> int:
	if stat_name in ["EvasionMelee", "EvasionRanged"]:
		return stat - power
	return stat


func get_info_as_text() -> String:
	var source_text := "" if trait_source.is_empty() else " (source: %s)" % trait_source
	return "Permanent melee and ranged evasion -%d%s" % [power, source_text]
