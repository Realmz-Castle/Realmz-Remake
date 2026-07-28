class_name RuntimeFixtureScenarioPort
extends ScenarioCommandPort


func port_id() -> String:
	return "scenario.runtime-fixture.presentation"


func owned_command_ids() -> PackedStringArray:
	return PackedStringArray(["scenario.runtime-fixture.present"])


func execute(_command_id: String, request: Dictionary) -> Dictionary:
	return {
		"status": "ok",
		"marker": str(request.get("marker", "")),
	}
