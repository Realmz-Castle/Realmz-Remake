class_name ClassicCampaignInstall
extends RefCounted

const BundleScript = preload("res://scripts/classic_runtime/classic_campaign_bundle.gd")
const ReadinessScript = preload(
	"res://scripts/classic_runtime/classic_campaign_readiness.gd"
)

const REQUIRED_NATIVE_MAP_FILES := [
	"map_info.json",
	"map_scriptareas.json",
	"map_scripts.gd",
	"map_things.json",
]

var campaign_name := ""
var campaign_directory := ""
var bundle: ClassicCampaignBundle
var readiness_report: Dictionary = {}
var start_diagnostic := ""
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
	readiness_report = ReadinessScript.new().inspect(bundle)
	start_diagnostic = _validate_native_start_map()
	return true


func selection_rules() -> Dictionary:
	if bundle == null or not last_error.is_empty():
		var invalid_title := campaign_name
		if bundle != null:
			var manifest_title := str(bundle.manifest.get("name", "")).strip_edges()
			if not manifest_title.is_empty():
				invalid_title = manifest_title
		return {
			"title": invalid_title,
			"description": last_error,
			"restrictionsDescription": last_error,
			"charactersLimit": 0,
			"classic": true,
			"valid": false,
			"readinessState": "Invalid",
			"readinessSummary": "Invalid Classic campaign package.",
			"diagnostic": last_error,
		}
	var title := str(bundle.manifest.get("name", campaign_name)).strip_edges()
	if title.is_empty():
		title = campaign_name
	var description := str(bundle.manifest.get("description", "")).strip_edges()
	if description.is_empty():
		description = "%s (Classic compatibility campaign)" % title
	var ready := bool(readiness_report.get("ready", false)) and start_diagnostic.is_empty()
	var fallback_count := int(
		readiness_report.get("totals", {}).get("fidelityFallbacks", 0)
	)
	var readiness_state := "Ready with fallbacks" if ready and fallback_count > 0 else "Ready"
	var diagnostic := ""
	if not start_diagnostic.is_empty():
		readiness_state = "Blocked"
		diagnostic = start_diagnostic
	elif not bool(readiness_report.get("ready", false)):
		readiness_state = "Blocked"
		diagnostic = _first_progression_blocker()
	var readiness_summary := str(readiness_report.get("summary", ""))
	if not start_diagnostic.is_empty():
		readiness_summary = "Blocked: required native start-map files are unavailable."
	var format_version := int(bundle.manifest.get("formatVersion", 0))
	var compatibility_profile := str(bundle.manifest.get("compatibilityProfile", ""))
	var version_label := "Classic format v%d" % format_version
	if not compatibility_profile.is_empty():
		version_label += " (%s)" % compatibility_profile
	return {
		"title": title,
		"description": description,
		"restrictionsDescription": (
			"No race or class restrictions; 6 characters maximum"
			if ready
			else "Cannot start: %s" % diagnostic
		),
		"charactersLimit": 6,
		"classic": true,
		"valid": ready,
		"formatVersion": format_version,
		"compatibilityProfile": compatibility_profile,
		"versionLabel": version_label,
		"readinessState": readiness_state,
		"readinessSummary": readiness_summary,
		"diagnostic": diagnostic,
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
	readiness_report.clear()
	start_diagnostic = ""
	last_error = ""


func _fail(message: String) -> bool:
	last_error = message
	return false


func _normalized_directory(directory: String) -> String:
	return directory.strip_edges().replace("\\", "/").trim_suffix("/")


func _validate_native_start_map() -> String:
	var start := bundle.get_start()
	var level_type := str(start.get("levelType", ""))
	var level_index := int(start.get("levelIndex", -1))
	var map_name := ""
	if level_type == "land":
		map_name = "map_%d" % level_index
	elif level_type == "dungeon":
		map_name = "mapd_%d" % level_index
	if map_name.is_empty() or level_index < 0:
		return "Compiled campaign has an invalid start-map identity"
	var map_directory := campaign_directory.path_join("Maps").path_join(map_name)
	for file_name: String in REQUIRED_NATIVE_MAP_FILES:
		if not FileAccess.file_exists(map_directory.path_join(file_name)):
			return "Native start map %s is missing %s" % [map_name, file_name]
	return ""


func _first_progression_blocker() -> String:
	for diagnostic_value: Variant in readiness_report.get("diagnostics", []):
		if (
			diagnostic_value is Dictionary
			and str(diagnostic_value.get("classification", "")) == "progression-blocker"
		):
			return str(diagnostic_value.get("message", "Campaign readiness check failed"))
	return "Campaign readiness check failed"
