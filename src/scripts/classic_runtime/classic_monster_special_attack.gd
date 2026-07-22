class_name ClassicMonsterSpecialAttack
extends RefCounted

const SpellSavesScript = preload("res://scripts/classic_runtime/classic_spell_saves.gd")
const StatusAttackScript = preload(
	"res://scripts/classic_runtime/classic_monster_status_attack.gd"
)
const PermanentAfflictionScript = preload(
	"res://scripts/classic_runtime/classic_permanent_affliction.gd"
)
const CharmedTrait = preload("res://shared_assets/traits/t_classic_charmed.gd")

const SAVE_BY_SPECIAL := {
	8: 6,
	9: 5,
	10: 0,
	18: 7,
	19: 7,
}


static func supports(special_code: int) -> bool:
	return StatusAttackScript.supports(special_code) or SAVE_BY_SPECIAL.has(special_code)


static func apply_from_weapon(
	attacker: Object,
	target: Object,
	weapon: Dictionary,
	save_roll := -1,
	party_charm_bonus := 0
) -> Dictionary:
	var extra_data: Variant = weapon.get("extra_data", {})
	if not (extra_data is Dictionary):
		return {"handled": false}
	var special_code := int(extra_data.get("classicSpecialAttack", 0))
	if not supports(special_code):
		return {"handled": false}
	return apply(attacker, target, special_code, save_roll, party_charm_bonus)


static func apply(
	attacker: Object,
	target: Object,
	special_code: int,
	save_roll := -1,
	party_charm_bonus := 0
) -> Dictionary:
	if StatusAttackScript.supports(special_code):
		return StatusAttackScript.apply(attacker, target, special_code, -1, save_roll)
	if not SAVE_BY_SPECIAL.has(special_code):
		return {"handled": false}
	if attacker == null or target == null \
			or not attacker.has_method("get_stat") \
			or not target.has_method("get_stat"):
		return _error("Classic monster special attack has an invalid combatant")

	var is_monster_target := target.has_meta("classic_hit_dice")
	var result := {
		"handled": true,
		"status": "ok",
		"specialCode": special_code,
		"saveIndex": int(SAVE_BY_SPECIAL[special_code]),
		"applied": false,
	}
	if is_monster_target \
			and int(target.get_meta("classic_magic_resistance", 0)) > 100:
		result["blockedByMagicResistance"] = true
		return result
	# Drain Victory has no monster-target case in attack.c.
	if special_code == 9 and is_monster_target:
		result["partyTargetOnly"] = true
		return result

	var actual_save_roll := save_roll if save_roll >= 0 else randi_range(1, 100)
	var save_chance := SpellSavesScript.monster_attack_save_chance_for(
		target,
		int(result["saveIndex"]),
		party_charm_bonus if special_code == 10 else 0
	)
	result["saveChance"] = save_chance
	result["saveRoll"] = actual_save_roll
	result["saved"] = actual_save_roll <= save_chance
	if bool(result["saved"]):
		return result

	match special_code:
		8:
			return _drain_spell_points(attacker, target, result)
		9:
			return _drain_experience(attacker, target, result)
		10:
			return _charm(attacker, target, result)
		18:
			return _blind(target, result)
		19:
			return _petrify(target, result)
	return result


static func _drain_spell_points(
	attacker: Object,
	target: Object,
	result: Dictionary
) -> Dictionary:
	var attacker_stats: Variant = _property_value(attacker, "stats")
	var target_stats: Variant = _property_value(target, "stats")
	if not (attacker_stats is Dictionary) or not (target_stats is Dictionary):
		return _error("Classic spell-point drain requires mutable combat stats")
	var target_spell_points := maxi(0, int(target_stats.get("curSP", 0)))
	if target_spell_points == 0:
		result["drainedSpellPoints"] = 0
		return result
	var hit_dice := maxi(0, int(attacker.get_meta("classic_hit_dice", 0)))
	var drained := mini(target_spell_points, hit_dice * 3)
	target_stats["curSP"] = target_spell_points - drained
	# Classic lets the attacker retain drained points above its normal maximum.
	attacker_stats["curSP"] = int(attacker_stats.get("curSP", 0)) + drained
	result["drainedSpellPoints"] = drained
	result["applied"] = drained > 0
	return result


static func _drain_experience(
	attacker: Object,
	target: Object,
	result: Dictionary
) -> Dictionary:
	if not _has_property(target, "exp_tnl"):
		return _error("Classic experience drain requires player experience state")
	var penalty := maxi(0, int(attacker.get_stat("maxHP"))) * 20
	# Remake stores experience remaining to the next level, so losing earned
	# experience increases this value.
	target.set("exp_tnl", int(target.get("exp_tnl")) + penalty)
	result["experienceRemoved"] = penalty
	result["applied"] = penalty > 0
	return result


static func _charm(
	attacker: Object,
	target: Object,
	result: Dictionary
) -> Dictionary:
	if not target.has_method("add_trait"):
		return _error("Classic Charm requires mutable target traits")
	target.add_trait(CharmedTrait, [attacker])
	if target.has_meta("classic_hit_dice"):
		var attacker_memory: Variant = _property_value(
			attacker,
			"creature_script_memory"
		)
		if attacker_memory is Dictionary:
			attacker_memory.erase("target_crea")
			result["attackerTargetCleared"] = true
	result["applied"] = true
	result["targetFaction"] = int(target.get("curFaction"))
	return result


static func _blind(target: Object, result: Dictionary) -> Dictionary:
	if not PermanentAfflictionScript.apply_blindness(target):
		return _error("Classic blindness requires mutable target traits")
	result["applied"] = true
	return result


static func _petrify(target: Object, result: Dictionary) -> Dictionary:
	if not PermanentAfflictionScript.apply_petrification(target):
		return _error("Classic petrification requires mutable combat health")
	result["applied"] = true
	result["targetKilled"] = true
	return result


static func _property_value(value: Object, property_name: String) -> Variant:
	for property: Dictionary in value.get_property_list():
		if str(property.get("name", "")) == property_name:
			return value.get(property_name)
	return null


static func _has_property(value: Object, property_name: String) -> bool:
	return _property_value(value, property_name) != null


static func _error(message: String) -> Dictionary:
	return {
		"handled": true,
		"status": "error",
		"message": message,
	}
