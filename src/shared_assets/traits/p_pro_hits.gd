const name := "p_pro_hits.gd"
const menuname := "Protection from Hits (P)"
const stacks := true
const permanent := true
const trait_types: Array = []
var chara
var power: int


func _init(args: Array) -> void:
	chara = args[0]
	power = int(args[1])


func stack(args: Array) -> void:
	power += int(args[0])


func unstack(args: Array) -> void:
	power -= int(args[0])


func get_saved_variables() -> Array:
	return [power]


func _on_get_stat(stat_name: String, stat: Variant) -> Variant:
	if stat_name == "EvasionMelee":
		# One native evasion point changes hit chance by five percentage points.
		return float(stat) + 0.4 * power
	return stat


func get_info_as_text() -> String:
	return "Permanent melee hit chance -%d%%" % (2 * power)
