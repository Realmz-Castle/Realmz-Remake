class_name ClassicSpellResourceCatalog
extends RefCounted

static func merge_directory(directory: String, destination: Dictionary) -> void:
	var access := DirAccess.open(directory)
	if access == null:
		return
	# Resource metadata is enough for audit and avoids instantiating spell scripts.
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

	access.list_dir_begin()
	var file_name := access.get_next()
	while not file_name.is_empty():
		if not access.current_is_dir() and file_name.ends_with(".gd"):
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
		file_name = access.get_next()
	access.list_dir_end()


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
