class_name ClassicSpellResourceCatalog
extends RefCounted

static func merge_directory(directory: String, destination: Dictionary) -> void:
	# ResourceLoader preserves the original resource names when scripts are
	# remapped inside an exported PCK. DirAccess/FileAccess cannot reliably see
	# or read those compiled scripts.
	var file_names := _resource_file_names(directory)
	if file_names.is_empty():
		return
	var name_expression := _expression("(?m)^\\s*name\\s*=\\s*[\"']([^\"']+)[\"']")
	var class_expression := _expression("(?m)^\\s*classic_spell_class\\s*=\\s*(-?\\d+)")
	var ids_expression := _expression("(?m)^\\s*classic_spell_ids\\s*=\\s*\\[([^\\]]*)\\]")
	var save_index_expression := _expression(
		"(?m)^\\s*classic_spell_save_index\\s*=\\s*(-?\\d+)"
	)
	var save_mode_expression := _expression(
		"(?m)^\\s*classic_spell_save_mode\\s*=\\s*[\"']([^\"']+)[\"']"
	)
	var field_expression := _expression("(?m)^\\s*in_field\\s*=\\s*(true|false)")
	var combat_expression := _expression("(?m)^\\s*in_combat\\s*=\\s*(true|false)")

	for file_name: String in file_names:
		if file_name.ends_with("/") or not file_name.ends_with(".gd"):
			continue
		var path := directory.path_join(file_name)
		var source := FileAccess.get_file_as_string(path)
		var name_match := name_expression.search(source)
		if name_match != null:
			var metadata := {"resourcePath": path}
			var class_match := class_expression.search(source)
			if class_match != null:
				metadata["classicSpellClass"] = int(class_match.get_string(1))
			var ids_match := ids_expression.search(source)
			if ids_match != null:
				metadata["classicSpellIds"] = _integer_list(ids_match.get_string(1))
			var save_index_match := save_index_expression.search(source)
			if save_index_match != null:
				metadata["classicSpellSaveIndex"] = int(save_index_match.get_string(1))
			var save_mode_match := save_mode_expression.search(source)
			if save_mode_match != null:
				metadata["classicSpellSaveMode"] = save_mode_match.get_string(1)
			var field_match := field_expression.search(source)
			if field_match != null:
				metadata["inField"] = field_match.get_string(1) == "true"
			var combat_match := combat_expression.search(source)
			if combat_match != null:
				metadata["inCombat"] = combat_match.get_string(1) == "true"
			destination[name_match.get_string(1)] = metadata
			continue
		_merge_loaded_script(path, destination)


static func _resource_file_names(directory: String) -> Array[String]:
	var file_names: Array[String] = []
	if directory.begins_with("res://"):
		for resource_name: String in ResourceLoader.list_directory(directory):
			if not file_names.has(resource_name):
				file_names.append(resource_name)
	var access := DirAccess.open(directory)
	if access != null:
		access.list_dir_begin()
		var file_name := access.get_next()
		while not file_name.is_empty():
			if not access.current_is_dir() and not file_names.has(file_name):
				file_names.append(file_name)
			file_name = access.get_next()
		access.list_dir_end()
	file_names.sort()
	return file_names


static func _merge_loaded_script(path: String, destination: Dictionary) -> void:
	var script := ResourceLoader.load(path) as GDScript
	if script == null:
		return
	var instance: Variant = script.new()
	if not (instance is Object):
		return
	var spell_name := str(instance.get("name")).strip_edges()
	if spell_name.is_empty():
		return
	var metadata := {
		"resourcePath": path,
		"classicSpellClass": int(instance.get("classic_spell_class")),
		"classicSpellSaveIndex": int(instance.get("classic_spell_save_index")),
		"classicSpellSaveMode": str(instance.get("classic_spell_save_mode")),
		"inField": bool(instance.get("in_field")),
		"inCombat": bool(instance.get("in_combat")),
	}
	var spell_ids: Array[int] = []
	var instance_spell_ids: Variant = instance.get("classic_spell_ids")
	if not (instance_spell_ids is Array):
		instance_spell_ids = []
	for id_value: Variant in instance_spell_ids:
		var spell_id: int = abs(int(id_value))
		if spell_id > 0 and not spell_ids.has(spell_id):
			spell_ids.append(spell_id)
	if not spell_ids.is_empty():
		metadata["classicSpellIds"] = spell_ids
	destination[spell_name] = metadata


static func _expression(pattern: String) -> RegEx:
	var expression := RegEx.new()
	expression.compile(pattern)
	return expression


static func _integer_list(source: String) -> Array[int]:
	var values: Array[int] = []
	for value_text: String in source.split(","):
		var trimmed_value := value_text.strip_edges()
		if trimmed_value.is_valid_int():
			values.append(int(trimmed_value))
	return values
