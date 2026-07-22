class_name ClassicCoreSpellPointDrainSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const SpellPointMutationScript = preload(
	"res://scripts/classic_runtime/classic_spell_point_mutation.gd"
)

var _duration_fields_are_drain := false


func configure_core_spell_point_drain(
	spell_id: int,
	duration_fields_are_drain := false
) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic spell-point drain %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_spell_point_drain_record(record, duration_fields_are_drain):
		push_error("Classic spell %d is not a supported special-60 drain record" % spell_id)
		return false

	_configure_core_record(inventory, record)
	_duration_fields_are_drain = duration_fields_are_drain
	if int(record.get("targetType", -1)) == 6:
		ray = true
	classic_spell_save_mode = "half_damage"
	description = _drain_description(duration_fields_are_drain)
	return true


func get_min_spell_point_drain(power: int) -> int:
	return get_min_duration(power, null) \
		if _duration_fields_are_drain else get_min_damage(power, null)


func get_max_spell_point_drain(power: int) -> int:
	return get_max_duration(power, null) \
		if _duration_fields_are_drain else get_max_damage(power, null)


func get_spell_point_drain_roll(power: int) -> int:
	return get_duration_roll(power, null) \
		if _duration_fields_are_drain else get_damage_roll(power, null)


func apply_power_drain(target: Object, power: int, effect_scale := 1.0) -> int:
	return SpellPointMutationScript.drain(
		target,
		get_spell_point_drain_roll(power),
		effect_scale
	)


func apply_classic_scaled_effect(
	_caster,
	target,
	power: int,
	effect_scale: float
) -> int:
	return apply_power_drain(target, power, effect_scale)


func _is_spell_point_drain_record(
	record: Dictionary,
	duration_fields_are_drain: bool
) -> bool:
	if absi(int(record.get("special", 0))) != 60 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or int(record.get("cannot", 0)) > 1 \
			or absi(int(record.get("damageType", 0))) != 7 \
			or absi(int(record.get("spellClass", 0))) != 7 \
			or int(record.get("targetType", -1)) not in [0, 6] \
			or not bool(record.get("inCombat", 0)) \
			or bool(record.get("inCamp", 0)):
		return false
	var has_damage := _has_nonzero_field(
		record,
		["damage1", "damage2", "powerDamage1", "powerDamage2"]
	)
	var has_duration := _has_nonzero_field(
		record,
		["duration1", "duration2", "powerDuration1", "powerDuration2"]
	)
	return not has_damage and has_duration \
		if duration_fields_are_drain else has_damage and not has_duration


func _has_nonzero_field(record: Dictionary, field_names: Array[String]) -> bool:
	for field_name: String in field_names:
		if int(record.get(field_name, 0)) != 0:
			return true
	return false


func _drain_description(corrected_source_defect: bool) -> String:
	var amount := "%d-%d" % [
		get_min_spell_point_drain(1),
		get_max_spell_point_drain(1),
	]
	if not corrected_source_defect:
		amount = "%s at power one, scaling with power" % amount
	return "%s: Drains %s spell points from each affected creature." % [name, amount]
