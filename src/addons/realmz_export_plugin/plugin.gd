@tool
extends EditorPlugin

var export_plugin : RealmzExportPlugin

func _enter_tree():
	export_plugin = RealmzExportPlugin.new()
	add_export_plugin(export_plugin)

func _exit_tree():
	remove_export_plugin(export_plugin)
	export_plugin = null

class RealmzExportPlugin extends EditorExportPlugin:
	var _plugin_name = "RealmzExportPlugin"

	func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
		_export_dir(path.get_base_dir(), "Data")
		_export_dir(path.get_base_dir(), "Campaigns")

	func _export_dir(export_root: String, source_dir_name: String):
		var src_dir_path = ProjectSettings.globalize_path("res://" + source_dir_name)
		var export_path = ProjectSettings.globalize_path("res://" + export_root)
		var dest_dir_path = export_path + "/" + source_dir_name
		print_verbose("Starting export of data files from '" + src_dir_path + "' to '" + dest_dir_path + "'")

		var src_dir = DirAccess.open(src_dir_path)
		if not src_dir:
			push_error("Could not open source directory: " + src_dir_path)
			return

		if not _try_create_dir(export_path, dest_dir_path):
			push_error("Could not create subdirectory: " + dest_dir_path)
			return

		_copy_directory(src_dir_path, dest_dir_path)

	func _copy_directory(src: String, dest: String) -> void:
		var dir = DirAccess.open(src)

		if dir:
			dir.list_dir_begin()

			var file_name = dir.get_next()
			while file_name != "":
				if file_name == "." or file_name == ".." or file_name == ".gdignore":
					file_name = dir.get_next()
					continue

				var src_file_path = src + "/" + file_name
				var dest_file_path = dest + "/" + file_name

				if dir.current_is_dir():
					if not _try_create_dir(dest, dest_file_path):
						push_error("Could not create subdirectory: " + dest_file_path)
						return

					_copy_directory(src_file_path, dest_file_path)
				else:
					var src_file = FileAccess.open(src_file_path, FileAccess.READ)
					if src_file:
						var dest_file = FileAccess.open(dest_file_path, FileAccess.WRITE)
						if dest_file:
							dest_file.store_buffer(src_file.get_buffer(src_file.get_length()))
							dest_file.close()
							print_verbose("Exporting file: " + dest_file_path)
						else:
							push_error("Failed to write file: " + dest_file_path + " - Reason: " + get_error_description(FileAccess.get_open_error()))
						src_file.close()
					else:
						push_error("Could not copy file: " + src_file_path)

				file_name = dir.get_next()

			dir.list_dir_end()
		else:
			push_error("Could not open directory: " + src)

	func _try_create_dir(parent_path: String, new_dir_path: String) -> bool:
		var subdir = DirAccess.open(new_dir_path)
		if not subdir:
			var dest_dir = DirAccess.open(parent_path)
			if dest_dir:
				if dest_dir.make_dir(new_dir_path) != OK:
					push_error("Could not create destination directory: " + new_dir_path)
					return false
				else:
					print_verbose("Created directory at " + new_dir_path)
			else:
				push_error("Could not open destination directory: " + parent_path)
				return false
		return true

	func _get_name():
		return _plugin_name

	func get_error_description(error_code: int) -> String:
		match error_code:
			ERR_FILE_NOT_FOUND:
				return "File not found"
			ERR_FILE_CANT_OPEN:
				return "Cannot open file"
			ERR_FILE_CANT_WRITE:
				return "Cannot write to file"
			ERR_FILE_CANT_READ:
				return "Cannot read from file"
			ERR_CANT_CREATE:
				return "Cannot create file"
			ERR_UNAUTHORIZED:
				return "Unauthorized access"
			_:
				return "Unknown error code (" + str(error_code) + ")"
