const name: String = "p_poison.gd"
const menuname: String = "Poison (P)"
const stacks: bool = false
const trait_types: Array = ["Poison"]
const PoisonRules = preload(
	"res://scripts/classic_runtime/classic_poison.gd"
)

var chara
var power: int
var trait_source: String = ""


func _init(args: Array) -> void:
	chara = args[0]
	power = int(args[1])
	_log_condition(" is Permanently Poisoned!")


func get_saved_variables() -> Array:
	return [power]


func _on_new_round(_character) -> void:
	if PoisonRules.can_take_damage(chara):
		chara.change_cur_hp(-power)
	_remove_if_invalid()


func _on_time_pass(_character, seconds: int) -> void:
	if power <= 0 or not PoisonRules.is_player_character(chara):
		return
	for _hour in range(PoisonRules.elapsed_time_pass_hour_boundaries(seconds)):
		if PoisonRules.can_take_damage(chara):
			chara.change_cur_hp(-power)


func get_info_as_text() -> String:
	return "Permanently Poisoned for %d damage per round" % power


func _remove_if_invalid() -> void:
	if power <= 0:
		chara.remove_trait(self)


func _log_condition(message: String) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var ui: Node = tree.root.get_node_or_null("UI") if tree != null else null
	if ui != null and ui.get("ow_hud") != null:
		ui.get("ow_hud").creatureRect.logrect.log_other_text(chara, message, null, "")
