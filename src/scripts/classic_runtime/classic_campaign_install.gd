class_name ClassicCampaignInstall
extends RefCounted

const BundleScript = preload("res://scripts/classic_runtime/classic_campaign_bundle.gd")

var campaign_name := ""
var campaign_directory := ""
var bundle: ClassicCampaignBundle
var last_error := ""


static func has_manifest(campaigns_directory: String, candidate_name: String) -> bool:
	if not is_safe_campaign_name(candidate_name):
		return false
	return FileAccess.file_exists(
		campaigns_directory.path_join(candidate_name).path_join("campaign.json")
	)


static func is_safe_campaign_name(candidate_name: String) -> bool:
	var stripped := candidate_name.strip_edges()
	return (
		not stripped.is_empty()
		and stripped == candidate_name
		and stripped not in [".", ".."]
		and not stripped.contains("/")
		and not stripped.contains("\\")
		and not stripped.contains(":")
		and not stripped.is_absolute_path()
	)


func load_from_campaigns_directory(
	campaigns_directory: String,
	candidate_name: String
) -> bool:
	_reset()
	if not is_safe_campaign_name(candidate_name):
		return _fail("Classic campaign name must identify one installed campaign directory")
	var normalized_root := _normalized_directory(campaigns_directory)
	if normalized_root.is_empty():
		return _fail("Classic campaigns directory is unavailable")
	campaign_name = candidate_name
	campaign_directory = normalized_root.path_join(candidate_name)
	if not DirAccess.dir_exists_absolute(campaign_directory):
		return _fail("Installed campaign directory does not exist: %s" % candidate_name)
	if not FileAccess.file_exists(campaign_directory.path_join("campaign.json")):
		return _fail("Installed Classic campaign is missing campaign.json")

	bundle = BundleScript.new()
	if not bundle.load_from_directory(campaign_directory):
		return _fail(bundle.last_error)
	if not _validate_packaged_payloads():
		return false
	return true


func selection_rules() -> Dictionary:
	if bundle == null:
		return {
			"description": last_error,
			"restrictionsDescription": last_error,
			"charactersLimit": 0,
			"classic": true,
			"valid": false,
		}
	var description := str(bundle.manifest.get("description", "")).strip_edges()
	if description.is_empty():
		description = "%s (Classic compatibility campaign)" % bundle.manifest.get(
			"name",
			campaign_name
		)
	return {
		"description": description,
		"restrictionsDescription": "No race or class restrictions; 6 characters maximum",
		"charactersLimit": 6,
		"classic": true,
		"valid": true,
		"formatVersion": int(bundle.manifest.get("formatVersion", 0)),
	}


func _validate_packaged_payloads() -> bool:
	var assets: Variant = bundle.documents.get("assets", {})
	if not (assets is Dictionary):
		return _fail("Classic assets document is unavailable")
	var records: Array = []
	var managed_assets: Variant = assets.get("managedAssets", [])
	if managed_assets is Array:
		records.append_array(managed_assets)
	var catalog: Variant = assets.get("catalog", {})
	if catalog is Dictionary:
		for collection_name: String in [
			"tilesets", "pictures", "icons", "sounds", "specialLandTiles"
		]:
			var collection: Variant = catalog.get(collection_name, [])
			if collection is Array:
				records.append_array(collection)

	var checked_paths: Dictionary = {}
	for record_value: Variant in records:
		if not (record_value is Dictionary) or not record_value.has("payloadPath"):
			continue
		var relative_path := str(record_value.get("payloadPath", ""))
		if checked_paths.has(relative_path):
			continue
		checked_paths[relative_path] = true
		var payload_path := campaign_directory.path_join(relative_path)
		if not FileAccess.file_exists(payload_path):
			return _fail("Installed Classic campaign is missing payload: %s" % relative_path)
		var expected_bytes: Variant = record_value.get("payloadBytes")
		if expected_bytes is int or expected_bytes is float:
			var file := FileAccess.open(payload_path, FileAccess.READ)
			if file == null or file.get_length() != int(expected_bytes):
				return _fail("Installed Classic payload has the wrong size: %s" % relative_path)
		var expected_hash := str(record_value.get("payloadSha256", "")).to_lower()
		if not expected_hash.is_empty() \
				and FileAccess.get_sha256(payload_path).to_lower() != expected_hash:
			return _fail("Installed Classic payload failed its checksum: %s" % relative_path)
	return true


func _reset() -> void:
	campaign_name = ""
	campaign_directory = ""
	bundle = null
	last_error = ""


func _fail(message: String) -> bool:
	last_error = message
	return false


func _normalized_directory(directory: String) -> String:
	return directory.strip_edges().replace("\\", "/").trim_suffix("/")
