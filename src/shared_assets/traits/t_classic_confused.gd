extends "res://scripts/classic_runtime/classic_confusion_condition_trait.gd"

const name := "t_classic_confused.gd"
const menuname := "Confused"
const stacks := true

var remaining_rounds := 0


func _init(args: Array) -> void:
	super(args)
	remaining_rounds = max(0, int(args[1]))


func stack(args: Array) -> void:
	# Classic stores party members and monsters in condition arrays with different caps.
	remaining_rounds = ConfusionRules.stack_condition(
		remaining_rounds,
		int(args[0]),
		99 if bool(chara.get("is_player_controlled")) else 124
	)


func unstack(args: Array) -> void:
	remaining_rounds = ConfusionRules.reduce(remaining_rounds, int(args[0]))


func get_saved_variables() -> Array:
	return [remaining_rounds]


func _on_new_round(character) -> void:
	# reduce.c clears the temporary side change before reducing the condition.
	_reset_turn(character)
	remaining_rounds = ConfusionRules.reduce(remaining_rounds)
	if remaining_rounds == 0:
		character.remove_trait(self)


func _on_time_pass(character, seconds: int) -> void:
	if remaining_rounds == 0:
		return
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
	remaining_rounds = ConfusionRules.advance_time(
		remaining_rounds,
		current_time - scaled_seconds,
		current_time
	)
	if remaining_rounds == 0:
		character.remove_trait(self)


func get_info_as_text() -> String:
	return "Confused for %d rounds" % remaining_rounds
