class_name ClassicDisease
extends RefCounted

const SECONDS_PER_HOUR := 3600


static func stack_condition(
	current: int,
	added: int,
	maximum: int,
	absolute_cap := false
) -> int:
	# resolvespell.c rejects the entire addition when it would cross the actor cap.
	# Its monster check is absolute, while its party check remains signed.
	if current < 0:
		return current
	var candidate := current + added
	var within_cap := absi(candidate) <= maximum \
		if absolute_cap else candidate <= maximum
	return candidate if within_cap else current


static func reduce(condition: int, reduction_calls: int = 1) -> int:
	if condition <= 0:
		return condition
	return max(0, condition - max(0, reduction_calls))


static func player_reduction(condition: int) -> Dictionary:
	# reduce.c damages party members before reducing the condition.
	var current := condition
	return {
		"condition": reduce(current),
		"damage": absi(current),
	}


static func monster_reduction(condition: int) -> Dictionary:
	# getup.c reduces monster conditions before applying disease damage.
	var remaining := reduce(condition)
	return {
		"condition": remaining,
		"damage": absi(remaining),
	}


static func elapsed_hour_boundaries(previous_time: int, current_time: int) -> int:
	if current_time <= previous_time:
		return 0
	var previous_hour := int(floor(float(previous_time) / SECONDS_PER_HOUR))
	var current_hour := int(floor(float(current_time) / SECONDS_PER_HOUR))
	return max(0, current_hour - previous_hour)


static func player_reductions(condition: int, reduction_calls: int) -> Array[Dictionary]:
	var remaining := condition
	var results: Array[Dictionary] = []
	for _reduction in range(max(0, reduction_calls)):
		if remaining == 0:
			break
		var result: Dictionary = player_reduction(remaining)
		results.append(result)
		remaining = int(result["condition"])
	return results


static func advance_player_time(
	condition: int,
	previous_time: int,
	current_time: int
) -> Dictionary:
	var remaining := condition
	var damage := 0
	for result: Dictionary in player_reductions(
		condition,
		elapsed_hour_boundaries(previous_time, current_time)
	):
		remaining = int(result["condition"])
		damage += int(result["damage"])
	return {
		"condition": remaining,
		"damage": damage,
	}
