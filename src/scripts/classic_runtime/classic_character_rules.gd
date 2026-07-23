class_name ClassicCharacterRules
extends RefCounted

const AdmissionScript = preload(
	"res://scripts/classic_runtime/classic_campaign_admission.gd"
)
const MagicResistanceScript = preload(
	"res://scripts/classic_runtime/classic_magic_resistance.gd"
)


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

	if movement.is_empty() and magic_resistance.is_empty():
		return {}

	var profile := {
		"campaignId": campaign_id,
	}
	if not movement.is_empty():
		profile["movement"] = movement
	if not magic_resistance.is_empty():
		profile["magicResistance"] = magic_resistance
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
	if stat_name != "MaxMovement":
		return native_value
	var movement := _dictionary_value(profile.get("movement", {}))
	if movement.is_empty():
		return native_value

	# Remake already combines identity and equipment movement. Replace only the
	# native race/caste contributions so ordinary equipment modifiers still apply.
	var adjusted := float(native_value)
	if movement.has("raceBaseMove"):
		adjusted += int(movement["raceBaseMove"]) \
			- _native_identity_stat(_value(character, "racegd", null), stat_name)
	if movement.has("casteMoveBonus"):
		adjusted += int(movement["casteMoveBonus"]) \
			- _native_identity_stat(_value(character, "classgd", null), stat_name)
	return roundi(adjusted)


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
