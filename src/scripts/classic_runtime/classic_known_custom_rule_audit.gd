class_name ClassicKnownCustomRuleAudit
extends RefCounted

const MANIFEST_PATH := \
	"res://scripts/classic_runtime/classic_known_custom_rule_manifest.json"
const SCHEMA_VERSION := 1
const CLASSIFICATIONS := [
	"native-equivalent",
	"generically-representable",
	"fidelity-only",
	"unsupported-optional",
	"progression-blocker",
]
const REPRESENTATIVE_FIXTURES := [
	"empty-spell-template",
	"representable-custom-spell",
	"unsupported-special-spell",
	"no-op-race-caste-table",
	"active-changed-override",
]

var last_error := ""


func load_manifest(path := MANIFEST_PATH) -> Dictionary:
	last_error = ""
	if not FileAccess.file_exists(path):
		last_error = "Known custom-rule manifest not found: %s" % path
		return {}
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (value is Dictionary):
		last_error = "Known custom-rule manifest must contain a JSON object"
		return {}
	return value


func inspect_path(path := MANIFEST_PATH) -> Dictionary:
	var manifest := load_manifest(path)
	if manifest.is_empty():
		return {
			"accepted": false,
			"errors": [last_error],
			"computedTotals": {},
		}
	return inspect(manifest)


func inspect(manifest: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	if int(manifest.get("schemaVersion", 0)) != SCHEMA_VERSION:
		errors.append("schemaVersion must be %d" % SCHEMA_VERSION)

	var audit: Variant = manifest.get("audit", {})
	if not (audit is Dictionary):
		errors.append("audit must be an object")
	else:
		_expect_string(errors, audit, "issue", "audit")
		_expect_string(errors, audit, "compatibilityProfile", "audit")
		var classifications: Variant = audit.get("classifications", [])
		if not (classifications is Array) or classifications != CLASSIFICATIONS:
			errors.append("audit.classifications must contain the canonical ordered set")

	var corpus: Variant = manifest.get("corpus", {})
	var scenarios: Array = []
	if not (corpus is Dictionary):
		errors.append("corpus must be an object")
	else:
		var scenario_value: Variant = corpus.get("scenarios", [])
		if not (scenario_value is Array):
			errors.append("corpus.scenarios must be an array")
		else:
			scenarios = scenario_value

	var spell_payloads := _array_field(errors, manifest, "spellPayloads", "manifest")
	var race_payloads := _array_field(errors, manifest, "racePayloads", "manifest")
	var caste_payloads := _array_field(errors, manifest, "castePayloads", "manifest")
	var table_references := _array_field(errors, manifest, "tableReferences", "manifest")
	var malformed := _array_field(errors, manifest, "malformedLegacyPayloads", "manifest")
	var fixtures := _array_field(errors, manifest, "representativeFixtures", "manifest")

	var scenario_ids: Dictionary = {}
	var spell_table_count := 0
	var race_table_count := 0
	var caste_table_count := 0
	for index: int in range(scenarios.size()):
		var scenario_value: Variant = scenarios[index]
		if not (scenario_value is Dictionary):
			errors.append("corpus.scenarios[%d] must be an object" % index)
			continue
		var scenario: Dictionary = scenario_value
		var campaign_id := str(scenario.get("campaignId", ""))
		if campaign_id.is_empty() or scenario_ids.has(campaign_id):
			errors.append("corpus.scenarios[%d] has a missing or duplicate campaignId" % index)
		scenario_ids[campaign_id] = true
		if bool(scenario.get("spellTable", {}).get("present", false)):
			spell_table_count += 1
		if int(scenario.get("raceTable", {}).get("fileBytes", 0)) > 0:
			race_table_count += 1
		if int(scenario.get("casteTable", {}).get("fileBytes", 0)) > 0:
			caste_table_count += 1

	var payload_ids: Dictionary = {}
	var definition_ids: Dictionary = {}
	var definition_count := 0
	var active_definition_count := 0
	var active_consumer_count := 0
	var classification_counts := {}
	for classification: String in CLASSIFICATIONS:
		classification_counts[classification] = 0
	for payload_index: int in range(spell_payloads.size()):
		var payload_value: Variant = spell_payloads[payload_index]
		if not (payload_value is Dictionary):
			errors.append("spellPayloads[%d] must be an object" % payload_index)
			continue
		var payload: Dictionary = payload_value
		_validate_payload_identity(errors, payload, "spell", payload_index, payload_ids)
		if not (payload.get("nativeEquivalentCandidates", []) is Array):
			errors.append(
				"spellPayloads[%d].nativeEquivalentCandidates must be an array" % payload_index
			)
		var definitions := _array_field(
			errors, payload, "definitions", "spellPayloads[%d]" % payload_index
		)
		for definition_index: int in range(definitions.size()):
			var definition_value: Variant = definitions[definition_index]
			if not (definition_value is Dictionary):
				errors.append(
					"spellPayloads[%d].definitions[%d] must be an object"
						% [payload_index, definition_index]
				)
				continue
			var definition: Dictionary = definition_value
			definition_count += 1
			_validate_definition(
				errors,
				definition,
				"spell",
				payload_index,
				definition_index,
				scenario_ids,
				definition_ids
			)
			var classification := str(definition.get("classification", ""))
			if classification not in CLASSIFICATIONS:
				errors.append(
					"spell definition %s has unknown classification %s"
						% [definition.get("stableId", "<missing>"), classification]
				)
			else:
				classification_counts[classification] = \
					int(classification_counts[classification]) + 1
			var consumers: Variant = definition.get("consumers", [])
			if not (consumers is Array):
				errors.append(
					"spell definition %s consumers must be an array"
						% definition.get("stableId", "<missing>")
				)
				continue
			if bool(definition.get("active", false)):
				active_definition_count += 1
				active_consumer_count += consumers.size()
				if consumers.is_empty():
					errors.append(
						"active spell definition %s must identify a consumer"
							% definition.get("stableId", "<missing>")
					)
				if int(payload.get("special", 0)) != 0 \
						and classification != "progression-blocker":
					errors.append(
						"active special spell definition %s must be a progression blocker"
							% definition.get("stableId", "<missing>")
					)

	_validate_simple_payloads(errors, race_payloads, "race", scenario_ids, payload_ids, definition_ids)
	_validate_simple_payloads(errors, caste_payloads, "caste", scenario_ids, payload_ids, definition_ids)
	_validate_table_references(errors, table_references, scenario_ids)
	_validate_malformed_payloads(errors, malformed, scenario_ids)
	_validate_representative_fixtures(errors, fixtures)

	var computed_totals := {
		"scenarios": scenarios.size(),
		"spellTables": spell_table_count,
		"populatedSpellDefinitions": definition_count,
		"uniqueSpellPayloads": spell_payloads.size(),
		"activeSpellDefinitions": active_definition_count,
		"activeSpellConsumers": active_consumer_count,
		"raceTables": race_table_count,
		"uniqueChangedRacePayloads": race_payloads.size(),
		"casteTables": caste_table_count,
		"uniqueChangedCastePayloads": caste_payloads.size(),
		"malformedLegacyPayloads": malformed.size(),
		"classifications": classification_counts,
	}
	_validate_totals(errors, manifest.get("totals", {}), computed_totals)
	return {
		"accepted": errors.is_empty(),
		"errors": errors,
		"computedTotals": computed_totals,
	}


func _array_field(
	errors: Array[String],
	value: Dictionary,
	field_name: String,
	context: String
) -> Array:
	var field_value: Variant = value.get(field_name, [])
	if not (field_value is Array):
		errors.append("%s.%s must be an array" % [context, field_name])
		return []
	return field_value


func _expect_string(
	errors: Array[String],
	value: Dictionary,
	field_name: String,
	context: String
) -> void:
	if str(value.get(field_name, "")).is_empty():
		errors.append("%s.%s must be a non-empty string" % [context, field_name])


func _validate_payload_identity(
	errors: Array[String],
	payload: Dictionary,
	kind: String,
	index: int,
	payload_ids: Dictionary
) -> void:
	var payload_id := str(payload.get("payloadId", ""))
	var sha256 := str(payload.get("sha256", ""))
	if not payload_id.begins_with("%s-sha256:" % kind) or payload_ids.has(payload_id):
		errors.append("%sPayloads[%d] has a missing or duplicate payloadId" % [kind, index])
	payload_ids[payload_id] = true
	if sha256.length() != 64 or not sha256.is_valid_hex_number():
		errors.append("%sPayloads[%d].sha256 must be a 64-character hex digest" % [kind, index])


func _validate_definition(
	errors: Array[String],
	definition: Dictionary,
	kind: String,
	payload_index: int,
	definition_index: int,
	scenario_ids: Dictionary,
	definition_ids: Dictionary
) -> void:
	var context := "%sPayloads[%d].definitions[%d]" % [
		kind, payload_index, definition_index,
	]
	var stable_id := str(definition.get("stableId", ""))
	var campaign_id := str(definition.get("campaignId", ""))
	var source_file := str(definition.get("sourceFile", ""))
	var record_index := int(definition.get("recordIndex", -1))
	if stable_id != "%s:%s:%d" % [campaign_id, kind, record_index] \
			or definition_ids.has(stable_id):
		errors.append("%s has a malformed or duplicate stableId" % context)
	definition_ids[stable_id] = true
	if not scenario_ids.has(campaign_id):
		errors.append("%s references unknown campaignId %s" % [context, campaign_id])
	if source_file.is_empty() or record_index < 0 or int(definition.get("byteOffset", -1)) < 0:
		errors.append("%s must preserve source file, record index, and byte offset" % context)


func _validate_simple_payloads(
	errors: Array[String],
	payloads: Array,
	kind: String,
	scenario_ids: Dictionary,
	payload_ids: Dictionary,
	definition_ids: Dictionary
) -> void:
	for payload_index: int in range(payloads.size()):
		var payload_value: Variant = payloads[payload_index]
		if not (payload_value is Dictionary):
			errors.append("%sPayloads[%d] must be an object" % [kind, payload_index])
			continue
		var payload: Dictionary = payload_value
		_validate_payload_identity(errors, payload, kind, payload_index, payload_ids)
		var definitions := _array_field(
			errors, payload, "definitions", "%sPayloads[%d]" % [kind, payload_index]
		)
		for definition_index: int in range(definitions.size()):
			var definition_value: Variant = definitions[definition_index]
			if not (definition_value is Dictionary):
				errors.append(
					"%sPayloads[%d].definitions[%d] must be an object"
						% [kind, payload_index, definition_index]
				)
				continue
			_validate_definition(
				errors,
				definition_value,
				kind,
				payload_index,
				definition_index,
				scenario_ids,
				definition_ids
			)


func _validate_table_references(
	errors: Array[String],
	references: Array,
	scenario_ids: Dictionary
) -> void:
	var stable_ids: Dictionary = {}
	for index: int in range(references.size()):
		var reference_value: Variant = references[index]
		if not (reference_value is Dictionary):
			errors.append("tableReferences[%d] must be an object" % index)
			continue
		var reference: Dictionary = reference_value
		var stable_id := str(reference.get("stableId", ""))
		var campaign_id := str(reference.get("campaignId", ""))
		if stable_id.is_empty() or stable_ids.has(stable_id):
			errors.append("tableReferences[%d] has a missing or duplicate stableId" % index)
		stable_ids[stable_id] = true
		if not scenario_ids.has(campaign_id):
			errors.append("tableReferences[%d] references unknown campaignId" % index)
		if str(reference.get("consumer", "")) != "Classic loadprofile":
			errors.append("tableReferences[%d] must identify the Classic consumer" % index)


func _validate_malformed_payloads(
	errors: Array[String],
	payloads: Array,
	scenario_ids: Dictionary
) -> void:
	for index: int in range(payloads.size()):
		var payload_value: Variant = payloads[index]
		if not (payload_value is Dictionary):
			errors.append("malformedLegacyPayloads[%d] must be an object" % index)
			continue
		var payload: Dictionary = payload_value
		if str(payload.get("status", "")) != "malformed-legacy":
			errors.append("malformedLegacyPayloads[%d] must retain its separate status" % index)
		if not scenario_ids.has(str(payload.get("campaignId", ""))):
			errors.append("malformedLegacyPayloads[%d] references unknown campaignId" % index)


func _validate_representative_fixtures(errors: Array[String], fixtures: Array) -> void:
	var fixture_ids: Array[String] = []
	for fixture_value: Variant in fixtures:
		if fixture_value is Dictionary:
			fixture_ids.append(str(fixture_value.get("id", "")))
	fixture_ids.sort()
	var expected := REPRESENTATIVE_FIXTURES.duplicate()
	expected.sort()
	if fixture_ids != expected:
		errors.append("representativeFixtures must contain all five acceptance cases")


func _validate_totals(
	errors: Array[String],
	totals_value: Variant,
	computed: Dictionary
) -> void:
	if not (totals_value is Dictionary):
		errors.append("totals must be an object")
		return
	var totals: Dictionary = totals_value
	for field_name: String in [
		"scenarios",
		"spellTables",
		"populatedSpellDefinitions",
		"uniqueSpellPayloads",
		"activeSpellDefinitions",
		"activeSpellConsumers",
		"raceTables",
		"uniqueChangedRacePayloads",
		"casteTables",
		"uniqueChangedCastePayloads",
		"malformedLegacyPayloads",
	]:
		if int(totals.get(field_name, -1)) != int(computed[field_name]):
			errors.append(
				"totals.%s is %s but the manifest computes %s"
					% [field_name, totals.get(field_name, "<missing>"), computed[field_name]]
			)
	var classifications: Variant = totals.get("classifications", {})
	if not (classifications is Dictionary):
		errors.append("totals.classifications must be an object")
		return
	for classification: String in CLASSIFICATIONS:
		if int(classifications.get(classification, -1)) != \
				int(computed["classifications"][classification]):
			errors.append(
				"totals.classifications.%s does not match the definitions" % classification
			)
