class_name ClassicCoreAnimationSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const PermanentAnimatedTrait = preload(
	"res://shared_assets/traits/p_classic_animated.gd"
)


func configure_core_animation_spell(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic animation spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_animation_record(record):
		push_error("Classic spell %d is not a special-26 animation record" % spell_id)
		return false
	_configure_core_record(inventory, record)
	elements.clear()
	attributes = ["Magical", "Special"]
	tags = ["Magical", "Animation"]
	description = (
		"%s: Permanently animates dead characters at one-quarter health. "
		+ "Animated characters fight automatically and cannot gain experience, "
		+ "cast spells, or use missile weapons."
	) % name
	# Camp target type zero uses Classic's party picker for one character per power.
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
			or not target.has_method("add_trait"):
		return false
	var stats: Variant = target.get("stats")
	if not (stats is Dictionary) or int(stats.get("curHP", 0)) >= -9:
		return false
	stats["curHP"] = floori(float(stats.get("maxHP", 0)) / 4.0)
	target.set("life_status", 0)
	target.add_trait(PermanentAnimatedTrait, [])
	return true


func _is_animation_record(record: Dictionary) -> bool:
	if absi(int(record.get("special", 0))) != 26 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or int(record.get("targetType", -1)) != 0 \
			or int(record.get("range1", 0)) != 0 \
			or int(record.get("range2", 0)) != 0 \
			or int(record.get("cannot", 0)) != 3 \
			or absi(int(record.get("damageType", 0))) != 7 \
			or absi(int(record.get("spellClass", 0))) != 7 \
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
