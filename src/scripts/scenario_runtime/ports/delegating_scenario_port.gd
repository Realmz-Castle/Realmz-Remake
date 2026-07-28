class_name DelegatingScenarioPort
extends ScenarioCommandPort

var _port_runtime: Object
var gameplay_rules: GameplayRuleSet
var extension_registry: ScenarioExtensionRegistry
var runtime_bindings: Dictionary = {}


func configure(services: Dictionary) -> void:
	_port_runtime = services.get("scenarioPortRuntime")
	gameplay_rules = services.get("gameplayRules")
	extension_registry = services.get("extensionRegistry")
	runtime_bindings = services.get("runtimeBindings", {}).duplicate(true)


func rule_option(domain: String, option_id: String, fallback: Variant) -> Variant:
	if gameplay_rules == null:
		return fallback
	return gameplay_rules.options(domain).get(option_id, fallback)


func service_operation(_command_id: String) -> String:
	return ""


func execute(command_id: String, request: Dictionary) -> Dictionary:
	if _port_runtime == null:
		return {
			"status": "error",
			"message": "Scenario port '%s' is not configured" % port_id(),
		}
	var operation := service_operation(command_id)
	if not operation.is_empty() and _port_runtime.has_method(operation):
		if _port_runtime.has_method("prepare_scenario_command"):
			_port_runtime.call("prepare_scenario_command", command_id)
		return await _port_runtime.call(operation, request)
	# Focused test doubles may still expose the old generic entry point. The
	# production Godot service does not; command ownership remains in the port.
	if _port_runtime.has_method("execute_command"):
		return await _port_runtime.call("execute_command", command_id, request)
	return {
		"status": "error",
		"message": "Scenario port '%s' has no configured Godot service" % port_id(),
	}


func invoke_runtime_binding(
	binding_group: String,
	capability: String,
	lookup_keys: Array,
	request: Dictionary
) -> Dictionary:
	if extension_registry == null:
		return {"handled": false}
	var group: Variant = runtime_bindings.get(binding_group, {})
	if not (group is Dictionary):
		return {"handled": false}
	for lookup_key_value: Variant in lookup_keys:
		var lookup_key := str(lookup_key_value)
		if lookup_key.is_empty() or not group.has(lookup_key):
			continue
		var binding_id := str(group[lookup_key])
		var result := extension_registry.invoke_binding(
			capability,
			binding_id,
			request,
			self
		)
		result["handled"] = true
		result["runtimeBinding"] = binding_id
		return result
	return {"handled": false}
