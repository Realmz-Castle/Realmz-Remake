class_name ItemInstance
extends RefCounted

var _instance_id := ""
var _definition_id := ""
var charges := 0
var equipped := false
var identified := true
var _state_data: Dictionary = {}

var instance_id: String:
	get:
		return _instance_id

var definition_id: String:
	get:
		return _definition_id


func _init(
	new_instance_id := "",
	new_definition_id := "",
	initial_charges := 0,
	initial_equipped := false,
	initial_identified := true,
	initial_state_data: Dictionary = {},
) -> void:
	_instance_id = new_instance_id
	_definition_id = new_definition_id
	charges = initial_charges
	equipped = initial_equipped
	identified = initial_identified
	_state_data = initial_state_data.duplicate(true)


func state_data() -> Dictionary:
	return _state_data.duplicate(true)


func state_value(field_name: String, fallback: Variant = null) -> Variant:
	var value: Variant = _state_data.get(field_name, fallback)
	if value is Dictionary or value is Array:
		return value.duplicate(true)
	return value


func set_state_value(field_name: String, value: Variant) -> bool:
	if not _is_json_compatible(value):
		return false
	_state_data[field_name] = value.duplicate(true) \
		if value is Dictionary or value is Array else value
	return true


func erase_state_value(field_name: String) -> void:
	_state_data.erase(field_name)


static func _is_json_compatible(value: Variant) -> bool:
	if value == null or value is bool or value is String or value is int or value is float:
		return true
	if value is Array:
		for child: Variant in value:
			if not _is_json_compatible(child):
				return false
		return true
	if value is Dictionary:
		for key: Variant in value:
			if not (key is String) or not _is_json_compatible(value[key]):
				return false
		return true
	return false
