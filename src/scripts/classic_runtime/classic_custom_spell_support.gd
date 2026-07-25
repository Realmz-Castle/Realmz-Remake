class_name ClassicCustomSpellSupport
extends RefCounted

const GENERIC := "generic"
const CONDITION := "condition"
const LETHAL := "lethal"
const CHARM := "charm"
const HEALING := "healing"
const SPELL_POINT_SURGE := "spell-point-surge"
const UNSUPPORTED := ""

const CONDITION_SPECIALS := [
	1, 2, 6, 7, 8, 9, 10, 16, 19, 30, 31, 35, 53,
]


static func normalize_record(record: Dictionary) -> Dictionary:
	var normalized := record.duplicate(true)
	# Data Spell stores these fields as signed C chars. Providence preserves
	# their source bytes, so compatibility checks must use the runtime values.
	for field_name: String in [
		"range1", "range2", "queueIcon", "toHitBonus", "saveBonus",
		"fixedTargetNum", "canRotate", "saveAdjust", "cannot", "resistAdjust",
		"cost", "damage1", "damage2", "powerDamage1", "powerDamage2",
		"duration1", "duration2", "powerDuration1", "powerDuration2",
		"spellLook1", "spellLook2", "sound1", "sound2", "targetType", "size",
		"damageType",
	]:
		var value := int(normalized.get(field_name, 0))
		if value in range(128, 256):
			normalized[field_name] = value - 256
	return normalized


static func kind(record: Dictionary) -> String:
	var source := normalize_record(record)
	var special := absi(int(source.get("special", 0)))
	if special == 0:
		return GENERIC
	if special in CONDITION_SPECIALS and _supports_condition(source):
		return CONDITION
	if special == 49 and _supports_lethal(source):
		return LETHAL
	if special in [51, 52] and _supports_charm(source):
		return CHARM
	if special == 57 and _supports_healing(source):
		return HEALING
	if special == 59 and _supports_spell_point_surge(source):
		return SPELL_POINT_SURGE
	return UNSUPPORTED


static func is_executable(record: Dictionary) -> bool:
	return not kind(record).is_empty()


static func _supports_condition(record: Dictionary) -> bool:
	if not bool(record.get("inCombat", false)):
		return false
	if not _has_nonzero_field(
		record,
		[
			"duration1", "duration2", "powerDuration1", "powerDuration2",
			"damage1", "damage2", "powerDamage1", "powerDamage2",
		]
	):
		return false
	var queue_icon := int(record.get("queueIcon", 0))
	return queue_icon <= 0 or queue_icon in range(4, 17)


static func _supports_lethal(record: Dictionary) -> bool:
	if int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or int(record.get("cannot", 0)) != 0 \
			or not bool(record.get("inCombat", 0)) \
			or bool(record.get("inCamp", 0)) \
			or int(record.get("targetType", -1)) not in [1, 3] \
			or absi(int(record.get("damageType", 0))) not in [4, 7]:
		return false
	return not _has_nonzero_field(
		record,
		["duration1", "duration2", "powerDuration1", "powerDuration2"]
	)


static func _supports_charm(record: Dictionary) -> bool:
	if int(record.get("cost", 0)) <= 0 \
			or int(record.get("cannot", 0)) != 0 \
			or not bool(record.get("inCombat", 0)) \
			or bool(record.get("inCamp", 0)) \
			or int(record.get("targetType", -1)) not in [0, 3, 4, 10] \
			or absi(int(record.get("damageType", 0))) not in range(0, 8):
		return false
	return not _has_nonzero_field(
		record,
		[
			"damage1", "damage2", "powerDamage1", "powerDamage2",
			"duration1", "duration2", "powerDuration1", "powerDuration2",
		]
	)


static func _supports_healing(record: Dictionary) -> bool:
	return bool(record.get("inCombat", false)) and _has_nonzero_field(
		record,
		["damage1", "damage2", "powerDamage1", "powerDamage2"]
	)


static func _supports_spell_point_surge(record: Dictionary) -> bool:
	return (
		bool(record.get("inCombat", false))
		and _has_nonzero_field(
			record,
			["damage1", "damage2", "powerDamage1", "powerDamage2"]
		)
		and not _has_nonzero_field(
			record,
			["duration1", "duration2", "powerDuration1", "powerDuration2"]
		)
	)


static func _has_nonzero_field(
	record: Dictionary,
	field_names: Array
) -> bool:
	for field_name: String in field_names:
		if int(record.get(field_name, 0)) != 0:
			return true
	return false
