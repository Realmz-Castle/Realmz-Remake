class_name CoreScenarioHandlerCatalog
extends RefCounted

const HANDLER_SCRIPTS := [
	preload("res://scripts/scenario_runtime/handlers/control_flow_handler.gd"),
	preload("res://scripts/scenario_runtime/handlers/encounter_handler.gd"),
	preload("res://scripts/scenario_runtime/handlers/map_time_handler.gd"),
	preload("res://scripts/scenario_runtime/handlers/combat_handler.gd"),
	preload("res://scripts/scenario_runtime/handlers/inventory_handler.gd"),
	preload("res://scripts/scenario_runtime/handlers/character_handler.gd"),
	preload("res://scripts/scenario_runtime/handlers/rules_state_handler.gd"),
	preload("res://scripts/scenario_runtime/handlers/presentation_handler.gd"),
]


static func register_all(registry: ScenarioInstructionRegistry) -> bool:
	for handler_script: GDScript in HANDLER_SCRIPTS:
		var handler: ScenarioInstructionHandler = handler_script.new()
		if not registry.register_handler(handler):
			return false
	return true


static func all_classic_opcodes() -> PackedInt32Array:
	var result := PackedInt32Array()
	for handler_script: GDScript in HANDLER_SCRIPTS:
		var handler: ScenarioInstructionHandler = handler_script.new()
		for opcode: int in handler.classic_opcodes():
			result.append(opcode)
	result.sort()
	return result
