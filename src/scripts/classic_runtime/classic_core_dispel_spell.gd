class_name ClassicCoreDispelSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const DispelScript = preload("res://scripts/classic_runtime/classic_dispel.gd")


func configure_core_dispel_spell(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic dispel %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_dispel_record(record):
		push_error("Classic spell %d is not a special-61 dispel" % spell_id)
		return false

	_configure_core_record(inventory, record)
	elements.clear()
	attributes = ["Magical", "Special"]
	tags = ["Magical", "Dispel"]
	description = (
		"Destroy Magic: Removes temporary condition effects from one selected "
		+ "creature per power while preserving permanent conditions."
	)
	classic_spell_save_index = -1
	classic_spell_save_mode = "none"
	resist = RESIST_TYPE.IGNORE_MRES_DODGE
	return true


func apply_classic_scaled_effect(
	_caster,
	target,
	_power: int,
	effect_scale: float
) -> int:
	if effect_scale <= 0.0 or not (target is Object):
		return 0
	return DispelScript.apply(target).get("removed", []).size()


func _is_dispel_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) != 61 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or int(record.get("targetType", -1)) != 0 \
			or int(record.get("cannot", 0)) not in [3, 4] \
			or int(record.get("damageType", 0)) != 8 \
			or int(record.get("spellClass", 0)) != 8 \
			or not bool(record.get("inCombat", 0)) \
			or not bool(record.get("inCamp", 0)):
		return false
	for field_name: String in [
		"damage1", "damage2", "powerDamage1", "powerDamage2",
		"duration1", "duration2", "powerDuration1", "powerDuration2",
	]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return true
