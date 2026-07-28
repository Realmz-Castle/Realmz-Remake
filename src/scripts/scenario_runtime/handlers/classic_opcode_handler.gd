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


func execute_on_runtime(
	_instruction: Dictionary,
	_runtime: Object
) -> Dictionary:
	return {
		"status": "error",
		"message": "Classic handler '%s' has no opcode implementation" % _id,
	}


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


func _invoke(runtime: Object, method_name: String, arguments := []) -> Dictionary:
	if runtime == null or not runtime.has_method(method_name):
		return {
			"status": "error",
			"message": "Classic handler '%s' requires unavailable operation '%s'" % [
				_id,
				method_name,
			],
		}
	var result: Variant = runtime.callv(method_name, arguments)
	if result is Dictionary:
		return result
	return {
		"status": "error",
		"message": "Classic operation '%s' returned invalid state" % method_name,
	}


func _call_void(runtime: Object, method_name: String, arguments := []) -> bool:
	if runtime == null or not runtime.has_method(method_name):
		return false
	runtime.callv(method_name, arguments)
	return true


func _unsupported(instruction: Dictionary) -> Dictionary:
	return {
		"status": "error",
		"message": "Classic handler '%s' does not implement opcode %d" % [
			_id,
			int(instruction.get("code", 0)),
		],
	}
