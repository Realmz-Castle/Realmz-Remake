class_name ClassicRandomRectangle
extends RefCounted

const METADATA_KEY := "classicRandomRectangle"
const MAX_RECTANGLES := 20
const MAX_RANDOM_DOORS := 3


static func identity(area_name: String, area: Dictionary) -> Dictionary:
	var metadata: Variant = area.get(METADATA_KEY)
	if metadata is Dictionary:
		var level_type := str(metadata.get("levelType", ""))
		var level_index := int(metadata.get("levelIndex", -1))
		var rect_index := int(metadata.get("rectIndex", -1))
		if (
			level_type in ["land", "dungeon"]
			and level_index >= 0
			and rect_index >= 0
			and rect_index < MAX_RECTANGLES
		):
			return {
				"levelType": level_type,
				"levelIndex": level_index,
				"rectIndex": rect_index,
			}

	var level_type := ""
	var encoded_identity := ""
	if area_name.begins_with("LRR"):
		level_type = "land"
		encoded_identity = area_name.trim_prefix("LRR")
	elif area_name.begins_with("DRR"):
		level_type = "dungeon"
		encoded_identity = area_name.trim_prefix("DRR")
	else:
		return {}
	var separator := encoded_identity.find(".")
	if separator <= 0 or separator >= encoded_identity.length() - 1:
		return {}
	var level_text := encoded_identity.left(separator)
	var rectangle_text := encoded_identity.substr(separator + 1)
	if not level_text.is_valid_int() or not rectangle_text.is_valid_int():
		return {}
	var level_index := int(level_text)
	var rect_index := int(rectangle_text)
	if level_index < 0 or rect_index < 0 or rect_index >= MAX_RECTANGLES:
		return {}
	return {
		"levelType": level_type,
		"levelIndex": level_index,
		"rectIndex": rect_index,
	}


static func project_area(
	level_type: String,
	level_index: int,
	rectangle: Dictionary,
	message_text: String
) -> Dictionary:
	var area := {"scriptToLoad": []}
	apply_rectangle(area, level_type, level_index, rectangle, message_text)
	return area


static func apply_rectangle(
	area: Dictionary,
	level_type: String,
	level_index: int,
	rectangle: Dictionary,
	message_text: String
) -> void:
	area["scriptRectangle"] = [
		[int(rectangle.get("left", 0)), int(rectangle.get("top", 0))],
		[int(rectangle.get("right", 0)), int(rectangle.get("bottom", 0))],
	]
	area["chance"] = clampf(
		float(rectangle.get("percent", 0)) / 10000.0,
		0.0,
		1.0
	)
	area[METADATA_KEY] = {
		"levelType": level_type,
		"levelIndex": level_index,
		"rectIndex": int(rectangle.get("rectIndex", -1)),
		"percent": int(rectangle.get("percent", 0)),
		"only": bool(rectangle.get("only", false)),
		"randomDoors": _three_integers(rectangle.get("randomDoors", [])),
		"randomDoorPercent": _three_integers(
			rectangle.get("randomDoorPercent", [])
		),
	}

	var battle_range := _battle_range(rectangle)
	if battle_range[0] <= 0 or battle_range[1] < battle_range[0]:
		area.erase("RR_Battle")
		return
	area["RR_Battle"] = {
		"battle_range": battle_range,
		"option_chance": int(rectangle.get("option", 0)),
		"sfx_id": int(rectangle.get("sound", 0)),
		"text": message_text,
	}


static func contains(
	rectangle: Dictionary,
	area: Dictionary,
	position: Vector2i
) -> bool:
	if (
		rectangle.has("left")
		and rectangle.has("right")
		and rectangle.has("top")
		and rectangle.has("bottom")
	):
		return (
			position.x >= int(rectangle["left"])
			and position.x <= int(rectangle["right"])
			and position.y >= int(rectangle["top"])
			and position.y <= int(rectangle["bottom"])
		)
	var bounds: Variant = area.get("scriptRectangle", [])
	if not (bounds is Array) \
			or bounds.size() < 2 \
			or not (bounds[0] is Array) \
			or not (bounds[1] is Array) \
			or bounds[0].size() < 2 \
			or bounds[1].size() < 2:
		return false
	return (
		position.x >= int(bounds[0][0])
		and position.x <= int(bounds[1][0])
		and position.y >= int(bounds[0][1])
		and position.y <= int(bounds[1][1])
	)


static func chance_succeeds(
	rectangle: Dictionary,
	area: Dictionary,
	roll: int
) -> bool:
	var percent := int(rectangle.get(
		"percent",
		roundi(float(area.get("chance", 0.0)) * 10000.0)
	))
	return percent > 0 and roll >= 1 and roll <= percent


static func door_outcomes(rectangle: Dictionary) -> Array[Dictionary]:
	var doors := _three_integers(rectangle.get("randomDoors", []))
	var percentages := _three_integers(
		rectangle.get("randomDoorPercent", [])
	)
	var outcomes: Array[Dictionary] = []
	for door_index: int in range(MAX_RANDOM_DOORS):
		outcomes.append({
			"doorIndex": door_index,
			"triggerId": int(doors[door_index]),
			"percent": int(percentages[door_index]),
		})
	return outcomes


static func door_roll_succeeds(percent: int, roll: int) -> bool:
	return percent != 0 and roll >= 1 and roll <= absi(percent)


static func has_battle(rectangle: Dictionary, area: Dictionary) -> bool:
	var battle_range := _battle_range(rectangle)
	if battle_range[0] > 0 and battle_range[1] >= battle_range[0]:
		return true
	var battle: Variant = area.get("RR_Battle")
	if not (battle is Dictionary):
		return false
	var native_range: Variant = battle.get("battle_range", [])
	return (
		native_range is Array
		and native_range.size() >= 2
		and int(native_range[0]) > 0
		and int(native_range[1]) >= int(native_range[0])
	)


static func is_only(rectangle: Dictionary, area: Dictionary) -> bool:
	if rectangle.has("only"):
		return bool(rectangle["only"])
	var metadata: Variant = area.get(METADATA_KEY)
	return metadata is Dictionary and bool(metadata.get("only", false))


static func _battle_range(rectangle: Dictionary) -> Array[int]:
	var source: Variant = rectangle.get("battleRange", [])
	if not (source is Array) or source.size() < 2:
		return [0, 0]
	return [int(source[0]), int(source[1])]


static func _three_integers(source: Variant) -> Array[int]:
	var result: Array[int] = [0, 0, 0]
	if not (source is Array):
		return result
	for index: int in range(mini(source.size(), MAX_RANDOM_DOORS)):
		result[index] = int(source[index])
	return result
