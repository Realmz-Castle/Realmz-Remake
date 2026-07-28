class_name ScenarioExtensionProvider
extends RefCounted


func provider_id() -> String:
	return ""


func api_version() -> int:
	return 0


func binding_ids() -> Dictionary:
	return {}


func configure(_configuration: Dictionary) -> Dictionary:
	return {"status": "ok"}


func invoke(
	_capability: String,
	_binding_id: String,
	_payload: Dictionary,
	_context: Object
) -> Dictionary:
	return {
		"status": "error",
		"message": "Scenario extension provider '%s' does not implement invoke()" % provider_id(),
	}
