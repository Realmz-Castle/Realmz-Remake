class_name ClassicRogueEncounterResolver
extends RefCounted

const ACTION_NAMES := [
	"Acrobatics",
	"Detect Trap",
	"Disarm Trap",
	"Hear Noise",
	"Force Lock",
	"Move Silently",
	"Pick Lock",
	"Pick Pocket",
]

const STAT_NAMES := [
	"Acrobatics",
	"Detect_Trap",
	"Disable_Trap",
	"",
	"Force_Lock",
	"",
	"Pick_Lock",
	"",
]

var encounter: Dictionary = {}
var rogue_encounter: Dictionary = {}
var last_error := ""


func configure(complex_record: Dictionary, rogue_record: Dictionary) -> bool:
	encounter = complex_record.duplicate(true)
	rogue_encounter = rogue_record.duplicate(true)
	last_error = ""
	if encounter.is_empty():
		return _fail("Classic complex encounter record is missing")
	if rogue_encounter.is_empty():
		return _fail("Classic rogue encounter record is missing")
	var type_flags := _type_flags()
	if type_flags.size() < 10:
		return _fail("Classic rogue encounter requires ten type flags")
	rogue_encounter["typeFlags"] = type_flags
	return true


func available_actions() -> Array:
	var actions: Array = []
	var type_flags := _type_flags()
	for action_index: int in range(8):
		if not bool(type_flags[action_index]):
			continue
		actions.append({
			"index": action_index,
			"label": ACTION_NAMES[action_index],
			"stat": STAT_NAMES[action_index],
			"modifier": _array_int("modifiers", action_index),
		})
	return actions


func success_percent(action_index: int, stat_value: float) -> int:
	if action_index < 0 or action_index >= 8:
		return 0
	var chance := int(round(stat_value)) + _array_int("modifiers", action_index)
	# Classic caps the four interactive lock/trap actions at 90 percent.
	if action_index in [2, 4, 6, 7]:
		chance = min(chance, 90)
	return clampi(chance, 0, 100)


func stat_name(action_index: int) -> String:
	return STAT_NAMES[action_index] if action_index >= 0 and action_index < 8 else ""


func resolve_action(action_index: int, succeeded: bool) -> Dictionary:
	last_error = ""
	if action_index < 0 or action_index >= 8:
		return _error_result("Classic rogue action index must be between 0 and 7")
	var type_flags := _type_flags()
	if type_flags.size() < 10 or not bool(type_flags[action_index]):
		return _error_result("Classic rogue action is not available")

	type_flags[action_index] = false
	var trap_armed := bool(type_flags[9])
	if trap_armed and action_index in [4, 6, 7]:
		if action_index == 4:
			type_flags[action_index] = true
		return _trap_result(type_flags)

	if succeeded:
		if action_index == 1 and trap_armed:
			type_flags[2] = true
		elif action_index == 2:
			type_flags[9] = false
	else:
		# Detect Trap is the only failed rogue action that cannot spring a trap.
		if trap_armed and action_index != 1:
			return _trap_result(type_flags)

	rogue_encounter["typeFlags"] = type_flags
	var prefix := "success" if succeeded else "failure"
	return {
		"status": "resolved",
		"outcome": _array_int("%sCodes" % prefix, action_index),
		"messageId": _array_int("%sText" % prefix, action_index),
		"soundId": _array_int("%sSounds" % prefix, action_index),
		"thiefEncounter": rogue_encounter.duplicate(true),
	}


func _trap_result(type_flags: Array) -> Dictionary:
	type_flags[9] = false
	type_flags[1] = false
	type_flags[6] = true
	rogue_encounter["typeFlags"] = type_flags
	return {
		"status": "trap",
		"outcome": 0,
		"trap": {
			"damageLow": int(rogue_encounter.get("lowDamage", 0)),
			"damageHigh": int(rogue_encounter.get("highDamage", 0)),
			"spellId": int(rogue_encounter.get("spell", 0)),
			"spellPower": _array_int("prompts", 2),
			"soundId": _array_int("prompts", 1),
			"rogueOnly": bool(type_flags[8]),
		},
		"thiefEncounter": rogue_encounter.duplicate(true),
	}


func _type_flags() -> Array:
	var value: Variant = rogue_encounter.get("typeFlags", [])
	return value.duplicate() if value is Array else []


func _array_int(field_name: String, index: int) -> int:
	var values: Variant = rogue_encounter.get(field_name, [])
	if not (values is Array) or index < 0 or index >= values.size():
		return 0
	return int(values[index])


func _error_result(message: String) -> Dictionary:
	last_error = message
	return {
		"status": "error",
		"message": message,
	}


func _fail(message: String) -> bool:
	last_error = message
	return false
