class_name ClassicCoreDiseaseSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const DiseaseTrait = preload(
	"res://shared_assets/traits/t_classic_disease.gd"
)

# resolvespell.c rolls duration before its target loop, so every affected
# creature receives the same condition value from a multi-target cast.
var _shared_condition := 0
var _has_shared_condition := false


func configure_core_disease_spell(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic disease spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_disease_record(record):
		push_error("Classic spell %d is not a special-29 disease record" % spell_id)
		return false
	_configure_core_record(inventory, record)
	attributes = ["Magical", "Chemical"]
	if not tags.has("Disease"):
		tags.append("Disease")
	description = _disease_description()
	return true


func begin_classic_target_resolution(caster, power: int) -> void:
	_shared_condition = get_duration_roll(power, caster)
	_has_shared_condition = true


func end_classic_target_resolution() -> void:
	_shared_condition = 0
	_has_shared_condition = false


func add_traits_to_creature(caster, target, power: int) -> void:
	if not (target is Object) or not target.has_method("add_trait"):
		return
	var condition := _shared_condition if _has_shared_condition \
		else get_duration_roll(power, caster)
	if condition != 0:
		target.add_trait(DiseaseTrait, [condition])


func _is_disease_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) != 29 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or int(record.get("cannot", 0)) != 0 \
			or absi(int(record.get("damageType", 0))) != 4 \
			or absi(int(record.get("spellClass", 0))) != 4 \
			or not bool(record.get("inCombat", 0)) \
			or bool(record.get("inCamp", 0)):
		return false
	if int(record.get("duration1", 0)) != 0 \
			or int(record.get("duration2", 0)) != 0:
		return false
	var target_type := int(record.get("targetType", -1))
	var power_duration_low := int(record.get("powerDuration1", 0))
	var power_duration_high := int(record.get("powerDuration2", 0))
	if target_type == 10:
		return int(record.get("range1", 0)) == 0 \
			and int(record.get("range2", 0)) == 0 \
			and int(record.get("size", 0)) == 0 \
			and not _has_damage(record) \
			and power_duration_low > 0 \
			and power_duration_high > 0
	if target_type == 3:
		return int(record.get("range1", 0)) == 5 \
			and int(record.get("range2", 0)) == 0 \
			and int(record.get("size", 0)) == 4 \
			and int(record.get("damage1", 0)) == 0 \
			and int(record.get("damage2", 0)) == 0 \
			and int(record.get("powerDamage1", 0)) == 2 \
			and int(record.get("powerDamage2", 0)) == 2 \
			and power_duration_low == -2 \
			and power_duration_high == -2
	return false


func _has_damage(record: Dictionary) -> bool:
	for field_name: String in ["damage1", "damage2", "powerDamage1", "powerDamage2"]:
		if int(record.get(field_name, 0)) != 0:
			return true
	return false


func _disease_description() -> String:
	if _power_duration_low < 0:
		return (
			"%s: Deals %d chemical damage per power and inflicts permanent disease "
			+ "for %d damage per round per power until cured."
		) % [name, _power_damage_low, absi(_power_duration_low)]
	return "%s: Diseases every enemy for %d-%d rounds per power." % [
		name,
		_power_duration_low,
		_power_duration_high,
	]
