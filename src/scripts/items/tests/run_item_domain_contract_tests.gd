extends SceneTree

const FIXTURE_PATH := \
	"res://scripts/items/tests/fixtures/item_domain_contract_v1.json"

var _failures: Array[String] = []
var _assertions := 0


func _init() -> void:
	var fixture_value: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(FIXTURE_PATH)
	)
	_expect(fixture_value is Dictionary, "contract fixture parses as an object")
	if not (fixture_value is Dictionary):
		_finish()
		return
	var fixture: Dictionary = fixture_value
	var contract: Dictionary = fixture.get("contract", {})
	_test_contract_metadata(contract)
	_test_catalog_cases(contract, fixture.get("catalogCases", []))
	_test_legacy_import_cases(contract, fixture.get("legacyImportCases", []))
	_finish()


func _test_contract_metadata(contract: Dictionary) -> void:
	_expect_equal(
		contract.get("format"),
		"realmz-remake-item-instance",
		"save format identity is frozen",
	)
	_expect_equal(contract.get("formatVersion"), 1, "save format version is frozen")
	_expect_equal(
		contract.get("migrationOrder", []),
		[
			"ISY-410",
			"ISY-411",
			"ISY-412",
			"ISY-413",
			"ISY-414",
			"ISY-415",
			"ISY-416",
		],
		"M6 dependency order is explicit",
	)
	for field_name: String in [
		"definitionRequired",
		"instanceRequired",
		"serializationRequired",
		"definitionDefaults",
		"instanceDefaults",
		"forbiddenSerializedKeys",
	]:
		_expect(contract.has(field_name), "contract contains %s" % field_name)


func _test_catalog_cases(contract: Dictionary, cases_value: Variant) -> void:
	_expect(cases_value is Array, "catalog cases are an array")
	if not (cases_value is Array):
		return
	var seen_case_ids := {}
	var seen_definition_ids := {}
	var seen_instance_ids := {}
	var classic_ids_by_campaign := {}
	for case_value: Variant in cases_value:
		_expect(case_value is Dictionary, "catalog case is an object")
		if not (case_value is Dictionary):
			continue
		var test_case: Dictionary = case_value
		var case_id := str(test_case.get("caseId", ""))
		_expect(not case_id.is_empty(), "catalog case has an ID")
		_expect(not seen_case_ids.has(case_id), "catalog case ID is unique: %s" % case_id)
		seen_case_ids[case_id] = true
		_test_source_artifact(case_id, test_case)
		_test_definition(
			case_id,
			test_case.get("definition", {}),
			contract,
			seen_definition_ids,
			classic_ids_by_campaign,
		)
		_test_instance(
			case_id,
			test_case.get("instance", {}),
			test_case.get("definition", {}),
			contract,
			seen_instance_ids,
		)
		_test_serialized_item(
			case_id,
			test_case.get("serialized", {}),
			test_case.get("instance", {}),
			contract,
			false,
		)


func _test_legacy_import_cases(contract: Dictionary, cases_value: Variant) -> void:
	_expect(cases_value is Array, "legacy import cases are an array")
	if not (cases_value is Array):
		return
	var seen_definition_ids := {}
	var seen_instance_ids := {}
	var classic_ids_by_campaign := {}
	for case_value: Variant in cases_value:
		_expect(case_value is Dictionary, "legacy import case is an object")
		if not (case_value is Dictionary):
			continue
		var test_case: Dictionary = case_value
		var case_id := str(test_case.get("caseId", ""))
		var legacy: Dictionary = test_case.get("legacyDictionary", {})
		var definition: Dictionary = test_case.get("definition", {})
		var serialized: Dictionary = test_case.get("serialized", {})
		_test_definition(
			case_id,
			definition,
			contract,
			seen_definition_ids,
			classic_ids_by_campaign,
		)
		_test_instance(
			case_id,
			test_case.get("instance", {}),
			definition,
			contract,
			seen_instance_ids,
		)
		_test_serialized_item(
			case_id,
			serialized,
			test_case.get("instance", {}),
			contract,
			true,
		)
		_expect_equal(
			serialized.get("embeddedDefinition"),
			definition,
			"%s serialization embeds the normalized definition exactly" % case_id,
		)
		_expect_equal(
			test_case.get("instance", {}).get("charges"),
			legacy.get("charges"),
			"%s import retains current charges as instance state" % case_id,
		)
		_expect_equal(
			test_case.get("instance", {}).get("identified"),
			int(legacy.get("is_identified", 0)) > 0,
			"%s import projects identification into instance state" % case_id,
		)
		_expect_equal(
			test_case.get("instance", {}).get("equipped"),
			int(legacy.get("equipped", 0)) > 0,
			"%s import projects equipment marker into instance state" % case_id,
		)
		_expect_equal(
			definition.get("media", {}).get("data"),
			legacy.get("imgdata"),
			"%s import retains portable encoded image data" % case_id,
		)
		_expect_equal(
			definition.get("media", {}).get("bytes"),
			legacy.get("imgdatasize"),
			"%s import retains encoded image byte metadata" % case_id,
		)
		_expect_equal(
			definition.get("hooks", {}).get("sources", {}).get("_on_field_use_source"),
			legacy.get("_on_field_use_source"),
			"%s import retains portable hook source" % case_id,
		)
		var discarded_value: Variant = test_case.get("discardedRuntimeKeys", [])
		_expect(discarded_value is Array, "%s discarded key list is an array" % case_id)
		if discarded_value is Array:
			for key_value: Variant in discarded_value:
				var key := str(key_value)
				_expect(legacy.has(key), "%s legacy input contains discarded %s" % [case_id, key])
				_expect(
					not _contains_key_recursive(serialized, key),
					"%s serialized output excludes runtime key %s" % [case_id, key],
				)
		_test_embedded_digest(case_id, definition)


func _test_source_artifact(case_id: String, test_case: Dictionary) -> void:
	var source: Dictionary = test_case.get("sourceArtifact", {})
	var path := str(source.get("path", ""))
	var catalog_key := str(source.get("catalogKey", ""))
	_expect(FileAccess.file_exists(path), "%s source artifact exists" % case_id)
	if not FileAccess.file_exists(path):
		return
	var book_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	_expect(book_value is Dictionary, "%s source artifact parses" % case_id)
	if not (book_value is Dictionary):
		return
	var book: Dictionary = book_value
	_expect(book.has(catalog_key), "%s source catalog key exists" % case_id)
	if not book.has(catalog_key) or not (book[catalog_key] is Dictionary):
		return
	var record: Dictionary = book[catalog_key]
	var subset: Dictionary = test_case.get("sourceSubset", {})
	for field_name: String in subset:
		_expect_equal(
			record.get(field_name),
			subset[field_name],
			"%s source field %s is characterized" % [case_id, field_name],
		)


func _test_definition(
	case_id: String,
	definition_value: Variant,
	contract: Dictionary,
	seen_definition_ids: Dictionary,
	classic_ids_by_campaign: Dictionary,
) -> void:
	_expect(definition_value is Dictionary, "%s definition is an object" % case_id)
	if not (definition_value is Dictionary):
		return
	var definition: Dictionary = definition_value
	for field_value: Variant in contract.get("definitionRequired", []):
		var field_name := str(field_value)
		_expect(definition.has(field_name), "%s definition has %s" % [case_id, field_name])
	var definition_id := str(definition.get("definitionId", ""))
	_expect(not definition_id.is_empty(), "%s definition ID is not empty" % case_id)
	_expect(
		not seen_definition_ids.has(definition_id),
		"%s definition ID is unique" % case_id,
	)
	seen_definition_ids[definition_id] = true
	var source: Dictionary = definition.get("source", {})
	var scope := str(source.get("scope", ""))
	var campaign_id := str(source.get("campaignId", ""))
	_expect(
		scope in ["shared", "campaign", "embedded"],
		"%s definition scope is valid" % case_id,
	)
	if scope == "campaign":
		_expect(not campaign_id.is_empty(), "%s campaign definition has campaign ID" % case_id)
	var classic: Dictionary = definition.get("classic", {})
	var item_ids_value: Variant = classic.get("itemIds", [])
	_expect(item_ids_value is Array, "%s Classic IDs are an array" % case_id)
	if item_ids_value is Array and not item_ids_value.is_empty():
		var primary_id := int(item_ids_value[0])
		_expect(primary_id > 0, "%s primary Classic ID is positive" % case_id)
		_expect_equal(
			definition_id,
			"classic:%s:%d" % [campaign_id, primary_id],
			"%s Classic ID determines stable definition ID" % case_id,
		)
		if not classic_ids_by_campaign.has(campaign_id):
			classic_ids_by_campaign[campaign_id] = {}
		for id_value: Variant in item_ids_value:
			var item_id := int(id_value)
			_expect(item_id > 0, "%s Classic alias is positive" % case_id)
			_expect(
				not classic_ids_by_campaign[campaign_id].has(item_id),
				"%s Classic alias is unique in campaign" % case_id,
			)
			classic_ids_by_campaign[campaign_id][item_id] = definition_id
	elif scope == "shared":
		_expect(
			definition_id.begins_with("shared:"),
			"%s shared identity uses shared namespace" % case_id,
		)
	elif scope == "campaign":
		_expect(
			definition_id.begins_with("campaign:%s:" % campaign_id),
			"%s campaign identity uses campaign namespace" % case_id,
		)
	elif scope == "embedded":
		_expect(
			definition_id.begins_with("embedded:sha256:"),
			"%s embedded identity uses digest namespace" % case_id,
		)
	_expect(
		_is_json_compatible(definition),
		"%s definition contains JSON-compatible values only" % case_id,
	)


func _test_instance(
	case_id: String,
	instance_value: Variant,
	definition_value: Variant,
	contract: Dictionary,
	seen_instance_ids: Dictionary,
) -> void:
	_expect(instance_value is Dictionary, "%s instance is an object" % case_id)
	if not (instance_value is Dictionary) or not (definition_value is Dictionary):
		return
	var instance: Dictionary = instance_value
	var definition: Dictionary = definition_value
	for field_value: Variant in contract.get("instanceRequired", []):
		var field_name := str(field_value)
		_expect(instance.has(field_name), "%s instance has %s" % [case_id, field_name])
	var instance_id := str(instance.get("instanceId", ""))
	_expect(not instance_id.is_empty(), "%s instance ID is not empty" % case_id)
	_expect(not seen_instance_ids.has(instance_id), "%s instance ID is unique" % case_id)
	seen_instance_ids[instance_id] = true
	_expect_equal(
		instance.get("definitionId"),
		definition.get("definitionId"),
		"%s instance resolves exact definition ID" % case_id,
	)
	_expect(instance.get("charges") is float or instance.get("charges") is int,
		"%s charges are numeric" % case_id)
	_expect(instance.get("equipped") is bool, "%s equipped state is boolean" % case_id)
	_expect(instance.get("identified") is bool, "%s identified state is boolean" % case_id)
	_expect(instance.get("stateData") is Dictionary, "%s state data is an object" % case_id)


func _test_serialized_item(
	case_id: String,
	serialized_value: Variant,
	instance_value: Variant,
	contract: Dictionary,
	expect_embedded: bool,
) -> void:
	_expect(serialized_value is Dictionary, "%s serialization is an object" % case_id)
	if not (serialized_value is Dictionary) or not (instance_value is Dictionary):
		return
	var serialized: Dictionary = serialized_value
	var instance: Dictionary = instance_value
	for field_value: Variant in contract.get("serializationRequired", []):
		var field_name := str(field_value)
		_expect(serialized.has(field_name), "%s serialization has %s" % [case_id, field_name])
	_expect_equal(
		serialized.get("format"),
		contract.get("format"),
		"%s serialization format matches contract" % case_id,
	)
	_expect_equal(
		serialized.get("formatVersion"),
		contract.get("formatVersion"),
		"%s serialization version matches contract" % case_id,
	)
	_expect_equal(
		serialized.get("instanceId"),
		instance.get("instanceId"),
		"%s serialization retains instance ID" % case_id,
	)
	_expect_equal(
		serialized.get("definitionId"),
		instance.get("definitionId"),
		"%s serialization retains definition ID" % case_id,
	)
	var expected_state := {
		"charges": instance.get("charges"),
		"equipped": instance.get("equipped"),
		"identified": instance.get("identified"),
		"data": instance.get("stateData"),
	}
	_expect_equal(
		serialized.get("state"),
		expected_state,
		"%s serialization contains instance state only" % case_id,
	)
	_expect_equal(
		serialized.has("embeddedDefinition"),
		expect_embedded,
		"%s embedded-definition policy is explicit" % case_id,
	)
	_expect(
		_is_json_compatible(serialized),
		"%s serialization contains JSON-compatible values only" % case_id,
	)
	for key_value: Variant in contract.get("forbiddenSerializedKeys", []):
		var key := str(key_value)
		_expect(
			not _contains_key_recursive(serialized, key),
			"%s serialization excludes runtime key %s" % [case_id, key],
		)


func _test_embedded_digest(case_id: String, definition: Dictionary) -> void:
	var digest := str(definition.get("digest", ""))
	_expect(digest.length() == 64, "%s embedded digest has 64 hex digits" % case_id)
	_expect(digest.is_valid_hex_number(false), "%s embedded digest is hexadecimal" % case_id)
	var payload := definition.duplicate(true)
	payload.erase("definitionId")
	payload.erase("digest")
	var canonical_json := JSON.stringify(payload, "", true)
	var hashing_context := HashingContext.new()
	var start_error := hashing_context.start(HashingContext.HASH_SHA256)
	_expect(start_error == OK, "%s SHA-256 context starts" % case_id)
	var update_error := hashing_context.update(canonical_json.to_utf8_buffer())
	_expect(update_error == OK, "%s SHA-256 payload is accepted" % case_id)
	var expected_digest: String = hashing_context.finish().hex_encode()
	_expect_equal(digest, expected_digest, "%s embedded digest matches payload" % case_id)
	_expect_equal(
		definition.get("definitionId"),
		"embedded:sha256:%s" % digest,
		"%s embedded definition ID matches digest" % case_id,
	)


func _is_json_compatible(value: Variant) -> bool:
	if value == null or value is bool or value is String or value is int or value is float:
		return true
	if value is Array:
		for child: Variant in value:
			if not _is_json_compatible(child):
				return false
		return true
	if value is Dictionary:
		for key: Variant in value:
			if not (key is String) or not _is_json_compatible(value[key]):
				return false
		return true
	return false


func _contains_key_recursive(value: Variant, target: String) -> bool:
	if value is Dictionary:
		if value.has(target):
			return true
		for child: Variant in value.values():
			if _contains_key_recursive(child, target):
				return true
	elif value is Array:
		for child: Variant in value:
			if _contains_key_recursive(child, target):
				return true
	return false


func _expect(condition: bool, message: String) -> void:
	_assertions += 1
	if not condition:
		_failures.append(message)


func _expect_equal(actual: Variant, expected: Variant, message: String) -> void:
	_expect(actual == expected, "%s; expected %s, got %s" % [message, expected, actual])


func _finish() -> void:
	if _failures.is_empty():
		print(
			(
				"ITEM_DOMAIN_CONTRACT PASS: %d assertions; catalog, Classic identity, "
				+ "legacy import, serialization, and M6 ordering are characterized."
			)
			% _assertions
		)
		quit(0)
		return
	for failure: String in _failures:
		printerr("ITEM_DOMAIN_CONTRACT FAIL: %s" % failure)
	printerr(
		"ITEM_DOMAIN_CONTRACT FAIL: %d of %d assertions failed."
		% [_failures.size(), _assertions]
	)
	quit(1)
