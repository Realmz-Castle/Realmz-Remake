extends "res://scripts/classic_runtime/classic_timed_condition_trait.gd"

const name := "t_classic_power_gather.gd"
const menuname := "Power Gathering (Classic)"


func _on_new_round(character) -> void:
	_restore_spell_points(character)
	super._on_new_round(character)


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
		_restore_spell_points(character)
		duration_seconds -= SECONDS_PER_ROUND
	_remove_if_expired()


func get_info_as_text() -> String:
	return "Gathering %d spell points next round" % _remaining_duration()


func _restore_spell_points(character) -> int:
	if not (character is Object) or not character.has_method("get_stat") \
			or not character.has_method("change_cur_sp"):
		return 0
	var current_hp := int(character.get_stat("curHP"))
	var current_sp := int(character.get_stat("curSP"))
	var maximum_sp := int(character.get_stat("maxSP"))
	if current_hp <= 0 or maximum_sp <= 0 or current_sp >= maximum_sp:
		return 0
	var restored := mini(_remaining_duration(), maximum_sp - current_sp)
	character.change_cur_sp(restored)
	return restored


func _remaining_duration() -> int:
	return ceili(float(duration_seconds) / SECONDS_PER_ROUND)
