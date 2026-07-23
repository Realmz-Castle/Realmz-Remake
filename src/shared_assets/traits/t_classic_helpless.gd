extends "res://scripts/classic_runtime/classic_helpless_condition_trait.gd"

const name := "t_classic_helpless.gd"
const menuname := "Helpless (Classic)"
const stacks := true
const permanent := false
const trait_types := ["crea_bg_blue"]
const SECONDS_PER_HOUR := 3600

var remaining_rounds := 0


func _init(args: Array) -> void:
	super(args)
	remaining_rounds = maxi(0, int(args[1]))


func stack(args: Array) -> void:
	remaining_rounds += maxi(0, int(args[0]))


func unstack(args: Array) -> void:
	remaining_rounds = maxi(0, remaining_rounds - maxi(0, int(args[0])))
	_remove_if_expired()


func get_saved_variables() -> Array:
	return [remaining_rounds]


func _on_new_round(_character) -> void:
	remaining_rounds = maxi(0, remaining_rounds - 1)
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
	var previous_hour := floori(
		float(current_time - scaled_seconds) / SECONDS_PER_HOUR
	)
	var current_hour := floori(float(current_time) / SECONDS_PER_HOUR)
	remaining_rounds = maxi(
		0,
		remaining_rounds - maxi(0, current_hour - previous_hour)
	)
	_remove_if_expired()


func get_info_as_text() -> String:
	return "Helpless for %d rounds" % remaining_rounds


func _remove_if_expired() -> void:
	if remaining_rounds == 0:
		chara.remove_trait(self)
