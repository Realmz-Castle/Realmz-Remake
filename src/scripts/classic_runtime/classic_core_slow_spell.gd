class_name ClassicCoreSlowSpell
extends "res://scripts/classic_runtime/classic_core_timed_condition_spell.gd"

const AreaPatternsScript = preload(
	"res://scripts/classic_runtime/classic_spell_area_patterns.gd"
)
const SlowTrait = preload("res://shared_assets/traits/t_slow.gd")

var _shared_duration := 0
var _has_shared_duration := false


func configure_core_slow_spell(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic Slug %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_slow_record(record):
		push_error("Classic spell %d is not a queued special-7 Slow record" % spell_id)
		return false

	_temporary_condition_trait = SlowTrait
	_conflicting_condition_traits = ["p_slow.gd"]
	_configure_core_record(inventory, record)
	elements.clear()
	attributes = ["Magical", "Special"]
	tags = ["Magical", "Special", "Terrain", "Slow"]
	terrain_tex = "Web"
	terrain_walk_type = 0
	description = (
		"%s: Halves movement and reduces physical accuracy and evasion for %s."
	) % [name, _duration_description()]
	return true


# Each target keeps its own resistance and save, but the cast shares one roll.
func uses_classic_group_effect() -> bool:
	return false


func begin_classic_target_resolution(caster, power: int) -> void:
	_shared_duration = get_duration_roll(power, caster)
	_has_shared_duration = true


func end_classic_target_resolution() -> void:
	_shared_duration = 0
	_has_shared_duration = false


func apply_classic_scaled_effect(
	caster,
	target,
	power: int,
	effect_scale: float
) -> int:
	if effect_scale <= 0.0:
		return 0
	var movement_before := _remaining_movement(target)
	var duration := _shared_duration if _has_shared_duration \
		else get_duration_roll(power, caster)
	var applied := _apply_duration(target, duration)
	_halve_remaining_movement(target, movement_before)
	return duration if applied else 0


func get_aoe(_power: int, _caster) -> Array[Vector2i]:
	return AreaPatternsScript.pattern(classic_size)


func is_classic_queued_spell() -> bool:
	return true


func _remaining_movement(target: Variant) -> int:
	if not (target is Object) or not target.has_method("get_movement_left"):
		return -1
	return maxi(0, int(target.call("get_movement_left")))


func _halve_remaining_movement(target: Variant, movement_before: int) -> void:
	if movement_before < 0 or not (target is Object) \
			or not target.has_method("get_movement_left") \
			or not _has_property(target, "used_movepoints"):
		return
	var movement_after := maxi(0, int(target.call("get_movement_left")))
	var used_movement := int(target.get("used_movepoints"))
	var maximum_after := used_movement + movement_after
	var desired_remaining := floori(float(movement_before) / 2.0)
	target.set("used_movepoints", maxi(0, maximum_after - desired_remaining))


func _is_slow_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) != 7 \
			or int(record.get("queueIcon", 0)) != 4 \
			or int(record.get("cost", 0)) <= 0 \
			or int(record.get("cannot", 0)) != 0 \
			or absi(int(record.get("damageType", 0))) != 7 \
			or absi(int(record.get("spellClass", 0))) != 7 \
			or not bool(record.get("inCombat", 0)) \
			or bool(record.get("inCamp", 0)) \
			or int(record.get("targetType", -1)) != 3 \
			or int(record.get("size", 0)) != 14:
		return false
	for field_name: String in ["damage1", "damage2", "powerDamage1", "powerDamage2"]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return int(record.get("duration1", 0)) == 0 \
		and int(record.get("duration2", 0)) == 0 \
		and int(record.get("powerDuration1", 0)) == 1 \
		and int(record.get("powerDuration2", 0)) == 2


func _has_property(target: Object, property_name: String) -> bool:
	for property: Dictionary in target.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true
	return false
