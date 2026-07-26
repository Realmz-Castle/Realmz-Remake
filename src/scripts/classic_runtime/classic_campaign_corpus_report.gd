class_name ClassicCampaignCorpusReport
extends RefCounted

const CampaignInstallScript = preload(
	"res://scripts/classic_runtime/classic_campaign_install.gd"
)

const SCHEMA_VERSION := 2
const REPORT_KIND := "classic-built-in-campaign-readiness-footprint"


func inspect(campaigns_directory: String, options := {}) -> Dictionary:
	var normalized_root := _normalized_directory(campaigns_directory)
	var expected_campaigns := int(options.get("expectedCampaigns", 13))
	var include_compressed_estimate := bool(
		options.get("includeCompressedEstimate", true)
	)
	var campaign_names := _classic_campaign_names(normalized_root)
	var campaigns: Array = []
	var footprint_totals := _empty_footprint()
	var diagnostic_breakdown := _empty_diagnostic_breakdown()
	var hash_index: Dictionary = {}
	var totals := {
		"campaigns": campaign_names.size(),
		"readyCampaigns": 0,
		"blockedCampaigns": 0,
		"installFailures": 0,
		"preparationErrors": 0,
		"progressionBlockers": 0,
		"fidelityFallbacks": 0,
		"diagnostics": 0,
	}
	for campaign_name: String in campaign_names:
		var install = CampaignInstallScript.new()
		var loaded := install.load_from_campaigns_directory(
			normalized_root,
			campaign_name
		)
		var selection := install.selection_rules()
		var readiness: Dictionary = install.readiness_report.duplicate(true)
		var preparation: Dictionary = install.native_context_report.duplicate(true)
		var campaign_footprint := _inspect_campaign_files(
			normalized_root.path_join(campaign_name),
			campaign_name,
			include_compressed_estimate,
			hash_index
		)
		_merge_footprint(footprint_totals, campaign_footprint)
		var selection_ready := loaded and bool(selection.get("valid", false))
		if selection_ready:
			totals["readyCampaigns"] += 1
		else:
			totals["blockedCampaigns"] += 1
		if not loaded:
			totals["installFailures"] += 1
		totals["preparationErrors"] += int(
			preparation.get("totals", {}).get("preparationErrors", 0)
		)
		totals["progressionBlockers"] += int(
			readiness.get("totals", {}).get("progressionBlockers", 0)
		)
		totals["fidelityFallbacks"] += int(
			readiness.get("totals", {}).get("fidelityFallbacks", 0)
		)
		totals["diagnostics"] += int(
			readiness.get("totals", {}).get("diagnostics", 0)
		)
		_merge_readiness_diagnostics(
			diagnostic_breakdown,
			readiness.get("diagnostics", [])
		)
		campaigns.append({
			"directory": campaign_name,
			"id": str(readiness.get("campaign", {}).get("id", "")),
			"name": str(
				readiness.get("campaign", {}).get(
					"name",
					selection.get("title", campaign_name)
				)
			),
			"install": {
				"loaded": loaded,
				"error": install.last_error,
				"startDiagnostic": install.start_diagnostic,
				"selectionState": str(selection.get("readinessState", "Invalid")),
				"selectionValid": selection_ready,
			},
			"preparation": preparation,
			"readiness": readiness,
			"footprint": campaign_footprint,
		})
	var shared_store_directory := normalized_root.get_base_dir().path_join(
		"ClassicAssets"
	)
	var shared_store_footprint := _inspect_shared_store_files(
		shared_store_directory,
		include_compressed_estimate
	)
	_merge_footprint(footprint_totals, shared_store_footprint)
	var duplication := _build_duplication_report(hash_index)
	var campaign_count_matches := (
		expected_campaigns <= 0
		or campaign_names.size() == expected_campaigns
	)
	var complete := campaign_count_matches and int(totals["installFailures"]) == 0
	var all_ready := complete and int(totals["blockedCampaigns"]) == 0
	var status := "ready"
	if not campaign_count_matches:
		status = "incomplete"
	elif int(totals["installFailures"]) > 0:
		status = "installation-failed"
	elif not all_ready:
		status = "blocked"
	return {
		"schemaVersion": SCHEMA_VERSION,
		"kind": REPORT_KIND,
		"campaignsDirectory": _portable_directory(normalized_root),
		"expectedCampaigns": expected_campaigns,
		"complete": complete,
		"allReady": all_ready,
		"status": status,
		"compressionEstimate": {
			"enabled": include_compressed_estimate,
			"method": "deflate-per-file" if include_compressed_estimate else "disabled",
		},
		"totals": totals.merged({
			"files": footprint_totals["files"],
			"installedBytes": footprint_totals["installedBytes"],
			"compressedEstimateBytes": footprint_totals["compressedEstimateBytes"],
			"jsonFiles": footprint_totals["extensions"].get(
				"json", {}
			).get("files", 0),
			"jsonBytes": footprint_totals["extensions"].get(
				"json", {}
			).get("installedBytes", 0),
			"sharedStoreFiles": shared_store_footprint["files"],
			"sharedStoreBytes": shared_store_footprint["installedBytes"],
			"duplicateBytes": duplication["duplicateBytes"],
			"crossCampaignDuplicateBytes": duplication[
				"crossCampaignDuplicateBytes"
			],
			"activeDiagnostics": diagnostic_breakdown["byActivity"].get(
				"active",
				0
			),
			"inactiveDiagnostics": diagnostic_breakdown["byActivity"].get(
				"inactive",
				0
			),
		}, true),
		"diagnosticBreakdown": diagnostic_breakdown,
		"categories": footprint_totals["categories"],
		"extensions": footprint_totals["extensions"],
		"sharedStore": {
			"directory": _portable_directory(shared_store_directory),
			"footprint": shared_store_footprint,
		},
		"duplication": duplication,
		"campaigns": campaigns,
	}


func _classic_campaign_names(campaigns_directory: String) -> Array[String]:
	var names: Array[String] = []
	var access := DirAccess.open(campaigns_directory)
	if access == null:
		return names
	access.list_dir_begin()
	var entry := access.get_next()
	while not entry.is_empty():
		if access.current_is_dir() and FileAccess.file_exists(
			campaigns_directory.path_join(entry).path_join("campaign.json")
		):
			names.append(entry)
		entry = access.get_next()
	access.list_dir_end()
	names.sort()
	return names


func _inspect_campaign_files(
	campaign_directory: String,
	campaign_name: String,
	include_compressed_estimate: bool,
	hash_index: Dictionary
) -> Dictionary:
	var footprint := _empty_footprint()
	var relative_paths: Array[String] = []
	_collect_relative_files(campaign_directory, "", relative_paths)
	relative_paths.sort()
	for relative_path: String in relative_paths:
		var path := campaign_directory.path_join(relative_path)
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			continue
		var bytes := file.get_buffer(file.get_length())
		file.close()
		var installed_bytes := bytes.size()
		var compressed_bytes := (
			bytes.compress(FileAccess.COMPRESSION_DEFLATE).size()
			if include_compressed_estimate
			else 0
		)
		var category := _category(relative_path)
		var extension := relative_path.get_extension().to_lower()
		if extension.is_empty():
			extension = "[none]"
		_add_footprint_row(
			footprint,
			category,
			extension,
			installed_bytes,
			compressed_bytes
		)
		var content_hash := FileAccess.get_sha256(path)
		var locations: Array = hash_index.get(content_hash, [])
		locations.append({
			"campaign": campaign_name,
			"path": relative_path.replace("\\", "/"),
			"category": category,
			"bytes": installed_bytes,
		})
		hash_index[content_hash] = locations
	return footprint


func _inspect_shared_store_files(
	store_directory: String,
	include_compressed_estimate: bool
) -> Dictionary:
	var footprint := _empty_footprint()
	var relative_paths: Array[String] = []
	_collect_relative_files(store_directory, "", relative_paths)
	relative_paths.sort()
	for relative_path: String in relative_paths:
		var path := store_directory.path_join(relative_path)
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			continue
		var bytes := file.get_buffer(file.get_length())
		file.close()
		var extension := relative_path.get_extension().to_lower()
		if extension.is_empty():
			extension = "[none]"
		_add_footprint_row(
			footprint,
			"shared-store",
			extension,
			bytes.size(),
			(
				bytes.compress(FileAccess.COMPRESSION_DEFLATE).size()
				if include_compressed_estimate
				else 0
			)
		)
	return footprint


func _collect_relative_files(
	root: String,
	relative_directory: String,
	destination: Array[String]
) -> void:
	var directory := root
	if not relative_directory.is_empty():
		directory = root.path_join(relative_directory)
	var access := DirAccess.open(directory)
	if access == null:
		return
	var directories: Array[String] = []
	var files: Array[String] = []
	access.list_dir_begin()
	var entry := access.get_next()
	while not entry.is_empty():
		if access.current_is_dir():
			directories.append(entry)
		elif entry != ".gdignore" and not entry.ends_with(".import"):
			files.append(entry)
		entry = access.get_next()
	access.list_dir_end()
	directories.sort()
	files.sort()
	for file_name: String in files:
		destination.append(
			file_name
			if relative_directory.is_empty()
			else relative_directory.path_join(file_name)
		)
	for directory_name: String in directories:
		var child_relative := (
			directory_name
			if relative_directory.is_empty()
			else relative_directory.path_join(directory_name)
		)
		_collect_relative_files(root, child_relative, destination)


func _build_duplication_report(hash_index: Dictionary) -> Dictionary:
	var groups: Array = []
	var duplicate_bytes := 0
	var cross_campaign_duplicate_bytes := 0
	var by_category: Dictionary = {}
	var hashes: Array = hash_index.keys()
	hashes.sort()
	for hash_value: Variant in hashes:
		var locations: Array = hash_index[hash_value]
		var campaigns: Dictionary = {}
		for location_value: Variant in locations:
			if location_value is Dictionary:
				campaigns[str(location_value.get("campaign", ""))] = true
		if campaigns.size() < 2:
			continue
		var installed_bytes := int(locations[0].get("bytes", 0))
		var group_duplicate_bytes := installed_bytes * (locations.size() - 1)
		var group_cross_campaign_bytes := installed_bytes * (campaigns.size() - 1)
		duplicate_bytes += group_duplicate_bytes
		cross_campaign_duplicate_bytes += group_cross_campaign_bytes
		var category := str(locations[0].get("category", "other"))
		for location_value: Variant in locations:
			if (
				location_value is Dictionary
				and str(location_value.get("category", "other")) != category
			):
				category = "mixed"
				break
		var category_row: Dictionary = by_category.get(category, {
			"groups": 0,
			"duplicateBytes": 0,
			"crossCampaignDuplicateBytes": 0,
		})
		category_row["groups"] += 1
		category_row["duplicateBytes"] += group_duplicate_bytes
		category_row["crossCampaignDuplicateBytes"] += group_cross_campaign_bytes
		by_category[category] = category_row
		var campaign_names: Array = campaigns.keys()
		campaign_names.sort()
		groups.append({
			"sha256": str(hash_value),
			"bytes": installed_bytes,
			"copies": locations.size(),
			"campaignCount": campaigns.size(),
			"duplicateBytes": group_duplicate_bytes,
			"crossCampaignDuplicateBytes": group_cross_campaign_bytes,
			"category": category,
			"campaigns": campaign_names,
			"locations": locations,
		})
	return {
		"groupCount": groups.size(),
		"duplicateBytes": duplicate_bytes,
		"crossCampaignDuplicateBytes": cross_campaign_duplicate_bytes,
		"byCategory": by_category,
		"groups": groups,
	}


static func _empty_footprint() -> Dictionary:
	return {
		"files": 0,
		"installedBytes": 0,
		"compressedEstimateBytes": 0,
		"categories": {},
		"extensions": {},
	}


static func _empty_diagnostic_breakdown() -> Dictionary:
	return {
		"byClassification": {},
		"byActivity": {},
		"byCode": {},
	}


static func _merge_readiness_diagnostics(
	destination: Dictionary,
	diagnostics: Variant
) -> void:
	if not (diagnostics is Array):
		return
	for diagnostic_value: Variant in diagnostics:
		if not (diagnostic_value is Dictionary):
			continue
		var classification := str(
			diagnostic_value.get("classification", "unclassified")
		)
		var activity := str(diagnostic_value.get("activity", "unspecified"))
		var code := str(diagnostic_value.get("code", "unknown"))
		var by_classification: Dictionary = destination["byClassification"]
		by_classification[classification] = int(
			by_classification.get(classification, 0)
		) + 1
		var by_activity: Dictionary = destination["byActivity"]
		by_activity[activity] = int(by_activity.get(activity, 0)) + 1
		var by_code: Dictionary = destination["byCode"]
		var code_row: Dictionary = by_code.get(code, {
			"diagnostics": 0,
			"active": 0,
			"inactive": 0,
			"progressionBlockers": 0,
			"fidelityFallbacks": 0,
		})
		code_row["diagnostics"] += 1
		if activity == "inactive":
			code_row["inactive"] += 1
		else:
			code_row["active"] += 1
		if classification == "progression-blocker":
			code_row["progressionBlockers"] += 1
		elif classification == "fidelity-fallback":
			code_row["fidelityFallbacks"] += 1
		by_code[code] = code_row


static func _add_footprint_row(
	footprint: Dictionary,
	category: String,
	extension: String,
	installed_bytes: int,
	compressed_bytes: int
) -> void:
	footprint["files"] += 1
	footprint["installedBytes"] += installed_bytes
	footprint["compressedEstimateBytes"] += compressed_bytes
	_add_summary_row(
		footprint["categories"],
		category,
		installed_bytes,
		compressed_bytes
	)
	_add_summary_row(
		footprint["extensions"],
		extension,
		installed_bytes,
		compressed_bytes
	)


static func _add_summary_row(
	destination: Dictionary,
	key: String,
	installed_bytes: int,
	compressed_bytes: int
) -> void:
	var row: Dictionary = destination.get(key, {
		"files": 0,
		"installedBytes": 0,
		"compressedEstimateBytes": 0,
	})
	row["files"] += 1
	row["installedBytes"] += installed_bytes
	row["compressedEstimateBytes"] += compressed_bytes
	destination[key] = row


static func _merge_footprint(destination: Dictionary, source: Dictionary) -> void:
	destination["files"] += int(source.get("files", 0))
	destination["installedBytes"] += int(source.get("installedBytes", 0))
	destination["compressedEstimateBytes"] += int(
		source.get("compressedEstimateBytes", 0)
	)
	for group_name: String in ["categories", "extensions"]:
		var source_group: Dictionary = source.get(group_name, {})
		var destination_group: Dictionary = destination[group_name]
		for key_value: Variant in source_group:
			var source_row: Dictionary = source_group[key_value]
			var key := str(key_value)
			var destination_row: Dictionary = destination_group.get(key, {
				"files": 0,
				"installedBytes": 0,
				"compressedEstimateBytes": 0,
			})
			destination_row["files"] += int(source_row.get("files", 0))
			destination_row["installedBytes"] += int(
				source_row.get("installedBytes", 0)
			)
			destination_row["compressedEstimateBytes"] += int(
				source_row.get("compressedEstimateBytes", 0)
			)
			destination_group[key] = destination_row


static func _category(relative_path: String) -> String:
	var normalized := relative_path.replace("\\", "/")
	if not normalized.contains("/"):
		return "root"
	return normalized.get_slice("/", 0).to_lower().replace(" ", "-")


static func _portable_directory(directory: String) -> String:
	if directory.begins_with("res://") or directory.begins_with("user://"):
		return directory
	return directory.get_file()


static func _normalized_directory(directory: String) -> String:
	return directory.strip_edges().replace("\\", "/").trim_suffix("/")
