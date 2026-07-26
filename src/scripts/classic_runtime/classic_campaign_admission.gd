class_name ClassicCampaignAdmission
extends RefCounted

const NATIVE_PARTY_LIMIT := 6


static func rules_from_bundle(bundle: Variant) -> Dictionary:
	var scenario := _bundle_document(bundle, "scenario")
	var rule_document := _bundle_document(bundle, "rules")
	var shell := _dictionary_value(scenario.get("shell", {}))
	var restrictions := _dictionary_value(scenario.get("restrictions", {}))
	var rule_names := _dictionary_value(rule_document.get("ruleNames", {}))

	var characters_limit := NATIVE_PARTY_LIMIT
	var authored_limit := maxi(0, int(restrictions.get("maxPartyCharacters", 0)))
	if authored_limit > 0:
		characters_limit = mini(characters_limit, authored_limit)

	# The shell maxLevel field was the unregistered Realmz party-total gate.
	# Remake is permanently registration-unlocked, so preserve it for diagnostics
	# without rejecting parties. Data RI restrictions remain authored rules.
	var rules := {
		"charactersLimit": characters_limit,
		"recommendedPartyLevel": maxi(0, int(shell.get("recLevel", 0))),
		"legacyRegistrationPartyLevelLimit": maxi(0, int(shell.get("maxLevel", 0))),
		"partyLevelLimit": 0,
		"characterLevelLimit": maxi(0, int(restrictions.get("maxPartyLevel", 0))),
		"bannedRaceIds": _positive_ids(restrictions.get("bannedRaces", [])),
		"bannedCasteIds": _positive_ids(restrictions.get("bannedCastes", [])),
		"raceNames": _string_array(rule_names.get("raceNames", [])),
		"casteNames": _string_array(rule_names.get("casteNames", [])),
		"unsupportedRaceOverrideIds": _unsupported_override_character_ids(
			rule_document.get("raceOverrides", []),
			_rule_table_selection(rule_document, "races")
		),
		"unsupportedCasteOverrideIds": _unsupported_override_character_ids(
			rule_document.get("casteOverrides", []),
			_rule_table_selection(rule_document, "castes")
		),
		"authoredRestrictionsDescription": str(
			restrictions.get("description", "")
		).strip_edges(),
	}
	rules["restrictionsDescription"] = describe(rules)
	return rules


static func describe(rules: Dictionary) -> String:
	var clauses: Array[String] = []
	var authored := str(rules.get("authoredRestrictionsDescription", "")).strip_edges()
	if not authored.is_empty():
		clauses.append(authored)

	var characters_limit := int(rules.get("charactersLimit", NATIVE_PARTY_LIMIT))
	clauses.append("Up to %d characters" % characters_limit)
	var character_level_limit := int(rules.get("characterLevelLimit", 0))
	if character_level_limit > 0:
		clauses.append("each character level %d or lower" % character_level_limit)

	var banned_races := _named_id_list(
		rules.get("bannedRaceIds", []),
		rules.get("raceNames", []),
		"race"
	)
	if not banned_races.is_empty():
		clauses.append("banned races: %s" % ", ".join(banned_races))
	var banned_castes := _named_id_list(
		rules.get("bannedCasteIds", []),
		rules.get("casteNames", []),
		"caste"
	)
	if not banned_castes.is_empty():
		clauses.append("banned castes: %s" % ", ".join(banned_castes))
	return "; ".join(clauses) + "."


static func character_admission(character: Variant, rules: Dictionary) -> Dictionary:
	if not bool(rules.get("valid", false)):
		var diagnostic := str(rules.get("diagnostic", "")).strip_edges()
		return _rejection(
			"campaign-not-ready",
			diagnostic if not diagnostic.is_empty() else "This campaign is not ready to start."
		)

	var character_name := _character_name(character)
	var level := maxi(0, int(_value(character, "level", 0)))
	var level_limit := int(rules.get("characterLevelLimit", 0))
	if level_limit > 0 and level > level_limit:
		return _rejection(
			"character-level",
			"%s is level %d; this scenario allows level %d or lower." % [
				character_name,
				level,
				level_limit,
			]
		)

	var race_result := _identity_admission(
		character,
		character_name,
		"race",
		"racegd",
		"raceName",
		rules.get("raceNames", []),
		rules.get("bannedRaceIds", []),
		rules.get("unsupportedRaceOverrideIds", [])
	)
	if not bool(race_result.get("allowed", false)):
		return race_result

	var caste_result := _identity_admission(
		character,
		character_name,
		"caste",
		"classgd",
		"casteName",
		rules.get("casteNames", []),
		rules.get("bannedCasteIds", []),
		rules.get("unsupportedCasteOverrideIds", [])
	)
	if not bool(caste_result.get("allowed", false)):
		return caste_result
	return {
		"allowed": true,
		"reason": "",
		"code": "allowed",
		"raceId": race_result.get("identityId", 0),
		"casteId": caste_result.get("identityId", 0),
	}


static func classic_identity_id(
	character: Variant,
	identity_kind: String,
	names_value: Variant
) -> int:
	var id_property: String
	var definition_property: String
	var name_property: String
	match identity_kind:
		"race":
			id_property = "classic_race_id"
			definition_property = "racegd"
			name_property = "raceName"
		"caste":
			id_property = "classic_caste_id"
			definition_property = "classgd"
			name_property = "casteName"
		_:
			return 0
	var identity_id := int(_value(character, id_property, 0))
	if identity_id > 0:
		return identity_id
	return _unique_name_id(
		_identity_name(character, definition_property, name_property),
		_string_array(names_value)
	)


static func party_admission(party: Array, rules: Dictionary) -> Dictionary:
	if not bool(rules.get("valid", false)):
		return character_admission(null, rules)
	if party.is_empty():
		return _rejection("empty-party", "Select at least one character.")

	var characters_limit := int(rules.get("charactersLimit", NATIVE_PARTY_LIMIT))
	if characters_limit > 0 and party.size() > characters_limit:
		return _rejection(
			"party-size",
			"This scenario allows at most %d characters." % characters_limit
		)

	var total_level := 0
	for character: Variant in party:
		var character_result := character_admission(character, rules)
		if not bool(character_result.get("allowed", false)):
			return character_result
		total_level += maxi(0, int(_value(character, "level", 0)))

	return {
		"allowed": true,
		"reason": "",
		"code": "allowed",
		"partyLevel": total_level,
	}


static func _identity_admission(
	character: Variant,
	character_name: String,
	identity_kind: String,
	definition_property: String,
	name_property: String,
	names_value: Variant,
	banned_value: Variant,
	unsupported_value: Variant
) -> Dictionary:
	var banned_ids := _positive_ids(banned_value)
	var unsupported_ids := _positive_ids(unsupported_value)
	var names := _string_array(names_value)
	if banned_ids.is_empty() and unsupported_ids.is_empty():
		return {"allowed": true, "identityId": 0}

	var identity_name := _identity_name(
		character,
		definition_property,
		name_property
	)
	var identity_id := classic_identity_id(character, identity_kind, names)
	if identity_id <= 0:
		var visible_identity := identity_name if not identity_name.is_empty() else "unknown"
		return _rejection(
			"unresolved-%s" % identity_kind,
			"%s's %s (%s) has no unambiguous Classic identity for this scenario." % [
				character_name,
				identity_kind,
				visible_identity,
			]
		)

	var display_name := _identity_display_name(identity_id, names, identity_kind)
	if identity_id in banned_ids:
		return _rejection(
			"banned-%s" % identity_kind,
			"%s cannot enter because %s %s is banned by this scenario." % [
				character_name,
				identity_kind,
				display_name,
			]
		)
	if identity_id in unsupported_ids:
		return _rejection(
			"unsupported-%s-override" % identity_kind,
			"%s uses scenario-defined %s %s, which Remake cannot apply yet." % [
				character_name,
				identity_kind,
				display_name,
			]
		)
	return {"allowed": true, "identityId": identity_id}


static func _identity_name(
	character: Variant,
	definition_property: String,
	name_property: String
) -> String:
	var direct_name := str(_value(character, name_property, "")).strip_edges()
	if not direct_name.is_empty():
		return direct_name
	var definition: Variant = _value(character, definition_property, null)
	if definition is Script:
		return str(definition.get_script_constant_map().get("classrace_name", "")).strip_edges()
	return str(_value(definition, "classrace_name", "")).strip_edges()


static func _unique_name_id(identity_name: String, names: Array[String]) -> int:
	if identity_name.is_empty():
		return 0
	var matched_id := 0
	for index: int in range(names.size()):
		if names[index].nocasecmp_to(identity_name) != 0:
			continue
		if matched_id != 0:
			return 0
		matched_id = index + 1
	return matched_id


static func _named_id_list(ids_value: Variant, names_value: Variant, kind: String) -> Array[String]:
	var result: Array[String] = []
	var names := _string_array(names_value)
	for identity_id: int in _positive_ids(ids_value):
		result.append(_identity_display_name(identity_id, names, kind))
	return result


static func _identity_display_name(identity_id: int, names: Array[String], kind: String) -> String:
	if identity_id > 0 and identity_id <= names.size():
		var display_name := names[identity_id - 1].strip_edges()
		if not display_name.is_empty():
			return display_name
	return "%s %d" % [kind.capitalize(), identity_id]


static func _unsupported_override_character_ids(
	records_value: Variant,
	selection: Dictionary
) -> Array[int]:
	var result: Array[int] = []
	if not (records_value is Array):
		return result
	var source := str(selection.get("source", "unresolved"))
	# Producer-identified shared rows are inactive, while scenario-local rows
	# now have complete runtime and creation consumers. Older bundles without a
	# resolved selection remain conservative.
	if source in ["shared", "scenario-local"]:
		return result
	for record_value: Variant in records_value:
		if not (record_value is Dictionary):
			continue
		var record_id := int(record_value.get("id", -1))
		if record_id >= 0:
			# Rule records are zero-based; character race and caste IDs are one-based.
			result.append(record_id + 1)
	result.sort()
	return result


static func _rule_table_selection(rule_document: Dictionary, table_name: String) -> Dictionary:
	var selection: Variant = rule_document.get("tableSelection", {})
	if not (selection is Dictionary):
		return {}
	var table: Variant = selection.get(table_name, {})
	return table if table is Dictionary else {}


static func _positive_ids(value: Variant) -> Array[int]:
	var result: Array[int] = []
	if not (value is Array):
		return result
	for id_value: Variant in value:
		var identity_id := int(id_value)
		if identity_id > 0 and identity_id not in result:
			result.append(identity_id)
	result.sort()
	return result


static func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if not (value is Array):
		return result
	for item: Variant in value:
		result.append(str(item))
	return result


static func _bundle_document(bundle: Variant, document_name: String) -> Dictionary:
	if bundle == null:
		return {}
	var documents: Variant = _value(bundle, "documents", {})
	if documents is Dictionary:
		return _dictionary_value(documents.get(document_name, {}))
	return {}


static func _dictionary_value(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}


static func _character_name(character: Variant) -> String:
	var result := str(_value(character, "name", "This character")).strip_edges()
	return result if not result.is_empty() else "This character"


static func _value(source: Variant, property_name: String, fallback: Variant) -> Variant:
	if source is Dictionary:
		return source.get(property_name, fallback)
	if source == null or not (source is Object):
		return fallback
	for property: Dictionary in source.get_property_list():
		if str(property.get("name", "")) == property_name:
			return source.get(property_name)
	return fallback


static func _rejection(code: String, reason: String) -> Dictionary:
	return {"allowed": false, "reason": reason, "code": code}
