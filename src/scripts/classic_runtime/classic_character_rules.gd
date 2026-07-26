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
const ItemIdentityScript = preload(
	"res://scripts/classic_runtime/classic_item_identity.gd"
)
const ItemMaterializerScript = preload(
	"res://scripts/classic_runtime/classic_item_materializer.gd"
)
const ItemIdsScript = preload("res://scripts/item_id_divinity.gd")
const SpellIdentityScript = preload(
	"res://scripts/classic_runtime/classic_spell_identity.gd"
)
const LearnedSpellIdentityScript = preload(
	"res://scripts/classic_runtime/classic_learned_spell_identity.gd"
)
const RANDOM_ROLL_UNSET := -2147483648
const SECONDS_PER_DAY := 86400
const CLASSIC_CASTER_SCHOOLS := {
	1: "Sorcerer",
	2: "Priest",
	3: "Enchanter",
}
const SPECIAL_ABILITY_COUNT := 14
const PERCENT_SPECIAL_ABILITY_COUNT := 12
const FOE_TYPE_TAGS: Array[String] = [
	"Magic Using",
	"Undead",
	"Demonic",
	"Reptilian",
	"Evil Creature",
	"Intelligent",
	"Large Creature",
	"Non-Humanoid",
]
const SNEAK_ATTACK_ABILITY_INDEX := 0
const MAJOR_WOUND_ABILITY_INDEX := 3
const ACROBATIC_ACT_ABILITY_INDEX := 5
const DISARM_TRAP_ABILITY_INDEX := 7
const FORCE_LOCK_ABILITY_INDEX := 9
const PICK_LOCK_ABILITY_INDEX := 11
const TURN_UNDEAD_ABILITY_INDEX := 13
const SPECIAL_ABILITY_ATTRIBUTE_VALUES: Array[int] = [
	3, 4, 5, 6, 7,
	17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
]
const SPECIAL_ABILITY_STRENGTH_MODIFIERS := {
	SNEAK_ATTACK_ABILITY_INDEX:
		[-5, -4, -3, -2, -1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 4, 4],
	MAJOR_WOUND_ABILITY_INDEX:
		[-5, -4, -3, -2, -1, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14],
	ACROBATIC_ACT_ABILITY_INDEX:
		[-75, -60, -45, -30, -15, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70],
	DISARM_TRAP_ABILITY_INDEX:
		[-10, -8, -6, -4, -2, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28],
	FORCE_LOCK_ABILITY_INDEX:
		[-75, -60, -45, -30, -15, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70],
}
const SPECIAL_ABILITY_DEXTERITY_MODIFIERS := {
	SNEAK_ATTACK_ABILITY_INDEX:
		[-5, -4, -3, -2, -1, 1, 1, 2, 2, 3, 3, 4, 4, 4, 5, 5, 5, 5, 5],
	ACROBATIC_ACT_ABILITY_INDEX:
		[-20, -15, -10, -5, -2, 5, 8, 11, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65],
	DISARM_TRAP_ABILITY_INDEX:
		[-25, -20, -15, -10, -5, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70],
	PICK_LOCK_ABILITY_INDEX:
		[-25, -20, -15, -10, -5, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70],
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


## Initializes a temporary level-one PlayerCharacter with an active scenario
## race/caste pair, then advances it through the ordinary level-up owner.
##
## Starting inventory is intentionally separate because the creation UI applies
## it after spell selection, matching Classic's addinitialitems() order.
static func initialize_character_creation(
	bundle: Variant,
	character: Variant,
	gender: int,
	starting_level: int,
	attribute_rolls: Array[int] = [],
	age_year: int = RANDOM_ROLL_UNSET,
	stamina_roll: int = RANDOM_ROLL_UNSET,
	spell_point_rolls: Array[int] = []
) -> Dictionary:
	if not (character is Object) \
			or not character.has_method("apply_classic_rule_profile") \
			or not character.has_method("level_up"):
		return {
			"status": "error",
			"message": "Classic character creation requires a mutable player character.",
		}
	if int(_value(character, "level", 0)) != 1:
		return {
			"status": "error",
			"message": "Classic character creation must begin from native level one.",
		}
	if starting_level < 1:
		return {
			"status": "error",
			"message": "Classic character creation requires a positive starting level.",
		}

	var apply_result := apply_party(bundle, [character])
	if str(apply_result.get("status", "")) == "error":
		return apply_result
	var profile := _dictionary_value(
		_value(character, "classic_rule_profile", {})
	)
	if profile.is_empty():
		return {"status": "native"}
	if _dictionary_value(profile.get("creation", {})).is_empty():
		return {
			"status": "error",
			"message": (
				"The selected scenario race and caste do not provide a complete "
				+ "Classic creation profile."
			),
		}

	var attributes := apply_character_creation_attributes(
		character,
		gender,
		attribute_rolls,
		age_year
	)
	if str(attributes.get("status", "")) != "ok":
		return attributes
	_refresh_creation_magic_resistance(character)

	var defenses := apply_character_creation_defenses(character)
	if str(defenses.get("status", "")) != "ok":
		return defenses
	var combat := apply_character_creation_combat(character, stamina_roll)
	if str(combat.get("status", "")) != "ok":
		return combat
	var spellcasting := apply_character_creation_spellcasting(
		character,
		starting_level,
		spell_point_rolls
	)
	if str(spellcasting.get("status", "")) == "error":
		return spellcasting
	var special_abilities := apply_character_creation_special_abilities(
		character
	)
	if str(special_abilities.get("status", "")) != "ok":
		return special_abilities

	while int(_value(character, "level", 0)) < starting_level:
		character.call("level_up")
	if int(_value(character, "level", 0)) != starting_level:
		return {
			"status": "error",
			"message": "Classic character creation could not reach the selected level.",
		}
	var next_requirement := post_level_up_experience_requirement(
		character,
		starting_level + 1,
		int(_value(character, "exp_tnl", 0))
	)
	if _has_property(character, "exp_tnl"):
		character.set("exp_tnl", next_requirement)
	return {
		"status": "ok",
		"startingLevel": starting_level,
		"attributes": attributes,
		"defenses": defenses,
		"combat": combat,
		"spellcasting": spellcasting,
		"specialAbilities": special_abilities,
		"nextExperienceRequirement": next_requirement,
	}


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
	var victory_progression := _victory_progression_profile(
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
	var caste_runtime := _caste_runtime_profile(
		active_caste_record,
		not changed_caste_record.is_empty()
	)
	var race_runtime := _race_runtime_profile(
		active_race_record,
		not changed_race_record.is_empty()
	)
	var special_abilities := _special_ability_profile(
		active_race_record,
		active_caste_record,
		not changed_race_record.is_empty() or not changed_caste_record.is_empty()
	)
	var item_permissions := _item_permissions_profile(
		active_race_record,
		active_caste_record,
		not changed_race_record.is_empty() or not changed_caste_record.is_empty()
	)
	var foe_type_bonuses := _foe_type_bonus_profile(
		active_race_record,
		not changed_race_record.is_empty()
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
			and victory_progression.is_empty() \
			and condition_progression.is_empty() \
			and spellcasting_progression.is_empty() \
			and caste_runtime.is_empty() \
			and race_runtime.is_empty() \
			and special_abilities.is_empty() \
			and item_permissions.is_empty() \
			and foe_type_bonuses.is_empty() \
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
	if not victory_progression.is_empty():
		profile["victoryProgression"] = victory_progression
	if not condition_progression.is_empty():
		profile["conditionProgression"] = condition_progression
	if not spellcasting_progression.is_empty():
		profile["spellcastingProgression"] = spellcasting_progression
	if not caste_runtime.is_empty():
		profile["casteRuntime"] = caste_runtime
	if not race_runtime.is_empty():
		profile["raceRuntime"] = race_runtime
	if not special_abilities.is_empty():
		profile["specialAbilities"] = special_abilities
	if not item_permissions.is_empty():
		profile["itemPermissions"] = item_permissions
	if not foe_type_bonuses.is_empty():
		profile["foeTypeBonuses"] = foe_type_bonuses
	if not creation.is_empty():
		profile["creation"] = creation
	if race_id > 0:
		profile["raceId"] = race_id
		var race_names: Variant = rule_names.get("raceNames", [])
		if race_names is Array and race_id <= race_names.size():
			profile["raceName"] = str(race_names[race_id - 1])
	if caste_id > 0:
		profile["casteId"] = caste_id
		var caste_names: Variant = rule_names.get("casteNames", [])
		if caste_names is Array and caste_id <= caste_names.size():
			profile["casteName"] = str(caste_names[caste_id - 1])
	return profile


static func classic_foe_type_bonus(
	character: Variant,
	defender: Variant
) -> int:
	var profile := _dictionary_value(
		_value(character, "classic_rule_profile", {})
	)
	var foe_profile := _dictionary_value(profile.get("foeTypeBonuses", {}))
	var bonuses := _integer_array(foe_profile.get("bonuses", []))
	if bonuses.size() < FOE_TYPE_TAGS.size():
		return 0

	var tags: Variant = _value(defender, "tags", [])
	if not (tags is Array):
		return 0
	var result := 0
	for index: int in FOE_TYPE_TAGS.size():
		if tags.has(FOE_TYPE_TAGS[index]):
			result += bonuses[index]
	return result


static func classic_item_use_permission(
	character: Variant,
	item: Variant
) -> Dictionary:
	var profile := _dictionary_value(
		_value(character, "classic_rule_profile", {})
	)
	var permissions := _dictionary_value(profile.get("itemPermissions", {}))
	if permissions.is_empty():
		return {"status": "native", "allowed": true}
	if not (item is Dictionary):
		return {
			"status": "error",
			"allowed": false,
			"message": "Classic item permissions require an item record.",
		}

	var category := _classic_item_category(item)
	if category < 0:
		if _has_classic_item_identity(item):
			return {
				"status": "unresolved",
				"allowed": false,
				"message": "The Classic item's use category is unavailable.",
			}
		return {"status": "native", "allowed": true}

	var race_masks := _integer_array(permissions.get("raceMasks", []))
	var caste_masks := _integer_array(permissions.get("casteMasks", []))
	var race_allowed := _item_category_allowed(race_masks, category)
	var caste_allowed := _item_category_allowed(caste_masks, category)
	var classic_record := _dictionary_value(item.get("classicRecord", {}))
	var identity_permission := _classic_item_identity_permission(
		character,
		classic_record
	)
	var result := {
		"status": "ok",
		"allowed": (
			race_allowed
			and caste_allowed
			and bool(identity_permission.get("allowed", true))
		),
		"category": category,
		"raceAllowed": race_allowed,
		"casteAllowed": caste_allowed,
	}
	if bool(identity_permission.get("handled", false)):
		result["identityAllowed"] = bool(
			identity_permission.get("allowed", true)
		)
		result["handlesIdentityRestrictions"] = true
	return result


static func classic_race_id(
	character: Variant,
	rule_names: Dictionary = {}
) -> int:
	var names: Variant = rule_names.get(
		"raceNames",
		ItemMaterializerScript.STANDARD_RACE_NAMES
	)
	return AdmissionScript.classic_identity_id(character, "race", names)


static func classic_caste_id(
	character: Variant,
	rule_names: Dictionary = {}
) -> int:
	var names: Variant = rule_names.get(
		"casteNames",
		ItemMaterializerScript.STANDARD_CASTE_NAMES
	)
	return AdmissionScript.classic_identity_id(character, "caste", names)


static func classic_race_descriptors(
	character: Variant,
	rule_names: Dictionary = {}
) -> int:
	var profile := _dictionary_value(
		_value(character, "classic_rule_profile", {})
	)
	var race_runtime := _dictionary_value(profile.get("raceRuntime", {}))
	if race_runtime.has("descriptors"):
		return int(race_runtime["descriptors"])
	var race_id := classic_race_id(character, rule_names)
	if race_id < 1 \
			or race_id > ItemMaterializerScript.STANDARD_RACE_DESCRIPTORS.size():
		return 0
	return int(ItemMaterializerScript.STANDARD_RACE_DESCRIPTORS[race_id - 1])


static func classic_caste_class(
	character: Variant,
	rule_names: Dictionary = {}
) -> int:
	var profile := _dictionary_value(
		_value(character, "classic_rule_profile", {})
	)
	var caste_runtime := _dictionary_value(profile.get("casteRuntime", {}))
	if caste_runtime.has("casteClass"):
		return int(caste_runtime["casteClass"])
	var caste_id := classic_caste_id(character, rule_names)
	if caste_id < 1 \
			or caste_id > ItemMaterializerScript.STANDARD_CASTE_CLASSES.size():
		return 0
	return int(ItemMaterializerScript.STANDARD_CASTE_CLASSES[caste_id - 1])


static func adjusted_stat(
	character: Variant,
	profile: Dictionary,
	stat_name: String,
	native_value: Variant
) -> Variant:
	if stat_name == "MaxMovement":
		var movement := _dictionary_value(profile.get("movement", {}))
		var adjusted := float(native_value)
		if not movement.is_empty():
			# Remake already combines identity and equipment movement. Replace
			# only native identity contributions so equipment still applies.
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
		adjusted += int(
			_value(character, "classic_age_movement_adjustment", 0)
		)
		return roundi(adjusted)
	if stat_name == "MaxActions":
		var attacks := _dictionary_value(profile.get("attacks", {}))
		if attacks.is_empty():
			return native_value
		return float(native_value) + float(
			attacks.get("nativeAdjustment", 0.0)
		)
	if stat_name == "MaxSpellsPerRound":
		var caste_runtime := _dictionary_value(
			profile.get("casteRuntime", {})
		)
		if caste_runtime.is_empty() \
				or not caste_runtime.has("maxSpellsPerRound"):
			return native_value
		# Remake already combines identity and equipment stats. Replace only
		# the native class contribution with Classic's caste-owned limit.
		return roundi(
			float(native_value)
			+ int(caste_runtime["maxSpellsPerRound"])
			- _native_identity_stat(
				_value(character, "classgd", null),
				stat_name
			)
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


## Initializes the fourteen Classic special abilities from the active race and
## caste. A race contributes to an ordinary skill only when the caste enables
## that skill. Turn Undead is the exception: Realmz restores the racial value
## even when the caste has no starting value.
static func apply_character_creation_special_abilities(
	character: Variant
) -> Dictionary:
	var profile := _dictionary_value(
		_value(character, "classic_rule_profile", {})
	)
	var rules := _dictionary_value(profile.get("specialAbilities", {}))
	if rules.is_empty():
		return {"status": "skipped"}
	if not (character is Object) \
			or not character.has_method("set_classic_special_abilities"):
		return {
			"status": "error",
			"message": "Classic character creation requires mutable special abilities.",
		}

	var race_base := _integer_array(rules.get("raceBase", []))
	var caste_base := _integer_array(rules.get("casteBase", []))
	if race_base.size() != SPECIAL_ABILITY_COUNT \
			or caste_base.size() != SPECIAL_ABILITY_COUNT:
		return {
			"status": "error",
			"message": "Classic character creation has incomplete special abilities.",
		}

	var strength := _character_stat(character, "Strength")
	var dexterity := _character_stat(character, "Dexterity")
	var abilities: Array[int] = []
	for ability_index: int in range(SPECIAL_ABILITY_COUNT):
		var value := 0
		if ability_index == TURN_UNDEAD_ABILITY_INDEX:
			value = race_base[ability_index] + caste_base[ability_index]
		elif caste_base[ability_index] != 0:
			value = race_base[ability_index] + caste_base[ability_index]
			value += _special_ability_attribute_modifier(
				SPECIAL_ABILITY_STRENGTH_MODIFIERS,
				ability_index,
				strength
			)
			value += _special_ability_attribute_modifier(
				SPECIAL_ABILITY_DEXTERITY_MODIFIERS,
				ability_index,
				dexterity
			)
		if ability_index < PERCENT_SPECIAL_ABILITY_COUNT:
			value = clampi(value, 0, 100)
		abilities.append(value)

	character.call("set_classic_special_abilities", abilities)
	return {"status": "ok", "abilities": abilities}


## Applies one Classic level's random special-ability gains. The optional
## rolls make source-bound tests deterministic; an empty array uses Realmz's
## inclusive random formula for every enabled slot.
static func apply_level_up_special_ability_progression(
	character: Variant,
	requested_rolls: Array[int] = []
) -> Dictionary:
	var profile := _dictionary_value(
		_value(character, "classic_rule_profile", {})
	)
	var rules := _dictionary_value(profile.get("specialAbilities", {}))
	if rules.is_empty():
		return {"status": "skipped"}
	if not requested_rolls.is_empty() \
			and requested_rolls.size() != SPECIAL_ABILITY_COUNT:
		return {
			"status": "error",
			"message": "Classic special-ability progression requires fourteen rolls.",
		}
	if not (character is Object) \
			or not character.has_method("set_classic_special_abilities"):
		return {
			"status": "error",
			"message": "Classic special-ability progression requires mutable abilities.",
		}

	var race_base := _integer_array(rules.get("raceBase", []))
	var caste_base := _integer_array(rules.get("casteBase", []))
	var level_maximums := _integer_array(rules.get("levelMaximums", []))
	var abilities := _integer_array(
		_value(character, "classic_special_abilities", [])
	)
	if race_base.size() != SPECIAL_ABILITY_COUNT \
			or caste_base.size() != SPECIAL_ABILITY_COUNT \
			or level_maximums.size() != SPECIAL_ABILITY_COUNT \
			or abilities.size() < SPECIAL_ABILITY_COUNT:
		return {
			"status": "error",
			"message": "Classic special-ability progression has incomplete state.",
		}

	var rolls: Array[int] = []
	for ability_index: int in range(SPECIAL_ABILITY_COUNT):
		var maximum := level_maximums[ability_index]
		var roll := 0
		if maximum != 0:
			var requested_roll := (
				requested_rolls[ability_index]
				if not requested_rolls.is_empty()
				else RANDOM_ROLL_UNSET
			)
			roll = _classic_rand(maximum, requested_roll)
			abilities[ability_index] += roll
		if ability_index < PERCENT_SPECIAL_ABILITY_COUNT:
			abilities[ability_index] = clampi(
				abilities[ability_index],
				0,
				100
			)
		rolls.append(roll)

	# bandaid() makes Turn Undead at least the racial base plus the caste's
	# deterministic value for the current level, even though updatespec() also
	# rolls that slot. Preserve a larger value supplied by items or actions.
	var turn_undead_floor := (
		race_base[TURN_UNDEAD_ABILITY_INDEX]
		+ caste_base[TURN_UNDEAD_ABILITY_INDEX]
		+ level_maximums[TURN_UNDEAD_ABILITY_INDEX]
			* maxi(0, int(_value(character, "level", 1)) - 1)
	)
	abilities[TURN_UNDEAD_ABILITY_INDEX] = maxi(
		abilities[TURN_UNDEAD_ABILITY_INDEX],
		turn_undead_floor
	)
	character.call("set_classic_special_abilities", abilities)
	return {
		"status": "ok",
		"rolls": rolls,
		"abilities": abilities.slice(0, SPECIAL_ABILITY_COUNT),
		"turnUndeadFloor": turn_undead_floor,
	}


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


## Advances the exact Classic age counter and applies at most one age band.
##
## Classic calls age() once per midnight, aging attack, or aging spell. Even
## when a spell jumps across several bands, that call applies only the next
## row in the direction of travel.
static func advance_character_age_days(
	character: Variant,
	day_change: int
) -> Dictionary:
	var creation := _dictionary_value(
		_dictionary_value(
			_value(character, "classic_rule_profile", {})
		).get("creation", {})
	)
	if creation.is_empty():
		return {"status": "skipped"}
	if not (character is Object) \
			or not character.has_method("has_classic_creation_demographics") \
			or not bool(character.call("has_classic_creation_demographics")) \
			or not character.has_method("set_classic_age_state") \
			or not character.has_method("has_classic_saving_throws") \
			or not bool(character.call("has_classic_saving_throws")) \
			or not character.has_method("has_classic_magic_resistance") \
			or not bool(character.call("has_classic_magic_resistance")):
		return {
			"status": "error",
			"message": "Classic aging requires initialized character state.",
		}

	var age_ranges := _integer_rows(creation.get("ageRanges", []))
	var age_changes := _integer_rows(creation.get("ageChanges", []))
	if age_ranges.size() != 5 or age_changes.size() != 5:
		return {
			"status": "error",
			"message": "Classic aging has incomplete race rules.",
		}
	for age_range: Array[int] in age_ranges:
		if age_range.size() != 2 or age_range[0] > age_range[1]:
			return {
				"status": "error",
				"message": "Classic aging has an invalid age range.",
			}
	for changes: Array[int] in age_changes:
		if changes.size() != 15:
			return {
				"status": "error",
				"message": "Classic aging has an invalid change row.",
			}

	var current_days := int(
		_value(
			character,
			"classic_age_days",
			int(_value(character, "classic_age_years", 0)) * 365
		)
	)
	var target_days := current_days + day_change
	if target_days < 0:
		return {
			"status": "error",
			"message": "Classic age cannot be negative.",
		}
	var current_group := int(_value(character, "classic_age_group", 0))
	if current_group < 1 or current_group > 5:
		return {
			"status": "error",
			"message": "Classic aging requires a valid current age group.",
		}

	var target_group := 0
	var target_year := int(target_days / 365)
	for range_index: int in range(age_ranges.size()):
		var age_range: Array[int] = age_ranges[range_index]
		if target_year >= age_range[0] and target_year <= age_range[1]:
			target_group = range_index + 1
			break

	var direction := 0
	var next_group := current_group
	var change_row_index := -1
	if target_group > current_group and current_group < 5:
		direction = 1
		next_group = current_group + 1
		change_row_index = next_group - 1
	elif target_group > 0 and target_group < current_group and current_group > 1:
		direction = -1
		next_group = current_group - 1
		change_row_index = current_group - 1

	var assigned := {
		"classicAgeDays": target_days,
		"classicAgeYears": target_year,
		"classicAgeGroup": next_group,
	}
	if direction == 0:
		character.call("set_classic_age_state", assigned)
		return {
			"status": "ok",
			"ageDays": target_days,
			"ageYears": target_year,
			"ageGroup": current_group,
			"transition": 0,
		}

	var changes: Array[int] = age_changes[change_row_index]
	var base_stats: Variant = _value(character, "base_stats", {})
	if not (base_stats is Dictionary):
		return {
			"status": "error",
			"message": "Classic aging requires native base stats.",
		}
	var old_strength := _character_stat(character, "Strength")
	var new_strength := old_strength + direction * changes[0]
	var maximum_damage_bonus := int(
		creation.get("maximumStrengthDamageBonus", 0)
	)
	var old_strength_bonuses := _classic_strength_bonuses(
		old_strength,
		maximum_damage_bonus
	)
	var new_strength_bonuses := _classic_strength_bonuses(
		new_strength,
		maximum_damage_bonus
	)
	var attributes := {
		"Strength": int(base_stats.get("Strength", 0))
			+ direction * changes[0],
		"Intellect": int(base_stats.get("Intellect", 0))
			+ direction * changes[1],
		"Wisdom": int(base_stats.get("Wisdom", 0))
			+ direction * changes[2],
		"Dexterity": int(base_stats.get("Dexterity", 0))
			+ direction * changes[3],
		"Vitality": int(base_stats.get("Vitality", 0))
			+ direction * changes[4],
	}
	var accuracy_melee := float(base_stats.get("AccuracyMelee", 0.0)) \
		+ (
			int(new_strength_bonuses["toHit"])
			- int(old_strength_bonuses["toHit"])
		) / 5.0
	var physical_damage := int(base_stats.get("Bonus_Physical_dmg", 0)) \
		+ int(new_strength_bonuses["damage"]) \
		- int(old_strength_bonuses["damage"])
	var movement_adjustment := int(
		_value(character, "classic_age_movement_adjustment", 0)
	)
	var current_movement := _character_stat(character, "MaxMovement")
	var next_movement := maxi(
		2,
		current_movement + direction * changes[7]
	)
	movement_adjustment += next_movement - current_movement
	var saving_throws: Array[int] = []
	for save_index: int in range(8):
		var saving_throw := int(
			character.call("get_classic_saving_throw", save_index)
		)
		if save_index < 7:
			saving_throw += direction * changes[8 + save_index]
		saving_throws.append(saving_throw)

	assigned.merge({
		"attributes": attributes,
		"classicLuck": int(_value(character, "classic_luck", 0))
			+ direction * changes[5],
		"classicMagicResistance": int(
			_value(character, "classic_magic_resistance", 0)
		) + direction * changes[6],
		"classicAgeMovementAdjustment": movement_adjustment,
		"classicSavingThrows": saving_throws,
		"AccuracyMelee": accuracy_melee,
		"Bonus_Physical_dmg": physical_damage,
	})
	character.call("set_classic_age_state", assigned)
	return {
		"status": "ok",
		"ageDays": target_days,
		"ageYears": target_year,
		"ageGroup": next_group,
		"transition": direction,
		"changeRow": change_row_index,
	}


## Applies one daily Classic aging call for every crossed game midnight.
static func advance_character_age_between_times(
	character: Variant,
	previous_time: int,
	current_time: int
) -> Dictionary:
	if previous_time < 0 or current_time <= previous_time:
		return {"status": "skipped", "days": 0, "transitions": []}
	var previous_day := int(floor(float(previous_time) / SECONDS_PER_DAY))
	var current_day := int(floor(float(current_time) / SECONDS_PER_DAY))
	var elapsed_days := maxi(0, current_day - previous_day)
	var transitions: Array[int] = []
	for _day: int in range(elapsed_days):
		var result := advance_character_age_days(character, 1)
		if str(result.get("status", "")) == "error":
			return result
		if int(result.get("transition", 0)) != 0:
			transitions.append(int(result["transition"]))
	return {
		"status": "ok" if elapsed_days > 0 else "skipped",
		"days": elapsed_days,
		"transitions": transitions,
	}


## Returns one character's share of a Classic battle reward.
##
## booty.c applies the maximum-age reduction after dividing combat experience
## among eligible party members. Other experience awards do not use this rule.
static func classic_battle_experience(
	character: Variant,
	experience: int
) -> int:
	var share := maxi(0, experience)
	var creation := _dictionary_value(
		_dictionary_value(
			_value(character, "classic_rule_profile", {})
		).get("creation", {})
	)
	var maximum_age := int(creation.get("maximumAge", 0))
	if maximum_age <= 0 \
			or not bool(
				_value(
					character,
					"classic_creation_demographics_initialized",
					false
				)
			):
		return share
	var age_days := int(
		_value(
			character,
			"classic_age_days",
			int(_value(character, "classic_age_years", 0)) * 365
		)
	)
	if int(age_days / 365) < maximum_age:
		return share
	# Preserve the source's float multiplication followed by integer storage.
	return int(float(share) * 0.6666666)


## Returns the active caste requirement loaded after an advancement.
## Realmz performs this lookup before incrementing the character's level, so
## the new level uses the preceding one-based table row. Lookups cap at row 30.
static func post_level_up_experience_requirement(
	character: Variant,
	new_level: int,
	native_requirement: int
) -> int:
	var profile := _dictionary_value(
		_value(character, "classic_rule_profile", {})
	)
	var progression := _dictionary_value(
		profile.get("victoryProgression", {})
	)
	var requirements := _integer_array(
		progression.get("requirements", [])
	)
	if requirements.size() != 30:
		return native_requirement
	var index := clampi(new_level - 2, 0, 29)
	return maxi(0, requirements[index])


## Applies Classic's eight saving throws and forty starting conditions.
##
## Call this after apply_character_creation_attributes so the caste's starting
## age group is available for the seven age-adjusted saving throws.
static func apply_character_creation_defenses(character: Variant) -> Dictionary:
	var creation := _dictionary_value(
		_dictionary_value(
			_value(character, "classic_rule_profile", {})
		).get("creation", {})
	)
	if creation.is_empty():
		return {"status": "skipped"}
	if not (character is Object) \
			or not character.has_method("set_classic_saving_throws") \
			or not character.has_method("set_classic_conditions") \
			or not character.has_method("set_classic_can_regenerate"):
		return {
			"status": "error",
			"message": "Classic character creation requires mutable defense state.",
		}
	if not character.has_method("has_classic_creation_demographics") \
			or not bool(character.call("has_classic_creation_demographics")):
		return {
			"status": "error",
			"message": "Classic defenses require finalized creation demographics.",
		}

	var race_saves := _integer_array(
		creation.get("raceSavingThrowBonuses", [])
	)
	var caste_saves := _integer_array(
		creation.get("casteSavingThrowBonuses", [])
	)
	var age_changes := _integer_rows(creation.get("ageChanges", []))
	var race_conditions := _integer_array(
		creation.get("raceStartingConditions", [])
	)
	var caste_conditions := _integer_array(
		creation.get("casteConditionLevels", [])
	)
	var age_group := int(_value(character, "classic_age_group", 0))
	if race_saves.size() != 8 \
			or caste_saves.size() != 8 \
			or age_changes.size() != 5 \
			or race_conditions.size() != 40 \
			or caste_conditions.size() != 40 \
			or age_group < 1 \
			or age_group > 5:
		return {
			"status": "error",
			"message": "Classic character creation has incomplete defense rules.",
		}
	for row: Array[int] in age_changes:
		if row.size() != 15:
			return {
				"status": "error",
				"message": "Classic character creation has invalid age defenses.",
			}

	var saving_throws: Array[int] = []
	for save_index: int in range(8):
		var value := 50 + race_saves[save_index] + caste_saves[save_index]
		# age.c changes only the first seven DRVs. The special save at index
		# seven keeps its race-and-caste creation value.
		if save_index < 7:
			for age_group_index: int in range(age_group):
				value += age_changes[age_group_index][8 + save_index]
		saving_throws.append(clampi(value, -99, 120))

	var starting_conditions := race_conditions.duplicate()
	for condition_index: int in range(40):
		# A caste value of one is an innate condition. Larger values are level
		# thresholds and are handled by apply_level_up_condition_progression.
		if caste_conditions[condition_index] == 1:
			starting_conditions[condition_index] = -1

	var unsupported_indices: Array[int] = []
	for condition_index: int in range(starting_conditions.size()):
		if starting_conditions[condition_index] != 0 \
				and not CharacterConditionRulesScript.supports_condition(
					condition_index
				):
			unsupported_indices.append(condition_index)
	if not unsupported_indices.is_empty():
		return {
			"status": "error",
			"message": (
				"Classic starting conditions have no safe Remake mapping: %s"
				% str(unsupported_indices)
			),
			"unsupportedConditionIndices": unsupported_indices,
		}

	character.call("set_classic_saving_throws", saving_throws)
	character.call("set_classic_conditions", starting_conditions)
	character.call(
		"set_classic_can_regenerate",
		bool(creation.get("raceCanRegenerate", false))
	)
	var applied_conditions: Array[Dictionary] = []
	for condition_index: int in range(starting_conditions.size()):
		var condition_value: int = int(starting_conditions[condition_index])
		if condition_value == 0:
			continue
		var result: Dictionary = (
			CharacterConditionRulesScript.set_condition_value(
				character,
				condition_index,
				condition_value
			)
		)
		if str(result.get("status", "")) == "error":
			return result
		applied_conditions.append(result)
	return {
		"status": "ok",
		"savingThrows": saving_throws,
		"conditions": starting_conditions,
		"canRegenerate": bool(creation.get("raceCanRegenerate", false)),
		"appliedConditions": applied_conditions,
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


## Replaces Remake's native creation gifts with the active Classic caste's
## starting items and gold. Call this once after advanced-level progression and
## spell selection, matching newcharacter.c's addinitialitems() order.
static func apply_character_creation_resources(
	character: Variant,
	item_book: Dictionary,
	item_mapping: Dictionary = {}
) -> Dictionary:
	var creation := _dictionary_value(
		_dictionary_value(
			_value(character, "classic_rule_profile", {})
		).get("creation", {})
	)
	if creation.is_empty():
		return {"status": "skipped"}
	if not (character is Object) \
			or not character.has_method("set_classic_creation_resources"):
		return {
			"status": "error",
			"message": "Classic character creation requires mutable resource state.",
		}
	if character.has_method("has_classic_creation_resources") \
			and bool(character.call("has_classic_creation_resources")):
		return {"status": "skipped", "reason": "already-applied"}

	var starting_item_ids := _integer_array(
		creation.get("startingItemIds", [])
	)
	if starting_item_ids.size() != 20:
		return {
			"status": "error",
			"message": "Classic character creation requires twenty starting-item slots.",
		}
	var effective_mapping := (
		item_mapping
		if not item_mapping.is_empty()
		else _default_item_mapping()
	)
	var resolved_items: Array[Dictionary] = []
	for raw_item_id: int in starting_item_ids:
		if raw_item_id == 0:
			continue
		var item_id := absi(raw_item_id)
		var resource_key := ItemIdentityScript.resource_key(
			item_id,
			effective_mapping,
			[],
			item_book
		)
		if resource_key.is_empty() \
				or not item_book.has(resource_key) \
				or not (item_book[resource_key] is Dictionary):
			return {
				"status": "error",
				"message": (
					"Classic starting item %d has no native Remake resource."
					% item_id
				),
				"itemId": item_id,
			}
		var item: Dictionary = item_book[resource_key].duplicate(true)
		item["classicItemId"] = item_id
		item["is_identified"] = 1
		item["equipped"] = 0
		resolved_items.append(item)

	var applied: Variant = character.call(
		"set_classic_creation_resources",
		resolved_items,
		int(creation.get("startingMoney", 0))
	)
	if not (applied is Dictionary):
		return {
			"status": "error",
			"message": "Classic character resource owner returned an invalid result.",
		}
	return applied


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


static func _caste_runtime_profile(
	caste_record: Dictionary,
	has_changed_caste: bool
) -> Dictionary:
	if not has_changed_caste \
			or not caste_record.has("getsMissileBonus") \
			or not caste_record.has("maxSpellsAttacks") \
			or not caste_record.has("casteClass"):
		return {}
	return {
		"getsMissileBonus": int(caste_record["getsMissileBonus"]) != 0,
		"maxSpellsPerRound": maxi(
			0,
			int(caste_record["maxSpellsAttacks"])
		),
		"casteClass": int(caste_record["casteClass"]),
	}


static func _race_runtime_profile(
	race_record: Dictionary,
	has_changed_race: bool
) -> Dictionary:
	if not has_changed_race or not race_record.has("descriptors"):
		return {}
	return {
		"descriptors": int(race_record["descriptors"]),
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


static func _special_ability_profile(
	race_record: Dictionary,
	caste_record: Dictionary,
	has_changed_record: bool
) -> Dictionary:
	if not has_changed_record:
		return {}
	var race_base := _integer_array(race_record.get("specialAbility", []))
	var caste_rows := _integer_rows(caste_record.get("specialAbility", []))
	if race_base.size() != SPECIAL_ABILITY_COUNT \
			or caste_rows.size() != 2 \
			or caste_rows[0].size() != SPECIAL_ABILITY_COUNT \
			or caste_rows[1].size() != SPECIAL_ABILITY_COUNT:
		return {}
	return {
		"raceBase": race_base,
		"casteBase": caste_rows[0],
		"levelMaximums": caste_rows[1],
	}


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
	var race_saving_throw_bonuses := _integer_array(
		race_record.get("drvBonus", [])
	)
	var caste_saving_throw_bonuses := _integer_array(
		caste_record.get("drvBonus", [])
	)
	var race_starting_conditions := _integer_array(
		race_record.get("conditions", [])
	)
	var caste_condition_levels := _integer_array(
		caste_record.get("conditions", [])
	)
	var starting_item_ids := _integer_array(caste_record.get("startItems", []))
	if stamina.size() < 2 \
			or race_attribute_bonuses.size() != 6 \
			or caste_attribute_bonuses.size() != 6 \
			or race_attribute_limits.size() != 12 \
			or caste_attribute_limits.size() != 12 \
			or race_saving_throw_bonuses.size() != 8 \
			or caste_saving_throw_bonuses.size() != 8 \
			or race_starting_conditions.size() != 40 \
			or caste_condition_levels.size() != 40 \
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
			or not caste_record.has("startMoney") \
			or starting_item_ids.size() != 20 \
			or not race_record.has("missile") \
			or not race_record.has("maxAge") \
			or not race_record.has("canRegenerate"):
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
		"maximumAge": int(race_record["maxAge"]),
		"raceSavingThrowBonuses": race_saving_throw_bonuses,
		"casteSavingThrowBonuses": caste_saving_throw_bonuses,
		"raceStartingConditions": race_starting_conditions,
		"casteConditionLevels": caste_condition_levels,
		"raceCanRegenerate": int(race_record["canRegenerate"]) != 0,
		"staminaDieMaximum": stamina[0],
		"maximumVitalityBonus": int(caste_record["maxStaminaBonus"]),
		"toHitBase": to_hit[0],
		"dodgeBase": dodge[0],
		"raceMissileBase": int(race_record["missile"]),
		"casteMissileBase": caste_missile[0],
		"canUseMissile": int(caste_record["canUseMissile"]) != 0,
		"handToHandBase": hand_to_hand[0],
		"maximumStrengthDamageBonus": strength[1],
		"startingMoney": int(caste_record["startMoney"]),
		"startingItemIds": starting_item_ids,
	}


static func _item_permissions_profile(
	race_record: Dictionary,
	caste_record: Dictionary,
	has_changed_record: bool
) -> Dictionary:
	if not has_changed_record:
		return {}
	var race_masks := _integer_array(race_record.get("itemTypes", []))
	var caste_masks := _integer_array(caste_record.get("itemTypes", []))
	if race_masks.size() != 2 or caste_masks.size() != 2:
		return {}
	return {
		"raceMasks": race_masks,
		"casteMasks": caste_masks,
	}


static func _classic_item_category(item: Dictionary) -> int:
	var stored_category := int(item.get("classicItemCategory", -1))
	if stored_category >= 0 and stored_category < 58:
		return stored_category
	var classic_record := _dictionary_value(item.get("classicRecord", {}))
	for category: int in range(58):
		var field_name := "itemCat0" if category < 32 else "itemCat1"
		var storage_bit := 31 - category % 32
		if (int(classic_record.get(field_name, 0)) & (1 << storage_bit)) != 0:
			return category
	return -1


static func _has_classic_item_identity(item: Dictionary) -> bool:
	return item.has("classicItemId") \
		or item.has("classicItemIds") \
		or item.has("classic_item_id") \
		or item.has("classicRecord")


static func _item_category_allowed(masks: Array[int], category: int) -> bool:
	var word := int(category / 32)
	if category < 0 or category >= 58 or masks.size() <= word:
		return false
	var storage_bit := 31 - category % 32
	return (masks[word] & (1 << storage_bit)) != 0


static func _classic_item_identity_permission(
	character: Variant,
	record: Dictionary
) -> Dictionary:
	if record.is_empty():
		return {"handled": false, "allowed": true}
	var specific_race := int(record.get("specificRace", 0))
	var specific_caste := int(record.get("specificCaste", 0))
	var race_restrictions := int(record.get("raceRestrictions", 0))
	var race_only := int(record.get("raceClassOnly", 0))
	var caste_restrictions := int(record.get("casteRestrictions", 0))
	var caste_only := int(record.get("casteClassOnly", 0))
	var handled := (
		specific_race != 0
		or specific_caste != 0
		or race_restrictions != 0
		or race_only != 0
		or caste_restrictions != 0
		or caste_only != 0
	)
	if not handled:
		return {"handled": false, "allowed": true}

	var race_id := classic_race_id(character)
	var caste_id := classic_caste_id(character)
	var descriptors := classic_race_descriptors(character)
	var caste_class := classic_caste_class(character)
	var allowed := true
	if specific_race != 0:
		allowed = allowed and race_id == specific_race
	if specific_caste != 0:
		allowed = allowed and caste_id == specific_caste
	if race_restrictions != 0:
		allowed = allowed and not _classic_masks_overlap(
			descriptors,
			race_restrictions,
			9
		)
	if race_only != 0:
		allowed = allowed and _classic_mask_contains_all(
			descriptors,
			race_only,
			9
		)
	if caste_restrictions != 0:
		allowed = allowed and caste_class > 0 \
			and not _classic_mask_has(caste_restrictions, caste_class - 1)
	if caste_only != 0:
		allowed = allowed and caste_class > 0 \
			and _classic_mask_has(caste_only, caste_class - 1)
	return {
		"handled": true,
		"allowed": allowed,
		"raceId": race_id,
		"casteId": caste_id,
		"raceDescriptors": descriptors,
		"casteClass": caste_class,
	}


static func _classic_mask_has(mask: int, bit_index: int) -> bool:
	return bit_index >= 0 \
		and bit_index < 16 \
		and (mask & (1 << (15 - bit_index))) != 0


static func _classic_masks_overlap(
	left: int,
	right: int,
	bit_count: int
) -> bool:
	for bit_index: int in range(bit_count):
		if _classic_mask_has(left, bit_index) \
				and _classic_mask_has(right, bit_index):
			return true
	return false


static func _classic_mask_contains_all(
	value: int,
	required: int,
	bit_count: int
) -> bool:
	for bit_index: int in range(bit_count):
		if _classic_mask_has(required, bit_index) \
				and not _classic_mask_has(value, bit_index):
			return false
	return true


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


static func _victory_progression_profile(
	caste_record: Dictionary,
	has_changed_caste: bool
) -> Dictionary:
	if not has_changed_caste:
		return {}
	var requirements := _integer_array(caste_record.get("victory", []))
	if requirements.size() != 30:
		return {}
	return {"requirements": requirements}


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


static func _foe_type_bonus_profile(
	race_record: Dictionary,
	has_changed_race: bool
) -> Dictionary:
	if not has_changed_race:
		return {}
	var bonuses := _integer_array(race_record.get("plusMinusToHit", []))
	if bonuses.size() < FOE_TYPE_TAGS.size():
		return {}
	bonuses.resize(FOE_TYPE_TAGS.size())
	return {"bonuses": bonuses}


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


static func _special_ability_attribute_modifier(
	modifiers: Dictionary,
	ability_index: int,
	attribute_value: int
) -> int:
	var range_index := SPECIAL_ABILITY_ATTRIBUTE_VALUES.find(attribute_value)
	if range_index < 0:
		return 0
	var values: Variant = modifiers.get(ability_index, [])
	if not (values is Array) or range_index >= values.size():
		return 0
	return int(values[range_index])


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


static func apply_attribute_improvement(
	character: Variant,
	source_size: int
) -> Dictionary:
	if not (character is Object):
		return {
			"status": "error",
			"message": "Classic attribute improvement target is invalid.",
		}
	if source_size == 6:
		if not _has_property(character, "classic_luck"):
			return {
				"status": "error",
				"message": "Classic Luck target has no compatibility value.",
			}
		var current_luck := int(_value(character, "classic_luck", 0))
		if current_luck >= 25:
			return {"status": "capped", "sourceSize": source_size}
		if character.has_method("set_classic_luck"):
			character.call("set_classic_luck", current_luck + 1)
		else:
			character.set("classic_luck", current_luck + 1)
		return {
			"status": "applied",
			"sourceSize": source_size,
			"stat": "Luck",
			"previous": current_luck,
			"current": current_luck + 1,
			"magicResistanceBonus": 0,
		}

	var stat_name := str({
		2: "Intellect",
		3: "Wisdom",
	}.get(source_size, ""))
	if stat_name.is_empty():
		return {
			"status": "error",
			"message": (
				"Classic attribute improvement size %d is unsupported."
				% source_size
			),
		}
	var base_stats_value: Variant = _value(character, "base_stats", {})
	if not (base_stats_value is Dictionary) \
			or not base_stats_value.has(stat_name):
		return {
			"status": "error",
			"message": (
				"Classic attribute improvement target has no %s value."
				% stat_name
			),
		}
	var base_stats: Dictionary = base_stats_value
	var previous := int(base_stats[stat_name])
	if previous >= 25:
		return {"status": "capped", "sourceSize": source_size, "stat": stat_name}
	var current := previous + 1
	base_stats[stat_name] = current
	if character.has_method("recalculate_stats"):
		character.call("recalculate_stats")

	var magic_resistance_bonus := 0
	if current > 15:
		var profile := _dictionary_value(
			_value(character, "classic_rule_profile", {})
		)
		var magic_resistance := _dictionary_value(
			profile.get("magicResistance", {})
		)
		if not magic_resistance.is_empty():
			_sync_magic_resistance(character, profile)
			magic_resistance_bonus = int(
				magic_resistance.get("casteMultiplier", 0)
			)
			if _has_magic_resistance(character):
				_store_magic_resistance(
					character,
					_current_magic_resistance(character)
						+ magic_resistance_bonus
				)
	return {
		"status": "applied",
		"sourceSize": source_size,
		"stat": stat_name,
		"previous": previous,
		"current": current,
		"magicResistanceBonus": magic_resistance_bonus,
	}


static func apply_first_spell_memory_increment(
	character: Variant,
	spell_book: Dictionary,
	spell_id_mapping: Dictionary
) -> Dictionary:
	if not (character is Object):
		return {
			"status": "error",
			"message": "Classic spell-memory target is invalid.",
		}
	var spells_value: Variant = _value(character, "spells", null)
	if not (spells_value is Array):
		return {
			"status": "error",
			"message": "Classic spell-memory target has no learned-spell table.",
		}
	var spells: Array = spells_value
	if character.has_method("ensure_classic_spell_levels"):
		character.call("ensure_classic_spell_levels", 1)
	while spells.is_empty():
		spells.append([])
	if not (spells[0] is Array):
		return {
			"status": "error",
			"message": "Classic spell-memory target has an invalid level-one spell row.",
		}

	var caster_type := _active_spellcaster_type(
		character,
		_spellcasting_progression(character)
	)
	var spell_id := caster_type * 1000 + 101 \
		if caster_type in range(1, 4) else 0
	var previous := _first_spell_memory_byte(character, spells[0], spell_id)
	if previous >= 25:
		return {
			"status": "capped",
			"sourceSize": 7,
			"previous": previous,
			"current": previous,
			"spellId": spell_id,
			"learned": false,
		}

	var learned_entry: Dictionary = {}
	var resource_name := ""
	var already_learned := (
		spell_id > 0
		and _has_learned_spell_id(spells[0], spell_id)
	)
	if spell_id > 0 and not already_learned:
		resource_name = SpellIdentityScript.resource_key(
			spell_id,
			spell_id_mapping,
			spell_book
		)
		if resource_name.is_empty():
			return {
				"status": "error",
				"message": (
					"Classic spell-memory mutation cannot resolve first spell %d."
					% spell_id
				),
			}
		var resource_value: Variant = spell_book.get(resource_name)
		if not (resource_value is Dictionary):
			return {
				"status": "error",
				"message": (
					"Classic spell-memory mutation has no resource for first spell %d."
					% spell_id
				),
			}
		learned_entry = LearnedSpellIdentityScript.with_explicit_id(
			resource_value,
			spell_id,
			resource_name
		)

	var current := previous + 1
	_store_first_spell_memory_byte(character, current)
	if not learned_entry.is_empty():
		if character.has_method("add_spell_drom_dict"):
			character.call(
				"add_spell_drom_dict",
				spell_book[resource_name],
				1,
				spell_id
			)
		else:
			spells[0].append(learned_entry)
	return {
		"status": "applied",
		"sourceSize": 7,
		"previous": previous,
		"current": current,
		"spellId": spell_id,
		"resourceName": resource_name,
		"learned": not learned_entry.is_empty(),
	}


static func _first_spell_memory_byte(
	character: Object,
	first_level: Array,
	spell_id: int
) -> int:
	if character.has_method("has_classic_first_spell_memory_byte") \
			and bool(character.call("has_classic_first_spell_memory_byte")):
		return int(_value(character, "classic_first_spell_memory_byte", 0))
	if _has_property(character, "classic_first_spell_memory_byte_initialized") \
			and bool(_value(
				character,
				"classic_first_spell_memory_byte_initialized",
				false
			)):
		return int(_value(character, "classic_first_spell_memory_byte", 0))
	return 1 if spell_id > 0 and _has_learned_spell_id(
		first_level,
		spell_id
	) else 0


static func _store_first_spell_memory_byte(
	character: Object,
	value: int
) -> void:
	if character.has_method("set_classic_first_spell_memory_byte"):
		character.call("set_classic_first_spell_memory_byte", value)
		return
	if _has_property(character, "classic_first_spell_memory_byte"):
		character.set("classic_first_spell_memory_byte", value)
	if _has_property(character, "classic_first_spell_memory_byte_initialized"):
		character.set("classic_first_spell_memory_byte_initialized", true)


static func _has_learned_spell_id(
	first_level: Array,
	spell_id: int
) -> bool:
	for entry_value: Variant in first_level:
		if not (entry_value is Dictionary):
			continue
		var entry: Dictionary = entry_value
		if abs(int(entry.get("classicSpellId", 0))) == spell_id:
			return true
		if spell_id in SpellIdentityScript.resource_ids(entry):
			return true
	return false


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


static func _refresh_creation_magic_resistance(character: Variant) -> void:
	var profile := _dictionary_value(
		_value(character, "classic_rule_profile", {})
	)
	var magic_resistance := _dictionary_value(
		profile.get("magicResistance", {})
	)
	if magic_resistance.is_empty():
		return
	var initial_value := (
		int(
			(
				_character_stat(character, "Intellect")
				+ _character_stat(character, "Wisdom")
			) / 10.0
		) * int(magic_resistance.get("casteMultiplier", 0))
		+ int(magic_resistance.get("raceBonus", 0))
	)
	magic_resistance["initialValue"] = initial_value
	profile["magicResistance"] = magic_resistance
	character.call("apply_classic_rule_profile", profile)
	_store_magic_resistance(character, initial_value)


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


static func _default_item_mapping() -> Dictionary:
	var source: Object = ItemIdsScript.new()
	var value: Variant = source.get("mapping")
	var mapping: Dictionary = value.duplicate() if value is Dictionary else {}
	source.free()
	return mapping


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


static func _has_property(source: Variant, property_name: String) -> bool:
	if source == null or not (source is Object):
		return false
	for property: Dictionary in source.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true
	return false


static func _value(source: Variant, property_name: String, fallback: Variant) -> Variant:
	if source is Dictionary:
		return source.get(property_name, fallback)
	if source == null or not (source is Object):
		return fallback
	for property: Dictionary in source.get_property_list():
		if str(property.get("name", "")) == property_name:
			return source.get(property_name)
	return fallback
