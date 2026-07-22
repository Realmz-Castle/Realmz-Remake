class_name ClassicCorePoisonSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const PermanentPoisonTrait = preload(
	"res://shared_assets/traits/p_poison.gd"
)
const PoisonRules = preload(
	"res://scripts/classic_runtime/classic_poison.gd"
)

var _shared_condition := 0
var _has_shared_condition := false


func configure_core_poison_spell(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic poison spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_poison_record(record):
		push_error("Classic spell %d is not the special-10 Poison record" % spell_id)
		return false
	_configure_core_record(inventory, record)
	attributes = ["Magical", "Chemical"]
	if not tags.has("Poison"):
		tags.append("Poison")
	description = (
		"Poison: Deals 2 chemical damage and inflicts permanent poison for "
		+ "2 damage per round or game hour until cured."
	)
	return true


func begin_classic_target_resolution(caster, power: int) -> void:
	_shared_condition = get_duration_roll(power, caster)
	_has_shared_condition = true


func end_classic_target_resolution() -> void:
	_shared_condition = 0
	_has_shared_condition = false


func add_traits_to_creature(caster, target, power: int) -> void:
	var condition := _shared_condition if _has_shared_condition \
		else get_duration_roll(power, caster)
	PoisonRules.apply_spell_condition(target, absi(condition), PermanentPoisonTrait)


func _is_poison_record(record: Dictionary) -> bool:
	return absi(int(record.get("special", 0))) == 10 \
		and int(record.get("queueIcon", 0)) == 0 \
		and int(record.get("cost", 0)) > 0 \
		and int(record.get("cannot", 0)) == 0 \
		and absi(int(record.get("damageType", 0))) == 4 \
		and absi(int(record.get("spellClass", 0))) == 4 \
		and bool(record.get("inCombat", 0)) \
		and not bool(record.get("inCamp", 0)) \
		and int(record.get("targetType", -1)) == 0 \
		and int(record.get("range1", 0)) == 1 \
		and int(record.get("range2", 0)) == 0 \
		and int(record.get("size", 0)) == 0 \
		and int(record.get("damage1", 0)) == 2 \
		and int(record.get("damage2", 0)) == 2 \
		and int(record.get("powerDamage1", 0)) == 0 \
		and int(record.get("powerDamage2", 0)) == 0 \
		and int(record.get("duration1", 0)) == -2 \
		and int(record.get("duration2", 0)) == -2 \
		and int(record.get("powerDuration1", 0)) == 0 \
		and int(record.get("powerDuration2", 0)) == 0
