class_name ClassicSharedAssetStore
extends RefCounted

const FORMAT := "realmz-remake-classic-shared-assets"
const FORMAT_VERSION := 1
const HASH_ALGORITHM := "sha256"
const STORE_DIRECTORY_NAME := "ClassicAssets"
const STORE_MANIFEST_NAME := "store.json"

var campaign_directory := ""
var store_directory := ""
var references: Dictionary = {}
var last_error := ""


func load_for_campaign(directory: String, manifest: Dictionary) -> bool:
	_reset()
	campaign_directory = _normalized_directory(directory)
	if campaign_directory.is_empty():
		return _fail("Classic campaign directory is unavailable")
	var section_error := validate_manifest_section(manifest)
	if not section_error.is_empty():
		return _fail(section_error)
	if not manifest.has("sharedAssets"):
		return true

	store_directory = campaign_directory.get_base_dir().get_base_dir().path_join(
		STORE_DIRECTORY_NAME
	)
	var store_manifest_path := store_directory.path_join(STORE_MANIFEST_NAME)
	if not FileAccess.file_exists(store_manifest_path):
		return _fail(
			"Built-in Classic shared asset store is missing: %s"
			% STORE_MANIFEST_NAME
		)
	var store_manifest_value: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(store_manifest_path)
	)
	if not (store_manifest_value is Dictionary):
		return _fail("Built-in Classic shared asset store manifest is invalid")
	var store_manifest: Dictionary = store_manifest_value
	if (
		str(store_manifest.get("format", "")) != FORMAT
		or int(store_manifest.get("formatVersion", 0)) != FORMAT_VERSION
		or str(store_manifest.get("hashAlgorithm", "")) != HASH_ALGORITHM
	):
		return _fail("Built-in Classic shared asset store has an unsupported format")
	var store_files: Variant = store_manifest.get("files", {})
	if not (store_files is Dictionary):
		return _fail("Built-in Classic shared asset store files must be a JSON object")

	var shared_assets: Dictionary = manifest["sharedAssets"]
	for reference_value: Variant in shared_assets["files"]:
		var reference: Dictionary = reference_value
		var logical_path := _normalized_logical_path(
			str(reference.get("logicalPath", ""))
		)
		var content_hash := str(reference.get("sha256", "")).to_lower()
		var expected_bytes := int(reference.get("bytes", -1))
		var extension := logical_path.get_extension().to_lower()
		var store_record_value: Variant = store_files.get(content_hash)
		if not (store_record_value is Dictionary):
			return _fail(
				"Shared Classic asset '%s' is absent from the store manifest"
				% logical_path
			)
		var store_record: Dictionary = store_record_value
		if (
			int(store_record.get("bytes", -1)) != expected_bytes
			or str(store_record.get("extension", "")).to_lower() != extension
		):
			return _fail(
				"Shared Classic asset '%s' disagrees with the store manifest"
				% logical_path
			)
		var content_path := _content_path(content_hash, extension)
		if not FileAccess.file_exists(content_path):
			return _fail(
				"Shared Classic asset '%s' is missing from the content store: %s"
				% [logical_path, content_hash]
			)
		var file := FileAccess.open(content_path, FileAccess.READ)
		if file == null or file.get_length() != expected_bytes:
			return _fail(
				"Shared Classic asset '%s' has the wrong size: %s"
				% [logical_path, content_hash]
			)
		file.close()
		if FileAccess.get_sha256(content_path).to_lower() != content_hash:
			return _fail(
				"Shared Classic asset '%s' failed its checksum: %s"
				% [logical_path, content_hash]
			)
		references[logical_path] = reference.duplicate(true)
	return true


func resolve(logical_path: String) -> String:
	var normalized := _normalized_logical_path(logical_path)
	var reference_value: Variant = references.get(normalized)
	if not (reference_value is Dictionary):
		return campaign_directory.path_join(normalized)
	var reference: Dictionary = reference_value
	var content_hash := str(reference.get("sha256", "")).to_lower()
	return _content_path(content_hash, normalized.get_extension().to_lower())


func shared_tileset_names() -> Array[String]:
	var names: Dictionary = {}
	for path_value: Variant in references:
		var logical_path := str(path_value)
		var components := logical_path.split("/", false)
		if components.size() >= 3 and components[0] == "Tilesets":
			names[str(components[1])] = true
	var result: Array[String] = []
	result.assign(names.keys())
	result.sort()
	return result


func has_reference(logical_path: String) -> bool:
	return references.has(_normalized_logical_path(logical_path))


static func validate_manifest_section(manifest: Dictionary) -> String:
	if not manifest.has("sharedAssets"):
		return ""
	var section_value: Variant = manifest.get("sharedAssets")
	if not (section_value is Dictionary):
		return "campaign.json sharedAssets must be a JSON object"
	var section: Dictionary = section_value
	if str(section.get("format", "")) != FORMAT:
		return "campaign.json sharedAssets.format must be '%s'" % FORMAT
	if int(section.get("formatVersion", 0)) != FORMAT_VERSION:
		return "campaign.json sharedAssets.formatVersion must be %d" % FORMAT_VERSION
	var files_value: Variant = section.get("files")
	if not (files_value is Array) or files_value.is_empty():
		return "campaign.json sharedAssets.files must be a non-empty JSON array"
	var paths: Dictionary = {}
	for index: int in range(files_value.size()):
		var record_value: Variant = files_value[index]
		var context := "campaign.json sharedAssets.files[%d]" % index
		if not (record_value is Dictionary):
			return "%s must be a JSON object" % context
		var record: Dictionary = record_value
		var logical_path_value: Variant = record.get("logicalPath")
		if (
			not (logical_path_value is String)
			or not _is_safe_logical_path(logical_path_value)
		):
			return "%s.logicalPath must be a safe campaign-relative path" % context
		var logical_path := _normalized_logical_path(logical_path_value)
		if paths.has(logical_path.to_lower()):
			return "%s.logicalPath duplicates %s" % [
				context,
				paths[logical_path.to_lower()],
			]
		paths[logical_path.to_lower()] = logical_path
		var bytes_value: Variant = record.get("bytes")
		if not _is_nonnegative_integer(bytes_value):
			return "%s.bytes must be a non-negative integer" % context
		var kind_value: Variant = record.get("kind")
		if not (kind_value is String) or kind_value.strip_edges().is_empty():
			return "%s.kind must be a non-empty string" % context
		var hash_value: Variant = record.get("sha256")
		if not (hash_value is String) or not _is_sha256(hash_value):
			return "%s.sha256 must be a 64-digit hexadecimal hash" % context
	return ""


func _content_path(content_hash: String, extension: String) -> String:
	return (
		store_directory
		.path_join(HASH_ALGORITHM)
		.path_join(content_hash.substr(0, 2))
		.path_join("%s.%s" % [content_hash, extension])
	)


func _reset() -> void:
	campaign_directory = ""
	store_directory = ""
	references.clear()
	last_error = ""


func _fail(message: String) -> bool:
	last_error = message
	return false


static func _normalized_directory(directory: String) -> String:
	return directory.strip_edges().replace("\\", "/").trim_suffix("/")


static func _normalized_logical_path(path: String) -> String:
	return path.strip_edges().replace("\\", "/")


static func _is_safe_logical_path(path: String) -> bool:
	var normalized := _normalized_logical_path(path)
	if (
		normalized.is_empty()
		or normalized.is_absolute_path()
		or normalized.contains(":")
		or normalized.get_extension().is_empty()
	):
		return false
	for component: String in normalized.split("/", false):
		if component.is_empty() or component in [".", ".."]:
			return false
	return true


static func _is_nonnegative_integer(value: Variant) -> bool:
	return (
		(value is int or value is float)
		and int(value) == value
		and int(value) >= 0
	)


static func _is_sha256(value: String) -> bool:
	if value.length() != 64:
		return false
	for character: String in value.to_lower():
		if character not in "0123456789abcdef":
			return false
	return true
