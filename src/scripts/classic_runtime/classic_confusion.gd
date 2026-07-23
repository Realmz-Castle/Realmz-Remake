class_name ClassicConfusion
extends RefCounted

const OUTCOME_NORMAL := "normal"
const OUTCOME_BETRAY := "betray"
const OUTCOME_IDLE := "idle"
const OUTCOME_FLEE := "flee"
const SECONDS_PER_HOUR := 3600
const PERMANENT_TRAIT_NAMES := [
	"p_classic_confused.gd",
	"p_confused.gd",
]


static func turn_outcome(action_roll: int, allegiance_roll: int) -> String:
	# getup.c separates allegiance, lost-turn, and fleeing behavior at 40 and 60.
	if action_roll < 40:
		return OUTCOME_BETRAY if allegiance_roll == 1 else OUTCOME_NORMAL
	if action_roll > 60:
		return OUTCOME_FLEE
	return OUTCOME_IDLE


static func stack_condition(current: int, added: int, maximum: int) -> int:
	# resolvespell.c rejects the entire addition when it would cross the actor cap.
	var candidate: int = max(0, current) + max(0, added)
	return candidate if candidate <= maximum else max(0, current)


static func reduce(condition: int, reduction_calls: int = 1) -> int:
	return max(0, condition - max(0, reduction_calls))


static func advance_time(condition: int, previous_time: int, current_time: int) -> int:
	if condition <= 0 or current_time <= previous_time:
		return max(0, condition)
	var previous_hour := int(floor(float(previous_time) / SECONDS_PER_HOUR))
	var current_hour := int(floor(float(current_time) / SECONDS_PER_HOUR))
	return reduce(condition, max(0, current_hour - previous_hour))


static func has_permanent_condition(character: Object) -> bool:
	if character == null:
		return false
	var traits: Variant = character.get("traits")
	if not (traits is Array):
		return false
	for trait_value: Variant in traits:
		if trait_value is Object \
				and str(trait_value.get("name")) in PERMANENT_TRAIT_NAMES:
			return true
	return false
