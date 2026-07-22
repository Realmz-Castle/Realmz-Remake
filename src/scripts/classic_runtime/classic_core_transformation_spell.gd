class_name ClassicCoreTransformationSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const TransformationScript = preload(
	"res://scripts/classic_runtime/classic_monster_transformation.gd"
)


func configure_core_transformation_spell(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic transformation spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_transformation_record(record):
		push_error("Classic spell %d is not a special-46 transformation record" % spell_id)
		return false

	_configure_core_record(inventory, record)
	attributes = ["Magical", "Special"]
	if not tags.has("Transformation"):
		tags.append("Transformation")
	description = (
		"%s: Replaces affected monsters with random summonable creatures "
		+ "of the same size for the rest of the battle."
	) % name
	return true


func apply_classic_scaled_effect(
	_caster,
	target,
	_power: int,
	effect_scale: float
) -> bool:
	return effect_scale > 0.0 and TransformationScript.transform(target)


func apply_classic_form(target: Object, replacement: Object) -> bool:
	return TransformationScript.apply_form(target, replacement)


func _is_transformation_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) != 46 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or int(record.get("cannot", 0)) != 0 \
			or not bool(record.get("inCombat", 0)) \
			or bool(record.get("inCamp", 0)) \
			or int(record.get("targetType", -1)) not in [1, 4] \
			or absi(int(record.get("damageType", 0))) != 7:
		return false
	for field_name: String in [
		"damage1", "damage2", "powerDamage1", "powerDamage2",
		"duration1", "duration2", "powerDuration1", "powerDuration2",
	]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return true
