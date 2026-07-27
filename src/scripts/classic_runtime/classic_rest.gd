class_name ClassicRest
extends RefCounted

const REST_TIMECLICKS := 5
const CAMP_EXIT_TIMECLICKS := 2
const OUTDOOR_CAMP_MOVEMENT_EXIT_TIMECLICKS := 15
const OUTDOOR_MINUTES_PER_TIMECLICK := 5
const INDOOR_MINUTES_PER_TIMECLICK := 1
const SECONDS_PER_MINUTE := 60
const SECONDS_PER_HOUR := 3600
const SECONDS_PER_HALF_DAY := 43200
const MIN_FATIGUE := 4.0
const MAX_FATIGUE := 135.0
const REST_FATIGUE_CHANGE := -2.0
const POISONED_CONDITION_INDEX := 9
const ANIMATED_CONDITION_INDEX := 25
const TURNED_TO_STONE_CONDITION_INDEX := 26


static func pass_time_units(
	timeclicks: int,
	base_scale: int,
	time_scale: float
) -> int:
	if timeclicks <= 0:
		return 0
	var minutes_per_timeclick := (
		INDOOR_MINUTES_PER_TIMECLICK
		if base_scale != 0
		else OUTDOOR_MINUTES_PER_TIMECLICK
	)
	var elapsed_seconds := timeclicks * minutes_per_timeclick * SECONDS_PER_MINUTE
	return maxi(1, roundi(float(elapsed_seconds) / maxf(time_scale, 0.001)))


static func elapsed_hour_boundaries(previous_time: int, current_time: int) -> int:
	if current_time <= previous_time:
		return 0
	return maxi(
		0,
		floori(float(current_time) / SECONDS_PER_HOUR)
			- floori(float(previous_time) / SECONDS_PER_HOUR)
	)


static func elapsed_half_day_boundaries(previous_time: int, current_time: int) -> int:
	if current_time <= previous_time:
		return 0
	return maxi(
		0,
		floori(float(current_time) / SECONDS_PER_HALF_DAY)
			- floori(float(previous_time) / SECONDS_PER_HALF_DAY)
	)


static func fatigue_before_rest(current_fatigue: float) -> float:
	return clampf(
		current_fatigue + REST_FATIGUE_CHANGE,
		MIN_FATIGUE,
		MAX_FATIGUE
	)


static func fatigue_after_time(
	current_fatigue: float,
	previous_time: int,
	current_time: int
) -> float:
	var hour_boundaries := elapsed_hour_boundaries(previous_time, current_time)
	if hour_boundaries == 0:
		return current_fatigue
	return clampf(
		current_fatigue + hour_boundaries,
		MIN_FATIGUE,
		MAX_FATIGUE
	)


static func apply_party_recovery(
	player_characters: Array,
	player_allies: Array,
	previous_time: int,
	current_time: int,
	consume_iron_ration := Callable()
) -> Dictionary:
	var hour_boundaries := elapsed_hour_boundaries(previous_time, current_time)
	var half_day_boundaries := elapsed_half_day_boundaries(previous_time, current_time)
	var report := {
		"hourBoundaries": hour_boundaries,
		"halfDayBoundaries": half_day_boundaries,
		"playerSpellPoints": 0,
		"allySpellPoints": 0,
		"playerHitPoints": 0,
		"allyHitPoints": 0,
		"ironRationsConsumed": 0,
	}

	for _hour: int in range(hour_boundaries):
		for character: Variant in player_characters:
			report["playerSpellPoints"] += _restore_player_spell_points(character)
		for ally: Variant in player_allies:
			report["allySpellPoints"] += _restore_ally_spell_points(ally)

	for _half_day: int in range(half_day_boundaries):
		for character: Variant in player_characters:
			var recovery: Dictionary = _restore_player_hit_points(
				character,
				consume_iron_ration
			)
			report["playerHitPoints"] += int(recovery["amount"])
			report["ironRationsConsumed"] += int(recovery["rationsConsumed"])
		for ally: Variant in player_allies:
			report["allyHitPoints"] += _restore_ally_hit_points(ally)
	return report


static func random_battle_area_eligible(
	area: Dictionary,
	position: Vector2i,
	chance_roll: float
) -> bool:
	var battle: Variant = area.get("RR_Battle")
	if not (battle is Dictionary):
		return false
	var battle_range: Variant = battle.get("battle_range", [])
	if not (battle_range is Array) \
			or battle_range.size() < 2 \
			or int(battle_range[0]) <= 0 \
			or int(battle_range[1]) < int(battle_range[0]):
		return false
	if not random_battle_area_contains(area, position):
		return false
	return chance_roll <= clampf(float(area.get("chance", 0.0)), 0.0, 1.0)


static func random_battle_area_contains(
	area: Dictionary,
	position: Vector2i
) -> bool:
	var bounds: Variant = area.get("scriptRectangle", [])
	if not (bounds is Array) \
			or bounds.size() < 2 \
			or not (bounds[0] is Array) \
			or not (bounds[1] is Array) \
			or bounds[0].size() < 2 \
			or bounds[1].size() < 2:
		return false
	if (
		position.x < int(bounds[0][0])
		or position.y < int(bounds[0][1])
		or position.x > int(bounds[1][0])
		or position.y > int(bounds[1][1])
	):
		return false
	return true


static func _restore_player_spell_points(character: Variant) -> int:
	if not _can_change_stat(character, "curSP", "maxSP") \
			or _stat(character, "curSP") >= _stat(character, "maxSP") \
			or _stat(character, "curHP") <= 0 \
			or _classic_condition(character, ANIMATED_CONDITION_INDEX) != 0:
		return 0
	var amount := maxi(1, int(_level(character) / 2.0))
	return _change_stat(character, "curSP", "maxSP", amount)


static func _restore_ally_spell_points(ally: Variant) -> int:
	if not _can_change_stat(ally, "curSP", "maxSP") \
			or _stat(ally, "curSP") >= _stat(ally, "maxSP"):
		return 0
	var amount := maxi(1, int(_hit_dice(ally) / 2.0))
	return _change_stat(ally, "curSP", "maxSP", amount)


static func _restore_player_hit_points(
	character: Variant,
	consume_iron_ration: Callable
) -> Dictionary:
	if not _can_change_stat(character, "curHP", "maxHP") \
			or _stat(character, "curHP") >= _stat(character, "maxHP") \
			or _stat(character, "curHP") <= -10:
		return {"amount": 0, "rationsConsumed": 0}
	var ration_consumed := (
		consume_iron_ration.is_valid()
		and bool(consume_iron_ration.call())
	)
	var amount := int(_level(character) / 3.0)
	if not ration_consumed:
		amount = int(amount / 2.0)
	amount = maxi(1, amount)
	amount += _classic_condition(character, POISONED_CONDITION_INDEX)
	if _classic_condition(character, TURNED_TO_STONE_CONDITION_INDEX) != 0:
		return {
			"amount": 0,
			"rationsConsumed": 1 if ration_consumed else 0,
		}
	return {
		"amount": _change_stat(character, "curHP", "maxHP", amount),
		"rationsConsumed": 1 if ration_consumed else 0,
	}


static func _restore_ally_hit_points(ally: Variant) -> int:
	if not _can_change_stat(ally, "curHP", "maxHP") \
			or _stat(ally, "curHP") >= _stat(ally, "maxHP"):
		return 0
	return _change_stat(
		ally,
		"curHP",
		"maxHP",
		int(_hit_dice(ally) / 4.0) + 1
	)


static func _can_change_stat(character: Variant, current_name: String, max_name: String) -> bool:
	return (
		character is Object
		and character.has_method("get_stat")
		and character.has_method(
			"change_cur_hp" if current_name == "curHP" else "change_cur_sp"
		)
		and _stat(character, max_name) > 0
	)


static func _change_stat(
	character: Object,
	current_name: String,
	max_name: String,
	amount: int
) -> int:
	var previous := _stat(character, current_name)
	if current_name == "curHP":
		character.call("change_cur_hp", amount)
	else:
		character.call("change_cur_sp", amount)
	return maxi(0, mini(_stat(character, current_name), _stat(character, max_name)) - previous)


static func _stat(character: Object, stat_name: String) -> int:
	return int(character.call("get_stat", stat_name))


static func _level(character: Object) -> int:
	return maxi(0, int(character.get("level")))


static func _hit_dice(character: Object) -> int:
	if character.has_meta("classic_hit_dice"):
		return maxi(0, int(character.get_meta("classic_hit_dice")))
	return _level(character)


static func _classic_condition(character: Object, condition_index: int) -> int:
	if character.has_method("get_classic_condition"):
		return int(character.call("get_classic_condition", condition_index))
	return 0
