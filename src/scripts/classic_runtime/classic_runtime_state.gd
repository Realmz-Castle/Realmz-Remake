class_name ClassicRuntimeState
extends RefCounted

var quest_flags: Dictionary = {}
var tile_overrides: Dictionary = {}
var trigger_percent_overrides: Dictionary = {}
var level_type := "land"
var level_index := 0
var x := 0
var y := 0


func configure_from_bundle(bundle: ClassicCampaignBundle) -> void:
	quest_flags.clear()
	tile_overrides.clear()
	trigger_percent_overrides.clear()
	var start := bundle.get_start()
	level_type = str(start.get("levelType", "land"))
	level_index = int(start.get("levelIndex", 0))
	x = int(start.get("x", 0))
	y = int(start.get("y", 0))


func set_quest_flag(signed_quest_id: int) -> void:
	if signed_quest_id == 0:
		return
	quest_flags[abs(signed_quest_id)] = signed_quest_id > 0


func is_quest_set(quest_id: int) -> bool:
	return bool(quest_flags.get(abs(quest_id), false))


func set_position(new_level_index: int, new_x: int, new_y: int) -> void:
	if new_level_index >= 0:
		level_index = new_level_index
	if new_x >= 0:
		x = new_x
	if new_y >= 0:
		y = new_y


func set_tile(level_kind: String, map_level: int, tile_x: int, tile_y: int, tile_value: int) -> void:
	tile_overrides[_tile_key(level_kind, map_level, tile_x, tile_y)] = tile_value


func get_tile(level_kind: String, map_level: int, tile_x: int, tile_y: int, fallback: int) -> int:
	return int(tile_overrides.get(_tile_key(level_kind, map_level, tile_x, tile_y), fallback))


func set_trigger_percent(level_kind: String, map_level: int, trigger_id: int, percent: int) -> void:
	trigger_percent_overrides[_trigger_key(level_kind, map_level, trigger_id)] = percent


func get_trigger_percent(
	level_kind: String,
	map_level: int,
	trigger_id: int,
	fallback: int
) -> int:
	return int(trigger_percent_overrides.get(
		_trigger_key(level_kind, map_level, trigger_id),
		fallback
	))


func snapshot() -> Dictionary:
	return {
		"questFlags": quest_flags.duplicate(true),
		"tileOverrides": tile_overrides.duplicate(true),
		"triggerPercentOverrides": trigger_percent_overrides.duplicate(true),
		"position": {
			"levelType": level_type,
			"levelIndex": level_index,
			"x": x,
			"y": y,
		},
	}


func restore(saved_state: Dictionary) -> void:
	quest_flags.clear()
	tile_overrides.clear()
	trigger_percent_overrides.clear()
	var saved_flags: Variant = saved_state.get("questFlags", {})
	if saved_flags is Dictionary:
		for quest_id: Variant in saved_flags:
			quest_flags[int(quest_id)] = bool(saved_flags[quest_id])
	_restore_dictionary(saved_state.get("tileOverrides", {}), tile_overrides)
	_restore_dictionary(saved_state.get("triggerPercentOverrides", {}), trigger_percent_overrides)
	var position: Variant = saved_state.get("position", {})
	if position is Dictionary:
		level_type = str(position.get("levelType", "land"))
		level_index = int(position.get("levelIndex", 0))
		x = int(position.get("x", 0))
		y = int(position.get("y", 0))


func _restore_dictionary(saved_value: Variant, target: Dictionary) -> void:
	if not (saved_value is Dictionary):
		return
	for key: Variant in saved_value:
		target[str(key)] = int(saved_value[key])


func _tile_key(level_kind: String, map_level: int, tile_x: int, tile_y: int) -> String:
	return "%s:%d:%d:%d" % [level_kind, map_level, tile_x, tile_y]


func _trigger_key(level_kind: String, map_level: int, trigger_id: int) -> String:
	return "%s:%d:%d" % [level_kind, map_level, trigger_id]
