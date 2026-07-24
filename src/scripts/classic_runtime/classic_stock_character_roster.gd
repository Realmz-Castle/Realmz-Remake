class_name ClassicStockCharacterRoster
extends RefCounted

const ROSTER_DIRECTORY := "Classic Character Roster"
const MANIFEST_FILE := "manifest.json"
const REQUIRED_CHARACTER_FILES := [
	"data.json",
	"class.gd",
	"race.gd",
	"icon.png",
	"portrait.png",
	"classic-source.json",
]


static func ensure_for_current_profile() -> Dictionary:
	var profile_directory := (
		Paths.profilesfolderpath
		.path_join(Paths.currentProfileFolderName)
		.path_join("Characters")
	)
	return ensure_roster(
		Paths.datafolderpath.path_join(ROSTER_DIRECTORY),
		profile_directory
	)


static func ensure_roster(
	template_root: String,
	profile_characters_directory: String
) -> Dictionary:
	var normalized_template_root := _normalize_path(template_root)
	var normalized_profile_directory := _normalize_path(
		profile_characters_directory
	)
	var manifest_result := _read_manifest(normalized_template_root)
	if str(manifest_result.get("status", "")) != "ok":
		return manifest_result
	var create_error := DirAccess.make_dir_recursive_absolute(
		normalized_profile_directory
	)
	if create_error != OK:
		return _error(
			"Could not create the profile character directory: %s"
			% error_string(create_error)
		)

	var manifest: Dictionary = manifest_result["manifest"]
	var character_specs: Variant = manifest.get("characters", [])
	if not (character_specs is Array):
		return _error("Classic stock-character manifest has no character list.")

	var created: Array[String] = []
	var existing: Array[String] = []
	var repaired: Array[String] = []
	for spec_value: Variant in character_specs:
		if not (spec_value is Dictionary):
			return _error("Classic stock-character manifest contains a malformed entry.")
		var spec: Dictionary = spec_value
		var character_name := str(spec_value.get("name", "")).strip_edges()
		if character_name.is_empty() or character_name in [".", ".."]:
			return _error("Classic stock-character manifest contains an invalid name.")
		var source_directory := (
			normalized_template_root
			.path_join("Characters")
			.path_join(character_name)
		)
		var destination_directory := normalized_profile_directory.path_join(
			character_name
		)
		if DirAccess.dir_exists_absolute(destination_directory):
			existing.append(character_name)
			var existing_repair := _identify_stock_inventory(
				destination_directory,
				spec,
			)
			if str(existing_repair.get("status", "")) != "ok":
				existing_repair["created"] = created
				existing_repair["existing"] = existing
				existing_repair["repaired"] = repaired
				return existing_repair
			if bool(existing_repair.get("changed", false)):
				repaired.append(character_name)
			continue
		var copy_result := _copy_character_atomically(
			source_directory,
			destination_directory
		)
		if str(copy_result.get("status", "")) != "ok":
			copy_result["created"] = created
			copy_result["existing"] = existing
			copy_result["repaired"] = repaired
			return copy_result
		var copied_repair := _identify_stock_inventory(
			destination_directory,
			spec,
		)
		if str(copied_repair.get("status", "")) != "ok":
			_remove_directory(destination_directory)
			copied_repair["created"] = created
			copied_repair["existing"] = existing
			copied_repair["repaired"] = repaired
			return copied_repair
		created.append(character_name)
		if bool(copied_repair.get("changed", false)):
			repaired.append(character_name)
	return {
		"status": "ok",
		"created": created,
		"existing": existing,
		"repaired": repaired,
		"total": character_specs.size(),
	}


static func _read_manifest(template_root: String) -> Dictionary:
	var manifest_path := template_root.path_join(MANIFEST_FILE)
	if not FileAccess.file_exists(manifest_path):
		return _error(
			"Classic stock-character manifest is missing at %s." % manifest_path
		)
	var parser := JSON.new()
	var parse_error := parser.parse(
		FileAccess.get_file_as_string(manifest_path)
	)
	if parse_error != OK or not (parser.data is Dictionary):
		return _error(
			"Classic stock-character manifest is invalid: %s"
			% parser.get_error_message()
		)
	if int(parser.data.get("schemaVersion", 0)) != 1:
		return _error("Classic stock-character manifest has an unsupported version.")
	return {"status": "ok", "manifest": parser.data}


static func _copy_character_atomically(
	source_directory: String,
	destination_directory: String
) -> Dictionary:
	if not DirAccess.dir_exists_absolute(source_directory):
		return _error(
			"Classic stock-character template is missing: %s"
			% source_directory
		)
	for file_name: String in REQUIRED_CHARACTER_FILES:
		if not FileAccess.file_exists(source_directory.path_join(file_name)):
			return _error(
				"Classic stock-character template %s is missing %s."
				% [source_directory.get_file(), file_name]
			)

	var temporary_directory := (
		destination_directory
		+ ".stock-import-%d" % Time.get_ticks_usec()
	)
	var create_error := DirAccess.make_dir_recursive_absolute(
		temporary_directory
	)
	if create_error != OK:
		return _error(
			"Could not stage Classic character %s: %s"
			% [destination_directory.get_file(), error_string(create_error)]
		)
	for file_name: String in REQUIRED_CHARACTER_FILES:
		var copy_error := _copy_file(
			source_directory.path_join(file_name),
			temporary_directory.path_join(file_name)
		)
		if copy_error != OK:
			_remove_directory(temporary_directory)
			return _error(
				"Could not copy Classic character %s: %s"
				% [destination_directory.get_file(), error_string(copy_error)]
			)
	var rename_error := DirAccess.rename_absolute(
		temporary_directory,
		destination_directory
	)
	if rename_error != OK:
		_remove_directory(temporary_directory)
		return _error(
			"Could not install Classic character %s: %s"
			% [destination_directory.get_file(), error_string(rename_error)]
		)
	return {"status": "ok"}


static func _identify_stock_inventory(
	character_directory: String,
	spec: Dictionary,
) -> Dictionary:
	var data_path := character_directory.path_join("data.json")
	if not FileAccess.file_exists(data_path):
		return {"status": "ok", "changed": false}
	var data_value: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(data_path)
	)
	if not (data_value is Dictionary):
		return {"status": "ok", "changed": false}
	var data: Dictionary = data_value
	var source_value: Variant = data.get("classicSourceCharacter", {})
	if not (source_value is Dictionary):
		return {"status": "ok", "changed": false}
	var expected_sha := str(spec.get("sourceSha256", ""))
	if expected_sha.is_empty() \
			or str(source_value.get("sourceSha256", "")) != expected_sha:
		return {"status": "ok", "changed": false}
	var inventory_value: Variant = data.get("inventory", [])
	if not (inventory_value is Array):
		return _error(
			"Classic stock character %s has a malformed inventory."
			% str(spec.get("name", character_directory.get_file()))
		)
	var source_items_value: Variant = spec.get("items", [])
	if not (source_items_value is Array):
		return _error(
			"Classic stock character %s has malformed source inventory."
			% str(spec.get("name", character_directory.get_file()))
		)
	var stock_prefix := "classic-stock:%s:item:" % str(
		spec.get("name", "")
	).uri_encode()
	var repair_legacy_inventory := _legacy_inventory_matches_source(
		inventory_value,
		source_items_value,
	)
	var changed := false
	for item_value: Variant in inventory_value:
		if not (item_value is Dictionary):
			return _error(
				"Classic stock character %s has a malformed inventory item."
				% str(spec.get("name", character_directory.get_file()))
			)
		var item: Dictionary = item_value
		var state_value: Variant = item.get("state")
		if state_value is Dictionary:
			var instance_id := str(item.get("instanceId", ""))
			if not instance_id.begins_with(stock_prefix):
				continue
			var source_index_text := instance_id.trim_prefix(stock_prefix)
			if not source_index_text.is_valid_int():
				continue
			var source_index := int(source_index_text)
			if source_index < 0 or source_index >= source_items_value.size():
				continue
			var source_item_value: Variant = source_items_value[source_index]
			if not (source_item_value is Dictionary) \
					or _classic_item_id(item) != int(
						source_item_value.get("id", 0)
					):
				continue
			var state: Dictionary = state_value
			if not bool(state.get("identified", false)):
				state["identified"] = true
				item["state"] = state
				changed = true
		elif repair_legacy_inventory \
				and int(
					item.get("is_identified", item.get("identified", 0))
				) != 1:
			item["is_identified"] = 1
			if item.has("identified"):
				item["identified"] = true
			changed = true
	if not changed:
		return {"status": "ok", "changed": false}
	var write_error := _write_json_atomically(data_path, data)
	if write_error != OK:
		return _error(
			"Could not update Classic stock character %s: %s"
			% [
				str(spec.get("name", character_directory.get_file())),
				error_string(write_error),
			]
		)
	return {"status": "ok", "changed": true}


static func _legacy_inventory_matches_source(
	inventory: Array,
	source_items: Array,
) -> bool:
	if inventory.size() != source_items.size():
		return false
	for item_index: int in range(inventory.size()):
		var item_value: Variant = inventory[item_index]
		var source_item_value: Variant = source_items[item_index]
		if not (item_value is Dictionary) \
				or not (source_item_value is Dictionary) \
				or item_value.get("state") is Dictionary \
				or _classic_item_id(item_value) != int(
					source_item_value.get("id", 0)
				):
			return false
	return true


static func _classic_item_id(item: Dictionary) -> int:
	if item.has("classicItemId"):
		return abs(int(item.get("classicItemId", 0)))
	var state_value: Variant = item.get("state", {})
	if state_value is Dictionary:
		var state_data_value: Variant = state_value.get("data", {})
		if state_data_value is Dictionary:
			var identity_value: Variant = state_data_value.get(
				"legacyDefinitionIdentity",
				{},
			)
			if identity_value is Dictionary:
				return abs(int(identity_value.get("classicItemId", 0)))
	return 0


static func _write_json_atomically(path: String, value: Dictionary) -> Error:
	var suffix := ".stock-update-%d" % Time.get_ticks_usec()
	var temporary_path := path + suffix
	var backup_path := path + suffix + ".backup"
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(value, "\t"))
	file.close()
	var backup_error := DirAccess.rename_absolute(path, backup_path)
	if backup_error != OK:
		DirAccess.remove_absolute(temporary_path)
		return backup_error
	var replace_error := DirAccess.rename_absolute(temporary_path, path)
	if replace_error != OK:
		DirAccess.rename_absolute(backup_path, path)
		DirAccess.remove_absolute(temporary_path)
		return replace_error
	DirAccess.remove_absolute(backup_path)
	return OK


static func _copy_file(source_path: String, destination_path: String) -> Error:
	var source := FileAccess.open(source_path, FileAccess.READ)
	if source == null:
		return FileAccess.get_open_error()
	var destination := FileAccess.open(destination_path, FileAccess.WRITE)
	if destination == null:
		var open_error := FileAccess.get_open_error()
		source.close()
		return open_error
	destination.store_buffer(source.get_buffer(source.get_length()))
	source.close()
	destination.close()
	return OK


static func _remove_directory(path: String) -> void:
	var directory := DirAccess.open(path)
	if directory == null:
		return
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		if entry not in [".", ".."]:
			var entry_path := path.path_join(entry)
			if directory.current_is_dir():
				_remove_directory(entry_path)
			else:
				DirAccess.remove_absolute(entry_path)
		entry = directory.get_next()
	directory.list_dir_end()
	DirAccess.remove_absolute(path)


static func _normalize_path(path: String) -> String:
	var stripped := path.strip_edges().replace("\\", "/").trim_suffix("/")
	if stripped.begins_with("res://") or stripped.begins_with("user://"):
		return stripped
	return ProjectSettings.globalize_path(stripped).replace("\\", "/")


static func _error(message: String) -> Dictionary:
	return {"status": "error", "message": message}
