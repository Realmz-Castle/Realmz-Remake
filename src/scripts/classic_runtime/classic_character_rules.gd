class_name ClassicCharacterRules
extends RefCounted

const AdmissionScript = preload(
	"res://scripts/classic_runtime/classic_campaign_admission.gd"
)
const MagicResistanceScript = preload(
	"res://scripts/classic_runtime/classic_magic_resistance.gd"
)
const RANDOM_ROLL_UNSET := -2147483648


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

	if movement.is_empty() \
			and magic_resistance.is_empty() \
			and attacks.is_empty() \
			and combat_progression.is_empty() \
			and stamina_progression.is_empty():
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
