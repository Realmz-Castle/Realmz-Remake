class_name ClassicSpellPointConditionTrait
extends "res://scripts/classic_runtime/classic_timed_condition_trait.gd"


func _on_new_round(character) -> void:
	if _is_player_character(character) or _monster_effect_precedes_decay():
		_change_spell_points(character)
		super._on_new_round(character)
	else:
		super._on_new_round(character)
		_change_spell_points(character)


func _on_time_pass(character, seconds: int) -> void:
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
	for _hour: int in range(elapsed_hours):
		if duration_seconds <= 0:
			break
		_change_spell_points(character)
		duration_seconds -= SECONDS_PER_ROUND
	_remove_if_expired()


func _change_spell_points(character) -> int:
	if not (character is Object) or not character.has_method("get_stat") \
			or not character.has_method("change_cur_sp"):
		return 0
	if int(character.get_stat("curHP")) <= 0:
		return 0
	var current_sp := int(character.get_stat("curSP"))
	var maximum_sp := int(character.get_stat("maxSP"))
	var requested_change := _spell_point_change(_remaining_duration())
	var applied_change := maxi(-current_sp, requested_change)
	if requested_change > 0:
		if maximum_sp <= 0:
			return 0
		applied_change = mini(maximum_sp - current_sp, requested_change)
	if applied_change == 0:
		return 0
	character.change_cur_sp(applied_change)
	return applied_change


func _spell_point_change(_condition: int) -> int:
	return 0


func _monster_effect_precedes_decay() -> bool:
	return false


func _remaining_duration() -> int:
	return ceili(float(duration_seconds) / SECONDS_PER_ROUND)


func _is_player_character(character) -> bool:
	return character is PlayerCharacter or bool(character.get("is_player_controlled"))
