class_name ClassicCoreSpellScreenSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const SpellScreenScript = preload(
	"res://scripts/classic_runtime/classic_spell_screen.gd"
)
const TemporaryScreenTrait = preload(
	"res://shared_assets/traits/t_classic_spell_screen.gd"
)


func configure_core_spell_screen(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic spell screen %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_spell_screen_record(record):
		push_error("Classic spell %d is not a spell-screen record" % spell_id)
		return false
	_configure_core_record(inventory, record)
	var screen_level := _screen_level()
	elements = [GameGlobal.ELEMENTS.MAGICAL]
	attributes = ["Magical"]
	tags = ["Magical", "Protection", "Spell Screen"]
	description = "%s: Blocks spells through level %d for %s." % [
		name,
		screen_level,
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
	var screen_level := _screen_level()
	var innate_level := clampi(
		int(target.get_meta(SpellScreenScript.META_KEY, 0)),
		0,
		5
	)
	if innate_level >= screen_level:
		return false
	var current_duration := SpellScreenScript.temporary_duration(target, screen_level)
	var condition_cap := 99 if _is_player_character(target) else 124
	if current_duration + duration > condition_cap:
		return false
	target.add_trait(TemporaryScreenTrait, [screen_level, duration])
	return true


func _screen_level() -> int:
	return classic_special - 16


func _is_player_character(target: Object) -> bool:
	return target is PlayerCharacter or bool(target.get("is_player_controlled"))


func _is_spell_screen_record(record: Dictionary) -> bool:
	var screen_level := absi(int(record.get("special", 0))) - 16
	if screen_level not in range(1, 6) \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or absi(int(record.get("damageType", 0))) != 8 \
			or absi(int(record.get("spellClass", 0))) != 8 \
			or int(record.get("cannot", 0)) != 4 \
			or not bool(record.get("inCombat", 0)) \
			or not bool(record.get("inCamp", 0)) \
			or int(record.get("targetType", -1)) not in [0, 3, 5]:
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
