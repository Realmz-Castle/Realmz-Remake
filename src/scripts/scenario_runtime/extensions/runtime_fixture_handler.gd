class_name RuntimeFixtureScenarioHandler
extends ScenarioInstructionHandler


func handler_id() -> String:
	return "scenario.runtime-fixture.instructions"


func semantic_operations() -> PackedStringArray:
	return PackedStringArray(["scenario.runtime-fixture.mark"])


func execute(instruction: Dictionary, _context: Object) -> ScenarioStepResult:
	var parameters: Variant = instruction.get("parameters", {})
	if not (parameters is Dictionary):
		return ScenarioStepResult.failed("Runtime fixture parameters must be a dictionary")
	return ScenarioStepResult.yielded(
		"scenario.runtime-fixture.present",
		{"marker": str(parameters.get("marker", ""))},
		{"operation": "scenario.runtime-fixture.mark"}
	)


func resume(
	_pending: ScenarioPendingCommand,
	response: Dictionary,
	_context: Object
) -> ScenarioStepResult:
	if str(response.get("status", "")) != "ok":
		return ScenarioStepResult.failed("Runtime fixture presentation did not complete")
	return ScenarioStepResult.continued({"fixture": true})
