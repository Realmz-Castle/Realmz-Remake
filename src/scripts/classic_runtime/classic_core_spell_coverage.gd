class_name ClassicCoreSpellCoverage
extends RefCounted

const CoreSpellCatalogScript = preload(
	"res://scripts/classic_runtime/classic_core_spell_catalog.gd"
)
const SpellIdentityScript = preload(
	"res://scripts/classic_runtime/classic_spell_identity.gd"
)
const SpellIdsScript = preload("res://scripts/spells_id_divinity.gd")

const SCHEMA_VERSION := 1

var _spell_mapping: Dictionary = {}


func _init() -> void:
	var mapping_source: Object = SpellIdsScript.new()
	var mappings: Variant = mapping_source.get("mappings")
	_spell_mapping = mappings.duplicate() if mappings is Dictionary else {}
	mapping_source.free()


func inspect(matrix: Dictionary, native_spells: Dictionary) -> Dictionary:
	var matrix_by_id := _index_matrix(matrix)
	var rows: Array = []
	var coverage_counts: Dictionary = {}
	var resolution_counts: Dictionary = {}
	var matrix_supported := 0
	var generic_records := 0
	var special_records := 0
	for inventory_value: Variant in CoreSpellCatalogScript.inventory_records():
		var inventory: Dictionary = inventory_value
		var spell_id := int(inventory.get("packedSpellId", 0))
		var matrix_row: Dictionary = matrix_by_id.get(spell_id, {})
		var resolution := SpellIdentityScript.native_resolution(
			spell_id, _spell_mapping, native_spells
		)
		var coverage_status := _coverage_status(inventory, matrix_row, resolution)
		var support_status := str(matrix_row.get("supportStatus", "unclassified"))
		var resolution_status := str(resolution.get("status", "not-audited"))
		coverage_counts[coverage_status] = int(coverage_counts.get(coverage_status, 0)) + 1
		resolution_counts[resolution_status] = int(
			resolution_counts.get(resolution_status, 0)
		) + 1
		if support_status == "supported":
			matrix_supported += 1
		if str(inventory.get("recordShape", "")) == "generic":
			generic_records += 1
		else:
			special_records += 1
		var row := {
			"classicSpellId": spell_id,
			"displayName": str(inventory.get("displayName", "")),
			"casterClass": str(inventory.get("casterClass", "")),
			"level": int(inventory.get("level", 0)),
			"slot": int(inventory.get("slot", 0)),
			"recordShape": str(inventory.get("recordShape", "")),
			"sourceRecord": inventory.get("sourceRecord", {}).duplicate(true),
			"supportStatus": support_status,
			"classification": str(matrix_row.get("classification", "unclassified")),
			"nativeResolution": resolution,
			"coverageStatus": coverage_status,
		}
		var mapped_name := str(resolution.get("mappedName", ""))
		if mapped_name != str(inventory.get("displayName", "")):
			row["mappedNameMismatch"] = mapped_name
		if matrix_row.has("resource"):
			row["resource"] = str(matrix_row["resource"])
		rows.append(row)

	return {
		"schemaVersion": SCHEMA_VERSION,
		"totals": {
			"spellIds": rows.size(),
			"matrixSupported": matrix_supported,
			"genericRecords": generic_records,
			"specialBehaviorRecords": special_records,
			"coverageStatus": coverage_counts,
			"nativeResolution": resolution_counts,
		},
		"spells": rows,
	}


func _index_matrix(matrix: Dictionary) -> Dictionary:
	var indexed: Dictionary = {}
	var values: Variant = matrix.get("spells", [])
	if not (values is Array):
		return indexed
	for value: Variant in values:
		if not (value is Dictionary):
			continue
		var spell_id := int(value.get("classicSpellId", 0))
		if spell_id >= 1101 and not indexed.has(spell_id):
			indexed[spell_id] = value
	return indexed


func _coverage_status(
	inventory: Dictionary,
	matrix_row: Dictionary,
	resolution: Dictionary
) -> String:
	var support_status := str(matrix_row.get("supportStatus", "unclassified"))
	var resolution_status := str(resolution.get("status", "not-audited"))
	if support_status == "supported":
		return "supported" \
			if resolution_status == "exact-id-resource" else "support-resource-mismatch"
	if support_status != "unclassified":
		return "documented-gap"
	match resolution_status:
		"exact-id-resource":
			return "exact-resource-review"
		"name-only-resource":
			return "named-resource-review"
		"unsupported-native-variant":
			return "native-variant-review"
	if str(inventory.get("recordShape", "")) == "generic":
		return "generic-implementation-candidate"
	return "special-implementation-required"
