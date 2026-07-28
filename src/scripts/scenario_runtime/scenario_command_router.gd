class_name ScenarioCommandRouter
extends RefCounted

const CORE_COMMAND_PREFIX := "core."

var _ports_by_id: Dictionary = {}
var _ports_by_command: Dictionary = {}
var last_error := ""


func register_port(port: ScenarioCommandPort) -> bool:
	last_error = ""
	if port == null:
		return _fail("Cannot register a null scenario command port")
	var id := port.port_id().strip_edges()
	if id.is_empty():
		return _fail("Scenario command ports require a stable ID")
	if _ports_by_id.has(id):
		return _fail("Duplicate scenario command port ID '%s'" % id)
	var seen_local: Dictionary = {}
	var requests := port.request_contracts()
	var responses := port.response_contracts()
	for command: String in port.owned_command_ids():
		var command_id := command.strip_edges()
		if command_id.is_empty():
			return _fail("Scenario command port '%s' declares an empty command ID" % id)
		if seen_local.has(command_id):
			return _fail(
				"Scenario command port '%s' declares '%s' more than once" % [id, command_id]
			)
		if _ports_by_command.has(command_id):
			return _fail(
				"Scenario command '%s' is already owned by port '%s'" % [
					command_id,
					_ports_by_command[command_id].port_id(),
				]
			)
		if not (requests.get(command_id) is Dictionary):
			return _fail(
				"Scenario port '%s' has no request contract for '%s'" % [id, command_id]
			)
		if not (responses.get(command_id) is Dictionary):
			return _fail(
				"Scenario port '%s' has no response contract for '%s'" % [id, command_id]
			)
		seen_local[command_id] = true
	_ports_by_id[id] = port
	for command: String in port.owned_command_ids():
		_ports_by_command[command] = port
	return true


func configure(services: Dictionary) -> void:
	for port: ScenarioCommandPort in _ports_by_id.values():
		port.configure(services)


func route(command_id: String, request: Dictionary) -> Dictionary:
	var port: ScenarioCommandPort = _ports_by_command.get(command_id)
	if port == null:
		return {
			"status": "error",
			"message": "No scenario port owns command '%s'" % command_id,
		}
	var request_error := _contract_error(
		request,
		port.request_contracts().get(command_id, {}),
		"request"
	)
	if not request_error.is_empty():
		return {
			"status": "error",
			"message": "Scenario command '%s' %s" % [command_id, request_error],
		}
	var response: Variant = await port.execute(command_id, request)
	if not (response is Dictionary):
		return {
			"status": "error",
			"message": "Scenario port '%s' returned an invalid response" % port.port_id(),
		}
	var response_error := _contract_error(
		response,
		port.response_contracts().get(command_id, {}),
		"response"
	)
	if not response_error.is_empty():
		return {
			"status": "error",
			"message": "Scenario command '%s' %s" % [command_id, response_error],
		}
	return response


func port_for_command(command_id: String) -> ScenarioCommandPort:
	return _ports_by_command.get(command_id)


func port_by_id(id: String) -> ScenarioCommandPort:
	return _ports_by_id.get(id)


func snapshot_state() -> Dictionary:
	var result: Dictionary = {}
	for id: String in _ports_by_id:
		var port: ScenarioCommandPort = _ports_by_id[id]
		if str(port.save_policy().get("state", "none")) != "none":
			result[id] = port.snapshot_state()
	return result


func restore_state(state: Dictionary) -> Dictionary:
	for id: String in state:
		var port: ScenarioCommandPort = _ports_by_id.get(id)
		if port == null:
			return {
				"status": "error",
				"message": "Saved scenario port '%s' is unavailable" % id,
			}
		var result := port.restore_state(state[id])
		if str(result.get("status", "")) != "ok":
			return result
	return {"status": "ok"}


func _fail(message: String) -> bool:
	last_error = message
	return false


func _contract_error(value: Variant, contract_value: Variant, label: String) -> String:
	if not (contract_value is Dictionary):
		return "%s contract is invalid" % label
	var contract: Dictionary = contract_value
	if str(contract.get("type", "")) == "object" and not (value is Dictionary):
		return "%s must be an object" % label
	if value is Dictionary:
		var required: Variant = contract.get("required", [])
		if required is Array:
			for field_name: Variant in required:
				if not value.has(str(field_name)):
					return "%s is missing '%s'" % [label, field_name]
		var properties: Variant = contract.get("properties", {})
		if properties is Dictionary:
			for field_name: Variant in properties:
				if not value.has(field_name):
					continue
				var expected_type := str(properties[field_name].get("type", ""))
				var field_value: Variant = value[field_name]
				var valid := (
					expected_type.is_empty()
					or (expected_type == "string" and field_value is String)
					or (expected_type == "integer" and field_value is int)
					or (expected_type == "number" and (
						field_value is int or field_value is float
					))
					or (expected_type == "boolean" and field_value is bool)
					or (expected_type == "object" and field_value is Dictionary)
					or (expected_type == "array" and field_value is Array)
				)
				if not valid:
					return "%s field '%s' must be a %s" % [
						label,
						field_name,
						expected_type,
					]
	return ""
