class_name ClassicCombatPhase
extends RefCounted

const TILE_SIZE := 32


static func destination_is_blocked(caster: Object, destination: Vector2i) -> bool:
	var game_global := _autoload("GameGlobal")
	if game_global == null:
		return true
	var map: Variant = game_global.get("map")
	if not is_instance_valid(map):
		return true
	var map_data: Variant = map.get("mapdata")
	if not (map_data is Array) or map_data.is_empty():
		return true
	var caster_size := Vector2i.ONE
	if _has_property(caster, "size"):
		caster_size = Vector2i(caster.get("size"))
	for x: int in range(maxi(1, caster_size.x)):
		for y: int in range(maxi(1, caster_size.y)):
			var tile := destination + Vector2i(x, y)
			if tile.x < 0 or tile.y < 0 or tile.x >= map_data.size() \
					or not (map_data[tile.x] is Array) \
					or tile.y >= map_data[tile.x].size() \
					or not bool(game_global.call("is_map_tile_walkable_by_char", caster, tile)):
				return true
			var occupant: Variant = game_global.call("who_is_at_tile", tile)
			if is_instance_valid(occupant) and occupant.get("creature") != caster:
				return true
	return false


static func relocate(
	caster: Object,
	destination: Vector2i,
	ends_turn: bool,
	destination_blocked: bool
) -> Dictionary:
	if not is_instance_valid(caster) or not _has_property(caster, "position"):
		return {"status": "invalid-caster"}

	caster.set("position", Vector2(destination))
	var combat_button: Variant = caster.get("combat_button") \
		if _has_property(caster, "combat_button") else null
	if is_instance_valid(combat_button) and _has_property(combat_button, "position"):
		combat_button.set("position", Vector2(destination) * TILE_SIZE)

	if destination_blocked:
		_kill(caster)
		_refresh_battle_position(caster)
		return {"status": "collision", "destination": destination}

	if ends_turn and _has_property(caster, "used_apr"):
		var maximum_actions := int(caster.get("used_apr"))
		if caster.has_method("get_stat"):
			maximum_actions = int(caster.get_stat("MaxActions"))
		caster.set("used_apr", maximum_actions)
	_refresh_battle_position(caster)
	return {"status": "moved", "destination": destination}


static func _kill(caster: Object) -> void:
	var current_health := 0
	var stats: Variant = caster.get("stats") if _has_property(caster, "stats") else null
	if stats is Dictionary:
		current_health = int(stats.get("curHP", 0))
	if caster.has_method("change_cur_hp"):
		caster.change_cur_hp(-10 - current_health)
	if stats is Dictionary:
		stats["curHP"] = -10
	if _has_property(caster, "life_status"):
		caster.set("life_status", 3)


static func _refresh_battle_position(caster: Object) -> void:
	var game_global := _autoload("GameGlobal")
	if game_global == null:
		return
	var map: Variant = game_global.get("map")
	if not is_instance_valid(map):
		return
	var focus: Variant = map.get("focuscharacter")
	if is_instance_valid(focus) and focus.has_method("set_tile_position"):
		focus.set_tile_position(Vector2(caster.get("position")))
	if not map.has_method("pathfinder_update_characters"):
		return
	var state_machine := _autoload("StateMachine")
	var combat_state: Variant = state_machine.get("combat_state") \
		if state_machine != null else null
	if not is_instance_valid(combat_state):
		return
	var buttons: Variant = combat_state.get("all_battle_creatures_btns")
	if not (buttons is Array):
		return
	var creatures: Array = []
	for button: Variant in buttons:
		if is_instance_valid(button) and _has_property(button, "creature"):
			creatures.append(button.get("creature"))
	map.pathfinder_update_characters(creatures, caster)
	if map.has_method("pathfinder_clear_pos"):
		map.pathfinder_clear_pos(Vector2i(caster.get("position")))


static func _autoload(name: String) -> Node:
	var tree := Engine.get_main_loop() as SceneTree
	return tree.root.get_node_or_null(name) if tree != null else null


static func _has_property(value: Object, property_name: String) -> bool:
	for property: Dictionary in value.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true
	return false
