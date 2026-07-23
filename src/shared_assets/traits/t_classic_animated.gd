extends "res://scripts/classic_runtime/classic_animated_condition_trait.gd"

const name := "t_classic_animated.gd"
const menuname := "Animated (Classic)"
const stacks := true
const permanent := false
const SECONDS_PER_HOUR := 3600

var condition := 0


func _init(args: Array) -> void:
	super(args)
	condition = maxi(0, int(args[1]))


func stack(args: Array) -> void:
	condition += maxi(0, int(args[0]))


func unstack(args: Array) -> void:
	condition = maxi(0, condition - maxi(0, int(args[0])))
	_remove_if_expired()


func get_saved_variables() -> Array:
	return [condition]


func _on_turn_end(_character) -> void:
	# getup.c clears positive Animated after the affected character acts.
	chara.remove_trait(self)


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
	condition = maxi(0, condition - maxi(0, current_hour - previous_hour))
	_remove_if_expired()


func get_info_as_text() -> String:
	return "Animated until this character finishes a turn"


func _remove_if_expired() -> void:
	if condition == 0:
		chara.remove_trait(self)
