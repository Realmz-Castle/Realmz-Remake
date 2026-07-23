class_name ClassicMonsterStatusAttack
extends RefCounted

const SpellSavesScript = preload("res://scripts/classic_runtime/classic_spell_saves.gd")

const STATUS_BY_SPECIAL := {
	1: {
		"name": "Fear",
		"conditionIndex": 0,
		"saveIndex": 5,
		"trait": "t_classic_fleeing.gd",
		"temporaryTraits": ["t_classic_fleeing.gd", "t_fleeing.gd"],
		"permanentTraits": ["p_classic_fleeing.gd", "p_fleeing.gd"],
	},
	2: {
		"name": "Paralyze",
		"conditionIndex": 1,
		"saveIndex": 5,
		"trait": "t_classic_helpless.gd",
		"temporaryTraits": ["t_classic_helpless.gd", "t_helpless.gd"],
		"permanentTraits": ["p_classic_helpless.gd"],
	},
	3: {
		"name": "Curse",
		"conditionIndex": 3,
		"saveIndex": 7,
		"trait": "t_cursed.gd",
		"temporaryTraits": ["t_cursed.gd"],
		"permanentTraits": ["p_cursed.gd"],
	},
	4: {
		"name": "Stupid",
		"conditionIndex": 5,
		"saveIndex": 5,
		"trait": "t_dumb.gd",
		"temporaryTraits": ["t_dumb.gd"],
		"permanentTraits": ["p_dumb.gd"],
	},
	# The source labels special 5 "Entangle" but writes the Slow condition.
	5: {
		"name": "Slow",
		"conditionIndex": 6,
		"saveIndex": 7,
		"trait": "t_slow.gd",
		"temporaryTraits": ["t_slow.gd"],
		"permanentTraits": ["p_slow.gd"],
	},
	6: {
		"name": "Poison",
		"conditionIndex": 9,
		"saveIndex": 4,
		"trait": "t_poison.gd",
		"temporaryTraits": ["t_poison.gd"],
		"permanentTraits": ["p_poison.gd"],
	},
	7: {
		"name": "Confuse",
		"conditionIndex": 29,
		"saveIndex": 5,
		"trait": "t_classic_confused.gd",
		"temporaryTraits": ["t_classic_confused.gd", "t_confused.gd"],
		"permanentTraits": ["p_classic_confused.gd", "p_confused.gd"],
	},
	16: {
		"name": "Disease",
		"conditionIndex": 28,
		"saveIndex": 4,
		"trait": "t_classic_disease.gd",
		"temporaryTraits": ["t_classic_disease.gd", "t_disease.gd"],
		"permanentTraits": ["p_disease.gd"],
	},
}


static func supports(special_code: int) -> bool:
	return STATUS_BY_SPECIAL.has(special_code)


static func apply_from_weapon(
	attacker: Object,
	target: Object,
	weapon: Dictionary,
	duration_roll := -1,
	save_roll := -1
) -> Dictionary:
	var extra_data: Variant = weapon.get("extra_data", {})
	if not (extra_data is Dictionary):
		return {"handled": false}
	var special_code := int(extra_data.get("classicSpecialAttack", 0))
	if not supports(special_code):
		return {"handled": false}
	return apply(attacker, target, special_code, duration_roll, save_roll)


static func apply(
	attacker: Object,
	target: Object,
	special_code: int,
	duration_roll := -1,
	save_roll := -1
) -> Dictionary:
	if not supports(special_code):
		return {"handled": false}
	if attacker == null or target == null or not target.has_method("get_stat") \
			or not target.has_method("add_trait"):
		return _error("Classic monster status attack has an invalid combatant")

	var definition: Dictionary = STATUS_BY_SPECIAL[special_code]
	var save_index := int(definition["saveIndex"])
	var result := {
		"handled": true,
		"status": "ok",
		"specialCode": special_code,
		"conditionIndex": int(definition["conditionIndex"]),
		"conditionName": str(definition["name"]),
		"saveIndex": save_index,
		"applied": false,
	}
	var is_monster_target := target.has_meta("classic_hit_dice")
	if is_monster_target \
			and int(target.get_meta("classic_magic_resistance", 0)) > 100:
		result["blockedByMagicResistance"] = true
		return result
	var actual_save_roll := save_roll if save_roll >= 0 else randi_range(1, 100)
	var save_chance := SpellSavesScript.monster_attack_save_chance_for(
		target,
		save_index
	)
	result["saveChance"] = save_chance
	result["saveRoll"] = actual_save_roll
	result["saved"] = actual_save_roll <= save_chance
	if bool(result["saved"]):
		return result

	var traits: Variant = target.get("traits")
	if not (traits is Array):
		return _error("Classic monster status target has no trait state")
	if _has_named_trait(traits, definition["permanentTraits"]):
		result["blockedByPermanentCondition"] = true
		return result
	var current_duration := _condition_duration(traits, definition["temporaryTraits"])
	result["previousDuration"] = current_duration
	# Party conditions stop stacking at 30; the monster path has no equivalent cap.
	if not is_monster_target and current_duration >= 30:
		result["capped"] = true
		return result

	var hit_dice := int(attacker.get_meta("classic_hit_dice", 0))
	if hit_dice < 1:
		hit_dice = int(attacker.get("level"))
	hit_dice = maxi(1, hit_dice)
	var minimum_duration := maxi(1, floori(float(hit_dice) / 2.0))
	var actual_duration := duration_roll if duration_roll >= 0 \
		else randi_range(minimum_duration, hit_dice)
	actual_duration = clampi(actual_duration, minimum_duration, hit_dice)
	var trait_script: GDScript = load(
		"res://shared_assets/traits/%s" % str(definition["trait"])
	)
	if trait_script == null:
		return _error(
			"Classic monster status trait '%s' could not be loaded" % definition["trait"]
		)
	target.add_trait(trait_script, [actual_duration])
	result["duration"] = actual_duration
	result["applied"] = true
	return result


static func _has_named_trait(traits: Array, names: Array) -> bool:
	for trait_value: Variant in traits:
		if trait_value is Object and str(trait_value.get("name")) in names:
			return true
	return false


static func _condition_duration(traits: Array, names: Array) -> int:
	var duration := 0
	for trait_value: Variant in traits:
		if not (trait_value is Object) or str(trait_value.get("name")) not in names:
			continue
		if trait_value.has_method("get_saved_variables"):
			var saved: Variant = trait_value.call("get_saved_variables")
			if saved is Array and not saved.is_empty():
				duration += maxi(0, int(saved[0]))
	return duration


static func _error(message: String) -> Dictionary:
	return {
		"handled": true,
		"status": "error",
		"message": message,
	}
