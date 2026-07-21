const name := "t_classic_attack_bonus.gd"
const menuname := "Classic Attack Bonus (T)"
const stacks := true
const trait_types: Array = []

var chara
var duration_seconds := 0


func _init(args: Array) -> void:
	chara = args[0]
	duration_seconds = 5 * int(args[1])


func get_saved_variables() -> Array:
	return [ceili(float(duration_seconds) / 5.0)]


func stack(args: Array) -> void:
	duration_seconds += 5 * int(args[0])


func unstack(args: Array) -> void:
	duration_seconds -= 5 * int(args[0])
	_remove_if_expired()


func _on_new_round(_character) -> void:
	duration_seconds -= 5
	_remove_if_expired()


func _on_time_pass(_character, seconds: int) -> void:
	duration_seconds -= seconds
	_remove_if_expired()


func _on_get_stat(stat_name: String, stat: int) -> int:
	if stat_name == "Bonus_Physical_dmg":
		return stat + ceili(float(duration_seconds) / 5.0)
	return stat


func get_info_as_text() -> String:
	return "Classic physical damage bonus +%d" % ceili(float(duration_seconds) / 5.0)


func _remove_if_expired() -> void:
	if duration_seconds <= 0:
		chara.remove_trait(self)
