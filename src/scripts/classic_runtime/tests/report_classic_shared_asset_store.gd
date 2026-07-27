extends SceneTree

const StoreScript = preload(
	"res://scripts/classic_runtime/classic_shared_asset_store.gd"
)

const SCHEMA_VERSION := 1
const REPORT_KIND := "classic-shared-asset-payload-and-render-fingerprints"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	for child: Node in root.get_children():
		child.process_mode = Node.PROCESS_MODE_DISABLED
	var arguments := OS.get_cmdline_user_args()
	var campaigns_directory := "res://Campaigns"
	var output_path := ""
	var baseline_path := ""
	for argument: String in arguments:
		if argument.begins_with("--output="):
			output_path = argument.trim_prefix("--output=")
		elif argument.begins_with("--baseline="):
			baseline_path = argument.trim_prefix("--baseline=")
		elif not argument.begins_with("--"):
			campaigns_directory = argument
	var report := _inspect(campaigns_directory)
	if str(report.get("status", "")) != "ok":
		push_error(str(report.get("error", "Shared asset audit failed")))
		quit(2)
		return
	var rendered := JSON.stringify(report, "  ", true) + "\n"
	if not output_path.is_empty():
		var output := FileAccess.open(output_path, FileAccess.WRITE)
		if output == null:
			push_error("Could not write shared asset audit: %s" % output_path)
			quit(2)
			return
		output.store_string(rendered)
		output.close()
	if not baseline_path.is_empty():
		var baseline_contents := FileAccess.get_file_as_string(baseline_path)
		var baseline_value: Variant = JSON.parse_string(baseline_contents)
		if not (baseline_value is Dictionary):
			push_error("Shared asset audit baseline is invalid: %s" % baseline_path)
			quit(2)
			return
		if baseline_contents != rendered:
			push_error("Shared asset payload or decoded-image fingerprints changed")
			quit(1)
			return
	print(rendered)
	quit(0)


func _inspect(campaigns_directory: String) -> Dictionary:
	var normalized_root := ProjectSettings.globalize_path(
		campaigns_directory
	).replace("\\", "/").trim_suffix("/")
	var campaign_names := _campaign_names(normalized_root)
	var entries: Array = []
	for campaign_name: String in campaign_names:
		var campaign_directory := normalized_root.path_join(campaign_name)
		var manifest_value: Variant = JSON.parse_string(
			FileAccess.get_file_as_string(
				campaign_directory.path_join("campaign.json")
			)
		)
		if not (manifest_value is Dictionary):
			return {
				"status": "error",
				"error": "%s has an invalid campaign.json" % campaign_name,
			}
		var store = StoreScript.new()
		if not store.load_for_campaign(campaign_directory, manifest_value):
			return {"status": "error", "error": store.last_error}
		var logical_paths: Dictionary = {}
		_collect_local_tileset_files(
			campaign_directory.path_join("Tilesets"),
			"Tilesets",
			logical_paths
		)
		for path_value: Variant in store.references:
			var logical_path := str(path_value)
			if logical_path.begins_with("Tilesets/"):
				logical_paths[logical_path] = true
		var sorted_paths: Array = logical_paths.keys()
		sorted_paths.sort()
		for path_value: Variant in sorted_paths:
			var logical_path := str(path_value)
			var physical_path := store.resolve(logical_path)
			if not FileAccess.file_exists(physical_path):
				return {
					"status": "error",
					"error": "%s is missing %s" % [campaign_name, logical_path],
				}
			var file := FileAccess.open(physical_path, FileAccess.READ)
			if file == null:
				return {
					"status": "error",
					"error": "%s cannot read %s" % [campaign_name, logical_path],
				}
			var row := {
				"campaign": campaign_name,
				"logicalPath": logical_path,
				"bytes": file.get_length(),
				"sha256": FileAccess.get_sha256(physical_path),
			}
			file.close()
			if logical_path.get_extension().to_lower() == "png":
				var image := Image.new()
				var image_error := image.load(physical_path)
				if image_error != OK:
					return {
						"status": "error",
						"error": "%s cannot decode %s" % [
							campaign_name,
							logical_path,
						],
					}
				var hash_context := HashingContext.new()
				hash_context.start(HashingContext.HASH_SHA256)
				hash_context.update(image.get_data())
				row["decodedImage"] = {
					"width": image.get_width(),
					"height": image.get_height(),
					"format": image.get_format(),
					"sha256": hash_context.finish().hex_encode(),
				}
			entries.append(row)
	return {
		"schemaVersion": SCHEMA_VERSION,
		"kind": REPORT_KIND,
		"status": "ok",
		"campaigns": campaign_names.size(),
		"files": entries.size(),
		"entries": entries,
	}


func _campaign_names(campaigns_directory: String) -> Array[String]:
	var names: Array[String] = []
	var access := DirAccess.open(campaigns_directory)
	if access == null:
		return names
	for entry: String in access.get_directories():
		if (
			entry.ends_with(" (Classic)")
			and FileAccess.file_exists(
				campaigns_directory.path_join(entry).path_join("campaign.json")
			)
		):
			names.append(entry)
	names.sort()
	return names


func _collect_local_tileset_files(
	directory: String,
	logical_directory: String,
	destination: Dictionary
) -> void:
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
		elif entry != ".gdignore":
			files.append(entry)
		entry = access.get_next()
	access.list_dir_end()
	directories.sort()
	files.sort()
	for file_name: String in files:
		destination[logical_directory.path_join(file_name)] = true
	for directory_name: String in directories:
		_collect_local_tileset_files(
			directory.path_join(directory_name),
			logical_directory.path_join(directory_name),
			destination
		)
