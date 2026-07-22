class_name ClassicPartyCondition
extends RefCounted

const SECONDS_PER_HOUR := 3600
const EFFECT_BY_INDEX := {
	1: "WaterBreath",
	2: "Shielded",
	3: "Awareness",
	4: "Scrying",
	6: "FeatherFall",
	7: "Sentry",
	8: "CharmProt",
}


static func apply(current_condition: int, duration: int) -> int:
	return maxi(maxi(0, current_condition), duration)


static func reduce(condition: int, reduction_calls: int = 1) -> int:
	return maxi(0, condition - maxi(0, reduction_calls))


static func advance_time(condition: int, previous_time: int, current_time: int) -> int:
	if condition <= 0 or current_time <= previous_time:
		return maxi(0, condition)
	var previous_hour := floori(float(previous_time) / SECONDS_PER_HOUR)
	var current_hour := floori(float(current_time) / SECONDS_PER_HOUR)
	return reduce(condition, maxi(0, current_hour - previous_hour))


static func remaining_seconds(condition: int, current_time: int) -> int:
	if condition <= 0:
		return 0
	var seconds_into_hour := posmod(current_time, SECONDS_PER_HOUR)
	return SECONDS_PER_HOUR - seconds_into_hour + (condition - 1) * SECONDS_PER_HOUR
