const name := "t_classic_strong.gd"
const menuname := "Strong (Classic)"
const stacks := true
const permanent := false
const trait_types: Array = []

const SECONDS_PER_ROUND := 5
const SECONDS_PER_HOUR := 3600
const ACCURACY_BONUS := 3
const DAMAGE_BONUS := 3

var chara
var duration_seconds := 0


func _init(args: Array) -> void:
	chara = args[0]
	duration_seconds = SECONDS_PER_ROUND * int(args[1])


func stack(args: Array) -> void:
	duration_seconds += SECONDS_PER_ROUND * int(args[0])


func unstack(args: Array) -> void:
	duration_seconds -= SECONDS_PER_ROUND * int(args[0])
	_remove_if_expired()


func get_saved_variables() -> Array:
	return [ceili(float(duration_seconds) / SECONDS_PER_ROUND)]


func _on_new_round(_character) -> void:
	duration_seconds -= SECONDS_PER_ROUND
	_remove_if_expired()


func _on_time_pass(_character, seconds: int) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	var state_machine: Node = tree.root.get_node_or_null("StateMachine")
	if state_machine != null and bool(state_machine.call("is_combat_state")):
		return
	var game_global: Node = tree.root.get_node_or_null("GameGlobal")
	if game_global == null:
		return
	var current_time := int(game_global.get("time"))
	var scaled_seconds := roundi(seconds * float(game_global.get("time_scale")))
	var elapsed_hours := elapsed_hour_boundaries(current_time - scaled_seconds, current_time)
	duration_seconds -= elapsed_hours * SECONDS_PER_ROUND
	_remove_if_expired()


func _on_get_stat(stat_name: String, stat):
	# Remake turns each accuracy-stat point into five percentage points.
	if stat_name in ["AccuracyMelee", "AccuracyRanged"]:
		return stat + ACCURACY_BONUS
	if stat_name == "Bonus_Physical_dmg":
		return stat + DAMAGE_BONUS
	return stat


func get_info_as_text() -> String:
	return "Strong for %d rounds" % ceili(float(duration_seconds) / SECONDS_PER_ROUND)


static func elapsed_hour_boundaries(previous_time: int, current_time: int) -> int:
	if current_time <= previous_time:
		return 0
	var previous_hour := floori(float(previous_time) / SECONDS_PER_HOUR)
	var current_hour := floori(float(current_time) / SECONDS_PER_HOUR)
	return maxi(0, current_hour - previous_hour)


func _remove_if_expired() -> void:
	if duration_seconds <= 0:
		chara.remove_trait(self)
