class_name ClassicCoreStrongSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const TemporaryStrongTrait = preload(
	"res://shared_assets/traits/t_classic_strong.gd"
)
const PermanentStrongTraitName := "p_strong.gd"


func configure_core_strong_spell(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic Strong spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_strong_record(record):
		push_error("Classic spell %d is not a special-22 Strong record" % spell_id)
		return false
	_configure_core_record(inventory, record)
	elements.clear()
	attributes = ["Magical"]
	tags = ["Magical", "Enhancement", "Strong"]
	description = "%s: Adds 15 percentage points to physical accuracy and 3 damage for %s." % [
		name,
		_duration_description(),
	]
	return true


func apply_classic_scaled_effect(
	_caster,
	target,
	power: int,
	effect_scale: float
) -> int:
	if effect_scale <= 0.0:
		return 0
	var duration := get_duration_roll(power, _caster)
	return duration if _apply_duration(target, duration) else 0


# resolvespell.c rolls once before iterating every target in the cast.
func apply_classic_group_effect(
	_caster,
	targets: Array,
	power: int,
	effect_scale := 1.0
) -> int:
	if effect_scale <= 0.0 or targets.is_empty():
		return 0
	var duration := get_duration_roll(power, _caster)
	var affected := 0
	for target: Variant in targets:
		if _apply_duration(target, duration):
			affected += 1
	return affected


func _apply_duration(target: Variant, duration: int) -> bool:
	if duration <= 0 or not (target is Object) or not target.has_method("add_trait"):
		return false
	var traits: Variant = target.get("traits")
	if not (traits is Array):
		return false
	var current_duration := 0
	for trait_value: Variant in traits:
		if not (trait_value is Object):
			continue
		var trait_name := str(trait_value.get("name"))
		if trait_name == PermanentStrongTraitName:
			return false
		if trait_name == TemporaryStrongTrait.name:
			current_duration = ceili(float(trait_value.get("duration_seconds")) / 5.0)
	var condition_cap := 99 if _is_player_character(target) else 124
	if current_duration + duration > condition_cap:
		return false
	target.add_trait(TemporaryStrongTrait, [duration])
	return true


func _is_player_character(target: Object) -> bool:
	return target is PlayerCharacter or bool(target.get("is_player_controlled"))


func _is_strong_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) != 22 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or absi(int(record.get("damageType", 0))) != 8 \
			or absi(int(record.get("spellClass", 0))) != 8 \
			or int(record.get("cannot", 0)) != 4 \
			or not bool(record.get("inCombat", 0)) \
			or not bool(record.get("inCamp", 0)) \
			or int(record.get("targetType", -1)) != 0:
		return false
	for field_name: String in ["damage1", "damage2", "powerDamage1", "powerDamage2"]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return int(record.get("duration1", 0)) > 0 \
		or int(record.get("powerDuration1", 0)) > 0


func _duration_description() -> String:
	if _power_duration_low > 0:
		return "%d-%d rounds per power" % [
			_power_duration_low,
			_power_duration_high,
		]
	return "%d-%d rounds" % [_duration_low, _duration_high]
