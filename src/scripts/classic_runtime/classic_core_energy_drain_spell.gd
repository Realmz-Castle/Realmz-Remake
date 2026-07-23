class_name ClassicCoreEnergyDrainSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const TimedConditionSpell = preload(
	"res://scripts/classic_runtime/classic_core_timed_condition_spell.gd"
)
const EnergyDrainTrait = preload(
	"res://shared_assets/traits/t_classic_power_wither.gd"
)


func configure_core_energy_drain_spell(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic energy-drain spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_energy_drain_record(record):
		push_error("Classic spell %d is not a special-35 energy-drain record" % spell_id)
		return false
	_configure_core_record(inventory, record)
	if not tags.has("Spell Point Drain"):
		tags.append("Spell Point Drain")
	description = _energy_drain_description()
	return true


func add_traits_to_creature(caster, target, power: int) -> void:
	apply_energy_drain_duration(target, get_duration_roll(power, caster))


func apply_energy_drain_duration(target: Variant, duration: int) -> bool:
	return TimedConditionSpell.apply_condition_duration(
		target,
		duration,
		EnergyDrainTrait,
		["p_classic_power_wither.gd"]
	)


func _is_energy_drain_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) != 35 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or absi(int(record.get("damageType", 0))) != 7 \
			or absi(int(record.get("spellClass", 0))) != 7 \
			or int(record.get("cannot", 0)) != 0 \
			or not bool(record.get("inCombat", 0)) \
			or bool(record.get("inCamp", 0)) \
			or int(record.get("targetType", -1)) != 1:
		return false
	for field_name: String in ["powerDamage1", "powerDamage2"]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return int(record.get("duration1", 0)) > 0 \
		or int(record.get("powerDuration1", 0)) > 0


func _energy_drain_description() -> String:
	var immediate_damage := ""
	if _damage_low != 0 or _damage_high != 0:
		immediate_damage = " Deals %d-%d immediate special damage." % [
			_damage_low,
			_damage_high,
		]
	return "%s: Drains spell points equal to its remaining condition each round.%s" % [
		name,
		immediate_damage,
	]
