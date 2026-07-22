const name := "t_classic_disease.gd"
const menuname := "Diseased (Classic)"
const stacks := true
const trait_types := ["Disease"]

const DiseaseRules = preload(
	"res://scripts/classic_runtime/classic_disease.gd"
)
const AnimationScript = preload(
	"res://scripts/classic_runtime/classic_animation.gd"
)

var chara
var condition := 0


func _init(args: Array) -> void:
	chara = args[0]
	condition = int(args[1])
	_log_condition(" is Diseased!")


func stack(args: Array) -> void:
	var is_player := _is_player_character(chara)
	condition = DiseaseRules.stack_condition(
		condition,
		int(args[0]),
		99 if is_player else 124,
		not is_player
	)


func unstack(args: Array) -> void:
	condition = DiseaseRules.reduce(condition, int(args[0]))
	_remove_if_expired()


func get_saved_variables() -> Array:
	return [condition]


func _on_new_round(character) -> void:
	var result: Dictionary
	if _is_player_character(character):
		result = DiseaseRules.player_reduction(condition)
	else:
		result = DiseaseRules.monster_reduction(condition)
	condition = int(result["condition"])
	if _can_take_disease_damage(character):
		character.change_cur_hp(-int(result["damage"]))
	_remove_if_expired()


func _on_time_pass(character, seconds: int) -> void:
	if condition == 0:
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
	var previous_time := current_time - scaled_seconds
	if _is_player_character(character):
		for result: Dictionary in DiseaseRules.player_reductions(
			condition,
			DiseaseRules.elapsed_hour_boundaries(previous_time, current_time)
		):
			condition = int(result["condition"])
			if _can_take_disease_damage(character):
				character.change_cur_hp(-int(result["damage"]))
	else:
		condition = DiseaseRules.reduce(
			condition,
			DiseaseRules.elapsed_hour_boundaries(previous_time, current_time)
		)
	_remove_if_expired()


func get_info_as_text() -> String:
	if condition < 0:
		return "Permanently Diseased for %d damage per round" % absi(condition)
	return "Diseased for %d rounds" % condition


func _is_player_character(character) -> bool:
	return character is PlayerCharacter or bool(character.get("is_player_controlled"))


func _can_take_disease_damage(character) -> bool:
	if not character.has_method("get_stat") or int(character.get_stat("curHP")) <= 0:
		return false
	if _is_player_character(character):
		return not AnimationScript.is_permanently_animated(character)
	return not AnimationScript.is_animated(character)


func _remove_if_expired() -> void:
	if condition == 0:
		chara.remove_trait(self)


func _log_condition(message: String) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var ui: Node = tree.root.get_node_or_null("UI") if tree != null else null
	if ui != null and ui.get("ow_hud") != null:
		ui.get("ow_hud").creatureRect.logrect.log_other_text(chara, message, null, "")
