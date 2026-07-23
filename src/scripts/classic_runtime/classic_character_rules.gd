class_name ClassicCharacterRules
extends RefCounted

const AdmissionScript = preload(
	"res://scripts/classic_runtime/classic_campaign_admission.gd"
)
const MagicResistanceScript = preload(
	"res://scripts/classic_runtime/classic_magic_resistance.gd"
)
const CharacterConditionRulesScript = preload(
	"res://scripts/classic_runtime/classic_character_condition_rules.gd"
)
const RANDOM_ROLL_UNSET := -2147483648
const CLASSIC_CASTER_SCHOOLS := {
	1: "Sorcerer",
	2: "Priest",
	3: "Enchanter",
}


static func apply_party(bundle: Variant, party: Array) -> Dictionary:
	var applied := 0
	for character: Variant in party:
		var profile := profile_for_character(bundle, character)
		if profile.is_empty():
			if character is Object \
					and character.has_method("clear_classic_rule_profile"):
				character.call("clear_classic_rule_profile")
			continue
		if not (character is Object) \
				or not character.has_method("apply_classic_rule_profile"):
			return {
				"status": "error",
				"message": "A selected character cannot receive Classic campaign rules.",
			}
		character.call("apply_classic_rule_profile", profile)
		_sync_magic_resistance(character, profile)
		var spellcasting_result := _sync_spellcasting_identity(character, profile)
		if str(spellcasting_result.get("status", "")) == "error":
			return spellcasting_result
		applied += 1
	return {"status": "ok", "applied": applied}


static func profile_for_character(bundle: Variant, character: Variant) -> Dictionary:
	var rules := _bundle_document(bundle, "rules")
	var campaign_id := _campaign_id(bundle)
	var rule_names := _dictionary_value(rules.get("ruleNames", {}))
	var race_id := AdmissionScript.classic_identity_id(
		character,
		"race",
		rule_names.get("raceNames", [])
	)
	var caste_id := AdmissionScript.classic_identity_id(
		character,
		"caste",
		rule_names.get("casteNames", [])
	)

	var changed_race_record := _active_changed_record(
		rules,
		"races",
		"raceOverrides",
		race_id - 1
	) if race_id > 0 else {}
	var changed_caste_record := _active_changed_record(
		rules,
		"castes",
		"casteOverrides",
		caste_id - 1
	) if caste_id > 0 else {}
	var active_race_record := _active_record(
		rules,
		"races",
		"raceOverrides",
		race_id - 1
	) if race_id > 0 else {}
	var active_caste_record := _active_record(
		rules,
		"castes",
		"casteOverrides",
		caste_id - 1
	) if caste_id > 0 else {}
	var movement: Dictionary = {}
	if changed_race_record.has("baseMove"):
		movement["raceBaseMove"] = int(changed_race_record["baseMove"])
	if changed_caste_record.has("moveBonus"):
		movement["casteMoveBonus"] = int(changed_caste_record["moveBonus"])

	var magic_resistance := _magic_resistance_profile(
		character,
		campaign_id,
		race_id,
		caste_id,
		active_race_record,
		active_caste_record,
		not changed_race_record.is_empty() or not changed_caste_record.is_empty()
	)
	var attacks := _attack_profile(
		character,
		active_race_record,
		active_caste_record,
		not changed_race_record.is_empty() or not changed_caste_record.is_empty()
	)
	var combat_progression := _combat_progression_profile(
		active_caste_record,
		not changed_caste_record.is_empty()
	)
	var stamina_progression := _stamina_progression_profile(
		active_caste_record,
		not changed_caste_record.is_empty()
	)
	var condition_progression := _condition_progression_profile(
		active_caste_record,
		not changed_caste_record.is_empty()
	)
	var spellcasting_progression := _spellcasting_progression_profile(
		active_caste_record,
		not changed_caste_record.is_empty()
	)
	var creation := _creation_profile(
		active_race_record,
		active_caste_record,
		caste_id,
		not changed_race_record.is_empty() or not changed_caste_record.is_empty()
	)

	if movement.is_empty() \
			and magic_resistance.is_empty() \
			and attacks.is_empty() \
			and combat_progression.is_empty() \
			and stamina_progression.is_empty() \
			and condition_progression.is_empty() \
			and spellcasting_progression.is_empty() \
			and creation.is_empty():
		return {}

	var profile := {
		"campaignId": campaign_id,
	}
	if not movement.is_empty():
		profile["movement"] = movement
	if not magic_resistance.is_empty():
		profile["magicResistance"] = magic_resistance
	if not attacks.is_empty():
		profile["attacks"] = attacks
	if not combat_progression.is_empty():
		profile["combatProgression"] = combat_progression
	if not stamina_progression.is_empty():
		profile["staminaProgression"] = stamina_progression
	if not condition_progression.is_empty():
		profile["conditionProgression"] = condition_progression
	if not spellcasting_progression.is_empty():
		profile["spellcastingProgression"] = spellcasting_progression
	if not creation.is_empty():
		profile["creation"] = creation
	if race_id > 0:
		profile["raceId"] = race_id
	if caste_id > 0:
		profile["casteId"] = caste_id
	return profile


static func adjusted_stat(
	character: Variant,
	profile: Dictionary,
	stat_name: String,
	native_value: Variant
) -> Variant:
	if stat_name == "MaxMovement":
		var movement := _dictionary_value(profile.get("movement", {}))
		if movement.is_empty():
			return native_value

		# Remake already combines identity and equipment movement. Replace only
		# the native race/caste contributions so equipment still applies.
		var adjusted := float(native_value)
		if movement.has("raceBaseMove"):
			adjusted += int(movement["raceBaseMove"]) \
				- _native_identity_stat(
					_value(character, "racegd", null),
					stat_name
				)
		if movement.has("casteMoveBonus"):
			adjusted += int(movement["casteMoveBonus"]) \
				- _native_identity_stat(
					_value(character, "classgd", null),
					stat_name
				)
		return roundi(adjusted)
	if stat_name == "MaxActions":
		var attacks := _dictionary_value(profile.get("attacks", {}))
		if attacks.is_empty():
			return native_value
		return float(native_value) + float(
			attacks.get("nativeAdjustment", 0.0)
		)
	return native_value


static func apply_level_up_combat_progression(
	character: Variant,
	missile_roll: int = -1
) -> Dictionary:
	var profile := _dictionary_value(
		_value(character, "classic_rule_profile", {})
	)
	var progression := _dictionary_value(
		profile.get("combatProgression", {})
	)
	if progression.is_empty():
		return {"status": "skipped"}

	var base_stats: Variant = _value(character, "base_stats", {})
	if not (base_stats is Dictionary):
		return {
			"status": "error",
			"message": "Classic combat progression requires native base stats.",
		}

	# Native race and class level-up scripts have already run. Remove their
	# identity-owned gains before applying the active Classic caste instead.
	# One Remake accuracy/evasion point represents five percentage points.
	# Classic's canUseMissile flag applies only at character creation; later
	# level-ups still roll from one through the caste missile maximum.
	var to_hit_gain := float(progression.get("toHitPerLevel", 0)) / 5.0
	var dodge_gain := float(progression.get("dodgePerLevel", 0)) / 5.0
	var missile_max := maxi(
		0,
		int(progression.get("missilePerLevelMaximum", 0))
	)
	var missile_gain_percent := _missile_level_gain(
		missile_max,
		missile_roll
	)
	var missile_gain := float(missile_gain_percent) / 5.0
	base_stats["AccuracyMelee"] = (
		float(base_stats.get("AccuracyMelee", 0.0))
		- _native_level_up_stat(character, "AccuracyMelee")
		+ to_hit_gain
	)
	base_stats["AccuracyRanged"] = clampf(
		float(base_stats.get("AccuracyRanged", 0.0))
		- _native_level_up_stat(character, "AccuracyRanged")
		+ missile_gain,
		0.0,
		20.0
	)
	base_stats["EvasionRanged"] = clampf(
		float(base_stats.get("EvasionRanged", 0.0))
		- _native_level_up_stat(character, "EvasionRanged")
		+ dodge_gain,
		0.0,
		20.0
	)

	var hand_to_hand_gain := int(progression.get("handToHandPerLevel", 0))
	# Creation-time hand-to-hand is not retrofitted onto an existing character.
	# The first compatible level-up grows that character's current native die.
	var hand_to_hand := (
		_current_hand_to_hand(character)
		if _has_hand_to_hand(character)
		else _native_unarmed_max(character)
	)
	_store_hand_to_hand(
		character,
		clampi(hand_to_hand + hand_to_hand_gain, 0, 200)
	)
	if character is Object and character.has_method("recalculate_stats"):
		character.call("recalculate_stats")
	return {
		"status": "ok",
		"toHitGain": to_hit_gain,
		"missileRoll": missile_gain_percent,
		"missileGain": missile_gain,
		"dodgeGain": dodge_gain,
		"handToHand": _current_hand_to_hand(character),
	}


static func adjusted_unarmed_damage_range(
	character: Variant,
	weapon: Dictionary,
	damage_range: Array
) -> Array:
	if str(weapon.get("name", "")) != "NO_MELEE_WEAPON" \
			or not _has_hand_to_hand(character):
		return damage_range
	var hand_to_hand := _current_hand_to_hand(character)
	if hand_to_hand <= 0:
		return [0, 0]
	return [1, hand_to_hand]


static func apply_level_up_attack_progression(character: Variant) -> Dictionary:
	var profile := _dictionary_value(
		_value(character, "classic_rule_profile", {})
	)
	var attacks := _dictionary_value(profile.get("attacks", {}))
	if attacks.is_empty():
		return {"status": "skipped"}

	var desired_actions := _classic_action_budget(
		int(_value(character, "level", 1)),
		int(attacks.get("baseHalfAttacks", 0)),
		int(attacks.get("bonusHalfAttacks", 0)),
		_integer_array(attacks.get("levelThresholds", [])),
		int(attacks.get("maxAttacks", 0))
	)
	attacks["nativeAdjustment"] = (
		desired_actions - _raw_base_stat(character, "MaxActions")
	)
	profile["attacks"] = attacks
	if character is Object \
			and character.has_method("apply_classic_rule_profile"):
		character.call("apply_classic_rule_profile", profile)
	return {
		"status": "ok",
		"maxActions": desired_actions,
		"halfAttacks": int((desired_actions - 1.0) * 2.0),
	}


static func apply_level_up_stamina_progression(
	character: Variant,
	stamina_roll: int = RANDOM_ROLL_UNSET
) -> Dictionary:
	var profile := _dictionary_value(
		_value(character, "classic_rule_profile", {})
	)
	var progression := _dictionary_value(
		profile.get("staminaProgression", {})
	)
	if progression.is_empty():
		return {"status": "skipped"}

	var base_stats: Variant = _value(character, "base_stats", {})
	if not (base_stats is Dictionary):
		return {
			"status": "error",
			"message": "Classic stamina progression requires native base stats.",
		}

	var vitality_bonus := 0
	var vitality := _character_stat(character, "Vitality")
	if vitality > 16:
		vitality_bonus = mini(
			vitality - 16,
			int(progression.get("maximumVitalityBonus", 0))
		)
	var rolled_stamina := _classic_rand(
		int(progression.get("dieMaximum", 0)),
		stamina_roll
	)
	var stamina_gain := rolled_stamina + vitality_bonus

	# Native race and class level-up scripts have already run. Replace only
	# their max-HP contribution. Recalculate_stats preserves the existing HP
	# deficit, so current and maximum stamina rise together as they do in Realmz.
	base_stats["maxHP"] = (
		int(base_stats.get("maxHP", 0))
		- roundi(_native_level_up_stat(character, "maxHP"))
		+ stamina_gain
	)
	if character is Object and character.has_method("recalculate_stats"):
		character.call("recalculate_stats")
	return {
		"status": "ok",
		"roll": rolled_stamina,
		"vitalityBonus": vitality_bonus,
		"staminaGain": stamina_gain,
	}


static func apply_level_up_condition_progression(character: Variant) -> Dictionary:
	var profile := _dictionary_value(
		_value(character, "classic_rule_profile", {})
	)
	var progression: Variant = profile.get("conditionProgression", [])
	if not (progression is Array) or progression.is_empty():
		return {"status": "skipped"}

	var current_level := int(_value(character, "level", 1))
	var due_indices: Array[int] = []
	for entry_value: Variant in progression:
		if not (entry_value is Dictionary):
			continue
		if int(entry_value.get("level", 0)) == current_level:
			due_indices.append(int(entry_value.get("conditionIndex", -1)))
	if due_indices.is_empty():
		return {"status": "ok", "applied": []}

	# Validate the whole level before changing any trait. A partly translated
	# caste must not receive only the convenient subset of its authored grants.
	for condition_index: int in due_indices:
		if not CharacterConditionRulesScript.supports_condition(condition_index):
			return {
				"status": "error",
				"message": (
					"Classic caste condition %d has no safe Remake mapping."
					% condition_index
				),
			}

	var applied: Array[Dictionary] = []
	for condition_index: int in due_indices:
		var result: Dictionary = (
			CharacterConditionRulesScript.grant_permanent_condition(
				character,
				condition_index
			)
		)
		if str(result.get("status", "")) == "error":
			return result
		applied.append(result)
	return {"status": "ok", "applied": applied}


## Rolls and assigns Classic's six creation attributes and demographics.
##
## Call this before the other creation adapters. Luck, gender, and age have no
## native Remake owner, so PlayerCharacter retains them as compatibility state.
static func apply_character_creation_attributes(
	character: Variant,
	gender: int,
	attribute_rolls: Array[int] = [],
	age_year: int = RANDOM_ROLL_UNSET
) -> Dictionary:
	var creation := _dictionary_value(
		_dictionary_value(
			_value(character, "classic_rule_profile", {})
		).get("creation", {})
	)
	if creation.is_empty():
		return {"status": "skipped"}
	if not (character is Object) \
			or not character.has_method("set_classic_creation_attributes"):
		return {
			"status": "error",
			"message": "Classic character creation requires mutable attributes.",
		}
	if gender not in [1, 2]:
		return {
			"status": "error",
			"message": "Classic character creation gender must be 1 or 2.",
		}
	if not attribute_rolls.is_empty() and attribute_rolls.size() != 6:
		return {
			"status": "error",
			"message": "Classic character creation requires six attribute rolls.",
		}
	if not bool(creation.get("casteAllowed", false)):
		return {
			"status": "error",
			"message": "The selected Classic race cannot use this caste.",
		}

	var race_bonuses := _integer_array(
		creation.get("raceAttributeBonuses", [])
	)
	var caste_bonuses := _integer_array(
		creation.get("casteAttributeBonuses", [])
	)
	var race_limits := _integer_array(
		creation.get("raceAttributeLimits", [])
	)
	var caste_limits := _integer_array(
		creation.get("casteAttributeLimits", [])
	)
	var age_ranges := _integer_rows(creation.get("ageRanges", []))
	var age_changes := _integer_rows(creation.get("ageChanges", []))
	var minimum_age_group := int(creation.get("minimumAgeGroup", 0))
	if race_bonuses.size() != 6 \
			or caste_bonuses.size() != 6 \
			or race_limits.size() != 12 \
			or caste_limits.size() != 12 \
			or age_ranges.size() != 5 \
			or age_changes.size() != 5 \
			or minimum_age_group < 1 \
			or minimum_age_group > 5:
		return {
			"status": "error",
			"message": "Classic character creation has incomplete attribute rules.",
		}
	for row: Array[int] in age_ranges:
		if row.size() != 2:
			return {
				"status": "error",
				"message": "Classic character creation has an invalid age range.",
			}
	for row: Array[int] in age_changes:
		if row.size() != 15:
			return {
				"status": "error",
				"message": "Classic character creation has invalid age changes.",
			}

	var rolls: Array[int] = []
	var attributes: Array[int] = []
	for attribute_index: int in range(6):
		var roll := (
			attribute_rolls[attribute_index]
			if not attribute_rolls.is_empty()
			else _classic_rand(18)
		)
		if roll < 1 or roll > 18:
			return {
				"status": "error",
				"message": "Classic attribute rolls must be between 1 and 18.",
			}
		rolls.append(roll)
		var value := roll + race_bonuses[attribute_index] \
			+ caste_bonuses[attribute_index]
		value = _classic_pin(
			value,
			caste_limits[attribute_index * 2],
			caste_limits[attribute_index * 2 + 1]
		)
		value = _classic_pin(
			value,
			race_limits[attribute_index * 2],
			race_limits[attribute_index * 2 + 1]
		)
		attributes.append(value)

	# Gender 2 is female in Classic's creation dialog.
	if gender == 2:
		attributes[0] -= 1
		attributes[2] += 1
		attributes[3] += 1
	else:
		attributes[0] += 1
		attributes[3] -= 1

	for age_group_index: int in range(minimum_age_group):
		var changes: Array[int] = age_changes[age_group_index]
		for attribute_index: int in range(6):
			attributes[attribute_index] += changes[attribute_index]

	for attribute_index: int in range(6):
		attributes[attribute_index] = _classic_pin(
			attributes[attribute_index],
			caste_limits[attribute_index * 2],
			caste_limits[attribute_index * 2 + 1]
		)
		attributes[attribute_index] = _classic_pin(
			attributes[attribute_index],
			race_limits[attribute_index * 2],
			race_limits[attribute_index * 2 + 1]
		)

	var selected_age_range: Array[int] = age_ranges[minimum_age_group - 1]
	var minimum_age := selected_age_range[0]
	var maximum_age := selected_age_range[1]
	if minimum_age > maximum_age:
		return {
			"status": "error",
			"message": "Classic character creation has a reversed age range.",
		}
	var selected_age := age_year
	if selected_age == RANDOM_ROLL_UNSET:
		selected_age = _classic_rand(maximum_age - minimum_age + 1) \
			- 1 + minimum_age
	elif selected_age < minimum_age or selected_age > maximum_age:
		return {
			"status": "error",
			"message": (
				"Classic creation age must be between %d and %d."
				% [minimum_age, maximum_age]
			),
		}

	var assigned := {
		"Strength": attributes[0],
		"Intellect": attributes[1],
		"Wisdom": attributes[2],
		"Dexterity": attributes[3],
		"Vitality": attributes[4],
		"classicLuck": attributes[5],
		"classicGender": gender,
		"classicAgeYears": selected_age,
		"classicAgeGroup": minimum_age_group,
	}
	character.call("set_classic_creation_attributes", assigned)
	return {
		"status": "ok",
		"rolls": rolls,
		"attributes": {
			"Strength": attributes[0],
			"Intellect": attributes[1],
			"Wisdom": attributes[2],
			"Dexterity": attributes[3],
			"Vitality": attributes[4],
			"Luck": attributes[5],
		},
		"gender": gender,
		"ageYears": selected_age,
		"ageGroup": minimum_age_group,
	}


## Applies Classic's initial stamina and mundane combat values.
##
## Call this after the level-one attributes and active rule profile have been
## assigned, but before any level-ups used to reach an advanced starting level.
static func apply_character_creation_combat(
	character: Variant,
	stamina_roll: int = RANDOM_ROLL_UNSET
) -> Dictionary:
	var creation := _dictionary_value(
		_dictionary_value(
			_value(character, "classic_rule_profile", {})
		).get("creation", {})
	)
	if creation.is_empty():
		return {"status": "skipped"}
	if not (character is Object) \
			or not character.has_method("set_classic_creation_combat_stats"):
		return {
			"status": "error",
			"message": "Classic character creation requires mutable combat stats.",
		}

	var strength := _character_stat(character, "Strength")
	var dexterity := _character_stat(character, "Dexterity")
	var vitality := _character_stat(character, "Vitality")
	var strength_bonuses := _classic_strength_bonuses(
		strength,
		int(creation.get("maximumStrengthDamageBonus", 0))
	)
	var vitality_bonus := 0
	if vitality > 16:
		vitality_bonus = mini(
			vitality - 16,
			int(creation.get("maximumVitalityBonus", 0))
		)
	var rolled_stamina := _classic_rand(
		int(creation.get("staminaDieMaximum", 0)),
		stamina_roll
	)
	var stamina := rolled_stamina + vitality_bonus
	var melee_to_hit := (
		int(creation.get("toHitBase", 0))
		+ int(strength_bonuses.get("toHit", 0))
	)
	var melee_evasion := maxi(0, 2 * (dexterity - 14))
	var dodge := clampi(
		2 * dexterity + int(creation.get("dodgeBase", 0)),
		0,
		100
	)
	var missile := 0
	if bool(creation.get("canUseMissile", false)):
		missile = clampi(
			int(creation.get("raceMissileBase", 0))
				+ int(creation.get("casteMissileBase", 0)),
			0,
			100
		)
	var hand_to_hand := clampi(
		int(creation.get("handToHandBase", 0)),
		0,
		200
	)
	character.call(
		"set_classic_creation_combat_stats",
		{
			"maxHP": stamina,
			"AccuracyMelee": float(melee_to_hit) / 5.0,
			"AccuracyRanged": float(missile) / 5.0,
			"EvasionMelee": float(melee_evasion) / 5.0,
			"EvasionRanged": float(dodge) / 5.0,
			"Bonus_Physical_dmg": int(
				strength_bonuses.get("damage", 0)
			),
			"classicHandToHand": hand_to_hand,
		}
	)
	return {
		"status": "ok",
		"staminaRoll": rolled_stamina,
		"vitalityBonus": vitality_bonus,
		"stamina": stamina,
		"toHit": melee_to_hit,
		"armorClass": melee_evasion,
		"dodge": dodge,
		"missile": missile,
		"handToHand": hand_to_hand,
		"damageBonus": int(strength_bonuses.get("damage", 0)),
	}


## Applies the spell-point portion of Classic character creation.
##
## Call this after the level-one attributes and active rule profile have been
## assigned, but before any level-ups used to reach an advanced starting level.
## `starting_level` is the level selected in the creation dialog, not the
## character's current level at this point in the construction sequence.
static func apply_character_creation_spellcasting(
	character: Variant,
	starting_level: int,
	spell_point_rolls: Array[int] = []
) -> Dictionary:
	if starting_level < 1:
		return {
			"status": "error",
			"message": "Classic character creation requires a positive starting level.",
		}
	var progression := _spellcasting_progression(character)
	if progression.is_empty():
		return {"status": "skipped"}
	var start_levels := _integer_array(progression.get("startLevels", []))
	if start_levels.size() < 3:
		return {
			"status": "error",
			"message": "Classic character creation requires all three caster rows.",
		}
	if not (character is Object) \
			or not character.has_method("set_classic_creation_spell_points") \
			or not character.has_method("set_classic_spellcaster_type"):
		return {
			"status": "error",
			"message": "Classic character creation requires mutable spell-point state.",
		}

	var intellect := _character_stat(character, "Intellect")
	var wisdom := _character_stat(character, "Wisdom")
	var caster_type := 0
	var initial_spell_points := 0
	var applied_rows: Array[Dictionary] = []
	for row_index: int in range(3):
		var start_level := start_levels[row_index]
		if start_level == 0:
			continue

		# newcharacter.c uses independent checks here. A later row therefore
		# replaces the displayed caster identity, and, when eligible, the pool
		# calculated by an earlier row.
		caster_type = row_index + 1
		if starting_level < start_level:
			continue
		var roll_maximum := 0
		var fixed_points := 0
		match caster_type:
			1:
				roll_maximum = wisdom
				fixed_points = 4 + intellect
			2:
				roll_maximum = intellect
				fixed_points = 4 + wisdom
			3:
				roll_maximum = wisdom + intellect
				fixed_points = 10
		var requested_roll := (
			spell_point_rolls[row_index]
			if row_index < spell_point_rolls.size()
			else RANDOM_ROLL_UNSET
		)
		var rolled_points := _classic_rand(roll_maximum, requested_roll)
		initial_spell_points = fixed_points + rolled_points
		applied_rows.append({
			"casterType": caster_type,
			"rollMaximum": roll_maximum,
			"roll": rolled_points,
			"spellPoints": initial_spell_points,
		})

	character.call("set_classic_spellcaster_type", caster_type)
	if character.has_method("ensure_classic_spell_levels"):
		character.call(
			"ensure_classic_spell_levels",
			int(progression.get("maximumSpellLevel", 0))
		)
	character.call(
		"set_classic_creation_spell_points",
		initial_spell_points
	)
	return {
		"status": "ok",
		"casterType": caster_type,
		"school": spellcaster_school(caster_type),
		"initialSpellPoints": initial_spell_points,
		"appliedRows": applied_rows,
	}


static func apply_level_up_spellcasting_progression(
	character: Variant,
	spell_point_roll: int = RANDOM_ROLL_UNSET
) -> Dictionary:
	var profile := _dictionary_value(
		_value(character, "classic_rule_profile", {})
	)
	var progression := _dictionary_value(
		profile.get("spellcastingProgression", {})
	)
	if progression.is_empty():
		return {"status": "skipped"}

	var identity_result := _sync_spellcasting_identity(character, profile)
	if str(identity_result.get("status", "")) == "error":
		return identity_result
	var caster_type := int(progression.get("casterType", 0))
	var level := int(_value(character, "level", 1))
	var start_level := int(progression.get("startLevel", 0))
	var base_stats: Variant = _value(character, "base_stats", {})
	if not (base_stats is Dictionary):
		return {
			"status": "error",
			"message": "Classic spellcasting progression requires native base stats.",
		}

	var roll_maximum := 0
	var rolled_points := 0
	var spell_point_gain := 0
	if level > 1 and start_level <= level:
		var intellect := _character_stat(character, "Intellect")
		var wisdom := _character_stat(character, "Wisdom")
		roll_maximum = (
			intellect + int(wisdom / 2.0)
			if caster_type == 1
			else wisdom + int(intellect / 2.0)
		)
		rolled_points = _classic_rand(roll_maximum, spell_point_roll)
		spell_point_gain = level + rolled_points

	# Current and maximum spell points rise together in Realmz. Remake's normal
	# recalculation preserves the spent-point deficit and reapplies equipment.
	# Native class growth is removed even before the Classic start level.
	base_stats["maxSP"] = (
		int(base_stats.get("maxSP", 0))
		- roundi(_native_level_up_stat(character, "maxSP"))
		+ spell_point_gain
	)
	if character.has_method("recalculate_stats"):
		character.call("recalculate_stats")
	return {
		"status": "ok",
		"casterType": caster_type,
		"school": spellcaster_school(caster_type),
		"rollMaximum": roll_maximum,
		"roll": rolled_points,
		"spellPointGain": spell_point_gain,
	}


static func spellcaster_school(caster_type: int) -> String:
	return str(CLASSIC_CASTER_SCHOOLS.get(caster_type, ""))


static func has_classic_spell_selection(character: Variant) -> bool:
	var progression := _spellcasting_progression(character)
	return CLASSIC_CASTER_SCHOOLS.has(
		int(progression.get("casterType", 0))
	)


# getnumspells.c derives this total each time from the active caste and current
# attributes. It is not the saved generic ability budget used by Remake.
static func classic_spell_selection_total(character: Variant) -> int:
	var progression := _spellcasting_progression(character)
	if progression.is_empty():
		return 0
	var start_levels := _integer_array(progression.get("startLevels", []))
	if start_levels.size() < 3:
		return 0
	var relative_level := (
		int(_value(character, "level", 1))
		- (start_levels[0] + start_levels[1] + start_levels[2] - 1)
	)
	if relative_level < 1:
		return 0

	var caster_type := _active_spellcaster_type(character, progression)
	var bonus_attribute := (
		_character_stat(character, "Wisdom")
		if caster_type == 2
		else _character_stat(character, "Intellect")
	)
	var total := 3 * relative_level
	total += int(relative_level * (relative_level - 1) / 2.0)
	if bonus_attribute > 15:
		total += relative_level * (bonus_attribute - 15)
	return total


static func classic_spell_selection_remaining(character: Variant) -> int:
	var remaining := classic_spell_selection_total(character)
	var spell_levels: Variant = _value(character, "spells", [])
	if not (spell_levels is Array):
		return remaining
	for level_index: int in range(mini(7, spell_levels.size())):
		var learned: Variant = spell_levels[level_index]
		if learned is Array:
			remaining -= learned.size() * classic_spell_selection_cost(
				level_index + 1
			)
	return remaining


# spellselect.c spends points in level and slot order, clearing later known
# spells when a changed level or attribute total can no longer afford them.
static func enforce_classic_spell_selection_budget(
	character: Variant
) -> Dictionary:
	var remaining := classic_spell_selection_total(character)
	var spell_levels: Variant = _value(character, "spells", [])
	if not (spell_levels is Array):
		return {
			"status": "error",
			"message": "Classic spell selection requires learned spell levels.",
		}
	var removed: Array = []
	for level_index: int in range(mini(7, spell_levels.size())):
		var learned: Variant = spell_levels[level_index]
		if not (learned is Array):
			continue
		var cost := classic_spell_selection_cost(level_index + 1)
		var retained: Array = []
		for spell: Variant in learned:
			if remaining >= cost:
				retained.append(spell)
				remaining -= cost
			else:
				removed.append(spell)
		spell_levels[level_index] = retained
	return {
		"status": "ok",
		"remaining": remaining,
		"removed": removed,
	}


static func classic_spell_selection_cost(spell_level: int) -> int:
	if spell_level < 1 or spell_level > 7:
		return 0
	return int(spell_level * (spell_level + 1) / 2.0)


static func classic_spell_level(character: Variant, spell: Variant) -> int:
	var progression := _spellcasting_progression(character)
	if progression.is_empty():
		return 0
	var school := spellcaster_school(
		_active_spellcaster_type(character, progression)
	)
	var school_levels := _dictionary_value(
		_value(spell, "school_levels", {})
	)
	var spell_level := int(school_levels.get(school, 0))
	var maximum_level := clampi(
		int(progression.get("maximumSpellLevel", 0)),
		0,
		7
	)
	if spell_level < 1 or spell_level > maximum_level:
		return 0
	return spell_level


static func classic_spell_selection_cost_for_spell(
	character: Variant,
	spell: Variant
) -> int:
	return classic_spell_selection_cost(classic_spell_level(character, spell))


static func _sync_spellcasting_identity(
	character: Variant,
	profile: Dictionary
) -> Dictionary:
	var progression := _dictionary_value(
		profile.get("spellcastingProgression", {})
	)
	if progression.is_empty():
		return {"status": "skipped"}
	var caster_type := int(progression.get("casterType", 0))
	if not CLASSIC_CASTER_SCHOOLS.has(caster_type):
		return {
			"status": "error",
			"message": "Classic spellcasting progression has an invalid caster type.",
		}
	if not (character is Object) \
			or not character.has_method("set_classic_spellcaster_type"):
		return {
			"status": "error",
			"message": "Classic spellcasting progression requires saved caster identity.",
		}
	character.call("set_classic_spellcaster_type", caster_type)
	if character.has_method("ensure_classic_spell_levels"):
		character.call(
			"ensure_classic_spell_levels",
			int(progression.get("maximumSpellLevel", 0))
		)
	return {
		"status": "ok",
		"casterType": caster_type,
		"school": spellcaster_school(caster_type),
	}


static func _spellcasting_progression_profile(
	caste_record: Dictionary,
	has_changed_caste: bool
) -> Dictionary:
	if not has_changed_caste:
		return {}
	var rows: Variant = caste_record.get("spellcasters", [])
	if not (rows is Array):
		return {}

	# levelup.c chooses the first nonzero start level, regardless of the editor's
	# display flag. Preserve that source precedence for unusual hybrid records.
	var caster_type := 0
	var catalog_enabled := 0
	var start_level := 0
	var maximum_spell_level := 0
	var start_levels: Array[int] = []
	var maximum_spell_levels: Array[int] = []
	for row_index: int in range(mini(3, rows.size())):
		var row: Variant = rows[row_index]
		if not (row is Array) or row.size() < 3:
			start_levels.append(0)
			maximum_spell_levels.append(0)
			continue
		var row_start_level := int(row[1])
		var row_maximum_level := int(row[2])
		start_levels.append(row_start_level)
		maximum_spell_levels.append(row_maximum_level)
		maximum_spell_level += row_maximum_level
		if caster_type == 0 and row_start_level != 0:
			caster_type = row_index + 1
			catalog_enabled = int(row[0])
			start_level = row_start_level
	if caster_type == 0:
		return {}
	return {
		"casterType": caster_type,
		"school": spellcaster_school(caster_type),
		"catalogEnabled": catalog_enabled,
		"startLevel": start_level,
		"startLevels": start_levels,
		"maximumSpellLevels": maximum_spell_levels,
		"maximumSpellLevel": maximum_spell_level,
	}


static func _spellcasting_progression(character: Variant) -> Dictionary:
	var profile := _dictionary_value(
		_value(character, "classic_rule_profile", {})
	)
	return _dictionary_value(profile.get("spellcastingProgression", {}))


static func _active_spellcaster_type(
	character: Variant,
	progression: Dictionary
) -> int:
	if character is Object \
			and character.has_method("has_classic_spellcaster_type") \
			and bool(character.call("has_classic_spellcaster_type")):
		return int(_value(character, "classic_spellcaster_type", 0))
	return int(progression.get("casterType", 0))


static func _creation_profile(
	race_record: Dictionary,
	caste_record: Dictionary,
	caste_id: int,
	has_changed_record: bool
) -> Dictionary:
	if not has_changed_record:
		return {}
	var race_attribute_bonuses := _integer_array(
		race_record.get("attBonus", [])
	)
	var caste_attribute_bonuses := _integer_array(
		caste_record.get("attBonus", [])
	)
	var race_attribute_limits := _integer_array(
		race_record.get("minMax", [])
	)
	var caste_attribute_limits := _integer_array(
		caste_record.get("minMax", [])
	)
	var allowed_castes := _integer_array(race_record.get("canCaste", []))
	var age_ranges := _integer_rows(race_record.get("ageRange", []))
	var age_changes := _integer_rows(race_record.get("ageChange", []))
	var stamina := _integer_array(caste_record.get("stamina", []))
	var to_hit := _integer_array(caste_record.get("toHit", []))
	var dodge := _integer_array(caste_record.get("dodge", []))
	var caste_missile := _integer_array(caste_record.get("missile", []))
	var hand_to_hand := _integer_array(caste_record.get("hand2Hand", []))
	var strength := _integer_array(caste_record.get("strength", []))
	if stamina.size() < 2 \
			or race_attribute_bonuses.size() != 6 \
			or caste_attribute_bonuses.size() != 6 \
			or race_attribute_limits.size() != 12 \
			or caste_attribute_limits.size() != 12 \
			or caste_id < 1 \
			or allowed_castes.size() < caste_id \
			or age_ranges.size() != 5 \
			or age_changes.size() != 5 \
			or to_hit.size() < 2 \
			or dodge.size() < 2 \
			or caste_missile.size() < 2 \
			or hand_to_hand.size() < 2 \
			or strength.size() < 2 \
			or not caste_record.has("maxStaminaBonus") \
			or not caste_record.has("canUseMissile") \
			or not caste_record.has("minimumAgeGroup") \
			or not race_record.has("missile"):
		return {}
	return {
		"raceAttributeBonuses": race_attribute_bonuses,
		"casteAttributeBonuses": caste_attribute_bonuses,
		"raceAttributeLimits": race_attribute_limits,
		"casteAttributeLimits": caste_attribute_limits,
		"casteAllowed": allowed_castes[caste_id - 1] != 0,
		"minimumAgeGroup": int(caste_record["minimumAgeGroup"]),
		"ageRanges": age_ranges,
		"ageChanges": age_changes,
		"staminaDieMaximum": stamina[0],
		"maximumVitalityBonus": int(caste_record["maxStaminaBonus"]),
		"toHitBase": to_hit[0],
		"dodgeBase": dodge[0],
		"raceMissileBase": int(race_record["missile"]),
		"casteMissileBase": caste_missile[0],
		"canUseMissile": int(caste_record["canUseMissile"]) != 0,
		"handToHandBase": hand_to_hand[0],
		"maximumStrengthDamageBonus": strength[1],
	}


static func _classic_strength_bonuses(
	strength: int,
	maximum_damage_bonus: int
) -> Dictionary:
	var to_hit := 0
	var damage := 0
	if strength < 4:
		to_hit = -20
	else:
		match strength:
			4:
				to_hit = -15
				damage = -1
			5:
				to_hit = -10
				damage = -1
			6:
				to_hit = -5
			16:
				to_hit = 5
				damage = 1
			17:
				to_hit = 5
				damage = 2
			18:
				to_hit = 10
				damage = 2
			19:
				to_hit = 10
				damage = 3
			20:
				to_hit = 15
				damage = 3
			21:
				to_hit = 15
				damage = 4
			22:
				to_hit = 20
				damage = 4
			23:
				to_hit = 20
				damage = 5
			24:
				to_hit = 25
				damage = 5
			25:
				to_hit = 25
				damage = 6
			26:
				to_hit = 30
				damage = 6
			27:
				to_hit = 30
				damage = 7
			28:
				to_hit = 35
				damage = 7
			29:
				to_hit = 35
				damage = 8
			30:
				to_hit = 40
				damage = 8
	damage = clampi(mini(damage, maximum_damage_bonus), 0, 200)
	return {
		"toHit": to_hit,
		"damage": damage,
	}


static func _classic_pin(value: int, low: int, high: int) -> int:
	if value < low:
		value = low
	if value > high:
		value = high
	return value


static func _condition_progression_profile(
	caste_record: Dictionary,
	has_changed_caste: bool
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not has_changed_caste:
		return result
	var conditions := _integer_array(caste_record.get("conditions", []))
	for condition_index: int in range(conditions.size()):
		var level := conditions[condition_index]
		if level > 0:
			result.append({
				"conditionIndex": condition_index,
				"level": level,
			})
	return result


static func _stamina_progression_profile(
	caste_record: Dictionary,
	has_changed_caste: bool
) -> Dictionary:
	if not has_changed_caste:
		return {}
	var stamina := _integer_array(caste_record.get("stamina", []))
	if stamina.size() < 2 or not caste_record.has("maxStaminaBonus"):
		return {}
	return {
		"dieMaximum": stamina[1],
		"maximumVitalityBonus": int(caste_record["maxStaminaBonus"]),
	}


static func _combat_progression_profile(
	caste_record: Dictionary,
	has_changed_caste: bool
) -> Dictionary:
	if not has_changed_caste:
		return {}
	var to_hit := _integer_array(caste_record.get("toHit", []))
	var dodge := _integer_array(caste_record.get("dodge", []))
	var missile := _integer_array(caste_record.get("missile", []))
	var hand_to_hand := _integer_array(caste_record.get("hand2Hand", []))
	if to_hit.size() < 2 \
			or dodge.size() < 2 \
			or missile.size() < 2 \
			or hand_to_hand.size() < 2:
		return {}
	return {
		"toHitPerLevel": to_hit[1],
		"dodgePerLevel": dodge[1],
		"missilePerLevelMaximum": missile[1],
		"handToHandPerLevel": hand_to_hand[1],
	}


static func _missile_level_gain(maximum: int, requested_roll: int = -1) -> int:
	if maximum <= 0:
		return 0
	if requested_roll >= 1:
		return clampi(requested_roll, 1, maximum)
	return _classic_rand(maximum)


static func _classic_rand(
	range_maximum: int,
	requested_roll: int = RANDOM_ROLL_UNSET
) -> int:
	if requested_roll != RANDOM_ROLL_UNSET:
		return requested_roll
	var raw_result := randi_range(0, 32767)
	# Realmz scales the signed 15-bit Random result and adds one. Keeping that
	# formula also preserves its unusual zero and negative-range behavior.
	return 1 + int(float(raw_result * range_maximum) / 32768.0)


static func _attack_profile(
	character: Variant,
	race_record: Dictionary,
	caste_record: Dictionary,
	has_changed_record: bool
) -> Dictionary:
	if not has_changed_record \
			or not race_record.has("numOfAttacks") \
			or not caste_record.has("bonusAttacks") \
			or not caste_record.has("attacks"):
		return {}
	var race_attacks := _integer_array(race_record["numOfAttacks"])
	if race_attacks.size() < 2:
		return {}
	var thresholds := _integer_array(caste_record["attacks"])
	var result := {
		"baseHalfAttacks": race_attacks[0],
		"maxAttacks": race_attacks[1],
		"bonusHalfAttacks": int(caste_record["bonusAttacks"]),
		"levelThresholds": thresholds,
	}
	var desired_actions := _classic_action_budget(
		int(_value(character, "level", 1)),
		int(result["baseHalfAttacks"]),
		int(result["bonusHalfAttacks"]),
		thresholds,
		int(result["maxAttacks"])
	)
	result["nativeAdjustment"] = (
		desired_actions - _raw_base_stat(character, "MaxActions")
	)
	return result


static func _classic_action_budget(
	level: int,
	base_half_attacks: int,
	bonus_half_attacks: int,
	level_thresholds: Array[int],
	max_attacks: int
) -> float:
	var half_attacks := base_half_attacks + bonus_half_attacks
	for threshold: int in level_thresholds:
		if threshold > 0 and threshold <= level:
			half_attacks += 1
	if max_attacks > 0:
		half_attacks = mini(half_attacks, max_attacks * 2)

	# Remake reserves one action for the turn itself. Each Classic half-attack
	# adds half an action; Creature.get_apr_left grants the fraction every other
	# round.
	return 1.0 + float(half_attacks) / 2.0


static func _magic_resistance_profile(
	character: Variant,
	campaign_id: String,
	race_id: int,
	caste_id: int,
	race_record: Dictionary,
	caste_record: Dictionary,
	has_changed_record: bool
) -> Dictionary:
	if not has_changed_record \
			or not race_record.has("magRes") \
			or not caste_record.has("magRes"):
		return {}

	var race_bonus := int(race_record["magRes"])
	var caste_multiplier := int(caste_record["magRes"])
	var result := {
		"raceBonus": race_bonus,
		"casteMultiplier": caste_multiplier,
		"initialValue": (
			int(
				(
					_character_stat(character, "Intellect")
					+ _character_stat(character, "Wisdom")
				) / 10.0
			) * caste_multiplier
			+ race_bonus
		),
	}
	var existing_profile := _dictionary_value(
		_value(character, "classic_rule_profile", {})
	)
	var existing_magic_resistance := _dictionary_value(
		existing_profile.get("magicResistance", {})
	)
	var same_character_rules := (
		str(existing_profile.get("campaignId", "")) == campaign_id
		and int(existing_profile.get("raceId", 0)) == race_id
		and int(existing_profile.get("casteId", 0)) == caste_id
		and int(existing_magic_resistance.get("raceBonus", race_bonus))
			== race_bonus
		and int(
			existing_magic_resistance.get(
				"casteMultiplier",
				caste_multiplier
			)
		) == caste_multiplier
	)
	if same_character_rules and existing_magic_resistance.has("initialValue"):
		# Attribute growth must not recalculate a value fixed at creation.
		result["initialValue"] = int(existing_magic_resistance["initialValue"])
	return result


static func apply_level_up_magic_resistance(
	character: Variant,
	roll: int = -1
) -> Dictionary:
	var profile := _dictionary_value(
		_value(character, "classic_rule_profile", {})
	)
	var magic_resistance := _dictionary_value(
		profile.get("magicResistance", {})
	)
	if magic_resistance.is_empty():
		return {"status": "skipped"}

	_sync_magic_resistance(character, profile)
	if not _has_magic_resistance(character):
		return {
			"status": "error",
			"message": "Classic magic resistance could not be initialized.",
		}
	var current_value := _current_magic_resistance(character)
	var chance := (
		_character_stat(character, "Intellect")
		+ _character_stat(character, "Wisdom")
		+ _character_stat(character, "Vitality")
	)
	var actual_roll := roll if roll >= 1 else randi_range(1, 100)
	var gained := actual_roll <= chance
	if gained:
		current_value += 1
		_store_magic_resistance(character, current_value)
	return {
		"status": "ok",
		"chance": chance,
		"roll": actual_roll,
		"gained": gained,
		"value": current_value,
	}


static func _active_changed_record(
	rules: Dictionary,
	table_name: String,
	records_name: String,
	record_id: int
) -> Dictionary:
	var selection := _dictionary_value(
		_dictionary_value(rules.get("tableSelection", {})).get(table_name, {})
	)
	if str(selection.get("source", "unresolved")) != "scenario-local":
		return {}
	if selection.has("changedRecordIds") \
			and record_id not in _integer_array(selection["changedRecordIds"]):
		return {}
	return _active_record(rules, table_name, records_name, record_id)


static func _active_record(
	rules: Dictionary,
	table_name: String,
	records_name: String,
	record_id: int
) -> Dictionary:
	var selection := _dictionary_value(
		_dictionary_value(rules.get("tableSelection", {})).get(table_name, {})
	)
	if str(selection.get("source", "unresolved")) != "scenario-local":
		return {}
	var records: Variant = rules.get(records_name, [])
	if not (records is Array):
		return {}
	for record: Variant in records:
		if record is Dictionary and int(record.get("id", -1)) == record_id:
			return record
	return {}


static func _sync_magic_resistance(
	character: Variant,
	profile: Dictionary
) -> void:
	var magic_resistance := _dictionary_value(
		profile.get("magicResistance", {})
	)
	if magic_resistance.is_empty():
		return
	if _has_magic_resistance(character):
		var current_value := _current_magic_resistance(character)
		# Older compatibility code may have set only the metadata key. Mirror it
		# into the character field so the next ordinary save retains the value.
		if character is Object \
				and character.has_method("has_classic_magic_resistance") \
				and not bool(character.call("has_classic_magic_resistance")):
			_store_magic_resistance(character, current_value)
		return
	_store_magic_resistance(
		character,
		int(magic_resistance.get("initialValue", 0))
	)


static func _has_magic_resistance(character: Variant) -> bool:
	if character is Object \
			and character.has_method("has_classic_magic_resistance") \
			and bool(character.call("has_classic_magic_resistance")):
		return true
	return character is Object \
		and character.has_meta(MagicResistanceScript.META_KEY)


static func _current_magic_resistance(character: Variant) -> int:
	if character is Object \
			and character.has_method("has_classic_magic_resistance") \
			and bool(character.call("has_classic_magic_resistance")):
		return int(_value(character, "classic_magic_resistance", 0))
	if character is Object and character.has_meta(MagicResistanceScript.META_KEY):
		return int(character.get_meta(MagicResistanceScript.META_KEY))
	return 0


static func _store_magic_resistance(character: Variant, value: int) -> void:
	if character is Object \
			and character.has_method("set_classic_magic_resistance"):
		character.call("set_classic_magic_resistance", value)
	elif character is Object:
		character.set_meta(MagicResistanceScript.META_KEY, value)


static func _character_stat(character: Variant, stat_name: String) -> int:
	if character is Object and character.has_method("get_stat"):
		return int(character.call("get_stat", stat_name))
	var stats: Variant = _value(character, "stats", {})
	return int(stats.get(stat_name, 0)) if stats is Dictionary else 0


static func _native_identity_stat(definition: Variant, stat_name: String) -> int:
	var bonuses: Variant = {}
	if definition is Script:
		bonuses = definition.get_script_constant_map().get("base_stat_bonuses", {})
	else:
		bonuses = _value(definition, "base_stat_bonuses", {})
	if bonuses is Dictionary:
		return int(bonuses.get(stat_name, 0))
	return 0


static func _native_level_up_stat(character: Variant, stat_name: String) -> float:
	var total := 0.0
	for definition: Variant in [
		_value(character, "racegd", null),
		_value(character, "classgd", null),
	]:
		var bonuses: Variant = {}
		if definition is Script:
			bonuses = definition.get_script_constant_map().get(
				"levelup_bonuses",
				{}
			)
		else:
			bonuses = _value(definition, "levelup_bonuses", {})
		if bonuses is Dictionary:
			total += float(bonuses.get(stat_name, 0.0))
	return total


static func _raw_base_stat(character: Variant, stat_name: String) -> float:
	var base_stats: Variant = _value(character, "base_stats", {})
	if base_stats is Dictionary and base_stats.has(stat_name):
		return float(base_stats[stat_name])
	var stats: Variant = _value(character, "stats", {})
	if stats is Dictionary and stats.has(stat_name):
		return float(stats[stat_name])
	return 0.0


static func _native_unarmed_max(character: Variant) -> int:
	var weapon: Variant = _value(character, "ITEM_NO_MELEE_WEAPON", {})
	if not (weapon is Dictionary):
		return 0
	var physical: Variant = weapon.get("weapon_dmg", {}).get("Physical", [])
	if physical is Array and physical.size() >= 2:
		return int(physical[1])
	return 0


static func _has_hand_to_hand(character: Variant) -> bool:
	return character is Object \
		and character.has_method("has_classic_hand_to_hand") \
		and bool(character.call("has_classic_hand_to_hand"))


static func _current_hand_to_hand(character: Variant) -> int:
	if _has_hand_to_hand(character):
		return int(_value(character, "classic_hand_to_hand", 0))
	return 0


static func _store_hand_to_hand(character: Variant, value: int) -> void:
	if character is Object and character.has_method("set_classic_hand_to_hand"):
		character.call("set_classic_hand_to_hand", value)


static func _integer_array(value: Variant) -> Array[int]:
	var result: Array[int] = []
	if value is Array:
		for item: Variant in value:
			result.append(int(item))
	return result


static func _integer_rows(value: Variant) -> Array[Array]:
	var result: Array[Array] = []
	if value is Array:
		for row_value: Variant in value:
			result.append(_integer_array(row_value))
	return result


static func _campaign_id(bundle: Variant) -> String:
	if bundle == null:
		return ""
	var manifest: Variant = _value(bundle, "manifest", {})
	return str(manifest.get("id", "")) if manifest is Dictionary else ""


static func _bundle_document(bundle: Variant, document_name: String) -> Dictionary:
	if bundle == null:
		return {}
	var documents: Variant = _value(bundle, "documents", {})
	if documents is Dictionary:
		return _dictionary_value(documents.get(document_name, {}))
	return {}


static func _dictionary_value(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}


static func _value(source: Variant, property_name: String, fallback: Variant) -> Variant:
	if source is Dictionary:
		return source.get(property_name, fallback)
	if source == null or not (source is Object):
		return fallback
	for property: Dictionary in source.get_property_list():
		if str(property.get("name", "")) == property_name:
			return source.get(property_name)
	return fallback
