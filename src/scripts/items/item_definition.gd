class_name ItemDefinition
extends RefCounted

var _data: Dictionary = {}

var definition_id: String:
	get:
		return str(_data.get("definitionId", ""))

var catalog_key: String:
	get:
		return str(_data.get("catalogKey", ""))

var display_name: String:
	get:
		return str(_data.get("name", ""))

var unidentified_name: String:
	get:
		return str(_data.get("unidentifiedName", ""))

var description: String:
	get:
		return str(_data.get("description", ""))

var item_type: String:
	get:
		return str(_data.get("type", ""))

var image_key: String:
	get:
		return str(_data.get("imageKey", ""))

var sound_key: String:
	get:
		return str(_data.get("soundKey", ""))

var source_scope: String:
	get:
		return str(_data.get("source", {}).get("scope", ""))

var campaign_id: String:
	get:
		return str(_data.get("source", {}).get("campaignId", ""))

var default_identified: bool:
	get:
		return bool(_data.get("defaultIdentified", true))


func _init(normalized_data: Dictionary = {}) -> void:
	_data = normalized_data.duplicate(true)


func to_dictionary() -> Dictionary:
	return _data.duplicate(true)


func source() -> Dictionary:
	return _data.get("source", {}).duplicate(true)


func gameplay() -> Dictionary:
	return _data.get("gameplay", {}).duplicate(true)


func gameplay_value(field_name: String, fallback: Variant = null) -> Variant:
	var value: Variant = _data.get("gameplay", {}).get(field_name, fallback)
	if value is Dictionary or value is Array:
		return value.duplicate(true)
	return value


func hooks() -> Dictionary:
	return _data.get("hooks", {}).duplicate(true)


func classic() -> Dictionary:
	return _data.get("classic", {}).duplicate(true)


func classic_item_ids() -> Array[int]:
	var result: Array[int] = []
	for value: Variant in _data.get("classic", {}).get("itemIds", []):
		result.append(int(value))
	return result
