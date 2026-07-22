const name: String = "t_poison.gd"
const menuname: String = "Poison"
const stacks: bool = true
const trait_types: Array = ["Poison"]
const PoisonRules = preload(
	"res://scripts/classic_runtime/classic_poison.gd"
)

var chara
var power: int


func _init(args: Array) -> void:
	chara = args[0]
	power = int(args[1])
	_log_condition(" is Poisoned!")


func stack(args: Array) -> void:
	power += int(args[0])


func unstack(args: Array) -> void:
	power -= int(args[0])
	_remove_if_expired()


func get_saved_variables() -> Array:
	return [power]


func _on_new_round(_character) -> void:
	var result: Dictionary = PoisonRules.player_reduction(power) \
		if PoisonRules.is_player_character(chara) \
		else PoisonRules.monster_reduction(power)
	power = int(result["power"])
	if PoisonRules.can_take_damage(chara):
		chara.change_cur_hp(-int(result["damage"]))
	_remove_if_expired()


func _on_time_pass(_character, seconds: int) -> void:
	if power <= 0 or not PoisonRules.is_player_character(chara):
		return
	var hour_boundaries := PoisonRules.elapsed_time_pass_hour_boundaries(seconds)
	for _hour in range(hour_boundaries):
		var result: Dictionary = PoisonRules.player_reduction(power)
		power = int(result["power"])
		if PoisonRules.can_take_damage(chara):
			chara.change_cur_hp(-int(result["damage"]))
		if power <= 0:
			_remove_if_expired()
			return


func get_info_as_text() -> String:
	return "Poisoned for %d rounds" % power


func _remove_if_expired() -> void:
	if power <= 0:
		chara.remove_trait(self)


func _log_condition(message: String) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var ui: Node = tree.root.get_node_or_null("UI") if tree != null else null
	if ui != null and ui.get("ow_hud") != null:
		ui.get("ow_hud").creatureRect.logrect.log_other_text(chara, message, null, "")
