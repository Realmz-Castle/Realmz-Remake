class_name ClassicCoreCurseRemovalSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const ConditionCureScript = preload(
	"res://scripts/classic_runtime/classic_condition_cure.gd"
)
const InventoryRulesScript = preload(
	"res://scripts/classic_runtime/classic_inventory_rules.gd"
)


func configure_core_curse_removal_spell(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic curse removal %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_curse_removal_record(record):
		push_error("Classic spell %d is not a special-62 curse removal" % spell_id)
		return false

	_configure_core_record(inventory, record)
	elements.clear()
	attributes = ["Magical", "Special"]
	tags = ["Magical", "Restoration"]
	description = (
		"%s: Clears curse effects and forcibly unequips every cursed item "
		+ "worn by each selected character without removing it from inventory."
	) % name
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
	var changed := ConditionCureScript.clear_condition(target, 3)
	var inventory_result: Dictionary = InventoryRulesScript.remove_equipped_cursed_items(
		target
	)
	if inventory_result.get("status") == "error":
		push_warning(str(inventory_result.get("message", "Classic curse removal failed")))
		return changed
	return changed + int(inventory_result.get("unequipped", 0))


func _is_curse_removal_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) != 62 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or int(record.get("targetType", -1)) != 0 \
			or int(record.get("cannot", 0)) != 4 \
			or int(record.get("damageType", 0)) != 7 \
			or int(record.get("spellClass", 0)) != 7 \
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
