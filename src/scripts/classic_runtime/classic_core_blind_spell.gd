class_name ClassicCoreBlindSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const PermanentAfflictionScript = preload(
	"res://scripts/classic_runtime/classic_permanent_affliction.gd"
)


func configure_core_blind_spell(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic blindness spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_blindness_record(record):
		push_error("Classic spell %d is not a special-28 blindness record" % spell_id)
		return false
	_configure_core_record(inventory, record)
	elements.clear()
	attributes = ["Magical", "Special"]
	tags = ["Magical", "Blindness"]
	description = (
		"%s: Permanently blinds one creature per power, reducing its melee and "
		+ "ranged accuracy and evasion by 15 percentage points."
	) % name
	return true


func apply_classic_scaled_effect(
	_caster,
	target,
	_power: int,
	effect_scale: float
) -> bool:
	if effect_scale <= 0.0 or not (target is Object):
		return false
	# resolvespell.c also feeds the -1 duration into a stale disease-damage path,
	# which heals one point. That unrelated side effect is not part of Blind.
	return PermanentAfflictionScript.apply_blindness(target)


func _is_blindness_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) != 28 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or int(record.get("targetType", -1)) != 0 \
			or int(record.get("fixedTargetNum", 0)) != 0 \
			or int(record.get("range1", 0)) != 1 \
			or int(record.get("range2", 0)) != 0 \
			or int(record.get("cannot", 0)) != 0 \
			or absi(int(record.get("damageType", 0))) != 7 \
			or absi(int(record.get("spellClass", 0))) != 7 \
			or not bool(record.get("inCombat", 0)) \
			or bool(record.get("inCamp", 0)):
		return false
	for field_name: String in [
		"damage1", "damage2", "powerDamage1", "powerDamage2",
		"powerDuration1", "powerDuration2",
	]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return int(record.get("duration1", 0)) == -1 \
		and int(record.get("duration2", 0)) == -1
