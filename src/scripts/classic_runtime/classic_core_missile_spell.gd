class_name ClassicCoreMissileSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const MISSILE_BONUS_CASTES := ["Archer", "Marksman"]
const MISSILE_BONUS_META_KEY := "classic_gets_missile_bonus"

var _resolution_damage := 0
var _resolution_damage_cached := false


func configure_core_missile_spell(spell_id: int) -> bool:
	if not configure_core_damage_spell(spell_id, 9):
		return false
	_configure_missile_presentation()
	return true


func configure_stock_missile_spell(record: Dictionary) -> bool:
	if not _is_stock_missile_record(record):
		push_error(
			"Classic stock spell %d is not a supported missile record"
			% int(record.get("packedSpellId", 0))
		)
		return false
	_configure_custom_record(record)
	_configure_missile_presentation()
	return true


func _configure_missile_presentation() -> void:
	attributes = ["Magical", "Projectile"]
	if not tags.has("Projectile"):
		tags.append("Projectile")


func get_damage_roll(power: int, caster) -> int:
	if _resolution_damage_cached:
		return _resolution_damage
	return _roll_missile_damage(power, caster)


func get_hits(_power: int, _caster) -> int:
	return maxi(1, classic_fixed_target_num)


func uses_classic_repeated_hits() -> bool:
	return absi(classic_spell_class) == 9 and classic_fixed_target_num > 1


func begin_classic_target_resolution(caster, power: int) -> void:
	_resolution_damage = _roll_missile_damage(power, caster)
	_resolution_damage_cached = true


func end_classic_target_resolution() -> void:
	_resolution_damage_cached = false
	_resolution_damage = 0


func _roll_missile_damage(power: int, caster) -> int:
	var result := super.get_damage_roll(power, caster)
	var bonus_range := classic_missile_bonus_range(caster)
	if bonus_range.y > 0:
		result += randi_range(bonus_range.x, bonus_range.y)
	return result


func classic_missile_bonus_range(caster) -> Vector2i:
	if not _caster_gets_missile_bonus(caster):
		return Vector2i.ZERO
	var level := maxi(1, int(caster.get("level")))
	return Vector2i(1, maxi(1, floori(level / 2.0)))


func _caster_gets_missile_bonus(caster) -> bool:
	if caster == null:
		return false
	var profile: Variant = caster.get("classic_rule_profile")
	if profile is Dictionary:
		var caste_runtime: Variant = profile.get("casteRuntime", {})
		if caste_runtime is Dictionary \
				and caste_runtime.has("getsMissileBonus"):
			return bool(caste_runtime["getsMissileBonus"])
	if caster.has_meta(MISSILE_BONUS_META_KEY):
		return bool(caster.get_meta(MISSILE_BONUS_META_KEY))
	var class_script: Variant = caster.get("classgd")
	if class_script == null:
		return false
	return str(class_script.get("classrace_name")) in MISSILE_BONUS_CASTES


func _is_stock_missile_record(record: Dictionary) -> bool:
	var spell_id := int(record.get("packedSpellId", 0))
	var fixed_target_num := int(record.get("fixedTargetNum", 0))
	var supported_hit_count := fixed_target_num in [0, 1] \
		or (spell_id == 4406 and fixed_target_num == 6)
	if int(spell_id / 1000) != 4 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) != 0 \
			or absi(int(record.get("spellClass", 0))) != 9 \
			or int(record.get("targetType", -1)) != 1 \
			or not supported_hit_count \
			or not bool(record.get("inCombat", 0)) \
			or bool(record.get("inCamp", 0)):
		return false
	for field_name: String in [
		"duration1", "duration2", "powerDuration1", "powerDuration2",
	]:
		if int(record.get(field_name, 0)) != 0:
			return false
	var special := absi(int(record.get("special", 0)))
	var damage_type := absi(int(record.get("damageType", 0)))
	if special == 0:
		if damage_type != 9 or int(record.get("cannot", 0)) != 3:
			return false
	elif special == 10:
		# Dart of Poison has the Poison special but no authored duration.
		# Classic therefore deals its chemical damage without adding poison.
		if damage_type != 4 or int(record.get("cannot", 0)) != 0:
			return false
	else:
		return false
	for field_name: String in [
		"damage1", "damage2", "powerDamage1", "powerDamage2",
	]:
		if int(record.get(field_name, 0)) != 0:
			return true
	return false
