class_name ScenarioCommandPort
extends RefCounted


func port_id() -> String:
	return ""


func owned_command_ids() -> PackedStringArray:
	return PackedStringArray()


func request_contracts() -> Dictionary:
	var contracts: Dictionary = {}
	for command_id: String in owned_command_ids():
		contracts[command_id] = {"type": "object"}
	return contracts


func response_contracts() -> Dictionary:
	var contracts: Dictionary = {}
	for command_id: String in owned_command_ids():
		# Command responses are domain payloads. A status field is reserved for
		# transport failures, but successful commands historically return only
		# their operation-specific fields (and often an empty object).
		contracts[command_id] = {"type": "object"}
	return contracts


func save_policy() -> Dictionary:
	return {"state": "none"}


func configure(_services: Dictionary) -> void:
	pass


func execute(_command_id: String, _request: Dictionary) -> Dictionary:
	return {
		"status": "error",
		"message": "Scenario command port '%s' does not implement execute()" % port_id(),
	}


func snapshot_state() -> Dictionary:
	return {}


func restore_state(_state: Dictionary) -> Dictionary:
	return {"status": "ok"}
