class_name ClassicCoreCharmSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const AreaPatternsScript = preload(
	"res://scripts/classic_runtime/classic_spell_area_patterns.gd"
)
const CharmedTrait = preload("res://shared_assets/traits/t_classic_charmed.gd")


func configure_core_charm_spell(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic charm spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_charm_record(record):
		push_error("Classic spell %d is not a charm record" % spell_id)
		return false

	_configure_core_record(inventory, record)
	elements = [GameGlobal.ELEMENTS.MAGICAL, GameGlobal.ELEMENTS.MENTAL]
	attributes = ["Magical", "Mental"]
	if not tags.has("Charm"):
		tags.append("Charm")
	description = "%s: Changes affected creatures' allegiance to the caster for the battle." % name
	return true


func configure_custom_charm_spell(record: Dictionary) -> bool:
	var source := record.duplicate(true)
	var raw_damage_type := int(source.get("damageType", 0))
	if raw_damage_type > 127 and raw_damage_type <= 255:
		source["damageType"] = raw_damage_type - 256
	if not _is_custom_charm_record(source):
		return false
	configure(source)
	elements = [GameGlobal.ELEMENTS.MAGICAL, GameGlobal.ELEMENTS.MENTAL]
	attributes = ["Magical", "Mental"]
	if not tags.has("Charm"):
		tags.append("Charm")
	description = "%s: Changes affected creatures' allegiance to the caster for the battle." % name
	return true


func is_generically_executable() -> bool:
	return true


func apply_classic_scaled_effect(
	caster,
	target,
	_power: int,
	effect_scale: float
) -> bool:
	if effect_scale <= 0.0 or not (target is Object) \
			or not target.has_method("add_trait"):
		return false
	target.add_trait(CharmedTrait, [caster])
	return true


func get_aoe(power: int, caster) -> Array[Vector2i]:
	if classic_target_type == 3:
		return AreaPatternsScript.pattern(classic_size)
	return super.get_aoe(power, caster)


func _is_charm_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) not in [51, 52] \
			or int(record.get("cost", 0)) <= 0 \
			or int(record.get("cannot", 0)) != 0 \
			or not bool(record.get("inCombat", 0)) \
			or bool(record.get("inCamp", 0)) \
			or int(record.get("targetType", -1)) not in [0, 3, 4, 10] \
			or int(record.get("damageType", 0)) != 0:
		return false
	for field_name: String in [
		"damage1", "damage2", "powerDamage1", "powerDamage2",
		"duration1", "duration2", "powerDuration1", "powerDuration2",
	]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return true


func _is_custom_charm_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) not in [51, 52] \
			or int(record.get("cost", 0)) <= 0 \
			or int(record.get("cannot", 0)) != 0 \
			or not bool(record.get("inCombat", 0)) \
			or bool(record.get("inCamp", 0)) \
			or int(record.get("targetType", -1)) not in [0, 3, 4, 10] \
			or absi(int(record.get("damageType", 0))) not in range(0, 8):
		return false
	for field_name: String in [
		"damage1", "damage2", "powerDamage1", "powerDamage2",
		"duration1", "duration2", "powerDuration1", "powerDuration2",
	]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return true
