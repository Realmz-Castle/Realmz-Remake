class_name ClassicRegeneration
extends RefCounted

const CONDITION_INDEX := 10
const META_KEY := "classic_regeneration_per_round"
const BESTIARY_FIELD := "classicRegenerationPerRound"


static func supports_condition(condition_index: int, value: int) -> bool:
	# Realmz decrements only positive condition values at a round boundary.
	return condition_index == CONDITION_INDEX and value < 0


static func permanent_amount(conditions: Variant) -> int:
	if not (conditions is Array) or conditions.size() <= CONDITION_INDEX:
		return 0
	var value := int(conditions[CONDITION_INDEX])
	return absi(value) if value < 0 else 0


static func stack_condition(current: int, added: int, maximum: int) -> int:
	# resolvespell.c rejects the entire addition when it would cross the actor cap.
	var candidate: int = max(0, current) + max(0, added)
	return candidate if candidate <= maximum else max(0, current)


static func reduce(condition: int, reduction_calls: int = 1) -> int:
	return max(0, condition - max(0, reduction_calls))


static func player_reduction(condition: int) -> Dictionary:
	# reduce.c heals party members before reducing the condition.
	var current: int = max(0, condition)
	return {
		"condition": reduce(current),
		"healing": current,
	}


static func monster_reduction(condition: int) -> Dictionary:
	# getup.c reduces monster conditions before applying regeneration.
	var remaining := reduce(condition)
	return {
		"condition": remaining,
		"healing": remaining,
	}


static func elapsed_hour_boundaries(previous_time: int, current_time: int) -> int:
	if current_time <= previous_time:
		return 0
	var previous_hour := int(floor(float(previous_time) / 3600.0))
	var current_hour := int(floor(float(current_time) / 3600.0))
	return max(0, current_hour - previous_hour)


static func player_reductions(condition: int, reduction_calls: int) -> Array[Dictionary]:
	var remaining: int = max(0, condition)
	var results: Array[Dictionary] = []
	for _reduction in range(max(0, reduction_calls)):
		if remaining == 0:
			break
		var result: Dictionary = player_reduction(remaining)
		results.append(result)
		remaining = int(result["condition"])
	return results


static func amount(character: Object) -> int:
	if character == null or not character.has_meta(META_KEY):
		return 0
	return maxi(0, int(character.get_meta(META_KEY)))


static func apply_new_round(character: Object) -> int:
	var regeneration := amount(character)
	if regeneration == 0 or not character.has_method("get_stat") \
			or not character.has_method("change_cur_hp"):
		return 0
	var current_hp := int(character.get_stat("curHP"))
	var maximum_hp := int(character.get_stat("maxHP"))
	if current_hp <= 0 or current_hp >= maximum_hp:
		return 0
	var healed := mini(regeneration, maximum_hp - current_hp)
	character.change_cur_hp(healed)
	return healed
