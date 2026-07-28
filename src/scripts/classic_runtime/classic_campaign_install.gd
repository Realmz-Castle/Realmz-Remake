class_name ClassicCampaignInstall
extends RefCounted

const BundleScript = preload("res://scripts/classic_runtime/classic_campaign_bundle.gd")
const ReadinessScript = preload(
	"res://scripts/classic_runtime/classic_campaign_readiness.gd"
)
const CampaignAdmissionScript = preload(
	"res://scripts/classic_runtime/classic_campaign_admission.gd"
)
const NativeContextBuilderScript = preload(
	"res://scripts/classic_runtime/classic_native_context_builder.gd"
)
const SharedAssetStoreScript = preload(
	"res://scripts/classic_runtime/classic_shared_asset_store.gd"
)

const REQUIRED_NATIVE_MAP_FILES := [
	"map_info.json",
	"map_scriptareas.json",
	"map_things.json",
]
const FORBIDDEN_EXECUTABLE_EXTENSIONS := [
	"gd",
	"gdc",
	"pck",
	"dll",
	"so",
	"dylib",
	"exe",
	"wasm",
]

var campaign_name := ""
var campaign_directory := ""
var bundle: ClassicCampaignBundle
var shared_asset_store: ClassicSharedAssetStore
var readiness_report: Dictionary = {}
var native_context_report: Dictionary = {}
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


static func preview_from_campaigns_directory(
	campaigns_directory: String,
	candidate_name: String
) -> Dictionary:
	var fallback := {
		"title": candidate_name,
		"description": "%s (Classic compatibility campaign)" % candidate_name,
		"restrictionsDescription": "Select this campaign to check compatibility.",
		"charactersLimit": CampaignAdmissionScript.NATIVE_PARTY_LIMIT,
		"classic": true,
		"preview": true,
		"valid": false,
		"readinessState": "Select to check",
		"readinessSummary": "Compatibility is checked when this campaign is selected.",
		"diagnostic": "",
	}
	if not is_safe_campaign_name(candidate_name):
		fallback["readinessState"] = "Invalid"
		fallback["diagnostic"] = "Classic campaign name is invalid"
		return fallback
	var campaign_directory := _normalized_directory(campaigns_directory).path_join(
		candidate_name
	)
	var manifest := _read_preview_json(campaign_directory.path_join("campaign.json"))
	if manifest.is_empty():
		fallback["readinessState"] = "Invalid"
		fallback["diagnostic"] = "Classic campaign manifest is unavailable"
		return fallback

	var title := str(manifest.get("name", candidate_name)).strip_edges()
	fallback["title"] = title if not title.is_empty() else candidate_name
	var description := str(manifest.get("description", "")).strip_edges()
	if not description.is_empty():
		fallback["description"] = description
	var format_version := int(manifest.get("formatVersion", 0))
	var compatibility_profile := str(
		manifest.get("compatibilityProfile", "")
	).strip_edges()
	var version_label := "Classic format v%d" % format_version
	if not compatibility_profile.is_empty():
		version_label += " (%s)" % compatibility_profile
	fallback["formatVersion"] = format_version
	fallback["compatibilityProfile"] = compatibility_profile
	fallback["versionLabel"] = version_label

	var files: Variant = manifest.get("files", {})
	if not (files is Dictionary):
		return fallback
	var scenario := _read_preview_document(
		campaign_directory,
		str(files.get("scenario", ""))
	)
	var rules := _read_preview_document(
		campaign_directory,
		str(files.get("rules", ""))
	)
	var admission := CampaignAdmissionScript.rules_from_bundle({
		"documents": {"scenario": scenario, "rules": rules},
	})
	fallback.merge(admission, true)
	fallback["preview"] = true
	fallback["valid"] = false
	return fallback


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
	var executable_payload := _find_executable_payload(campaign_directory)
	if not executable_payload.is_empty():
		return _fail(
			"Imported scenarios are data-only; executable payload '%s' is not allowed"
			% executable_payload
		)

	bundle = BundleScript.new()
	if not bundle.load_from_directory(campaign_directory):
		return _fail(bundle.last_error)
	shared_asset_store = SharedAssetStoreScript.new()
	if not shared_asset_store.load_for_campaign(campaign_directory, bundle.manifest):
		return _fail(shared_asset_store.last_error)
	if not _validate_packaged_payloads():
		return false
	var native_context_result: Dictionary = NativeContextBuilderScript.new().build(
		campaign_directory
	)
	native_context_report = NativeContextBuilderScript.public_report(
		native_context_result
	)
	if not bool(native_context_result.get("ok", false)):
		return _fail(NativeContextBuilderScript.first_error(native_context_result))
	readiness_report = ReadinessScript.new().inspect(
		bundle,
		native_context_result.get("context", {})
	)
	start_diagnostic = _validate_native_start_map()
	return true


func _find_executable_payload(directory_path: String, relative_path := "") -> String:
	var directory := DirAccess.open(directory_path)
	if directory == null:
		return relative_path
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		var child_path := directory_path.path_join(entry)
		var child_relative := entry if relative_path.is_empty() \
			else relative_path.path_join(entry)
		if directory.is_link(entry):
			directory.list_dir_end()
			return child_relative
		if directory.current_is_dir():
			var nested := _find_executable_payload(child_path, child_relative)
			if not nested.is_empty():
				directory.list_dir_end()
				return nested
		elif entry.get_extension().to_lower() in FORBIDDEN_EXECUTABLE_EXTENSIONS:
			directory.list_dir_end()
			return child_relative
		entry = directory.get_next()
	directory.list_dir_end()
	return ""


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
	var selection := {
		"title": title,
		"description": description,
		"classic": true,
		"valid": ready,
		"formatVersion": format_version,
		"compatibilityProfile": compatibility_profile,
		"versionLabel": version_label,
		"readinessState": readiness_state,
		"readinessSummary": readiness_summary,
		"diagnostic": diagnostic,
	}
	selection.merge(CampaignAdmissionScript.rules_from_bundle(bundle), true)
	if not ready:
		selection["restrictionsDescription"] = "Cannot start: %s" % diagnostic
	return selection


static func _read_preview_document(campaign_directory: String, relative_path: String) -> Dictionary:
	var normalized := relative_path.replace("\\", "/").strip_edges()
	if (
		normalized.is_empty()
		or normalized.is_absolute_path()
		or normalized.contains(":")
		or ".." in normalized.split("/", false)
	):
		return {}
	return _read_preview_json(campaign_directory.path_join(normalized))


static func _read_preview_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value if value is Dictionary else {}


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
	var maps: Variant = bundle.documents.get("maps", {})
	if maps is Dictionary:
		var map_records: Variant = maps.get("mapRecords", [])
		if map_records is Array:
			records.append_array(map_records)

	var checked_paths: Dictionary = {}
	for record_value: Variant in records:
		if not (record_value is Dictionary):
			continue
		if record_value.has("payloadPath") and not _validate_packaged_file(
			str(record_value.get("payloadPath", "")),
			record_value.get("payloadBytes"),
			str(record_value.get("payloadSha256", "")),
			"payload",
			checked_paths
		):
			return false
		var runtime_media: Variant = record_value.get("runtimeMedia", {})
		if runtime_media is Dictionary and not runtime_media.is_empty() \
				and not _validate_packaged_file(
					str(runtime_media.get("path", "")),
					runtime_media.get("bytes"),
					str(runtime_media.get("sha256", "")),
					"runtime media",
					checked_paths
				):
			return false
	return true


func _validate_packaged_file(
	relative_path: String,
	expected_bytes: Variant,
	expected_hash: String,
	file_kind: String,
	checked_paths: Dictionary
) -> bool:
	if checked_paths.has(relative_path):
		return true
	checked_paths[relative_path] = true
	var packaged_path := campaign_directory.path_join(relative_path)
	if not FileAccess.file_exists(packaged_path):
		return _fail("Installed Classic campaign is missing %s: %s" % [file_kind, relative_path])
	if expected_bytes is int or expected_bytes is float:
		var file := FileAccess.open(packaged_path, FileAccess.READ)
		if file == null or file.get_length() != int(expected_bytes):
			return _fail(
				"Installed Classic %s has the wrong size: %s" % [file_kind, relative_path]
			)
	var normalized_hash := expected_hash.to_lower()
	if not normalized_hash.is_empty() \
			and FileAccess.get_sha256(packaged_path).to_lower() != normalized_hash:
		return _fail(
			"Installed Classic %s failed its checksum: %s" % [file_kind, relative_path]
		)
	return true


func _reset() -> void:
	campaign_name = ""
	campaign_directory = ""
	bundle = null
	shared_asset_store = null
	readiness_report.clear()
	native_context_report.clear()
	start_diagnostic = ""
	last_error = ""


func _fail(message: String) -> bool:
	last_error = message
	return false


static func _normalized_directory(directory: String) -> String:
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
