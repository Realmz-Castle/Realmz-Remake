class_name ClassicCoreTimedConditionSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

var _temporary_condition_trait: GDScript
var _conflicting_condition_traits: Array[String] = []


func configure_core_timed_condition_spell(
	spell_id: int,
	special_code: int,
	temporary_trait: GDScript,
	conflicting_traits: Array[String],
	allowed_target_types: Array[int],
	allowed_cannot_values: Array[int],
	effect_description: String,
	condition_tags: Array[String],
	required_damage_type := 8,
	required_spell_class := 8,
	required_in_camp := true
) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic condition spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_timed_condition_record(
		record,
		special_code,
		allowed_target_types,
		allowed_cannot_values,
		required_damage_type,
		required_spell_class,
		required_in_camp
	):
		push_error(
			"Classic spell %d is not a special-%d timed condition record"
			% [spell_id, special_code]
		)
		return false
	_temporary_condition_trait = temporary_trait
	_conflicting_condition_traits = conflicting_traits.duplicate()
	_configure_core_record(inventory, record)
	elements.clear()
	attributes = ["Magical"]
	tags = ["Magical"]
	for condition_tag: String in condition_tags:
		if not tags.has(condition_tag):
			tags.append(condition_tag)
	description = "%s: %s for %s." % [
		name,
		effect_description,
		_duration_description(),
	]
	return true


func apply_classic_scaled_effect(
	_caster,
	target,
	power: int,
	effect_scale: float
) -> int:
	if effect_scale <= 0.0:
		return 0
	var duration := get_duration_roll(power, _caster)
	return duration if _apply_duration(target, duration) else 0


# resolvespell.c rolls once before iterating every target in the cast.
func apply_classic_group_effect(
	_caster,
	targets: Array,
	power: int,
	effect_scale := 1.0
) -> int:
	if effect_scale <= 0.0 or targets.is_empty():
		return 0
	var duration := get_duration_roll(power, _caster)
	var affected := 0
	for target: Variant in targets:
		if _apply_duration(target, duration):
			affected += 1
	return affected


func _apply_duration(target: Variant, duration: int) -> bool:
	return apply_condition_duration(
		target,
		duration,
		_temporary_condition_trait,
		_conflicting_condition_traits
	)


static func apply_condition_duration(
	target: Variant,
	duration: int,
	temporary_condition_trait: GDScript,
	conflicting_condition_traits: Array[String]
) -> bool:
	if duration <= 0 or temporary_condition_trait == null \
			or not (target is Object) or not target.has_method("add_trait"):
		return false
	var traits: Variant = target.get("traits")
	if not (traits is Array):
		return false
	var temporary_name := temporary_condition_trait.resource_path.get_file()
	var current_duration := 0
	for trait_value: Variant in traits:
		if not (trait_value is Object):
			continue
		var trait_name := str(trait_value.get("name"))
		if conflicting_condition_traits.has(trait_name):
			return false
		if trait_name == temporary_name:
			var stored_duration: Variant = trait_value.get("duration_seconds")
			if stored_duration == null:
				# Older native traits store the same value under `duration`.
				stored_duration = trait_value.get("duration")
			if stored_duration == null:
				return false
			current_duration = ceili(float(stored_duration) / 5.0)
	var condition_cap := 99 if _is_player_character(target) else 124
	if current_duration + duration > condition_cap:
		return false
	target.add_trait(temporary_condition_trait, [duration])
	return true


static func _is_player_character(target: Object) -> bool:
	return target is PlayerCharacter or bool(target.get("is_player_controlled"))


func _is_timed_condition_record(
	record: Dictionary,
	special_code: int,
	allowed_target_types: Array[int],
	allowed_cannot_values: Array[int],
	required_damage_type: int,
	required_spell_class: int,
	required_in_camp: bool
) -> bool:
	if absi(int(record.get("special", 0))) != special_code \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or absi(int(record.get("damageType", 0))) != required_damage_type \
			or absi(int(record.get("spellClass", 0))) != required_spell_class \
			or int(record.get("cannot", 0)) not in allowed_cannot_values \
			or not bool(record.get("inCombat", 0)) \
			or bool(record.get("inCamp", 0)) != required_in_camp \
			or int(record.get("targetType", -1)) not in allowed_target_types:
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
