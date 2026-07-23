class_name ClassicTimedEncounterScheduler
extends RefCounted

const SECONDS_PER_DAY := 86400

var percent_roller: Callable


func crossed_days(previous_time: int, current_time: int) -> Array[int]:
	var days: Array[int] = []
	if previous_time < 0 or current_time <= previous_time:
		return days
	var previous_day := floori(float(previous_time) / float(SECONDS_PER_DAY))
	var current_day := floori(float(current_time) / float(SECONDS_PER_DAY))
	for scenario_day: int in range(previous_day + 1, current_day + 1):
		days.append(scenario_day)
	return days


func scan_day(
	bundle: Object,
	runtime_state: Object,
	scenario_day: int,
	start_index: int,
	has_item: Callable = Callable()
) -> Dictionary:
	if bundle == null or runtime_state == null:
		return _error("Classic timed-encounter scheduling requires a loaded campaign")
	if scenario_day < 0 or start_index < 0:
		return _error("Classic timed-encounter scan has an invalid cursor")

	var encounter_ids: Array = bundle.timed_encounters_by_id.keys()
	encounter_ids.sort()
	for encounter_index: int in range(start_index, encounter_ids.size()):
		var encounter_id := int(encounter_ids[encounter_index])
		var encounter: Dictionary = runtime_state.get_effective_timed_encounter(
			bundle.get_timed_encounter(encounter_id)
		)
		var scheduled_day := int(encounter.get("day", 0))
		if scheduled_day == 0:
			return _complete(encounter_ids.size())
		if scheduled_day != scenario_day:
			continue

		# Chance, item, and quest failures write this record and end the day's scan.
		# A location mismatch continues without writing, matching timeclick's file cursor.
		encounter["day"] = scheduled_day + int(encounter.get("increment", 0))
		var roll := _roll_percent()
		if roll > int(encounter.get("percent", 0)):
			runtime_state.set_timed_encounter_override(encounter_id, encounter)
			return _complete(encounter_index + 1)
		var required_item := int(encounter.get("requiredItem", -1))
		if required_item > 0 and (
			not has_item.is_valid() or not bool(has_item.call(required_item))
		):
			runtime_state.set_timed_encounter_override(encounter_id, encounter)
			return _complete(encounter_index + 1)
		var required_quest := int(encounter.get("requiredQuest", -1))
		if required_quest > -1 and not runtime_state.is_quest_set(required_quest):
			runtime_state.set_timed_encounter_override(encounter_id, encounter)
			return _complete(encounter_index + 1)
		if not _location_matches(bundle, runtime_state, encounter):
			continue
		runtime_state.set_timed_encounter_override(encounter_id, encounter)

		return {
			"status": "ok",
			"complete": false,
			"nextIndex": encounter_index + 1,
			"dispatch": {
				"encounterId": encounter_id,
				"scenarioDay": scenario_day,
				"triggerId": "Data ED3:macro:%d" % int(encounter.get("door", 0)),
			},
		}
	return _complete(encounter_ids.size())


func _location_matches(
	bundle: Object,
	runtime_state: Object,
	encounter: Dictionary
) -> bool:
	var location_kind := str(encounter.get("locationKind", "any"))
	if location_kind not in ["land", "dungeon"]:
		return true
	if str(runtime_state.get("level_type")) != location_kind:
		return false
	var level_index := int(runtime_state.get("level_index"))
	if level_index != int(encounter.get("requiredLevel", -1)):
		return false
	var x := int(runtime_state.get("x"))
	var y := int(runtime_state.get("y"))
	var rect_index := int(encounter.get("requiredRandomRect", -1))
	if rect_index > -1:
		var baseline: Dictionary = bundle.get_random_rectangle(
			location_kind,
			level_index,
			rect_index
		)
		var rectangle: Dictionary = runtime_state.get_random_rectangle(
			location_kind,
			level_index,
			rect_index,
			baseline
		)
		if rectangle.is_empty() or not _point_in_rectangle(x, y, rectangle):
			return false
	var required_x := int(encounter.get("requiredX", -1))
	if required_x > -1 and x != required_x:
		return false
	var required_y := int(encounter.get("requiredY", -1))
	if required_y > -1 and y != required_y:
		return false
	return true


func _point_in_rectangle(x: int, y: int, rectangle: Dictionary) -> bool:
	return (
		x >= int(rectangle.get("left", 0))
		and x < int(rectangle.get("right", 0))
		and y >= int(rectangle.get("top", 0))
		and y < int(rectangle.get("bottom", 0))
	)


func _roll_percent() -> int:
	if percent_roller.is_valid():
		return clampi(int(percent_roller.call()), 1, 100)
	return randi_range(1, 100)


func _complete(next_index: int) -> Dictionary:
	return {
		"status": "ok",
		"complete": true,
		"nextIndex": next_index,
		"dispatch": {},
	}


func _error(message: String) -> Dictionary:
	return {"status": "error", "message": message}
