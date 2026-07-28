class_name ScenarioInstructionHandler
extends RefCounted


func handler_id() -> String:
	return ""


func classic_opcodes() -> PackedInt32Array:
	return PackedInt32Array()


func semantic_operations() -> PackedStringArray:
	return PackedStringArray()


func execute(_instruction: Dictionary, _context: Object) -> ScenarioStepResult:
	return ScenarioStepResult.failed(
		"Scenario instruction handler '%s' does not implement execute()" % handler_id()
	)


func resume(
	_pending: ScenarioPendingCommand,
	_response: Dictionary,
	_context: Object
) -> ScenarioStepResult:
	return ScenarioStepResult.failed(
		"Scenario instruction handler '%s' does not implement resume()" % handler_id()
	)
