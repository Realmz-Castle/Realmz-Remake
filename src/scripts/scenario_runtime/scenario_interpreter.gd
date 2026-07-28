class_name ScenarioInterpreter
extends RefCounted

const ClassicOpcodeRuntimeScript = preload(
	"res://scripts/scenario_runtime/handlers/classic_opcode_runtime.gd"
)
const CoreHandlerCatalogScript = preload(
	"res://scripts/scenario_runtime/handlers/core_handler_catalog.gd"
)
const ClassicContinuationRouterScript = preload(
	"res://scripts/scenario_runtime/classic_continuation_router.gd"
)
const SNAPSHOT_SCHEMA_VERSION := 2
const MAX_INTERNAL_STEPS := 256
const MAX_CALL_STACK_DEPTH := 20

var instruction_registry: ScenarioInstructionRegistry
var triggers: Dictionary = {}
var current_trigger_id := ""
var current_action_index := 0
var call_stack: Array = []
var encounter_origins: Array = []
var pending_command: ScenarioPendingCommand
var execution_context: Dictionary = {}
var trace: Array = []
var halted := true
var last_result: Dictionary = {}
var _classic_executor: Object
var _classic_continuation_router: ClassicContinuationRouter
var _classic_mode := false

var runtime_state: ClassicRuntimeState:
	get:
		return _classic_executor.runtime_state if _classic_executor != null else null
var active_action_point_header: Dictionary:
	get:
		return (
			_classic_executor.active_action_point_header
			if _classic_executor != null else {}
		)
var gosub_active: bool:
	get:
		return bool(_classic_executor.gosub_active) if _classic_executor != null else false
var remove_action_point: bool:
	get:
		return (
			bool(_classic_executor.remove_action_point)
			if _classic_executor != null else false
		)
var pending_choice: Dictionary:
	get:
		return _classic_pending("pending_choice")
var pending_encounter: Dictionary:
	get:
		return _classic_pending("pending_encounter")
var pending_battle: Dictionary:
	get:
		return _classic_pending("pending_battle")
var pending_selective_battle: Dictionary:
	get:
		return _classic_pending("pending_selective_battle")
var pending_random_branch: Dictionary:
	get:
		return _classic_pending("pending_random_branch")
var last_error: String:
	get:
		return str(_classic_executor.last_error) if _classic_executor != null else ""


func configure(registry_or_bundle: Variant, triggers_or_state: Variant) -> void:
	if registry_or_bundle is ClassicCampaignBundle \
			and triggers_or_state is ClassicRuntimeState:
		_configure_classic_compatibility(registry_or_bundle, triggers_or_state)
		return
	_classic_mode = false
	_classic_executor = null
	instruction_registry = registry_or_bundle
	triggers = (
		triggers_or_state.duplicate(true)
		if triggers_or_state is Dictionary
		else {}
	)
	reset()


func _configure_classic_compatibility(
	campaign_bundle: ClassicCampaignBundle,
	state: ClassicRuntimeState
) -> void:
	_classic_mode = true
	instruction_registry = ScenarioInstructionRegistry.new()
	if not CoreHandlerCatalogScript.register_all(instruction_registry):
		last_result = {
			"status": "error",
			"message": instruction_registry.last_error,
		}
		halted = true
		return
	if campaign_bundle.extension_registry != null and not (
		campaign_bundle.extension_registry.register_instruction_handlers(
			instruction_registry,
			campaign_bundle.required_extension_ids()
		)
	):
		last_result = {
			"status": "error",
			"message": campaign_bundle.extension_registry.last_error,
		}
		halted = true
		return
	if campaign_bundle.extension_registry != null and not (
		campaign_bundle.extension_registry.activate_providers(
			campaign_bundle.required_extension_ids(),
			campaign_bundle.documents.get("runtime", {}).get(
				"requiredExtensions",
				[]
			)
		)
	):
		last_result = {
			"status": "error",
			"message": campaign_bundle.extension_registry.last_error,
		}
		halted = true
		return
	_classic_executor = ClassicOpcodeRuntimeScript.new()
	_classic_executor.configure(campaign_bundle, state)
	_classic_continuation_router = ClassicContinuationRouterScript.new()
	_classic_continuation_router.configure(_classic_executor)
	_classic_executor.set_scenario_run_delegate(
		Callable(self, "_run_classic_loop")
	)
	_classic_executor.set_semantic_operation_executor(
		Callable(self, "_execute_classic_semantic_action")
	)
	_sync_classic_observability()


func set_percent_roll_provider(provider: Callable) -> void:
	if _classic_executor != null:
		_classic_executor.set_percent_roll_provider(provider)


func reset_execution() -> void:
	if _classic_executor != null:
		_classic_executor.reset_execution()
		_sync_classic_observability()
		return
	reset()


func begin_trigger(trigger_id: String, start_slot := 0, context := {}) -> bool:
	if _classic_executor == null:
		var started := start(trigger_id, start_slot, context)
		return str(started.get("status", "")) == "ok"
	var result: bool = _classic_executor.begin_trigger(trigger_id, start_slot, context)
	_sync_classic_observability()
	return result


func run_until_yield() -> Dictionary:
	if _classic_executor == null:
		return _error("Classic compatibility execution is not configured")
	return _classic_result(_run_classic_loop())


func _run_classic_loop() -> Dictionary:
	if instruction_registry == null:
		return _classic_error("Scenario instruction registry is unavailable")
	if pending_command != null:
		return _classic_error(
			"Scenario VM is waiting for command '%s'" % pending_command.command_id
		)
	for _step: int in range(MAX_INTERNAL_STEPS):
		var prepared: Dictionary = _classic_executor.take_next_instruction()
		if str(prepared.get("status", "")) != "instruction":
			return prepared
		var instruction_value: Variant = prepared.get("instruction")
		if not (instruction_value is Dictionary):
			return _classic_error(
				"Classic opcode runtime returned an invalid instruction"
			)
		var instruction := _normalized_instruction(instruction_value)
		var handler := instruction_registry.resolve(instruction)
		if handler == null:
			return _classic_error(_unhandled_message(instruction))
		var action_identity := _classic_action_identity()
		if str(instruction.get("kind", "classic")) == "semantic":
			action_identity["kind"] = "semantic"
			action_identity["operation"] = str(
				instruction.get("operation", "")
			)
			action_identity.erase("rawCode")
			action_identity.erase("code")
			action_identity.erase("id")
		var step_result: ScenarioStepResult
		if str(instruction.get("kind", "classic")) == "semantic":
			step_result = handler.execute(instruction, self)
			var semantic_result := _classic_semantic_step(
				step_result,
				handler.handler_id(),
				action_identity
			)
			if str(semantic_result.get("status", "")) == "continue":
				continue
			return semantic_result
		step_result = handler.execute(instruction, self)
		if step_result == null or not step_result.is_valid():
			return _classic_error(
				"Classic scenario handler '%s' returned an invalid result"
				% handler.handler_id()
			)
		var classic_result: Variant = step_result.data.get("classicResult")
		if not (classic_result is Dictionary):
			return _classic_error(
				"Classic scenario handler '%s' did not return opcode state"
				% handler.handler_id()
			)
		if str(classic_result.get("status", "")) == "continue":
			continue
		classic_result["_scenarioHandlerId"] = handler.handler_id()
		classic_result["_scenarioActionIdentity"] = action_identity
		return classic_result
	return _classic_error(
		"Scenario VM exceeded %d internal Classic steps" % MAX_INTERNAL_STEPS
	)


func execute_classic_instruction(
	handler_id: String,
	instruction: Dictionary
) -> ScenarioStepResult:
	if _classic_executor == null:
		return ScenarioStepResult.failed(
			"Classic opcode runtime is not configured"
		)
	var registered_handler := instruction_registry.resolve(instruction)
	if registered_handler == null or registered_handler.handler_id() != handler_id:
		return ScenarioStepResult.failed(
			"Classic opcode ownership changed during execution"
		)
	if not registered_handler.has_method("execute_on_runtime"):
		return ScenarioStepResult.failed(
			"Classic handler '%s' has no runtime implementation" % handler_id
		)
	var result: Variant = registered_handler.call(
		"execute_on_runtime",
		instruction,
		_classic_executor
	)
	if not (result is Dictionary):
		return ScenarioStepResult.failed(
			"Classic opcode runtime returned an invalid result"
		)
	return ScenarioStepResult.continued({"classicResult": result})


func resume_choice(accepted: bool) -> Dictionary:
	return resume_command({"accepted": accepted})


func resume_encounter(outcome: int, encounter_state := {}) -> Dictionary:
	var response: Dictionary = (
		encounter_state.duplicate(true) if encounter_state is Dictionary else {}
	)
	response["outcome"] = outcome
	return resume_command(response)


func resume_battle(coward: bool) -> Dictionary:
	return resume_command({"coward": coward})


func resume_selective_battle(survivor_count: int) -> Dictionary:
	return resume_command({"survivorCount": survivor_count})


func resume_forced_battle_end() -> Dictionary:
	return resume_command({})


func resume_forced_battle_at_slot(resume_slot: int) -> Dictionary:
	return resume_command({"forcedResumeSlot": resume_slot})


func resume_teleport() -> Dictionary:
	return resume_command({})


func resume_item_check(possessed: bool) -> Dictionary:
	return resume_command({"possessed": possessed})


func resume_wealth_payment(paid: bool) -> Dictionary:
	return resume_command({"paid": paid})


func resume_party_condition_check(active: bool) -> Dictionary:
	return resume_command({"active": active})


func resume_character_ability_check(passed: bool) -> Dictionary:
	return resume_command({"passed": passed})


func resume_misc_branch(matched: bool) -> Dictionary:
	return resume_command({"matched": matched})


func resume_ally_check(present: bool) -> Dictionary:
	return resume_command({"present": present})


func resume_combat_monster_check(present: bool) -> Dictionary:
	return resume_command({"present": present})


func resume_combat_revival(party_revived: bool) -> Dictionary:
	return resume_command({"partyRevived": 1 if party_revived else 0})


func resume_battle_round_macro() -> Dictionary:
	return resume_command({})


func resume_random_branch() -> Dictionary:
	return resume_command({})


func resume_back_up_party() -> Dictionary:
	return resume_command({})


func resume_time_mutation(response: Dictionary) -> Dictionary:
	return resume_command(response)


func resume_exploration_status(response: Dictionary) -> Dictionary:
	return resume_command(response)


func resume_command(response: Dictionary) -> Dictionary:
	if _classic_executor == null:
		return _error("Classic compatibility execution is not configured")
	if pending_command == null:
		return _classic_error("No scenario command is waiting for a response")
	var saved_pending := pending_command
	pending_command = null
	var handler := instruction_registry.handler_by_id(saved_pending.handler_id)
	if handler == null:
		return _classic_error(
			"Pending scenario handler '%s' is unavailable" % saved_pending.handler_id
		)
	var step := handler.resume(saved_pending, response, self)
	if not saved_pending.handler_id.begins_with("core."):
		var semantic_result := _classic_semantic_step(
			step,
			saved_pending.handler_id,
			saved_pending.action_identity
		)
		if str(semantic_result.get("status", "")) == "continue":
			return _classic_result(_classic_executor.run_until_yield())
		return _classic_result(semantic_result)
	if step == null or not step.is_valid():
		return _classic_error(
			"Classic scenario handler '%s' returned an invalid resume result"
			% saved_pending.handler_id
		)
	var classic_result: Variant = step.data.get("classicResult")
	if not (classic_result is Dictionary):
		return _classic_error(
			"Classic scenario handler '%s' did not return continuation state"
			% saved_pending.handler_id
		)
	return _classic_result(classic_result)


func resume_classic_instruction(
	handler_id: String,
	pending_value: Dictionary,
	response: Dictionary
) -> ScenarioStepResult:
	if _classic_continuation_router == null:
		return ScenarioStepResult.failed("Classic continuation registry is unavailable")
	var pending := ScenarioPendingCommand.from_dictionary(pending_value)
	if pending == null:
		return ScenarioStepResult.failed("Classic continuation record is invalid")
	if pending.handler_id != handler_id:
		return ScenarioStepResult.failed(
			"Classic continuation handler identity changed during resume"
		)
	var result: Dictionary = _classic_continuation_router.resume(pending, response)
	return ScenarioStepResult.continued({"classicResult": result})


func make_execution_snapshot() -> Dictionary:
	if _classic_executor == null:
		return {"status": "ok", "snapshot": snapshot()}
	var result: Dictionary = _classic_executor.make_execution_snapshot()
	if str(result.get("status", "")) == "ok":
		result["snapshot"]["scenarioPendingCommand"] = (
			pending_command.to_dictionary() if pending_command != null else null
		)
	return result


func restore_execution_snapshot(saved: Variant) -> Dictionary:
	if _classic_executor == null:
		return restore(saved)
	var result: Dictionary = _classic_executor.restore_execution_snapshot(saved)
	if str(result.get("status", "")) == "ok":
		pending_command = ScenarioPendingCommand.from_dictionary(
			saved.get("scenarioPendingCommand")
		) if saved.get("scenarioPendingCommand") is Dictionary else null
	_sync_classic_observability()
	return result


static func validate_execution_snapshot(saved: Variant) -> Dictionary:
	return ClassicOpcodeRuntimeScript.validate_execution_snapshot(saved)


func _classic_result(value: Variant) -> Dictionary:
	_sync_classic_observability()
	if value is Dictionary:
		if str(value.get("status", "")) == "yield":
			_capture_classic_pending(value)
		else:
			pending_command = null
		return value
	return {
		"status": "error",
		"message": "Classic opcode compatibility executor returned an invalid result",
	}


func _capture_classic_pending(result: Dictionary) -> void:
	var command_id := str(result.get("command", ""))
	var action_identity: Dictionary = result.get(
		"_scenarioActionIdentity",
		_classic_action_identity()
	)
	var handler_id := str(result.get("_scenarioHandlerId", "core.control-flow"))
	if instruction_registry != null and action_identity.has("code"):
		var handler := instruction_registry.resolve({
			"kind": "classic",
			"code": int(action_identity["code"]),
		})
		if handler != null:
			handler_id = handler.handler_id()
	var continuation: Dictionary = result.get("payload", {}).duplicate(true)
	var stored_continuation: Variant = result.get("_scenarioContinuation")
	if stored_continuation is Dictionary \
			and stored_continuation.get("data") is Dictionary \
			and stored_continuation.get("continuationId") is String:
		continuation.merge(stored_continuation["data"], true)
		continuation["_continuationId"] = str(
			stored_continuation["continuationId"]
		)
	pending_command = ScenarioPendingCommand.new(
		handler_id,
		command_id,
		action_identity,
		continuation
	)


func _execute_classic_semantic_action(action: Dictionary) -> Dictionary:
	if instruction_registry == null:
		return _classic_error("Scenario instruction registry is unavailable")
	var handler := instruction_registry.resolve(action)
	if handler == null:
		return _classic_error(
			"No scenario handler owns semantic operation '%s'" % action.get("operation", "")
		)
	var step_result := handler.execute(action, self)
	return _classic_semantic_step(
		step_result,
		handler.handler_id(),
		{
			"triggerId": str(_classic_executor.current_trigger.get("id", "")),
			"actionIndex": max(0, int(_classic_executor.current_action_index) - 1),
			"slot": int(action.get("slot", -1)),
			"kind": "semantic",
			"operation": str(action.get("operation", "")),
		}
	)


func _classic_semantic_step(
	step_result: ScenarioStepResult,
	handler_id: String,
	action_identity: Dictionary
) -> Dictionary:
	if step_result == null or not step_result.is_valid():
		return _classic_error(
			"Semantic scenario handler '%s' returned an invalid result" % handler_id
		)
	match step_result.kind:
		ScenarioStepResult.CONTINUE:
			return {"status": "continue"}
		ScenarioStepResult.YIELD:
			return {
				"status": "yield",
				"command": str(step_result.data.get("commandId", "")),
				"payload": step_result.data.get("request", {}).duplicate(true),
				"_scenarioHandlerId": handler_id,
				"_scenarioActionIdentity": action_identity.duplicate(true),
				"_scenarioContinuation": step_result.data.get(
					"continuation",
					{}
				).duplicate(true),
			}
		ScenarioStepResult.HALT:
			return {
				"status": "completed",
				"reason": "semantic-halt",
				"result": step_result.data.duplicate(true),
			}
		ScenarioStepResult.ERROR:
			return _classic_error(str(step_result.data.get(
				"message",
				"Semantic scenario handler failed"
			)))
	return _classic_error(
		"Semantic scenario handler '%s' returned unsupported control result '%s'" % [
			handler_id,
			step_result.kind,
		]
	)


func _classic_action_identity() -> Dictionary:
	if _classic_executor == null:
		return {}
	var executor_trace: Array = _classic_executor.trace
	var latest: Dictionary = (
		executor_trace[-1] if not executor_trace.is_empty() else {}
	)
	return {
		"triggerId": str(latest.get("triggerId", "")),
		"actionIndex": max(0, int(_classic_executor.current_action_index) - 1),
		"slot": int(latest.get("slot", -1)),
		"kind": "classic",
		"code": int(latest.get("code", 0)),
	}


func _classic_error(message: String) -> Dictionary:
	return {"status": "error", "message": message}


func _classic_pending(property_name: String) -> Dictionary:
	if _classic_executor == null:
		return {}
	var value: Variant = _classic_executor.get(property_name)
	return value if value is Dictionary else {}


func _sync_classic_observability() -> void:
	if _classic_executor == null:
		return
	call_stack = _classic_executor.call_stack.duplicate(true)
	encounter_origins = _classic_executor.encounter_origins.duplicate(true)
	trace = _classic_executor.trace.duplicate(true)


func reset() -> void:
	current_trigger_id = ""
	current_action_index = 0
	call_stack.clear()
	encounter_origins.clear()
	pending_command = null
	execution_context.clear()
	trace.clear()
	halted = true
	last_result = {}


func start(trigger_id: String, action_index := 0, context := {}) -> Dictionary:
	if instruction_registry == null:
		return _error("Scenario interpreter has no instruction registry")
	if not triggers.has(trigger_id):
		return _error("Scenario trigger '%s' is unavailable" % trigger_id)
	if action_index < 0:
		return _error("Scenario action index cannot be negative")
	current_trigger_id = trigger_id
	current_action_index = action_index
	call_stack.clear()
	encounter_origins.clear()
	pending_command = null
	execution_context = context.duplicate(true) if context is Dictionary else {}
	trace.clear()
	halted = false
	return {"status": "ok"}


func run(context: Object) -> Dictionary:
	if halted:
		return last_result if not last_result.is_empty() else _error("Scenario interpreter is stopped")
	if pending_command != null:
		return _error("Scenario interpreter is waiting for command '%s'" % pending_command.command_id)
	for _step: int in range(MAX_INTERNAL_STEPS):
		var trigger: Dictionary = triggers.get(current_trigger_id, {})
		var actions: Variant = trigger.get("actions", [])
		if not (actions is Array):
			return _error("Scenario trigger '%s' has invalid actions" % current_trigger_id)
		if current_action_index >= actions.size():
			if call_stack.is_empty():
				return _complete("fallthrough")
			_restore_call_frame()
			continue
		var instruction_value: Variant = actions[current_action_index]
		if not (instruction_value is Dictionary):
			return _error("Scenario instruction at %s[%d] is invalid" % [
				current_trigger_id,
				current_action_index,
			])
		var instruction := _normalized_instruction(instruction_value)
		var handler := instruction_registry.resolve(instruction)
		if handler == null:
			return _error(_unhandled_message(instruction))
		var action_identity := _action_identity(instruction)
		trace.append({
			"event": "execute",
			"handlerId": handler.handler_id(),
			"action": action_identity,
		})
		var step_result := handler.execute(instruction, context)
		if step_result == null or not step_result.is_valid():
			return _error("Scenario handler '%s' returned an invalid result" % handler.handler_id())
		var applied := _apply_step_result(step_result, handler.handler_id(), action_identity)
		if str(applied.get("status", "")) != "continue":
			return applied
	return _error("Scenario interpreter exceeded %d internal steps" % MAX_INTERNAL_STEPS)


func resume(response: Dictionary, context: Object) -> Dictionary:
	if pending_command == null:
		return _error("No scenario command is waiting for a response")
	var handler := instruction_registry.handler_by_id(pending_command.handler_id)
	if handler == null:
		return _error("Pending scenario handler '%s' is unavailable" % pending_command.handler_id)
	var saved_pending := pending_command
	pending_command = null
	trace.append({
		"event": "resume",
		"handlerId": saved_pending.handler_id,
		"commandId": saved_pending.command_id,
		"action": saved_pending.action_identity.duplicate(true),
	})
	var step_result := handler.resume(saved_pending, response, context)
	if step_result == null or not step_result.is_valid():
		return _error("Scenario handler '%s' returned an invalid resume result" % handler.handler_id())
	var applied := _apply_step_result(
		step_result,
		handler.handler_id(),
		saved_pending.action_identity
	)
	if str(applied.get("status", "")) != "continue":
		return applied
	return run(context)


func snapshot() -> Dictionary:
	var pending_value: Variant = null
	if pending_command != null:
		pending_value = pending_command.to_dictionary()
	return {
		"schemaVersion": SNAPSHOT_SCHEMA_VERSION,
		"currentTriggerId": current_trigger_id,
		"currentActionIndex": current_action_index,
		"callStack": call_stack.duplicate(true),
		"encounterOrigins": encounter_origins.duplicate(true),
		"pendingCommand": pending_value,
		"executionContext": execution_context.duplicate(true),
		"trace": trace.duplicate(true),
		"halted": halted,
		"lastResult": last_result.duplicate(true),
	}


func restore(value: Variant) -> Dictionary:
	var validation := validate_snapshot(value)
	if not bool(validation.get("valid", false)):
		return {"status": "error", "message": validation.get("message", "Invalid VM snapshot")}
	var saved: Dictionary = value
	if not triggers.has(str(saved["currentTriggerId"])):
		return _error("Saved scenario trigger '%s' is unavailable" % saved["currentTriggerId"])
	current_trigger_id = saved["currentTriggerId"]
	current_action_index = int(saved["currentActionIndex"])
	call_stack = saved["callStack"].duplicate(true)
	encounter_origins = saved["encounterOrigins"].duplicate(true)
	pending_command = ScenarioPendingCommand.from_dictionary(saved["pendingCommand"]) \
		if saved["pendingCommand"] != null else null
	execution_context = saved["executionContext"].duplicate(true)
	trace = saved["trace"].duplicate(true)
	halted = bool(saved["halted"])
	last_result = saved["lastResult"].duplicate(true)
	return {"status": "ok"}


static func validate_snapshot(value: Variant) -> Dictionary:
	if not (value is Dictionary):
		return _invalid("Scenario VM snapshot must be a dictionary")
	var saved: Dictionary = value
	if int(saved.get("schemaVersion", 0)) != SNAPSHOT_SCHEMA_VERSION:
		return _invalid(
			"Scenario VM snapshot is from an unsupported runtime; start a new playthrough"
		)
	if not (saved.get("currentTriggerId") is String):
		return _invalid("Scenario VM snapshot has an invalid trigger identity")
	if int(saved.get("currentActionIndex", -1)) < 0:
		return _invalid("Scenario VM snapshot has an invalid instruction position")
	for field_name: String in ["callStack", "encounterOrigins", "trace"]:
		if not (saved.get(field_name) is Array):
			return _invalid("Scenario VM snapshot has invalid %s" % field_name)
	if saved["callStack"].size() > MAX_CALL_STACK_DEPTH:
		return _invalid("Scenario VM snapshot exceeds the call-stack limit")
	for field_name: String in ["executionContext", "lastResult"]:
		if not (saved.get(field_name) is Dictionary):
			return _invalid("Scenario VM snapshot has invalid %s" % field_name)
	if not (saved.get("halted") is bool):
		return _invalid("Scenario VM snapshot has invalid halted state")
	if saved.get("pendingCommand") != null:
		var pending_validation := ScenarioPendingCommand.validate(saved["pendingCommand"])
		if not bool(pending_validation.get("valid", false)):
			return pending_validation
	return {"valid": true}


func _apply_step_result(
	result: ScenarioStepResult,
	handler_id: String,
	action_identity: Dictionary
) -> Dictionary:
	match result.kind:
		ScenarioStepResult.CONTINUE:
			current_action_index += 1
			return {"status": "continue"}
		ScenarioStepResult.YIELD:
			var command_id := str(result.data.get("commandId", ""))
			if command_id.is_empty():
				return _error("Scenario handler '%s' yielded an empty command ID" % handler_id)
			pending_command = ScenarioPendingCommand.new(
				handler_id,
				command_id,
				action_identity,
				result.data.get("continuation", {})
			)
			current_action_index += 1
			last_result = {
				"status": "yield",
				"commandId": command_id,
				"request": result.data.get("request", {}).duplicate(true),
				"pending": pending_command.to_dictionary(),
			}
			return last_result
		ScenarioStepResult.BRANCH:
			current_action_index = int(result.data.get("actionIndex", current_action_index + 1))
			return {"status": "continue"}
		ScenarioStepResult.CALL:
			if call_stack.size() >= MAX_CALL_STACK_DEPTH:
				return _error("Scenario call stack exceeded %d frames" % MAX_CALL_STACK_DEPTH)
			call_stack.append({
				"triggerId": current_trigger_id,
				"actionIndex": current_action_index + 1,
			})
			var call_result := _activate_target(result)
			return {"status": "continue"} if call_result.is_empty() else call_result
		ScenarioStepResult.RETURN:
			if call_stack.is_empty():
				return _complete("return-with-empty-stack")
			_restore_call_frame()
			return {"status": "continue"}
		ScenarioStepResult.REPLACE:
			var replace_result := _activate_target(result)
			return {"status": "continue"} if replace_result.is_empty() else replace_result
		ScenarioStepResult.HALT:
			halted = true
			last_result = {"status": "halt", "result": result.data.duplicate(true)}
			return last_result
		ScenarioStepResult.ERROR:
			return _error(str(result.data.get("message", "Scenario handler failed")))
	return _error("Unknown scenario step result '%s'" % result.kind)


func _activate_target(result: ScenarioStepResult) -> Dictionary:
	var trigger_id := str(result.data.get("triggerId", ""))
	if not triggers.has(trigger_id):
		return _error("Scenario target trigger '%s' is unavailable" % trigger_id)
	current_trigger_id = trigger_id
	current_action_index = int(result.data.get("actionIndex", 0))
	return {}


func _restore_call_frame() -> void:
	var frame: Dictionary = call_stack.pop_back()
	current_trigger_id = str(frame["triggerId"])
	current_action_index = int(frame["actionIndex"])


func _normalized_instruction(value: Dictionary) -> Dictionary:
	var instruction := value.duplicate(true)
	var kind := str(instruction.get("kind", "classic"))
	if kind.is_empty():
		kind = "classic"
	instruction["kind"] = kind
	if kind == "classic":
		var raw_code := int(instruction.get("rawCode", instruction.get("code", 0)))
		instruction["code"] = (
			abs(raw_code) if raw_code < 0 and raw_code not in [-14, -23] else raw_code
		)
		instruction["gosub"] = raw_code < 0 and raw_code not in [-14, -23]
	return instruction


func _action_identity(instruction: Dictionary) -> Dictionary:
	var identity := {
		"triggerId": current_trigger_id,
		"actionIndex": current_action_index,
		"slot": int(instruction.get("slot", current_action_index)),
		"kind": str(instruction.get("kind", "")),
	}
	if identity["kind"] == "classic":
		identity["rawCode"] = int(instruction.get("rawCode", 0))
		identity["code"] = int(instruction.get("code", 0))
		identity["id"] = int(instruction.get("id", 0))
	else:
		identity["operation"] = str(instruction.get("operation", ""))
	return identity


func _unhandled_message(instruction: Dictionary) -> String:
	if str(instruction.get("kind", "")) == "classic":
		return "No scenario handler owns Classic opcode %d" % int(instruction.get("code", -1))
	return "No scenario handler owns semantic operation '%s'" % instruction.get("operation", "")


func _complete(reason: String) -> Dictionary:
	halted = true
	last_result = {"status": "complete", "reason": reason}
	return last_result


func _error(message: String) -> Dictionary:
	halted = true
	last_result = {"status": "error", "message": message}
	return last_result


static func _invalid(message: String) -> Dictionary:
	return {"valid": false, "message": message}
