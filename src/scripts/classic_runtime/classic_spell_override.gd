class_name ClassicSpellOverride
extends Spell

const MagicResistanceScript = preload(
	"res://scripts/classic_runtime/classic_magic_resistance.gd"
)

# Classic spell rows are data, not scripts. This adapter exposes the subset
# with no special opcode through Remake's ordinary Spell interface.

var source_record: Dictionary = {}
var classic_fixed_target_num := 0
var classic_queue_icon := 0
var classic_to_hit_bonus := 0
var classic_raw_damage_type := 0
var classic_damage_type := 0
var classic_special := 0
var classic_cannot := 0
var classic_in_camp := false
var classic_size := 0
var classic_spell_look_ids: Array[int] = []
var classic_sound_ids: Array[int] = []
var _cost := 0
var _range_low := 0
var _range_per_power := 0
var _damage_low := 0
var _damage_high := 0
var _power_damage_low := 0
var _power_damage_high := 0
var _duration_low := 0
var _duration_high := 0
var _power_duration_low := 0
var _power_duration_high := 0
var _size := 0
var _native_aoe := ""


static func normalize_custom_record(record: Dictionary) -> Dictionary:
	var normalized := record.duplicate(true)
	# Data Spell stores these fields as signed C chars. Providence preserves
	# their source bytes, so the runtime owns their two's-complement meaning.
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


func configure(record: Dictionary) -> void:
	source_record = record.duplicate(true)
	var record_id := int(record.get("id", -1))
	var spell_id := int(record.get(
		"packedSpellId",
		5101 + floori(float(record_id) / 15.0) * 100 + record_id % 15
	))
	name = str(record.get("displayName", "")).strip_edges()
	if name.is_empty():
		name = "Classic spell %d" % spell_id
	description = str(record.get("description", ""))
	classic_spell_class = int(record.get("spellClass", 0))
	classic_spell_ids = [spell_id]
	classic_target_type = int(record.get("targetType", 0))
	classic_fixed_target_num = int(record.get("fixedTargetNum", 0))
	classic_queue_icon = int(record.get("queueIcon", 0))
	classic_to_hit_bonus = int(record.get("toHitBonus", 0))
	classic_raw_damage_type = int(record.get("damageType", 0))
	classic_damage_type = abs(classic_raw_damage_type)
	classic_opposed_level_check = classic_raw_damage_type < 0 and classic_damage_type != 9
	classic_special = abs(int(record.get("special", 0)))
	classic_cannot = int(record.get("cannot", 0))
	classic_save_bonus = int(record.get("saveBonus", 0))
	classic_save_adjust = int(record.get("saveAdjust", 0))
	classic_resist_adjust = int(record.get("resistAdjust", 0))
	classic_in_camp = bool(record.get("inCamp", false))
	classic_spell_look_ids = [
		int(record.get("spellLook1", 0)),
		int(record.get("spellLook2", 0)),
	]
	classic_sound_ids = [
		int(record.get("sound1", 0)),
		int(record.get("sound2", 0)),
	]
	_native_aoe = str(record.get("nativeAoe", ""))
	_cost = int(record.get("cost", 0))
	_range_low = int(record.get("range1", 0))
	_range_per_power = int(record.get("range2", 0))
	_damage_low = int(record.get("damage1", 0))
	_damage_high = _range_high(_damage_low, int(record.get("damage2", 0)))
	_power_damage_low = int(record.get("powerDamage1", 0))
	_power_damage_high = _range_high(
		_power_damage_low, int(record.get("powerDamage2", 0))
	)
	_duration_low = int(record.get("duration1", 0))
	_duration_high = _range_high(_duration_low, int(record.get("duration2", 0)))
	_power_duration_low = int(record.get("powerDuration1", 0))
	_power_duration_high = _range_high(
		_power_duration_low, int(record.get("powerDuration2", 0))
	)
	classic_size = int(record.get("size", 0))
	_size = classic_size

	_configure_presentation(record)
	in_combat = bool(record.get("inCombat", false))
	in_field = classic_in_camp
	rot = bool(record.get("canRotate", 0))
	resist = RESIST_TYPE.IGNORE_DODGE \
		if MagicResistanceScript.custom_spell_uses_resistance(self) \
		else RESIST_TYPE.IGNORE_MRES_DODGE
	classic_spell_save_index = classic_damage_type \
		if classic_damage_type in range(1, 8) and classic_cannot <= 1 else -1
	classic_spell_save_mode = _save_mode()
	_configure_targeting()


func is_generically_executable() -> bool:
	return classic_special == 0


func get_range(power: int, _caster) -> int:
	return abs(_range_low + _range_per_power * power)


func get_target_number(power: int, _caster) -> int:
	# Class 9 reuses fixedTargetNum as its same-target missile count.
	if absi(classic_spell_class) == 9:
		return 1
	if classic_fixed_target_num > 0:
		return classic_fixed_target_num
	if classic_target_type < 1:
		return max(1, power)
	return 1


func get_min_damage(power: int, _caster) -> int:
	return _damage_low + max(0, power) * _power_damage_low


func get_max_damage(power: int, _caster) -> int:
	return _damage_high + max(0, power) * _power_damage_high


func get_damage_roll(power: int, _caster) -> int:
	var result := randi_range(_damage_low, _damage_high)
	for _level: int in range(max(0, power)):
		if _power_damage_low != 0:
			result += randi_range(_power_damage_low, _power_damage_high)
	return result


func get_min_duration(power: int, _caster) -> int:
	return _duration_low + max(0, power) * _power_duration_low


func get_max_duration(power: int, _caster) -> int:
	return _duration_high + max(0, power) * _power_duration_high


func get_duration_roll(power: int, _caster) -> int:
	var result := randi_range(_duration_low, _duration_high)
	for _level: int in range(max(0, power)):
		if _power_duration_low != 0:
			result += randi_range(_power_duration_low, _power_duration_high)
	return result


func get_sp_cost(power: int, _caster) -> int:
	return abs(_cost * power)


func get_aoe(power: int, _caster) -> Array[Vector2i]:
	match _native_aoe:
		"round":
			return AoE_ROUND
		"radiant":
			return AoE_RADIANT
	var radius := _size
	if classic_target_type == 4:
		radius = power
	match clampi(radius, 1, 7):
		2:
			return AoE_b2
		3:
			return AoE_b3
		4:
			return AoE_b4
		5:
			return AoE_b5
		6:
			return AoE_b6
		7:
			return AoE_b7
		_:
			return AoE_b1


func _save_mode() -> String:
	if classic_spell_save_index < 0:
		return "none"
	if _damage_low != 0 or _damage_high != 0 \
		or _power_damage_low != 0 or _power_damage_high != 0:
		return "half_damage"
	return "negate"


func _configure_targeting() -> void:
	# Classic casts zero-range target types below 8 on the caster.
	if classic_target_type < 8 and _range_low == 0 and _range_per_power == 0:
		skip_targeting = true
		autotarget_type = AUTOTARGET_TYPE.SELF
		return
	match classic_target_type:
		0:
			targettile = TARGET_TILE.CREATURE
		1:
			targettile = TARGET_TILE.CREATURE
		2:
			targettile = TARGET_TILE.EMPTY
		5:
			skip_targeting = true
			autotarget_type = AUTOTARGET_TYPE.SELF
		9:
			skip_targeting = true
			autotarget_type = AUTOTARGET_TYPE.ALL_ALLIES
		10:
			skip_targeting = true
			autotarget_type = AUTOTARGET_TYPE.ALL_ENEMIES
		12:
			skip_targeting = true
			autotarget_type = AUTOTARGET_TYPE.EVERYONE
		_:
			targettile = TARGET_TILE.NOWALL


func _configure_presentation(record: Dictionary) -> void:
	elements.clear()
	var element_values: Variant = record.get("elements", [])
	if element_values is Array:
		for element_value: Variant in element_values:
			elements.append(int(element_value))
	tags = _string_array(record.get("tags", []))
	schools = _string_array(record.get("schools", []))
	var level_values: Variant = record.get("schoolLevels", {})
	if level_values is Dictionary:
		school_levels = level_values.duplicate(true)
	var cost_values: Variant = record.get("selectionCosts", {})
	if cost_values is Dictionary:
		selection_costs = cost_values.duplicate(true)
	max_plevel = int(record.get("maxPowerLevel", max_plevel))
	los = bool(record.get("lineOfSight", _range_low + _range_per_power != 0))
	ray = bool(record.get("ray", false))
	proj_tex = int(record.get("projectileTexture", GFX.NONE))
	proj_hit = int(record.get("projectileHit", GFX.NONE))
	sounds = _string_array(record.get("sounds", []))
	max_focus_loss = int(record.get("maxFocusLoss", 0))


func _string_array(value: Variant) -> Array:
	var result: Array = []
	if value is Array:
		for entry: Variant in value:
			result.append(str(entry))
	return result


func _range_high(low: int, high: int) -> int:
	# Authored fixed values commonly leave the second endpoint at zero.
	if high == 0 and low != 0:
		return low
	return max(low, high)
