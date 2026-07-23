class_name ClassicPermanentSpellPointConditionTrait
extends RefCounted

const stacks := false
const permanent := true
const trait_types: Array = []
const TimedConditionTrait = preload(
	"res://scripts/classic_runtime/classic_timed_condition_trait.gd"
)

var chara
var power: int
var trait_source := ""


func _init(args: Array) -> void:
	chara = args[0]
	power = maxi(1, absi(int(args[1])))


func get_saved_variables() -> Array:
	return [power]


func _on_new_round(character) -> void:
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
	var previous_time := current_time - scaled_seconds
	var elapsed_hours := TimedConditionTrait.elapsed_hour_boundaries(
		previous_time,
		current_time
	)
	for _hour: int in range(elapsed_hours):
		_change_spell_points(character)


func _change_spell_points(character) -> int:
	if not (character is Object) or not character.has_method("get_stat") \
			or not character.has_method("change_cur_sp"):
		return 0
	if int(character.get_stat("curHP")) <= 0:
		return 0
	var current_sp := int(character.get_stat("curSP"))
	var maximum_sp := int(character.get_stat("maxSP"))
	var requested_change := _spell_point_change(power)
	var applied_change := maxi(-current_sp, requested_change)
	if requested_change > 0:
		if maximum_sp <= 0:
			return 0
		applied_change = mini(maximum_sp - current_sp, requested_change)
	if applied_change == 0:
		return 0
	character.change_cur_sp(applied_change)
	return applied_change


func _spell_point_change(_power: int) -> int:
	return 0


func equals_args(traits_array: Array) -> bool:
	return int(traits_array[1]) == power
