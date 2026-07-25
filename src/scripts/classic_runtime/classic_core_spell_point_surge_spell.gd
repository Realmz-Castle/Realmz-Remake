class_name ClassicCoreSpellPointSurgeSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const SpellPointMutationScript = preload(
	"res://scripts/classic_runtime/classic_spell_point_mutation.gd"
)


func configure_core_spell_point_surge(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic Power Surge %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_spell_point_surge_record(record):
		push_error("Classic spell %d is not a supported special-59 record" % spell_id)
		return false

	_configure_core_record(inventory, record)
	classic_spell_save_index = -1
	classic_spell_save_mode = "none"
	description = "%s: Restores 5-8 spell points per power." % name
	return true


func configure_custom_spell_point_surge(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) != 59 \
			or not bool(record.get("inCombat", false)) \
			or not _has_nonzero_field(
				record,
				["damage1", "damage2", "powerDamage1", "powerDamage2"]
			) \
			or _has_nonzero_field(
				record,
				["duration1", "duration2", "powerDuration1", "powerDuration2"]
			):
		return false
	_configure_custom_record(record)
	classic_spell_save_index = -1
	classic_spell_save_mode = "none"
	if not tags.has("Spell Point Recovery"):
		tags.append("Spell Point Recovery")
	description = "%s: Restores spell points using its authored damage roll." % name
	return true


func is_generically_executable() -> bool:
	return classic_special == 59


func get_min_spell_point_gain(power: int) -> int:
	return get_min_damage(power, null)


func get_max_spell_point_gain(power: int) -> int:
	return get_max_damage(power, null)


func get_spell_point_gain_roll(power: int) -> int:
	return get_damage_roll(power, null)


func apply_power_surge(target: Object, power: int, effect_scale := 1.0) -> int:
	return SpellPointMutationScript.gain(
		target,
		get_spell_point_gain_roll(power),
		effect_scale
	)


func apply_classic_scaled_effect(
	_caster,
	target,
	power: int,
	effect_scale: float
) -> int:
	return apply_power_surge(target, power, effect_scale)


func _is_spell_point_surge_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) != 59 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or int(record.get("cannot", 0)) != 4 \
			or absi(int(record.get("damageType", 0))) != 8 \
			or absi(int(record.get("spellClass", 0))) != 8 \
			or int(record.get("targetType", -1)) != 1 \
			or not bool(record.get("inCombat", 0)) \
			or not bool(record.get("inCamp", 0)):
		return false
	if not _has_nonzero_field(
		record,
		["damage1", "damage2", "powerDamage1", "powerDamage2"]
	):
		return false
	return not _has_nonzero_field(
		record,
		["duration1", "duration2", "powerDuration1", "powerDuration2"]
	)


func _has_nonzero_field(record: Dictionary, field_names: Array[String]) -> bool:
	for field_name: String in field_names:
		if int(record.get(field_name, 0)) != 0:
			return true
	return false
