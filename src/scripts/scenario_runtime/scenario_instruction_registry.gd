class_name ScenarioInstructionRegistry
extends RefCounted

const CORE_NAMESPACE := "core."

var _handlers_by_id: Dictionary = {}
var _classic_handlers: Dictionary = {}
var _semantic_handlers: Dictionary = {}
var last_error := ""


func register_handler(handler: ScenarioInstructionHandler) -> bool:
	last_error = ""
	if handler == null:
		return _fail("Cannot register a null scenario instruction handler")
	var id := handler.handler_id().strip_edges()
	if id.is_empty():
		return _fail("Scenario instruction handlers require a stable ID")
	if _handlers_by_id.has(id):
		return _fail("Duplicate scenario instruction handler ID '%s'" % id)
	for opcode: int in handler.classic_opcodes():
		if _classic_handlers.has(opcode):
			return _fail(
				"Classic opcode %d is already owned by handler '%s'" % [
					opcode,
					_classic_handlers[opcode].handler_id(),
				]
			)
		if not id.begins_with(CORE_NAMESPACE):
			return _fail(
				"Classic opcode %d may only be owned by a core handler" % opcode
			)
	for operation: String in handler.semantic_operations():
		var operation_id := operation.strip_edges()
		if not _is_namespaced(operation_id):
			return _fail(
				"Semantic operation '%s' must use a namespace" % operation_id
			)
		if operation_id.begins_with(CORE_NAMESPACE) and not id.begins_with(CORE_NAMESPACE):
			return _fail(
				"Extension handler '%s' cannot register reserved operation '%s'" % [
					id,
					operation_id,
				]
			)
		if _semantic_handlers.has(operation_id):
			return _fail(
				"Semantic operation '%s' is already owned by handler '%s'" % [
					operation_id,
					_semantic_handlers[operation_id].handler_id(),
				]
			)
	_handlers_by_id[id] = handler
	for opcode: int in handler.classic_opcodes():
		_classic_handlers[opcode] = handler
	for operation: String in handler.semantic_operations():
		_semantic_handlers[operation] = handler
	return true


func resolve(instruction: Dictionary) -> ScenarioInstructionHandler:
	var kind := str(instruction.get("kind", ""))
	if kind == "classic":
		return _classic_handlers.get(int(instruction.get("code", -1)))
	if kind == "semantic":
		return _semantic_handlers.get(str(instruction.get("operation", "")))
	return null


func handler_by_id(id: String) -> ScenarioInstructionHandler:
	return _handlers_by_id.get(id)


func registered_classic_opcodes() -> PackedInt32Array:
	var result := PackedInt32Array()
	for opcode: Variant in _classic_handlers.keys():
		result.append(int(opcode))
	result.sort()
	return result


func registered_semantic_operations() -> PackedStringArray:
	var result := PackedStringArray()
	for operation: Variant in _semantic_handlers.keys():
		result.append(str(operation))
	result.sort()
	return result


func _is_namespaced(value: String) -> bool:
	var separator := value.find(".")
	return separator > 0 and separator < value.length() - 1


func _fail(message: String) -> bool:
	last_error = message
	return false
