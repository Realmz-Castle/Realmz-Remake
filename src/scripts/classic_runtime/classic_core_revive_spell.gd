class_name ClassicCoreReviveSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const ConditionCureScript = preload(
	"res://scripts/classic_runtime/classic_condition_cure.gd"
)
const AnimationScript = preload(
	"res://scripts/classic_runtime/classic_animation.gd"
)

# This is character.spec[2] in Classic's spelllist.c.
const RESURRECT_ABILITY_INDEX := 2


func configure_core_revive_spell(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic revive spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_revive_record(record):
		push_error("Classic spell %d is not a special-64 revive record" % spell_id)
		return false
	_configure_core_record(inventory, record)
	elements.clear()
	attributes = ["Magical", "Special"]
	tags = ["Magical", "Restoration"]
	description = (
		"Revive Dead: Returns a dead or animated character at -9 health and "
		+ "reduces their Classic Resurrect ability by 2. Petrified characters "
		+ "cannot be revived."
	)
	# Special 64 is camp-only. Classic uses the party portrait picker even
	# though its combat range fields are both zero.
	skip_targeting = false
	autotarget_type = AUTOTARGET_TYPE.NONE
	targettile = TARGET_TILE.CREATURE
	return true


func apply_classic_scaled_effect(
	_caster,
	target,
	_power: int,
	effect_scale: float
) -> bool:
	if effect_scale <= 0.0 or not (target is Object) \
			or ConditionCureScript.has_condition(target, 26):
		return false
	var stats: Variant = target.get("stats")
	if not (stats is Dictionary):
		return false
	var animated := AnimationScript.is_animated(target)
	if int(stats.get("curHP", 0)) >= -9 and not animated:
		return false
	AnimationScript.remove_animation_traits(target)
	stats["curHP"] = -9
	target.set("life_status", 2)
	if target.has_method("change_classic_special_ability"):
		target.change_classic_special_ability(RESURRECT_ABILITY_INDEX, -2)
	return true

func _is_revive_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) != 64 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("targetType", 0)) != 0 \
			or int(record.get("range1", 0)) != 0 \
			or int(record.get("range2", 0)) != 0 \
			or bool(record.get("inCombat", 0)) \
			or not bool(record.get("inCamp", 0)):
		return false
	for field_name: String in [
		"damage1", "damage2", "powerDamage1", "powerDamage2",
		"duration1", "duration2", "powerDuration1", "powerDuration2",
	]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return true
