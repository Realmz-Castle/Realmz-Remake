class_name ClassicPartyCondition
extends RefCounted

const SECONDS_PER_HOUR := 3600
const DRAGON_HIDE_DAMAGE_REDUCTION := 5
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


static func adjust_weapon_damage(
	damage_detail: Dictionary,
	dragon_hide_condition: int,
	applies_to_target: bool
) -> Dictionary:
	var result := damage_detail.duplicate()
	if dragon_hide_condition <= 0 or not applies_to_target:
		return result
	var physical_damage := floori(
		float(result.get("Physical", 0)) + float(result.get("Bonus_dmg", 0))
	)
	if physical_damage <= 1:
		return result

	# attack.c reduces the physical weapon hit but leaves its separate elemental
	# damage untouched. Combining Remake's physical and bonus fields preserves
	# that boundary while still showing the adjusted physical amount in the log.
	var adjusted_damage := maxi(1, physical_damage - DRAGON_HIDE_DAMAGE_REDUCTION)
	var reduction := physical_damage - adjusted_damage
	result["Physical"] = adjusted_damage
	result["Bonus_dmg"] = 0
	result["total"] = maxi(0, int(result.get("total", physical_damage)) - reduction)
	return result
