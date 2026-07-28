class_name ClassicOpcodeHandler
extends ScenarioInstructionHandler

var _id := ""
var _opcodes := PackedInt32Array()


func configure(id: String, opcodes: PackedInt32Array) -> void:
	_id = id
	_opcodes = opcodes.duplicate()


func handler_id() -> String:
	return _id


func classic_opcodes() -> PackedInt32Array:
	return _opcodes.duplicate()


func execute(instruction: Dictionary, context: Object) -> ScenarioStepResult:
	if context == null or not context.has_method("execute_classic_instruction"):
		return ScenarioStepResult.failed(
			"Classic handler '%s' requires a scenario execution context" % _id
		)
	var result: Variant = context.call("execute_classic_instruction", _id, instruction)
	return _coerce_result(result)


func resume(
	pending: ScenarioPendingCommand,
	response: Dictionary,
	context: Object
) -> ScenarioStepResult:
	if context == null or not context.has_method("resume_classic_instruction"):
		return ScenarioStepResult.failed(
			"Classic handler '%s' cannot resume without a scenario execution context" % _id
		)
	var result: Variant = context.call(
		"resume_classic_instruction",
		_id,
		pending.to_dictionary(),
		response
	)
	return _coerce_result(result)


func _coerce_result(value: Variant) -> ScenarioStepResult:
	if value is ScenarioStepResult:
		return value
	if value is Dictionary:
		var kind := str(value.get("kind", ""))
		var data: Variant = value.get("data", {})
		if kind in ScenarioStepResult.VALID_KINDS and data is Dictionary:
			return ScenarioStepResult.new(kind, data)
	return ScenarioStepResult.failed("Classic handler '%s' received an invalid result" % _id)
