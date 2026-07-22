class_name ClassicCoreRegenerationSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const RegenerationRules = preload(
	"res://scripts/classic_runtime/classic_regeneration.gd"
)
const RegenerationTrait = preload(
	"res://shared_assets/traits/t_classic_regeneration.gd"
)


func configure_core_regeneration_spell(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic regeneration spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_regeneration_record(record):
		push_error("Classic spell %d is not a special-11 regeneration record" % spell_id)
		return false
	_configure_core_record(inventory, record)
	elements.clear()
	attributes = ["Magical"]
	tags = ["Magical", "Regeneration"]
	description = _regeneration_description()
	return true


func apply_classic_scaled_effect(
	caster,
	target,
	power: int,
	effect_scale: float
) -> int:
	if effect_scale <= 0.0:
		return 0
	var duration := get_duration_roll(power, caster)
	return duration if _apply_duration(target, duration) else 0


# Classic resolves one duration roll before iterating every target in a cast.
func apply_classic_group_effect(
	caster,
	targets: Array,
	power: int,
	effect_scale := 1.0
) -> int:
	if effect_scale <= 0.0 or targets.is_empty():
		return 0
	var duration := get_duration_roll(power, caster)
	var affected := 0
	for target: Variant in targets:
		if _apply_duration(target, duration):
			affected += 1
	return affected


func _apply_duration(target: Variant, duration: int) -> bool:
	if not (target is Object) or not target.has_method("add_trait"):
		return false
	# Negative condition 10 is innate regeneration and cannot receive this spell.
	if RegenerationRules.amount(target) > 0:
		return false
	target.add_trait(RegenerationTrait, [duration])
	return true


func _is_regeneration_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) != 11 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or absi(int(record.get("damageType", 0))) != 7 \
			or absi(int(record.get("spellClass", 0))) != 7 \
			or int(record.get("cannot", 0)) != 4 \
			or not bool(record.get("inCombat", 0)) \
			or not bool(record.get("inCamp", 0)):
		return false
	if int(record.get("targetType", -1)) not in [0, 1]:
		return false
	for field_name: String in ["damage1", "damage2", "powerDamage1", "powerDamage2"]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return int(record.get("duration1", 0)) > 0 \
		or int(record.get("powerDuration1", 0)) > 0


func _regeneration_description() -> String:
	if _power_duration_low > 0:
		return "%s: Adds %d-%d regeneration per power." % [
			name, _power_duration_low, _power_duration_high,
		]
	return "%s: Adds %d-%d regeneration." % [
		name, _duration_low, _duration_high,
	]
