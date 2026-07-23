extends RefCounted

const trait_types: Array = []
const ConfusionRules = preload(
	"res://scripts/classic_runtime/classic_confusion.gd"
)
const IdleScript = preload(
	"res://shared_assets/CreatureScripts/classic_idle.gd"
)

var chara
var turn_outcome := ""
var trait_source := ""


func _init(args: Array) -> void:
	chara = args[0]


func _on_remove_trait(character, trait_script) -> void:
	if trait_script == self:
		character.curFaction = character.baseFaction


func _on_battle_end(character) -> void:
	# A per-turn allegiance change must not leak out of combat.
	_reset_turn(character)


func _on_get_stat(stat_name: String, stat: Variant) -> Variant:
	# Remake stat points are five percentage points in its combat chance formula.
	if stat_name in [
		"AccuracyMelee",
		"AccuracyRanged",
		"EvasionMelee",
		"EvasionRanged",
	]:
		return stat - 2
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
