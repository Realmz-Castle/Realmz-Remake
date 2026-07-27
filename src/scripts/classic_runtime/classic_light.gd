class_name ClassicLight
extends RefCounted

const CONDITION_PER_POWER := 30
const CONDITION_LOSS_PER_REDUCTION := 2
const SECONDS_PER_HOUR := 3600


static func apply_power(condition: int, power: int) -> int:
	# resolvespell.c replaces the torch counter only when the new cast extends it.
	var replacement: int = max(0, power * CONDITION_PER_POWER - 1)
	return max(condition, replacement)


static func reduce(condition: int, reduction_calls: int = 1) -> int:
	return max(0, condition - max(0, reduction_calls) * CONDITION_LOSS_PER_REDUCTION)


static func advance_time(condition: int, previous_time: int, current_time: int) -> int:
	if condition <= 0 or current_time <= previous_time:
		return max(0, condition)
	var previous_hour := int(floor(float(previous_time) / SECONDS_PER_HOUR))
	var current_hour := int(floor(float(current_time) / SECONDS_PER_HOUR))
	var elapsed_hour_boundaries: int = max(0, current_hour - previous_hour)
	# reduce.c decrements the torch in the party loop and once more explicitly.
	return reduce(condition, elapsed_hour_boundaries)


static func light_power(condition: int) -> int:
	return int(condition / CONDITION_PER_POWER) + 1 if condition > 0 else 0


static func remaining_seconds(condition: int, current_time: int) -> int:
	if condition <= 0:
		return 0
	var hour_boundaries := int(ceil(float(condition) / CONDITION_LOSS_PER_REDUCTION))
	var seconds_into_hour := posmod(current_time, SECONDS_PER_HOUR)
	var seconds_to_next_hour := SECONDS_PER_HOUR - seconds_into_hour
	return seconds_to_next_hour + (hour_boundaries - 1) * SECONDS_PER_HOUR


static func should_draw_darkness(
	darkness_level: int,
	in_combat: bool,
	classic_campaign_active: bool
) -> bool:
	if darkness_level < 0:
		return false
	# centerpict.c hands combat rendering to centerfield.c before its darkness
	# mask. Native Remake campaigns retain their existing battle presentation.
	return not (classic_campaign_active and in_combat)
