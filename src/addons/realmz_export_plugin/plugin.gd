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
	var _export_path: String
	var _export_base_dir: String

	func _export_begin(features: PackedStringArray, is_debug: bool, path: String, flags: int) -> void:
		var base_dir = path.get_base_dir()
		var	icons_path = ProjectSettings.globalize_path("res://application_icons")

		# Store export info for later use
		_export_path = path
		_export_base_dir = base_dir

		print("Export begin - Path: " + path)
		print("Export begin - Base dir: " + base_dir)
		print("Export begin - Features: " + str(features))
		print("Export begin - Debug: " + str(is_debug))

		if OS.get_name() == "macOS":
			var dir = DirAccess.open(base_dir)
			dir.make_dir("Realmz-Remake")
			_copy_file("res://INSTALL.txt", base_dir + "/INSTALL.txt")
			base_dir = base_dir + "/Realmz-Remake"

			#Set the folder icon

			var folder_path = ProjectSettings.globalize_path(base_dir)
			_set_folder_icon_mac(base_dir, icons_path.path_join("RealmzIcon.png"))

		if OS.get_name() == "Linux":
			_export_dir(base_dir, "application_icons", "icons")

		_export_dir(base_dir, "Data")
		_export_dir(base_dir, "Campaigns")
		_export_dir(base_dir, "ClassicAssets")
		_export_dir(base_dir, "Profiles")

		if OS.get_name() == "macOS":
			_set_folder_icon_mac(base_dir.path_join("Data"), icons_path.path_join("DataIcon.png"))
			_set_folder_icon_mac(base_dir.path_join("Data").path_join("Music"), icons_path.path_join("Music.png"))
			_set_folder_icon_mac(base_dir.path_join("Data").path_join("Character Icons"), icons_path.path_join("Tacticals.png"))
			_set_folder_icon_mac(base_dir.path_join("Data").path_join("Character Portraits"), icons_path.path_join("Portraits.png"))
			_set_folder_icon_mac(base_dir.path_join("Campaigns"), icons_path.path_join("Campaigns.png"))
			_set_folder_icon_mac(base_dir.path_join("Campaigns").path_join("City Of Bywater"), icons_path.path_join("City Of Bywater.png"))
			_set_folder_icon_mac(base_dir.path_join("Profiles"), icons_path.path_join("Characters.png"))
			_set_folder_icon_mac(base_dir.path_join("Profiles").path_join("Default Profile"), icons_path.path_join("Characters.png"))
			_set_folder_icon_mac(base_dir.path_join("Profiles").path_join("Default Profile").path_join("Saves"), icons_path.path_join("Saves.png"))
			_set_folder_icon_mac(base_dir.path_join("Profiles").path_join("Default Profile").path_join("Characters"), icons_path.path_join("Characters.png"))
			_set_folder_icon_mac(path.get_base_dir().path_join("INSTALL.txt"), icons_path.path_join("Document.png"))

	func _export_dir(export_root: String, source_dir_name: String, dest_dir_name: String = ""):
		var src_dir_path = ProjectSettings.globalize_path("res://" + source_dir_name)
		var export_path = export_root
		if export_path.is_relative_path():
			export_path = ProjectSettings.globalize_path("res://" + export_root)
		var dest_dir_path = export_path + "/" + (dest_dir_name if dest_dir_name else source_dir_name)
		print_verbose("Starting export of data files from '" + src_dir_path + "' to '" + dest_dir_path + "'")

		var src_dir = DirAccess.open(src_dir_path)
		if not src_dir:
			push_error("Could not open source directory: " + src_dir_path)
			return

		if not _try_create_dir(export_path, dest_dir_path):
			push_error("Could not create subdirectory: " + dest_dir_path)
			return

		_copy_directory(src_dir_path, dest_dir_path)

	func _copy_file(src: String, dest: String) -> void:
		var src_file = FileAccess.open(src, FileAccess.READ)
		if src_file:
			var dest_file = FileAccess.open(dest, FileAccess.WRITE)
			if dest_file:
				dest_file.store_buffer(src_file.get_buffer(src_file.get_length()))
				dest_file.close()
				print_verbose("Exporting file: " + dest)
			else:
				push_error("Failed to write file: " + dest + " - Reason: " + get_error_description(FileAccess.get_open_error()))
			src_file.close()
		else:
			push_error("Could not copy file: " + src)

	func _copy_directory(src: String, dest: String) -> void:
		var dir = DirAccess.open(src)

		if dir:
			dir.list_dir_begin()

			var file_name = dir.get_next()
			while file_name != "":
				if (
					file_name == "."
					or file_name == ".."
					or file_name == ".gdignore"
					or file_name.ends_with(".import")
				):
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
					_copy_file(src_file_path, dest_file_path)

				file_name = dir.get_next()

			dir.list_dir_end()
		else:
			push_error("Could not open directory: " + src)

	func _try_create_dir(parent_path: String, new_dir_path: String) -> bool:
		if DirAccess.dir_exists_absolute(new_dir_path):
			return true
		var error = DirAccess.make_dir_recursive_absolute(new_dir_path)
		if error != OK:
			push_error(
				"Could not create destination directory under %s: %s"
				% [parent_path, new_dir_path]
			)
			return false
		print_verbose("Created directory at " + new_dir_path)
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

	func _set_folder_icon_mac(folder_path: String, icns_path: String) -> void:
		if OS.get_name() != "macOS":
			return

		# Check if fileicon is installed
		var output = []
		var exit_code = OS.execute("which", ["fileicon"], output)

		if exit_code != 0:
			push_error("fileicon not found. Please install it via 'brew install fileicon'")
			return

		# Set the icon using fileicon
		var result = []
		exit_code = OS.execute("fileicon", ["set", folder_path, icns_path], result)

		if exit_code != 0:
			push_error("Failed to set icon: " + str(result))
		else:
			print("Successfully set icon for: " + folder_path)
