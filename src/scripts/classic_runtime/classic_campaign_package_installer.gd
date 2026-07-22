class_name ClassicCampaignPackageInstaller
extends RefCounted

const CampaignInstallScript = preload(
	"res://scripts/classic_runtime/classic_campaign_install.gd"
)
const MapMaterializerScript = preload(
	"res://scripts/classic_runtime/classic_map_materializer.gd"
)
const ItemMaterializerScript = preload(
	"res://scripts/classic_runtime/classic_item_materializer.gd"
)
const BestiaryMaterializerScript = preload(
	"res://scripts/classic_runtime/classic_bestiary_materializer.gd"
)

var last_error := ""


func install_export(
	export_directory: String,
	campaigns_directory: String,
	replace_existing := false
) -> Dictionary:
	last_error = ""
	var source := _absolute_directory(export_directory)
	var campaigns_root := _absolute_directory(campaigns_directory)
	if source.is_empty() or not DirAccess.dir_exists_absolute(source):
		return _fail("Classic campaign export directory does not exist")
	if campaigns_root.is_empty():
		return _fail("Campaigns directory is unavailable")

	var campaign_name := source.get_file()
	if not CampaignInstallScript.is_safe_campaign_name(campaign_name):
		return _fail("Classic campaign export must use one safe directory name")
	var destination := campaigns_root.path_join(campaign_name)
	if source.to_lower() == destination.to_lower():
		return _fail("Classic campaign export is already in the Campaigns directory")

	var source_check := _load_compiled_package(source)
	if not bool(source_check.get("valid", false)):
		return _fail(str(source_check.get("error", "Classic campaign export is invalid")))
	var destination_exists := DirAccess.dir_exists_absolute(destination)
	if destination_exists and not replace_existing:
		return _fail(
			"Campaign is already installed; pass --replace to update it: %s" % campaign_name
		)
	if destination_exists:
		var existing_identity := _read_campaign_identity(destination)
		if not bool(existing_identity.get("valid", false)):
			return _fail(str(existing_identity.get("error", "Installed campaign identity is invalid")))
		if str(existing_identity.get("campaignId", "")) != str(source_check.get("campaignId", "")):
			return _fail("Package update cannot change the installed campaign ID")

	var make_root_error := DirAccess.make_dir_recursive_absolute(campaigns_root)
	if make_root_error != OK:
		return _fail("Could not create Campaigns directory: %s" % error_string(make_root_error))

	var stamp := "%d-%d-%d" % [
		Time.get_unix_time_from_system(),
		OS.get_process_id(),
		Time.get_ticks_msec(),
	]
	var staging_name := ".realmz-install-%s-%s" % [campaign_name, stamp]
	var backup_name := ".realmz-backup-%s-%s" % [campaign_name, stamp]
	var staging_directory := campaigns_root.path_join(staging_name)
	var backup_directory := campaigns_root.path_join(backup_name)
	var copy_error := _copy_directory(source, staging_directory)
	if copy_error != OK:
		_remove_directory(staging_directory)
		return _fail("Could not stage Classic campaign: %s" % error_string(copy_error))

	var staged_source_check := _load_compiled_package(staging_directory)
	if not bool(staged_source_check.get("valid", false)):
		_remove_directory(staging_directory)
		return _fail(
			"Staged Classic campaign failed validation: %s" % staged_source_check.get(
				"error", ""
			)
		)
	var materializer = MapMaterializerScript.new()
	var materialize_result: Dictionary = materializer.materialize(
		staged_source_check["bundle"],
		staging_directory
	)
	if str(materialize_result.get("status", "")) != "ok":
		_remove_directory(staging_directory)
		return _fail(
			"Staged Classic maps could not be generated: %s" % materializer.last_error
		)
	var item_materializer = ItemMaterializerScript.new()
	var item_result: Dictionary = item_materializer.materialize(
		staged_source_check["bundle"],
		staging_directory
	)
	if str(item_result.get("status", "")) != "ok":
		_remove_directory(staging_directory)
		return _fail(
			"Staged Classic items could not be generated: %s" % item_materializer.last_error
		)
	var bestiary_materializer = BestiaryMaterializerScript.new()
	var bestiary_result: Dictionary = bestiary_materializer.materialize(
		staged_source_check["bundle"],
		staging_directory
	)
	if str(bestiary_result.get("status", "")) != "ok":
		_remove_directory(staging_directory)
		return _fail(
			"Staged Classic bestiary could not be generated: %s" \
				% bestiary_materializer.last_error
		)

	var staged_check := _load_launchable_package(staging_directory)
	if not bool(staged_check.get("valid", false)):
		_remove_directory(staging_directory)
		var failed_install := _fail(
			"Staged Classic campaign failed validation: %s" % staged_check.get("error", "")
		)
		failed_install["readinessReport"] = staged_check.get("readinessReport", {}).duplicate(true)
		return failed_install

	var replaced_existing := DirAccess.dir_exists_absolute(destination)
	if replaced_existing:
		var backup_error := DirAccess.rename_absolute(destination, backup_directory)
		if backup_error != OK:
			_remove_directory(staging_directory)
			return _fail("Could not preserve installed campaign: %s" % error_string(backup_error))

	var install_error := DirAccess.rename_absolute(staging_directory, destination)
	if install_error != OK:
		var restore_message := ""
		if replaced_existing:
			var restore_error := DirAccess.rename_absolute(backup_directory, destination)
			if restore_error != OK:
				restore_message = "; previous campaign remains at %s" % backup_directory
		_remove_directory(staging_directory)
		return _fail(
			"Could not install Classic campaign: %s%s" % [
				error_string(install_error),
				restore_message,
			]
		)

	var installed_check := _load_launchable_package(destination)
	if not bool(installed_check.get("valid", false)):
		var rollback_message := _rollback_install(destination, backup_directory, replaced_existing)
		return _fail(
			"Installed Classic campaign failed validation: %s%s" % [
				installed_check.get("error", ""),
				rollback_message,
			]
		)

	var warnings: Array[String] = []
	if replaced_existing:
		var cleanup_error := _remove_directory(backup_directory)
		if cleanup_error != OK:
			warnings.append(
				"The previous campaign remains at %s" % backup_directory
			)

	var rules: Dictionary = installed_check.get("rules", {})
	return {
		"status": "ok",
		"campaignName": campaign_name,
		"campaignId": installed_check.get("campaignId", ""),
		"installedDirectory": destination,
		"replacedExisting": replaced_existing,
		"readinessState": rules.get("readinessState", "Ready"),
		"readinessSummary": rules.get("readinessSummary", ""),
		"warnings": warnings,
	}


func _load_launchable_package(directory: String) -> Dictionary:
	var install = CampaignInstallScript.new()
	if not install.load_from_campaigns_directory(directory.get_base_dir(), directory.get_file()):
		return {"valid": false, "error": install.last_error}
	var rules: Dictionary = install.selection_rules()
	if not bool(rules.get("valid", false)):
		return {
			"valid": false,
			"error": str(rules.get("diagnostic", "Campaign is not ready to launch")),
			"readinessReport": install.readiness_report.duplicate(true),
		}
	return {
		"valid": true,
		"campaignId": str(install.bundle.manifest.get("id", "")),
		"rules": rules,
	}


func _load_compiled_package(directory: String) -> Dictionary:
	var install = CampaignInstallScript.new()
	if not install.load_from_campaigns_directory(directory.get_base_dir(), directory.get_file()):
		return {"valid": false, "error": install.last_error}
	return {
		"valid": true,
		"campaignId": str(install.bundle.manifest.get("id", "")),
		"bundle": install.bundle,
	}


func _read_campaign_identity(directory: String) -> Dictionary:
	var manifest_path := directory.path_join("campaign.json")
	if not FileAccess.file_exists(manifest_path):
		return {"valid": false, "error": "Installed campaign is missing campaign.json"}
	var manifest_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	if not (manifest_value is Dictionary):
		return {"valid": false, "error": "Installed campaign.json is not a JSON object"}
	var campaign_id := str(manifest_value.get("id", "")).strip_edges()
	if campaign_id.is_empty():
		return {"valid": false, "error": "Installed campaign.json is missing its id"}
	return {"valid": true, "campaignId": campaign_id}


func _rollback_install(destination: String, backup: String, had_previous: bool) -> String:
	var remove_error := _remove_directory(destination)
	if remove_error != OK:
		if had_previous:
			return (
				"; rollback could not remove the rejected package, " +
				"previous campaign remains at %s" % backup
			)
		return "; rollback could not remove the rejected package at %s" % destination
	if not had_previous:
		return ""
	var restore_error := DirAccess.rename_absolute(backup, destination)
	if restore_error != OK:
		return "; previous campaign remains at %s" % backup
	return ""


func _copy_directory(source: String, destination: String) -> Error:
	var make_error := DirAccess.make_dir_recursive_absolute(destination)
	if make_error != OK:
		return make_error
	var directory := DirAccess.open(source)
	if directory == null:
		return DirAccess.get_open_error()
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		var source_path := source.path_join(entry)
		var destination_path := destination.path_join(entry)
		if directory.is_link(entry):
			directory.list_dir_end()
			return ERR_INVALID_DATA
		var copy_error := OK
		if directory.current_is_dir():
			copy_error = _copy_directory(source_path, destination_path)
		else:
			copy_error = DirAccess.copy_absolute(source_path, destination_path)
		if copy_error != OK:
			directory.list_dir_end()
			return copy_error
		entry = directory.get_next()
	directory.list_dir_end()
	return OK


func _remove_directory(directory_path: String) -> Error:
	if not DirAccess.dir_exists_absolute(directory_path):
		return OK
	var directory := DirAccess.open(directory_path)
	if directory == null:
		return DirAccess.get_open_error()
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		var entry_path := directory_path.path_join(entry)
		var remove_error := OK
		if directory.current_is_dir() and not directory.is_link(entry):
			remove_error = _remove_directory(entry_path)
		else:
			remove_error = DirAccess.remove_absolute(entry_path)
		if remove_error != OK:
			directory.list_dir_end()
			return remove_error
		entry = directory.get_next()
	directory.list_dir_end()
	return DirAccess.remove_absolute(directory_path)


func _absolute_directory(path: String) -> String:
	var stripped := path.strip_edges()
	if stripped.is_empty():
		return ""
	return (
		ProjectSettings.globalize_path(stripped)
		.replace("\\", "/")
		.simplify_path()
		.trim_suffix("/")
	)


func _fail(message: String) -> Dictionary:
	last_error = message
	return {"status": "error", "message": message}
