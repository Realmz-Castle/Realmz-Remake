class_name ScenarioStepResult
extends RefCounted

const CONTINUE := "continue"
const YIELD := "yield"
const BRANCH := "branch"
const CALL := "call"
const RETURN := "return"
const REPLACE := "replace"
const HALT := "halt"
const ERROR := "error"
const VALID_KINDS := [
	CONTINUE,
	YIELD,
	BRANCH,
	CALL,
	RETURN,
	REPLACE,
	HALT,
	ERROR,
]

var kind := CONTINUE
var data: Dictionary = {}


func _init(result_kind := CONTINUE, result_data := {}) -> void:
	kind = str(result_kind)
	data = result_data.duplicate(true) if result_data is Dictionary else {}


func is_valid() -> bool:
	return kind in VALID_KINDS


func to_dictionary() -> Dictionary:
	return {
		"kind": kind,
		"data": data.duplicate(true),
	}


static func continued(data := {}) -> ScenarioStepResult:
	return ScenarioStepResult.new(CONTINUE, data)


static func yielded(command_id: String, request := {}, continuation := {}) -> ScenarioStepResult:
	return ScenarioStepResult.new(
		YIELD,
		{
			"commandId": command_id,
			"request": request.duplicate(true) if request is Dictionary else {},
			"continuation": (
				continuation.duplicate(true) if continuation is Dictionary else {}
			),
		}
	)


static func branched(action_index: int) -> ScenarioStepResult:
	return ScenarioStepResult.new(BRANCH, {"actionIndex": action_index})


static func called(trigger_id: String, action_index := 0) -> ScenarioStepResult:
	return ScenarioStepResult.new(
		CALL,
		{"triggerId": trigger_id, "actionIndex": action_index}
	)


static func returned() -> ScenarioStepResult:
	return ScenarioStepResult.new(RETURN)


static func replaced(trigger_id: String, action_index := 0) -> ScenarioStepResult:
	return ScenarioStepResult.new(
		REPLACE,
		{"triggerId": trigger_id, "actionIndex": action_index}
	)


static func halted(result := {}) -> ScenarioStepResult:
	return ScenarioStepResult.new(HALT, result)


static func failed(message: String, details := {}) -> ScenarioStepResult:
	var result := details.duplicate(true) if details is Dictionary else {}
	result["message"] = message
	return ScenarioStepResult.new(ERROR, result)
