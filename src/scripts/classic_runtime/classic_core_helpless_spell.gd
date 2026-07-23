class_name ClassicCoreHelplessSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const AreaPatternsScript = preload(
	"res://scripts/classic_runtime/classic_spell_area_patterns.gd"
)
const HelplessTrait = preload(
	"res://shared_assets/traits/t_classic_helpless.gd"
)
const TERRAIN_TEXTURE_BY_QUEUE_ICON := {
	4: "Web",
	7: "Gcl",
}

# resolvespell.c rolls duration once before resolving each target's resistance
# and save. Keep that roll shared without bypassing the per-target checks.
var _shared_duration := 0
var _has_shared_duration := false


func configure_core_helpless_spell(
	spell_id: int,
	equivalent_spell_ids: Array[int] = []
) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic helpless spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_helpless_record(record):
		push_error("Classic spell %d is not a helpless record" % spell_id)
		return false

	var spell_ids: Array[int] = [spell_id]
	for equivalent_spell_id: int in equivalent_spell_ids:
		var equivalent: Dictionary = CoreSpellCatalogScript.inventory_spell(
			equivalent_spell_id
		)
		if equivalent.is_empty() or equivalent.get("record", {}) != record:
			push_error(
				"Classic spell %d is not source-equivalent to helpless spell %d"
				% [equivalent_spell_id, spell_id]
			)
			return false
		spell_ids.append(equivalent_spell_id)

	_configure_core_record(inventory, record)
	classic_spell_ids = spell_ids
	attributes = ["Magical", _helpless_attribute(classic_damage_type)]
	if not tags.has("Helpless"):
		tags.append("Helpless")
	description = "%s: Renders affected creatures helpless for %s." % [
		name,
		_duration_description(),
	]

	if classic_queue_icon > 0:
		terrain_tex = str(TERRAIN_TEXTURE_BY_QUEUE_ICON.get(classic_queue_icon, ""))
		if terrain_tex.is_empty():
			push_error(
				"Classic helpless spell %d has unmapped queue icon %d"
				% [spell_id, classic_queue_icon]
			)
			return false
		terrain_walk_type = 0
		if not tags.has("Terrain"):
			tags.append("Terrain")
	return true


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
	var duration := _shared_duration if _has_shared_duration \
		else get_duration_roll(power, caster)
	var applied := _apply_helpless_duration(target, duration)
	_apply_current_turn_restrictions(target, applied)
	return duration if applied else 0


func get_aoe(power: int, _caster) -> Array[Vector2i]:
	if classic_target_type == 3:
		return AreaPatternsScript.pattern(classic_size)
	return super.get_aoe(power, _caster)


func is_classic_queued_spell() -> bool:
	return classic_queue_icon > 0


func _apply_helpless_duration(target: Variant, duration: int) -> bool:
	if duration <= 0 or not (target is Object) or not target.has_method("add_trait"):
		return false
	var traits: Variant = target.get("traits")
	if not (traits is Array):
		return false
	var current_duration := 0
	for trait_value: Variant in traits:
		if not (trait_value is Object) \
				or str(trait_value.get("name")) != HelplessTrait.name:
			continue
		var stored_duration: Variant = trait_value.get("duration")
		if stored_duration == null:
			stored_duration = trait_value.get("power")
		current_duration = int(stored_duration)
		break
	var exclusive_cap := 100 if _is_player_character(target) else 125
	if current_duration < 0 or current_duration + duration >= exclusive_cap:
		return false
	target.add_trait(HelplessTrait, [duration])
	return true


func _apply_current_turn_restrictions(target: Variant, helpless_applied: bool) -> void:
	if not (target is Object):
		return
	# The condition prevents further attacks. spelllist.c separately clears
	# movement even when resolvespell.c rejects a duration at its condition cap.
	if helpless_applied \
			and target.has_method("get_apr_left") \
			and _has_property(target, "used_apr"):
		target.set(
			"used_apr",
			int(target.get("used_apr")) + maxi(0, int(target.call("get_apr_left")))
		)
	if target.has_method("get_movement_left") \
			and _has_property(target, "used_movepoints"):
		target.set(
			"used_movepoints",
			int(target.get("used_movepoints"))
				+ maxi(0, int(target.call("get_movement_left")))
		)


func _is_helpless_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) not in [2, 53, 54] \
			or int(record.get("cost", 0)) <= 0 \
			or int(record.get("cannot", 0)) != 0 \
			or not bool(record.get("inCombat", 0)) \
			or bool(record.get("inCamp", 0)) \
			or int(record.get("targetType", -1)) not in [0, 3, 4, 10] \
			or absi(int(record.get("damageType", 0))) not in [4, 5, 7]:
		return false
	for field_name: String in ["damage1", "damage2", "powerDamage1", "powerDamage2"]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return int(record.get("duration1", 0)) > 0 \
		or int(record.get("powerDuration1", 0)) > 0


func _duration_description() -> String:
	if _power_duration_low > 0:
		return "%d-%d rounds per power" % [
			_power_duration_low,
			_power_duration_high,
		]
	return "%d-%d rounds" % [_duration_low, _duration_high]


func _helpless_attribute(damage_type: int) -> String:
	return str({4: "Chemical", 5: "Mental", 7: "Special"}.get(damage_type, "Special"))


func _is_player_character(target: Object) -> bool:
	return target is PlayerCharacter or bool(target.get("is_player_controlled"))


func _has_property(target: Object, property_name: String) -> bool:
	for property: Dictionary in target.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true
	return false
