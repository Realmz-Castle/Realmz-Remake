class_name ClassicSpellUsageAudit
extends RefCounted

const ExecutionAuditScript = preload(
	"res://scripts/classic_runtime/classic_execution_audit.gd"
)
const SpellIdentityScript = preload("res://scripts/classic_runtime/classic_spell_identity.gd")
const SpellIdsScript = preload("res://scripts/spells_id_divinity.gd")

const SCHEMA_VERSION := 1
const SUPPORT_MATRIX_PATH := \
	"res://scripts/classic_runtime/classic_spell_support_matrix.json"
const SPELL_DEFINITION_FIELDS := [
	"range1",
	"range2",
	"queueIcon",
	"toHitBonus",
	"saveBonus",
	"fixedTargetNum",
	"canRotate",
	"saveAdjust",
	"cannot",
	"resistAdjust",
	"cost",
	"damage1",
	"damage2",
	"powerDamage1",
	"powerDamage2",
	"duration1",
	"duration2",
	"powerDuration1",
	"powerDuration2",
	"spellLook1",
	"spellLook2",
	"sound1",
	"sound2",
	"targetType",
	"size",
	"special",
	"damageType",
	"spellClass",
	"inCombat",
	"inCamp",
]

var last_error := ""
var _spell_mapping: Dictionary = {}
var _spell_definitions: Dictionary = {}
var _spell_usages: Dictionary = {}
var _class_usages: Dictionary = {}
var _unresolved_usages: Dictionary = {}


func _init() -> void:
	var mapping_source: Object = SpellIdsScript.new()
	var mappings: Variant = mapping_source.get("mappings")
	_spell_mapping = mappings.duplicate() if mappings is Dictionary else {}
	mapping_source.free()


func load_support_matrix(path := SUPPORT_MATRIX_PATH) -> Dictionary:
	last_error = ""
	if not FileAccess.file_exists(path):
		last_error = "Classic spell support matrix not found: %s" % path
		return {}
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not (value is Dictionary):
		last_error = "Classic spell support matrix must contain a JSON object"
		return {}
	if int(value.get("schemaVersion", 0)) != SCHEMA_VERSION:
		last_error = "Unsupported Classic spell support matrix schema: %s" % \
			value.get("schemaVersion", "<missing>")
		return {}
	if not (value.get("spells", []) is Array):
		last_error = "Classic spell support matrix spells must be an array"
		return {}
	return value


func inspect(bundle: ClassicCampaignBundle, matrix := {}, native_spells := {}) -> Dictionary:
	return inspect_bundles([bundle], matrix, native_spells)


func inspect_bundles(bundles: Array, matrix := {}, native_spells := {}) -> Dictionary:
	last_error = ""
	_spell_definitions.clear()
	_spell_usages.clear()
	_class_usages.clear()
	_unresolved_usages.clear()

	var support_matrix: Dictionary = matrix if matrix is Dictionary else {}
	if support_matrix.is_empty():
		support_matrix = load_support_matrix()
	var campaigns: Array = []
	for bundle_value: Variant in bundles:
		if not (bundle_value is ClassicCampaignBundle):
			continue
		var bundle: ClassicCampaignBundle = bundle_value
		campaigns.append({
			"id": str(bundle.manifest.get("id", "")),
			"name": str(bundle.manifest.get("name", "Unknown Classic campaign")),
		})
		_collect_bundle(bundle)

	var matrix_by_id := _index_matrix(support_matrix)
	var native_spell_book: Dictionary = native_spells if native_spells is Dictionary else {}
	var spell_rows := _spell_rows(matrix_by_id, native_spell_book)
	var class_rows := _reference_rows(_class_usages, "classicSpellClass")
	var unresolved_rows := _reference_rows(_unresolved_usages, "referenceId")
	var documented := 0
	var supported := 0
	var definition_count := 0
	var active_definition_count := 0
	var usage_count := 0
	var resolution_counts := {
		"exact-id-resource": 0,
		"name-only-resource": 0,
		"unsupported-native-variant": 0,
		"missing-native-resource": 0,
		"unmapped-identity": 0,
		"not-audited": 0,
	}
	for row_value: Variant in spell_rows:
		var row: Dictionary = row_value
		for definition_value: Variant in row.get("definitions", []):
			if not (definition_value is Dictionary):
				continue
			definition_count += 1
			if bool(definition_value.get("active", false)):
				active_definition_count += 1
		usage_count += row.get("usages", []).size()
		if str(row.get("supportStatus", "unclassified")) != "unclassified":
			documented += 1
		if str(row.get("supportStatus", "")) == "supported":
			supported += 1
		var resolution_status := str(row.get("nativeResolution", {}).get(
			"status", "not-audited"
		))
		resolution_counts[resolution_status] = int(resolution_counts.get(
			resolution_status, 0
		)) + 1
	for row_value: Variant in class_rows:
		usage_count += row_value.get("usages", []).size()
	for row_value: Variant in unresolved_rows:
		usage_count += row_value.get("usages", []).size()

	return {
		"schemaVersion": SCHEMA_VERSION,
		"campaigns": campaigns,
		"totals": {
			"campaigns": campaigns.size(),
			"spellIds": spell_rows.size(),
			"spellClasses": class_rows.size(),
			"unresolvedReferences": unresolved_rows.size(),
			"definitions": definition_count,
			"activeDefinitionIds": active_definition_count,
			"usages": usage_count,
			"documentedSpellIds": documented,
			"supportedSpellIds": supported,
			"unclassifiedSpellIds": spell_rows.size() - documented,
			"nativeResolution": resolution_counts,
		},
		"sourceCoverage": {
			"covered": [
				"field-actions",
				"rogue-traps",
				"complex-responses",
				"combatants",
				"allies",
				"summoned-combatants",
				"scenario-spell-items",
				"scenario-definitions",
			],
			"notRepresentedByBundleV1": [
				"temple-offerings",
				"learned-spell-lists",
				"scroll-catalogs",
			],
		},
		"spells": spell_rows,
		"spellClasses": class_rows,
		"unresolvedReferences": unresolved_rows,
	}


func _collect_bundle(bundle: ClassicCampaignBundle) -> void:
	var execution_report: Dictionary = ExecutionAuditScript.new().inspect(bundle)
	var monster_contexts: Dictionary = {}
	_collect_action_references(bundle, execution_report, monster_contexts)
	_collect_battle_monster_contexts(bundle, monster_contexts)
	_collect_monster_spells(bundle, monster_contexts)
	_collect_complex_encounters(bundle)
	_collect_scenario_spell_items(bundle)
	_collect_spell_overrides(bundle)


func _collect_action_references(
	bundle: ClassicCampaignBundle,
	execution_report: Dictionary,
	monster_contexts: Dictionary
) -> void:
	for action_value: Variant in execution_report.get("actions", []):
		if not (action_value is Dictionary) or not bool(action_value.get("executable", false)):
			continue
		var action: Dictionary = action_value
		var code := int(action.get("code", 0))
		if code in [17, 18]:
			var extra_code := bundle.get_extra_code(int(action.get("id", 0)))
			var values: Variant = extra_code.get("values", [])
			if values is Array and not values.is_empty():
				var usage := _record_usage(
					bundle,
					extra_code,
					"Data EDCD",
					int(extra_code.get("id", -1)),
					0,
					"field-selected" if code == 17 else "field-party"
				)
				usage["ownerSource"] = str(action.get("source", ""))
				usage["ownerRecordIndex"] = int(action.get("recordIndex", -1))
				usage["ownerSlot"] = int(action.get("slot", -1))
				_add_reference(bundle, int(values[0]), usage)
		elif code == 89:
			_add_monster_context(monster_contexts, abs(int(action.get("id", 0))), "ally")
		elif code == 124:
			var extra_code := bundle.get_extra_code(int(action.get("id", 0)))
			var values: Variant = extra_code.get("values", [])
			if values is Array and values.size() > 1:
				_add_monster_context(
					monster_contexts,
					abs(int(values[1])),
					"summoned-combatant"
				)


func _collect_battle_monster_contexts(
	bundle: ClassicCampaignBundle,
	monster_contexts: Dictionary
) -> void:
	var battle_ids: Array = bundle.battles_by_id.keys()
	battle_ids.sort()
	for battle_id_value: Variant in battle_ids:
		var battle: Dictionary = bundle.battles_by_id[battle_id_value]
		if not _producer_marks_callable(battle):
			continue
		var grid: Variant = battle.get("grid", [])
		if not (grid is Array):
			continue
		for monster_id_value: Variant in grid:
			_add_monster_context(monster_contexts, abs(int(monster_id_value)), "combatant")


func _add_monster_context(contexts: Dictionary, monster_id: int, context: String) -> void:
	if monster_id == 0:
		return
	if not contexts.has(monster_id):
		contexts[monster_id] = []
	if not contexts[monster_id].has(context):
		contexts[monster_id].append(context)


func _collect_monster_spells(
	bundle: ClassicCampaignBundle,
	monster_contexts: Dictionary
) -> void:
	var monster_ids: Array = monster_contexts.keys()
	monster_ids.sort()
	for monster_id_value: Variant in monster_ids:
		var monster_id := int(monster_id_value)
		var monster := bundle.get_monster(monster_id)
		if monster.is_empty():
			continue
		var spells: Variant = monster.get("spells", [])
		if not (spells is Array):
			continue
		for context_value: Variant in monster_contexts[monster_id_value]:
			for slot: int in range(spells.size()):
				_add_reference(
					bundle,
					int(spells[slot]),
					_record_usage(
						bundle, monster, "Data MD", monster_id, slot, str(context_value)
					)
				)


func _collect_complex_encounters(bundle: ClassicCampaignBundle) -> void:
	var encounter_ids: Array = bundle.complex_encounters_by_id.keys()
	encounter_ids.sort()
	for encounter_id_value: Variant in encounter_ids:
		var encounter_id := int(encounter_id_value)
		var encounter: Dictionary = bundle.complex_encounters_by_id[encounter_id_value]
		if not _producer_marks_callable(encounter):
			continue
		var spell_ids: Variant = encounter.get("spellIds", [])
		if spell_ids is Array:
			for slot: int in range(spell_ids.size()):
				_add_reference(
					bundle,
					int(spell_ids[slot]),
					_record_usage(
						bundle,
						encounter,
						"Data ED2",
						encounter_id,
						slot,
						"complex-response"
					)
				)
		if not bool(encounter.get("thief", false)):
			continue
		var thief_id := int(encounter.get("thiefSuccess", -1))
		var thief_encounter := bundle.get_thief_encounter(thief_id)
		if thief_encounter.is_empty():
			continue
		var usage := _record_usage(
			bundle, thief_encounter, "Data TD2", thief_id, -1, "rogue-trap"
		)
		usage["ownerSource"] = "Data ED2"
		usage["ownerRecordIndex"] = encounter_id
		_add_reference(bundle, int(thief_encounter.get("spell", 0)), usage)


func _producer_marks_callable(record: Dictionary) -> bool:
	if record.has("callable"):
		return bool(record["callable"])
	return true


func _collect_scenario_spell_items(bundle: ClassicCampaignBundle) -> void:
	var item_ids: Array = bundle.scenario_items_by_id.keys()
	item_ids.sort()
	for item_id_value: Variant in item_ids:
		var item_id := int(item_id_value)
		var item: Dictionary = bundle.scenario_items_by_id[item_id_value]
		if int(item.get("type", 0)) != 20:
			continue
		var usage := _record_usage(bundle, item, "Data NI", item_id, -1, "scenario-spell-item")
		usage["field"] = "special2"
		_add_reference(
			bundle,
			abs(int(item.get("special2", 0))),
			usage
		)


func _collect_spell_overrides(bundle: ClassicCampaignBundle) -> void:
	var spell_ids: Array = bundle.spell_overrides_by_id.keys()
	spell_ids.sort()
	for spell_id_value: Variant in spell_ids:
		var spell_id := int(spell_id_value)
		var spell_override: Dictionary = bundle.spell_overrides_by_id[spell_id_value]
		if _is_empty_spell_definition(spell_override):
			continue
		var definition := _record_usage(
			bundle,
			spell_override,
			"Data Spell",
			int(spell_override.get("id", -1)),
			-1,
			"scenario-definition"
		)
		definition["stableId"] = "%s:spell:%d" % [
			str(bundle.manifest.get("id", "")),
			int(spell_override.get("id", -1)),
		]
		definition["packedSpellId"] = spell_id
		definition["displayName"] = str(spell_override.get("displayName", ""))
		definition["special"] = int(spell_override.get("special", 0))
		_append_usage(_spell_definitions, spell_id, definition)


func _is_empty_spell_definition(record: Dictionary) -> bool:
	for field_name: String in SPELL_DEFINITION_FIELDS:
		if int(record.get(field_name, 0)) != 0:
			return false
	return true


func _add_reference(
	bundle: ClassicCampaignBundle,
	reference_id: int,
	usage: Dictionary
) -> void:
	if reference_id == 0 or reference_id == 9999:
		return
	var spell_id: int = abs(reference_id)
	var spell_override := bundle.get_spell_override(spell_id)
	if not spell_override.is_empty():
		var packed_id: int = abs(int(spell_override.get("packedSpellId", spell_id)))
		if packed_id != spell_id:
			usage["originalReferenceId"] = spell_id
		spell_id = packed_id
	if spell_id >= 1101:
		_append_usage(_spell_usages, spell_id, usage)
	elif spell_id >= 1 and spell_id <= 6:
		_append_usage(_class_usages, spell_id, usage)
	else:
		_append_usage(_unresolved_usages, spell_id, usage)


func _append_usage(destination: Dictionary, reference_id: int, usage: Dictionary) -> void:
	if not destination.has(reference_id):
		destination[reference_id] = []
	var usage_key := _usage_key(usage)
	for existing_value: Variant in destination[reference_id]:
		if existing_value is Dictionary and _usage_key(existing_value) == usage_key:
			return
	destination[reference_id].append(usage)


func _usage_key(usage: Dictionary) -> String:
	return "%s|%s|%d|%d|%s|%s|%d|%d" % [
		str(usage.get("campaignId", "")),
		str(usage.get("sourceFile", "")),
		int(usage.get("recordIndex", -1)),
		int(usage.get("slot", -1)),
		str(usage.get("field", "")),
		str(usage.get("context", "")),
		int(usage.get("ownerRecordIndex", -1)),
		int(usage.get("ownerSlot", -1)),
	]


func _record_usage(
	bundle: ClassicCampaignBundle,
	record: Dictionary,
	fallback_source: String,
	fallback_index: int,
	slot: int,
	context: String
) -> Dictionary:
	var provenance: Variant = record.get("provenance", {})
	var source_file := fallback_source
	var record_index := fallback_index
	if provenance is Dictionary:
		source_file = str(provenance.get("sourceFile", source_file))
		record_index = int(provenance.get("recordIndex", record_index))
	var usage := {
		"campaignId": str(bundle.manifest.get("id", "")),
		"scenario": str(bundle.manifest.get("name", "Unknown Classic campaign")),
		"context": context,
		"sourceFile": source_file,
		"recordIndex": record_index,
	}
	if slot >= 0:
		usage["slot"] = slot
	return usage


func _index_matrix(matrix: Dictionary) -> Dictionary:
	var indexed: Dictionary = {}
	var rows: Variant = matrix.get("spells", [])
	if not (rows is Array):
		return indexed
	for row_value: Variant in rows:
		if not (row_value is Dictionary):
			continue
		var spell_id := int(row_value.get("classicSpellId", 0))
		if spell_id >= 1101 and not indexed.has(spell_id):
			indexed[spell_id] = row_value
	return indexed


func _spell_rows(matrix_by_id: Dictionary, native_spells: Dictionary) -> Array:
	var rows: Array = []
	var spell_ids: Array = _spell_usages.keys()
	for spell_id_value: Variant in _spell_definitions:
		if spell_id_value not in spell_ids:
			spell_ids.append(spell_id_value)
	spell_ids.sort()
	for spell_id_value: Variant in spell_ids:
		var spell_id := int(spell_id_value)
		var matrix_row: Dictionary = matrix_by_id.get(spell_id, {})
		var display_name := str(matrix_row.get(
			"displayName", SpellIdentityScript.mapped_name(spell_id, _spell_mapping)
		))
		if display_name.is_empty():
			display_name = "Classic spell %d" % spell_id
		var definitions: Array = _spell_definitions.get(
			spell_id_value, []
		).duplicate(true)
		var usages: Array = _spell_usages.get(spell_id_value, []).duplicate(true)
		for definition_value: Variant in definitions:
			if not (definition_value is Dictionary):
				continue
			var definition: Dictionary = definition_value
			var consumers: Array = []
			for usage_value: Variant in usages:
				if usage_value is Dictionary and str(usage_value.get(
					"campaignId", ""
				)) == str(definition.get("campaignId", "")):
					consumers.append(usage_value.duplicate(true))
			definition["active"] = not consumers.is_empty()
			definition["consumers"] = consumers
		var row := {
			"classicSpellId": spell_id,
			"displayName": display_name,
			"classification": str(matrix_row.get("classification", "unclassified")),
			"supportStatus": str(matrix_row.get("supportStatus", "unclassified")),
			"nativeResolution": _native_resolution(spell_id, native_spells),
			"definitionPresent": not definitions.is_empty(),
			"active": not usages.is_empty(),
			"definitions": definitions,
			"usages": usages,
		}
		if matrix_row.has("resource"):
			row["resource"] = str(matrix_row["resource"])
		if matrix_row.has("behavior"):
			row["behavior"] = matrix_row["behavior"].duplicate(true)
		rows.append(row)
	return rows


func _native_resolution(spell_id: int, native_spells: Dictionary) -> Dictionary:
	return SpellIdentityScript.native_resolution(spell_id, _spell_mapping, native_spells)


func _reference_rows(usages_by_id: Dictionary, id_field: String) -> Array:
	var rows: Array = []
	var reference_ids: Array = usages_by_id.keys()
	reference_ids.sort()
	for reference_id_value: Variant in reference_ids:
		rows.append({
			id_field: int(reference_id_value),
			"usages": usages_by_id[reference_id_value].duplicate(true),
		})
	return rows
