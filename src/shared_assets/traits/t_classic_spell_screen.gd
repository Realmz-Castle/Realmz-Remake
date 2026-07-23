const name := "t_classic_spell_screen.gd"
const menuname := "Spell Screen (Classic)"
const stacks := true
const permanent := false
const trait_types := ["Spell Screen"]
const SpellScreenRules = preload(
	"res://scripts/classic_runtime/classic_spell_screen.gd"
)

const SCREEN_LEVELS := 5
const SECONDS_PER_ROUND := 5

var chara
var duration_seconds: Array[int] = [0, 0, 0, 0, 0]


func _init(args: Array) -> void:
	chara = args[0]
	if args.size() >= 2 and args[1] is Array:
		_restore_durations(args[1])
	elif args.size() >= 3:
		_add_duration(int(args[1]), int(args[2]))


func stack(args: Array) -> void:
	if args.size() >= 2:
		_add_duration(int(args[0]), int(args[1]))


func unstack(args: Array) -> void:
	if args.size() >= 2:
		_add_duration(int(args[0]), -int(args[1]))
	_remove_if_expired()


func screen_level() -> int:
	for index: int in range(SCREEN_LEVELS - 1, -1, -1):
		if duration_seconds[index] > 0:
			return index + 1
	return 0


func duration_for_level(level: int) -> int:
	if level < 1 or level > SCREEN_LEVELS:
		return 0
	return ceili(float(duration_seconds[level - 1]) / SECONDS_PER_ROUND)


func set_duration_for_level(level: int, rounds: int) -> void:
	if level < 1 or level > SCREEN_LEVELS:
		return
	duration_seconds[level - 1] = maxi(0, rounds) * SECONDS_PER_ROUND
	_remove_if_expired()


func condition_values() -> Array[int]:
	var values: Array[int] = []
	for level: int in range(1, SCREEN_LEVELS + 1):
		values.append(duration_for_level(level))
	return values


func get_saved_variables() -> Array:
	return [condition_values()]


func _on_new_round(_character) -> void:
	_reduce_seconds(SECONDS_PER_ROUND)


func _on_time_pass(_character, seconds: int) -> void:
	if screen_level() == 0:
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
	var elapsed_hours := SpellScreenRules.elapsed_hour_boundaries(
		current_time - scaled_seconds,
		current_time
	)
	_reduce_seconds(elapsed_hours * SECONDS_PER_ROUND)


func get_info_as_text() -> String:
	return "Spell screen level %d" % screen_level()


func _restore_durations(values: Array) -> void:
	for index: int in range(mini(values.size(), SCREEN_LEVELS)):
		duration_seconds[index] = maxi(0, int(values[index])) * SECONDS_PER_ROUND


func _add_duration(level: int, rounds: int) -> void:
	if level < 1 or level > SCREEN_LEVELS:
		return
	duration_seconds[level - 1] = maxi(
		0,
		duration_seconds[level - 1] + rounds * SECONDS_PER_ROUND
	)


func _reduce_seconds(seconds: int) -> void:
	for index: int in range(SCREEN_LEVELS):
		duration_seconds[index] = maxi(0, duration_seconds[index] - maxi(0, seconds))
	_remove_if_expired()


func _remove_if_expired() -> void:
	if screen_level() == 0:
		chara.remove_trait(self)
