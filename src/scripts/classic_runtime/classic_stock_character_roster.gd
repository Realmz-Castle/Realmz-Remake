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
	for spec_value: Variant in character_specs:
		if not (spec_value is Dictionary):
			return _error("Classic stock-character manifest contains a malformed entry.")
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
			continue
		var copy_result := _copy_character_atomically(
			source_directory,
			destination_directory
		)
		if str(copy_result.get("status", "")) != "ok":
			copy_result["created"] = created
			copy_result["existing"] = existing
			return copy_result
		created.append(character_name)
	return {
		"status": "ok",
		"created": created,
		"existing": existing,
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
