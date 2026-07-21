const name := "t_classic_confused.gd"
const menuname := "Confused"
const stacks := true
const trait_types: Array = []

const ConfusionRules = preload(
	"res://scripts/classic_runtime/classic_confusion.gd"
)
const IdleScript = preload(
	"res://shared_assets/CreatureScripts/classic_idle.gd"
)

var chara
var remaining_rounds := 0
var turn_outcome := ""


func _init(args: Array) -> void:
	chara = args[0]
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


func _on_remove_trait(character, trait_script) -> void:
	if trait_script == self:
		character.curFaction = character.baseFaction


func _on_battle_end(character) -> void:
	# The condition may persist, but a per-turn allegiance change must not leave combat.
	_reset_turn(character)


func _on_get_stat(stat_name: String, stat: int) -> int:
	if stat_name in ["AccuracyMelee", "AccuracyRanged", "EvasionMelee", "EvasionRanged"]:
		return stat - 10
	return stat


func _on_get_player_controlled() -> bool:
	return _ensure_turn_outcome() == ConfusionRules.OUTCOME_NORMAL


func _on_get_creature_script():
	match _ensure_turn_outcome():
		ConfusionRules.OUTCOME_FLEE:
			return _creature_script("runningaway.gd")
		ConfusionRules.OUTCOME_IDLE:
			return IdleScript
	return (
		chara.creature_script
		if chara.creature_script != null
		else _creature_script("dumb_melee.gd")
	)


func _creature_script(script_name: String):
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var game_global: Node = tree.root.get_node_or_null("GameGlobal")
	if game_global == null:
		return null
	var resources = game_global.get("cmp_resources")
	if resources == null:
		return null
	var creature_scripts: Dictionary = resources.get("creascripts_book")
	return creature_scripts.get(script_name)


func _ensure_turn_outcome() -> String:
	if turn_outcome.is_empty():
		turn_outcome = ConfusionRules.turn_outcome(
			randi_range(1, 100),
			randi_range(1, 2)
		)
		if turn_outcome == ConfusionRules.OUTCOME_BETRAY:
			chara.curFaction = 1 if int(chara.baseFaction) == 0 else 0
	return turn_outcome


func _reset_turn(character) -> void:
	character.curFaction = character.baseFaction
	turn_outcome = ""


func get_info_as_text() -> String:
	return "Confused for %d rounds" % remaining_rounds
