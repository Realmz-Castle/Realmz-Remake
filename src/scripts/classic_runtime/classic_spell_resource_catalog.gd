class_name ClassicSpellResourceCatalog
extends RefCounted

const CORE_SPELL_INVENTORY_PATH := (
	"res://scripts/classic_runtime/classic_core_spell_inventory.json"
)

static var _core_save_metadata_by_id: Dictionary = {}
static var _core_save_metadata_loaded := false


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
	var use_core_save_metadata := (
		directory.replace("\\", "/").trim_suffix("/") == "res://shared_assets/spells"
	)

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
			if use_core_save_metadata:
				_merge_core_save_metadata(metadata)
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


static func _merge_core_save_metadata(metadata: Dictionary) -> void:
	if metadata.has("classicSpellSaveIndex") \
			and metadata.has("classicSpellSaveMode"):
		return
	var spell_ids: Variant = metadata.get("classicSpellIds", [])
	if not (spell_ids is Array) or spell_ids.is_empty():
		return
	var common_metadata: Dictionary = {}
	for spell_id_value: Variant in spell_ids:
		var save_metadata := _core_save_metadata(absi(int(spell_id_value)))
		if save_metadata.is_empty():
			return
		if common_metadata.is_empty():
			common_metadata = save_metadata
		elif common_metadata != save_metadata:
			return
	if not metadata.has("classicSpellSaveIndex"):
		metadata["classicSpellSaveIndex"] = common_metadata["index"]
	if not metadata.has("classicSpellSaveMode"):
		metadata["classicSpellSaveMode"] = common_metadata["mode"]


static func _core_save_metadata(spell_id: int) -> Dictionary:
	if not _core_save_metadata_loaded:
		_load_core_save_metadata()
	return _core_save_metadata_by_id.get(spell_id, {})


static func _load_core_save_metadata() -> void:
	_core_save_metadata_loaded = true
	var document: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(CORE_SPELL_INVENTORY_PATH)
	)
	if not (document is Dictionary):
		return
	var spell_values: Variant = document.get("spells", [])
	if not (spell_values is Array):
		return
	for spell_value: Variant in spell_values:
		if not (spell_value is Dictionary):
			continue
		var record: Variant = spell_value.get("record", {})
		if not (record is Dictionary):
			continue
		var damage_type := absi(int(record.get("damageType", 0)))
		var save_index := damage_type \
			if damage_type in range(1, 8) and int(record.get("cannot", 0)) <= 1 \
			else -1
		var save_mode := "none"
		if save_index >= 0:
			save_mode = "negate"
			for field_name: String in [
				"damage1", "damage2", "powerDamage1", "powerDamage2",
			]:
				if int(record.get(field_name, 0)) != 0:
					save_mode = "half_damage"
					break
		_core_save_metadata_by_id[int(spell_value.get("packedSpellId", 0))] = {
			"index": save_index,
			"mode": save_mode,
		}


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
