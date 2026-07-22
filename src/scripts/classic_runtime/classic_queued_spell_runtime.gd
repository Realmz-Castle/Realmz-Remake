class_name ClassicQueuedSpellRuntime
extends RefCounted

# Classic keeps a fixed collision queue. Each entry can hit a large creature
# only once per initiative phase, even when several occupied tiles overlap it.
const MAX_EFFECTS := 60


static func occupied_tiles(creature: Object) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var origin := Vector2i(creature.position)
	var creature_size := Vector2i(creature.size)
	for x: int in range(maxi(1, creature_size.x)):
		for y: int in range(maxi(1, creature_size.y)):
			result.append(origin + Vector2i(x, y))
	return result


static func effects_touching_creature(effects: Array, creature: Object) -> Array:
	var result: Array = []
	var creature_tiles := occupied_tiles(creature)
	for effect_value: Variant in effects:
		if not (effect_value is Dictionary):
			continue
		var effect: Dictionary = effect_value
		if not _intersection(effect.get("tiles", []), creature_tiles).is_empty():
			result.append(effect)
	return result


static func stationary_actions(effects: Array, combat_buttons: Array) -> Array:
	var result: Array = []
	for button: Variant in combat_buttons:
		if not is_instance_valid(button) or not is_instance_valid(button.creature):
			continue
		for effect: Dictionary in effects_touching_creature(effects, button.creature):
			if not bool(effect.get("classic", false)):
				continue
			var action := action_for_effect(effect, button)
			if not action.is_empty():
				result.append(action)
	return result


static func action_for_effect(effect: Dictionary, target_button: Object) -> Dictionary:
	if not is_instance_valid(target_button) or not is_instance_valid(target_button.creature):
		return {}
	if not is_instance_valid(effect.get("caster")) \
			or not is_instance_valid(effect.get("spell")):
		return {}
	var affected_tiles := _intersection(
		effect.get("tiles", []), occupied_tiles(target_button.creature)
	)
	if affected_tiles.is_empty():
		return {}
	# Absolute tiles avoid translating an already positioned field a second time
	# when the ordinary spell animation state resolves this synthetic action.
	return {
		"type": "Spell",
		"caster": target_button,
		"castercrea": effect.get("caster"),
		"spell": effect.get("spell"),
		"s_plvl": int(effect.get("power", 1)),
		"used_item": {},
		"add_terrain": false,
		"override_aoe": [],
		"absolute_aoe": affected_tiles,
		"from_terrain": true,
		"Targeted Tiles": affected_tiles,
		"Main Targeted Tile": affected_tiles[0],
	}


static func effect_key(effect: Dictionary) -> Variant:
	return effect.get("id", effect)


static func classic_effect_count(effects: Array) -> int:
	var result := 0
	for effect_value: Variant in effects:
		if effect_value is Dictionary and bool(effect_value.get("classic", false)):
			result += 1
	return result


static func advance_phase(effects: Array, phase_owner: Object) -> Array:
	var result: Array = []
	for effect_value: Variant in effects:
		if not (effect_value is Dictionary):
			continue
		var effect: Dictionary = effect_value
		if bool(effect.get("classic", false)) and effect.get("phase_owner") == phase_owner:
			effect["time"] = int(effect.get("time", 0)) - 1
		if int(effect.get("time", 0)) > 0:
			result.append(effect)
	return result


static func advance_missing_phases(effects: Array, live_creatures: Array) -> Array:
	# Realmz expires fields by numeric initiative slot. Once that slot's creature
	# has left Remake combat, the round boundary is the stable equivalent.
	var result: Array = []
	for effect_value: Variant in effects:
		if not (effect_value is Dictionary):
			continue
		var effect: Dictionary = effect_value
		if bool(effect.get("classic", false)) \
				and not live_creatures.has(effect.get("phase_owner")):
			effect["time"] = int(effect.get("time", 0)) - 1
		if int(effect.get("time", 0)) > 0:
			result.append(effect)
	return result


static func _intersection(left: Array, right: Array[Vector2i]) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for value: Variant in left:
		var point := Vector2i(value)
		if right.has(point) and not result.has(point):
			result.append(point)
	return result
