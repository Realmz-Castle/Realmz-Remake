class_name ClassicNativeContextBuilder
extends RefCounted

const SpellResourceCatalogScript = preload(
	"res://scripts/classic_runtime/classic_spell_resource_catalog.gd"
)
const ClassicItemIdsScript = preload("res://scripts/item_id_divinity.gd")

const SCHEMA_VERSION := 1
const DEFAULT_SHARED_DIRECTORY := "res://shared_assets"
const PREPARATION_ERROR := "preparation-error"

var _diagnostics: Array = []
var _sources: Array = []


func build(
	campaign_directory: String,
	shared_directory := DEFAULT_SHARED_DIRECTORY
) -> Dictionary:
	_diagnostics.clear()
	_sources.clear()
	var context := {
		"items": {},
		"bestiary": {},
		"spells": {},
		"sounds": {},
	}
	var normalized_campaign := _normalized_directory(campaign_directory)
	var normalized_shared := _normalized_directory(shared_directory)
	_merge_resource_book(
		normalized_shared,
		"items/stuff_book.json",
		"shared",
		"items",
		context["items"],
		true
	)
	_merge_resource_book(
		normalized_campaign,
		"Items/stuff_book.json",
		"campaign",
		"items",
		context["items"]
	)
	_merge_resource_book(
		normalized_shared,
		"Bestiary/stuff_book.json",
		"shared",
		"bestiary",
		context["bestiary"]
	)
	_merge_resource_book(
		normalized_campaign,
		"Bestiary/stuff_book.json",
		"campaign",
		"bestiary",
		context["bestiary"]
	)
	_merge_spell_directory(
		normalized_shared,
		"spells",
		"shared",
		context["spells"]
	)
	_merge_spell_directory(
		normalized_campaign,
		"Spells",
		"campaign",
		context["spells"]
	)
	_merge_sound_directory(
		normalized_shared,
		"sounds",
		"shared",
		context["sounds"]
	)
	_merge_sound_directory(
		normalized_campaign,
		"Sounds",
		"campaign",
		context["sounds"]
	)
	var error_count := 0
	for diagnostic_value: Variant in _diagnostics:
		if (
			diagnostic_value is Dictionary
			and str(diagnostic_value.get("classification", "")) == PREPARATION_ERROR
		):
			error_count += 1
	var ok := error_count == 0
	return {
		"schemaVersion": SCHEMA_VERSION,
		"ok": ok,
		"status": "ready" if ok else "preparation-failed",
		"context": context,
		"totals": {
			"preparationErrors": error_count,
			"sources": _sources.size(),
			"items": context["items"].size(),
			"bestiary": context["bestiary"].size(),
			"spells": context["spells"].size(),
			"sounds": context["sounds"].size(),
		},
		"sources": _sources.duplicate(true),
		"diagnostics": _diagnostics.duplicate(true),
	}


static func public_report(result: Dictionary) -> Dictionary:
	var report := result.duplicate(true)
	report.erase("context")
	return report


static func first_error(result: Dictionary) -> String:
	for diagnostic_value: Variant in result.get("diagnostics", []):
		if (
			diagnostic_value is Dictionary
			and str(diagnostic_value.get("classification", "")) == PREPARATION_ERROR
		):
			return str(
				diagnostic_value.get(
					"message",
					"Classic native resource preparation failed"
				)
			)
	return "Classic native resource preparation failed"


func _merge_resource_book(
	base_directory: String,
	relative_path: String,
	scope: String,
	resource_kind: String,
	destination: Dictionary,
	enrich_classic_item_ids := false
) -> void:
	var path := base_directory.path_join(relative_path)
	var display_path := _display_path(scope, relative_path)
	if not FileAccess.file_exists(path):
		_sources.append(_source_row(
			scope,
			resource_kind,
			display_path,
			false,
			0
		))
		return
	var parser := JSON.new()
	var error := parser.parse(FileAccess.get_file_as_string(path))
	if error != OK or not (parser.data is Dictionary):
		var detail := parser.get_error_message()
		if error == OK:
			detail = "the document root is not a JSON object"
		elif parser.get_error_line() > 0:
			detail += " at line %d" % parser.get_error_line()
		_add_preparation_error(
			"invalid-native-%s-book" % resource_kind,
			resource_kind,
			scope,
			display_path,
			"Native %s book is invalid: %s (%s)" % [
				resource_kind,
				display_path,
				detail,
			]
		)
		_sources.append(_source_row(
			scope,
			resource_kind,
			display_path,
			true,
			0
		))
		return
	var value: Dictionary = parser.data
	if enrich_classic_item_ids:
		value = ClassicItemIdsScript.new().enrich_item_book(value)
	destination.merge(value, true)
	_sources.append(_source_row(
		scope,
		resource_kind,
		display_path,
		true,
		value.size()
	))


func _merge_spell_directory(
	base_directory: String,
	relative_path: String,
	scope: String,
	destination: Dictionary
) -> void:
	var path := base_directory.path_join(relative_path)
	var exists := _directory_exists(path)
	var source_entries: Dictionary = {}
	if exists:
		SpellResourceCatalogScript.merge_directory(path, source_entries)
		destination.merge(source_entries, true)
	_sources.append(_source_row(
		scope,
		"spells",
		_display_path(scope, relative_path),
		exists,
		source_entries.size()
	))


func _merge_sound_directory(
	base_directory: String,
	relative_path: String,
	scope: String,
	destination: Dictionary
) -> void:
	var path := base_directory.path_join(relative_path)
	var access := DirAccess.open(path)
	var entries_read := 0
	if access != null:
		access.list_dir_begin()
		var file_name := access.get_next()
		while not file_name.is_empty():
			if not access.current_is_dir():
				var resource_name := file_name.trim_suffix(".import")
				if not resource_name.ends_with(".uid"):
					destination[resource_name] = true
					entries_read += 1
			file_name = access.get_next()
		access.list_dir_end()
	_sources.append(_source_row(
		scope,
		"sounds",
		_display_path(scope, relative_path),
		access != null,
		entries_read
	))


func _add_preparation_error(
	code: String,
	resource_kind: String,
	scope: String,
	path: String,
	message: String
) -> void:
	_diagnostics.append({
		"severity": "error",
		"classification": PREPARATION_ERROR,
		"activity": "preparation",
		"code": code,
		"resourceKind": resource_kind,
		"scope": scope,
		"source": path,
		"recordIndex": -1,
		"message": message,
	})


static func _source_row(
	scope: String,
	resource_kind: String,
	path: String,
	exists: bool,
	entries_read: int
) -> Dictionary:
	return {
		"scope": scope,
		"resourceKind": resource_kind,
		"path": path,
		"exists": exists,
		"entriesRead": entries_read,
	}


static func _display_path(scope: String, relative_path: String) -> String:
	return "%s://%s" % [scope, relative_path.replace("\\", "/")]


static func _directory_exists(path: String) -> bool:
	var access := DirAccess.open(path)
	return access != null


static func _normalized_directory(directory: String) -> String:
	return directory.strip_edges().replace("\\", "/").trim_suffix("/")
