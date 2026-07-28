class_name ScenarioPendingCommand
extends RefCounted

const SCHEMA_VERSION := 1

var handler_id := ""
var command_id := ""
var action_identity: Dictionary = {}
var continuation: Dictionary = {}


func _init(
	pending_handler_id := "",
	pending_command_id := "",
	pending_action_identity := {},
	pending_continuation := {}
) -> void:
	handler_id = str(pending_handler_id)
	command_id = str(pending_command_id)
	action_identity = (
		pending_action_identity.duplicate(true)
		if pending_action_identity is Dictionary else {}
	)
	continuation = (
		pending_continuation.duplicate(true)
		if pending_continuation is Dictionary else {}
	)


func to_dictionary() -> Dictionary:
	return {
		"schemaVersion": SCHEMA_VERSION,
		"handlerId": handler_id,
		"commandId": command_id,
		"actionIdentity": action_identity.duplicate(true),
		"continuation": continuation.duplicate(true),
	}


static func from_dictionary(value: Variant) -> ScenarioPendingCommand:
	var validation := validate(value)
	if not bool(validation.get("valid", false)):
		return null
	var record: Dictionary = value
	return ScenarioPendingCommand.new(
		record["handlerId"],
		record["commandId"],
		record["actionIdentity"],
		record["continuation"]
	)


static func validate(value: Variant) -> Dictionary:
	if not (value is Dictionary):
		return _invalid("Pending scenario command must be a dictionary")
	var record: Dictionary = value
	if int(record.get("schemaVersion", 0)) != SCHEMA_VERSION:
		return _invalid("Pending scenario command schema is not supported")
	for field_name: String in ["handlerId", "commandId"]:
		if not (record.get(field_name) is String) \
				or str(record.get(field_name)).strip_edges().is_empty():
			return _invalid("Pending scenario command is missing %s" % field_name)
	for field_name: String in ["actionIdentity", "continuation"]:
		if not (record.get(field_name) is Dictionary):
			return _invalid("Pending scenario command has invalid %s" % field_name)
	return {"valid": true}


static func _invalid(message: String) -> Dictionary:
	return {"valid": false, "message": message}
