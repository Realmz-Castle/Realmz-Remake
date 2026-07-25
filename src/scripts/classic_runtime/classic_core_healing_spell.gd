class_name ClassicCoreHealingSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"


func configure_core_healing_spell(
	spell_id: int,
	required_spell_class := 8
) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic healing spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_healing_record(record, required_spell_class):
		push_error("Classic spell %d is not a special-57 healing record" % spell_id)
		return false
	_configure_core_record(inventory, record)
	elements.clear()
	attributes = ["Magical"]
	tags = ["Magical", "Healing"]
	description = "%s: Heals %d-%d health per power." % [
		name,
		get_min_damage(1, null),
		get_max_damage(1, null),
	]
	return true


func configure_custom_healing_spell(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) != 57 \
			or not bool(record.get("inCombat", false)) \
			or not _has_custom_healing_amount(record):
		return false
	_configure_custom_record(record)
	elements.clear()
	attributes = ["Magical"]
	tags = ["Magical", "Healing"]
	description = "%s: Heals %d-%d health at the authored power." % [
		name,
		get_min_damage(1, null),
		get_max_damage(1, null),
	]
	return true


func is_generically_executable() -> bool:
	return classic_special == 57


# Classic resolves special 57 by negating the completed damage roll into healing.
func apply_classic_scaled_effect(
	caster,
	target,
	power: int,
	effect_scale: float
) -> int:
	if effect_scale <= 0.0 \
			or not (target is Object) \
			or not target.has_method("change_cur_hp"):
		return 0
	var healing := floori(get_damage_roll(power, caster) * effect_scale)
	var previous_health: Variant = target.get_stat("curHP") \
		if target.has_method("get_stat") else null
	target.change_cur_hp(healing)
	if previous_health != null and target.has_method("get_stat"):
		return maxi(0, int(target.get_stat("curHP")) - int(previous_health))
	return healing


func _is_healing_record(record: Dictionary, required_spell_class: int) -> bool:
	if absi(int(record.get("special", 0))) != 57 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or int(record.get("targetType", 0)) != 1 \
			or int(record.get("range1", 0)) != 1 \
			or int(record.get("range2", 0)) != 0 \
			or absi(int(record.get("damageType", 0))) != 8 \
			or int(record.get("cannot", 0)) != 4 \
			or not bool(record.get("inCombat", 0)) \
			or not bool(record.get("inCamp", 0)):
		return false
	if absi(int(record.get("spellClass", 0))) != required_spell_class:
		return false
	for field_name: String in [
		"damage1", "damage2", "duration1", "duration2",
		"powerDuration1", "powerDuration2",
	]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return int(record.get("powerDamage1", 0)) > 0 \
		and int(record.get("powerDamage2", 0)) > 0


func _has_custom_healing_amount(record: Dictionary) -> bool:
	for field_name: String in [
		"damage1", "damage2", "powerDamage1", "powerDamage2",
	]:
		if int(record.get(field_name, 0)) != 0:
			return true
	return false
