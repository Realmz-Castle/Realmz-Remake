class_name ClassicCoreUndeadTurningSpell
extends "res://scripts/classic_runtime/classic_core_damage_spell.gd"

const TurnUndeadRulesScript = preload("res://scripts/turn_undead_rules.gd")


func configure_core_undead_turning_spell(spell_id: int) -> bool:
	var inventory: Dictionary = CoreSpellCatalogScript.inventory_spell(spell_id)
	if inventory.is_empty():
		push_error("Classic undead-turning spell %d has no Data S inventory record" % spell_id)
		return false
	var record: Dictionary = inventory.get("record", {}).duplicate(true)
	if not _is_undead_turning_record(record):
		push_error("Classic spell %d is not the special-90 undead spell" % spell_id)
		return false

	_configure_core_record(inventory, record)
	elements = [GameGlobal.ELEMENTS.MAGICAL]
	attributes = ["Magical", "Special"]
	tags = ["Magical", "Undead"]
	# resolvespell.c checks the special DRV before spelllist.c applies the
	# spell's separate destroy-or-turn roll.
	classic_spell_save_index = 7
	classic_spell_save_mode = "negate"
	description = (
		"Destroy / Turn Undead: Tests every hostile undead or nether spawn. "
		+ "Successful lower margins destroy the target; margins of 30 or more "
		+ "turn it to the caster's side for the battle."
	)
	return true


func resolve_classic_target(caster, target, power: int, roll: int) -> Dictionary:
	if not (caster is Object) or not (target is Object):
		return {"status": "ineligible", "outcome": "ineligible"}
	var turning_strength := 5 * maxi(0, power) + 3 * maxi(0, int(caster.get("level")))
	# General magic resistance is resolved by the normal spell pipeline first.
	return TurnUndeadRulesScript.resolve_target(
		caster,
		target,
		turning_strength,
		roll,
		false
	)


func apply_classic_scaled_effect(
	caster,
	target,
	power: int,
	effect_scale: float
) -> bool:
	if effect_scale <= 0.0:
		return false
	var resolution := resolve_classic_target(caster, target, power, randi_range(1, 100))
	return str(resolution.get("outcome", "")) in ["destroyed", "turned"]


func uses_classic_group_effect() -> bool:
	return false


func _is_undead_turning_record(record: Dictionary) -> bool:
	if int(record.get("special", 0)) != 90 \
			or int(record.get("queueIcon", 0)) != 0 \
			or int(record.get("cost", 0)) <= 0 \
			or int(record.get("cannot", 0)) != 2 \
			or int(record.get("targetType", -1)) != 10 \
			or int(record.get("damageType", 0)) != 7 \
			or int(record.get("spellClass", 0)) != 7 \
			or not bool(record.get("inCombat", 0)) \
			or bool(record.get("inCamp", 0)):
		return false
	for field_name: String in [
		"damage1", "damage2", "powerDamage1", "powerDamage2",
		"duration1", "duration2", "powerDuration1", "powerDuration2",
	]:
		if int(record.get(field_name, 0)) != 0:
			return false
	return true
