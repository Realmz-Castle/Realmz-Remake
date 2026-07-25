class_name ClassicCoreLethalSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const AreaPatternsScript = preload(
	"res://scripts/classic_runtime/classic_spell_area_patterns.gd"
)


func configure_core_lethal_spell(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic lethal spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_lethal_record(record):
		push_error("Classic spell %d is not a special-49 lethal record" % spell_id)
		return false

	_configure_core_record(inventory, record)
	attributes = ["Magical", _lethal_attribute(classic_damage_type)]
	if not tags.has("Instant Death"):
		tags.append("Instant Death")
	description = _lethal_description()
	return true


func configure_custom_lethal_spell(record: Dictionary) -> bool:
	var source := record.duplicate(true)
	var raw_damage_type := int(source.get("damageType", 0))
	if raw_damage_type > 127 and raw_damage_type <= 255:
		source["damageType"] = raw_damage_type - 256
	if not _is_lethal_record(source):
		return false
	configure(source)
	attributes = ["Magical", _lethal_attribute(classic_damage_type)]
	if not tags.has("Instant Death"):
		tags.append("Instant Death")
	description = _lethal_description()
	return true


func is_generically_executable() -> bool:
	return true


func apply_classic_scaled_effect(
	_caster,
	target,
	power: int,
	effect_scale: float
) -> bool:
	if effect_scale <= 0.0 or not (target is Object) \
			or not target.has_method("change_cur_hp"):
		return false
	var stats: Variant = target.get("stats")
	if not (stats is Dictionary):
		return false
	var current_health := int(stats.get("curHP", 0))
	if current_health <= 0:
		return false

	if effect_scale < 1.0 and _has_fallback_damage():
		var damage := floori(float(get_damage_roll(power, _caster)) * effect_scale)
		if damage <= 0:
			return false
		target.change_cur_hp(-damage)
		return true

	# spelllist.c derives lethal damage from current stamina. Set the final value
	# explicitly because Creature's field path otherwise leaves deaths unconscious.
	target.change_cur_hp(-10 - current_health)
	stats["curHP"] = -10
	target.set("life_status", 3)
	return true


func get_aoe(power: int, caster) -> Array[Vector2i]:
	if classic_target_type == 3:
		return AreaPatternsScript.pattern(classic_size)
	return super.get_aoe(power, caster)


func _is_lethal_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) != 49 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or int(record.get("cannot", 0)) != 0 \
			or not bool(record.get("inCombat", 0)) \
			or bool(record.get("inCamp", 0)) \
			or int(record.get("targetType", -1)) not in [1, 3] \
			or absi(int(record.get("damageType", 0))) not in [4, 7]:
		return false
	for field_name: String in [
		"duration1", "duration2", "powerDuration1", "powerDuration2",
	]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return true


func _has_fallback_damage() -> bool:
	return _damage_low != 0 or _damage_high != 0 \
		or _power_damage_low != 0 or _power_damage_high != 0


func _lethal_description() -> String:
	if _has_fallback_damage():
		return (
			"%s: Kills creatures that fail their save; successful saves take half "
			+ "of its %d-%d chemical damage roll per power."
		) % [name, _power_damage_low, _power_damage_high]
	return "%s: Kills creatures that fail their Classic resistance and save checks." % name


func _lethal_attribute(damage_type: int) -> String:
	return "Chemical" if damage_type == 4 else "Special"
