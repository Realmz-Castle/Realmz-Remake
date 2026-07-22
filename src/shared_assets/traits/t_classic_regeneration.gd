const name := "t_classic_regeneration.gd"
const menuname := "Regenerating (Classic)"
const stacks := true
const trait_types := ["Regeneration"]

const RegenerationRules = preload(
	"res://scripts/classic_runtime/classic_regeneration.gd"
)
const AnimationScript = preload(
	"res://scripts/classic_runtime/classic_animation.gd"
)

var chara
var condition := 0


func _init(args: Array) -> void:
	chara = args[0]
	condition = max(0, int(args[1]))


func stack(args: Array) -> void:
	condition = RegenerationRules.stack_condition(
		condition,
		int(args[0]),
		99 if _is_player_character(chara) else 124
	)


func unstack(args: Array) -> void:
	condition = RegenerationRules.reduce(condition, int(args[0]))
	_remove_if_expired()


func get_saved_variables() -> Array:
	return [condition]


func _on_new_round(character) -> void:
	var result: Dictionary
	if _is_player_character(character):
		result = RegenerationRules.player_reduction(condition)
	else:
		result = RegenerationRules.monster_reduction(condition)
	condition = int(result["condition"])
	if _can_regenerate_in_combat(character):
		_apply_healing(character, int(result["healing"]))
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
	var reductions := RegenerationRules.elapsed_hour_boundaries(previous_time, current_time)
	if _is_player_character(character):
		for result: Dictionary in RegenerationRules.player_reductions(condition, reductions):
			condition = int(result["condition"])
			if _can_regenerate_in_field(character):
				_apply_healing(character, int(result["healing"]))
	else:
		# Classic's field-time reduce() processes party characters, not monsters.
		condition = RegenerationRules.reduce(condition, reductions)
	_remove_if_expired()


func get_info_as_text() -> String:
	return "Regenerating for %d rounds" % condition


func _is_player_character(character) -> bool:
	return character is PlayerCharacter or bool(character.get("is_player_controlled"))


func _can_regenerate_in_combat(character) -> bool:
	return _can_regenerate(character, 0)


func _can_regenerate_in_field(character) -> bool:
	return _can_regenerate(character, -10)


func _can_regenerate(character, minimum_health: int) -> bool:
	if not character.has_method("get_stat") or not character.has_method("change_cur_hp"):
		return false
	var current_health := int(character.get_stat("curHP"))
	if current_health <= minimum_health or current_health >= int(character.get_stat("maxHP")):
		return false
	return not (
		_is_player_character(character)
		and AnimationScript.is_animated(character)
	)


func _apply_healing(character, amount: int) -> void:
	var current_health := int(character.get_stat("curHP"))
	var maximum_health := int(character.get_stat("maxHP"))
	character.change_cur_hp(mini(max(0, amount), maximum_health - current_health))


func _remove_if_expired() -> void:
	if condition == 0:
		chara.remove_trait(self)
