class_name ScenarioExtensionRegistry
extends RefCounted

const BUILTIN_CATALOG := "res://scripts/scenario_runtime/extensions/catalog.json"
const CAPABILITIES := [
	"semanticOperations",
	"commands",
	"spells",
	"itemBehaviors",
	"encounterResolvers",
	"monsterAiProviders",
	"lifecycleHooks",
	"gameplayRuleProviders",
]
const RESERVED_PREFIX := "core."

var extensions: Dictionary = {}
var bindings: Dictionary = {}
var providers_by_binding: Dictionary = {}
var last_error := ""


func load_builtin_catalog() -> bool:
	last_error = ""
	extensions.clear()
	bindings.clear()
	providers_by_binding.clear()
	var file := FileAccess.open(BUILTIN_CATALOG, FileAccess.READ)
	if file == null:
		return _fail("Built-in scenario extension catalog is unavailable")
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return _fail("Built-in scenario extension catalog must be a JSON object")
	for descriptor: Variant in parsed.get("extensions", []):
		if not (descriptor is Dictionary) or not register_descriptor(descriptor):
			return false
	return true


func register_descriptor(descriptor: Dictionary) -> bool:
	var id := str(descriptor.get("id", "")).strip_edges()
	if not _is_namespaced(id):
		return _fail("Scenario extensions require a namespaced ID")
	if id.begins_with(RESERVED_PREFIX):
		return _fail("Scenario extension ID '%s' uses the reserved core namespace" % id)
	if int(descriptor.get("apiVersion", 0)) <= 0:
		return _fail("Scenario extension '%s' requires a positive API version" % id)
	if extensions.has(id):
		return _fail("Duplicate scenario extension ID '%s'" % id)
	var descriptor_capabilities: Variant = descriptor.get("capabilities", {})
	if not (descriptor_capabilities is Dictionary):
		return _fail("Scenario extension '%s' has invalid capabilities" % id)
	var pending_bindings: Array[Array] = []
	for capability: String in CAPABILITIES:
		var entries: Variant = descriptor_capabilities.get(capability, [])
		if not (entries is Array):
			return _fail("Scenario extension '%s' capability '%s' must be an array" % [id, capability])
		for entry: Variant in entries:
			var binding_id := _binding_id(entry)
			if not _is_namespaced(binding_id):
				return _fail("Scenario extension binding '%s' must be namespaced" % binding_id)
			if binding_id.begins_with(RESERVED_PREFIX):
				return _fail("Scenario extension '%s' cannot replace reserved binding '%s'" % [id, binding_id])
			var key := "%s:%s" % [capability, binding_id]
			if bindings.has(key):
				return _fail("Scenario extension binding '%s' is already registered" % binding_id)
			pending_bindings.append([key, id])
	extensions[id] = descriptor.duplicate(true)
	for binding: Array in pending_bindings:
		bindings[binding[0]] = binding[1]
	return true


func validate_requirements(requirements: Variant) -> Dictionary:
	if not (requirements is Array):
		return _invalid("runtime.requiredExtensions must be an array")
	for index: int in range(requirements.size()):
		var requirement: Variant = requirements[index]
		if not (requirement is Dictionary):
			return _invalid("runtime.requiredExtensions[%d] must be an object" % index)
		var id := str(requirement.get("id", ""))
		var descriptor: Variant = extensions.get(id)
		if not (descriptor is Dictionary):
			return _invalid("Required built-in scenario extension '%s' is unavailable" % id)
		var required_api := int(requirement.get("apiVersion", 0))
		if required_api != int(descriptor.get("apiVersion", 0)):
			return _invalid("Scenario extension '%s' requires API %d but the game provides API %d" % [
				id,
				required_api,
				int(descriptor.get("apiVersion", 0)),
			])
		var configuration: Variant = requirement.get("configuration", {})
		if not (configuration is Dictionary):
			return _invalid("Scenario extension '%s' configuration must be an object" % id)
		var configuration_validation := _validate_schema(
			configuration,
			descriptor.get("configurationSchema", {}),
			"Scenario extension '%s' configuration" % id
		)
		if not bool(configuration_validation.get("valid", false)):
			return configuration_validation
	return {"valid": true}


func validate_binding_reference(
	capability: String,
	binding_id: String,
	required_extension_ids: Dictionary
) -> Dictionary:
	var owner := binding_owner(capability, binding_id)
	if owner.is_empty():
		return _invalid(
			"Built-in scenario extension binding '%s' is unavailable" % binding_id
		)
	if not required_extension_ids.has(owner):
		return _invalid(
			"Scenario extension binding '%s' requires runtime.requiredExtensions to include '%s'" % [
				binding_id,
				owner,
			]
		)
	return {"valid": true}


func validate_semantic_operation(
	operation: String,
	parameters: Variant,
	required_extension_ids: Dictionary
) -> Dictionary:
	var binding_validation := validate_binding_reference(
		"semanticOperations",
		operation,
		required_extension_ids
	)
	if not bool(binding_validation.get("valid", false)):
		return binding_validation
	var operation_descriptor := binding_descriptor("semanticOperations", operation)
	return _validate_schema(
		parameters,
		operation_descriptor.get("parametersSchema", {}),
		"Semantic operation '%s' parameters" % operation
	)


func binding_owner(capability: String, binding_id: String) -> String:
	return str(bindings.get("%s:%s" % [capability, binding_id], ""))


func binding_descriptor(capability: String, binding_id: String) -> Dictionary:
	var owner := binding_owner(capability, binding_id)
	if owner.is_empty():
		return {}
	var descriptor: Variant = extensions.get(owner, {})
	if not (descriptor is Dictionary):
		return {}
	var entries: Variant = descriptor.get("capabilities", {}).get(capability, [])
	if not (entries is Array):
		return {}
	for entry: Variant in entries:
		if _binding_id(entry) == binding_id:
			return entry.duplicate(true) if entry is Dictionary else {"id": binding_id}
	return {}


func extension_catalog() -> Dictionary:
	var descriptors: Array = extensions.values()
	descriptors.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return str(left["id"]) < str(right["id"])
	)
	return {"schemaVersion": 1, "extensions": descriptors}


func register_instruction_handlers(
	registry: ScenarioInstructionRegistry,
	required_extension_ids: Dictionary
) -> bool:
	for extension_id: String in required_extension_ids:
		var descriptor: Variant = extensions.get(extension_id)
		if not (descriptor is Dictionary):
			return _fail("Required built-in scenario extension '%s' is unavailable" % extension_id)
		var script_paths: Variant = descriptor.get("instructionHandlerScripts", [])
		if not (script_paths is Array):
			return _fail("Scenario extension '%s' has invalid instruction handlers" % extension_id)
		for script_path_value: Variant in script_paths:
			var script_result := _trusted_script(
				str(script_path_value),
				extension_id,
				"instruction handler"
			)
			if not bool(script_result.get("valid", false)):
				return false
			var handler: Variant = script_result["script"].new()
			if not (handler is ScenarioInstructionHandler):
				return _fail(
					"Scenario extension '%s' instruction handler has the wrong type" % extension_id
				)
			if not str(handler.handler_id()).begins_with("%s." % extension_id):
				return _fail(
					"Scenario extension '%s' cannot register handler '%s'" % [
						extension_id,
						handler.handler_id(),
					]
				)
			if not registry.register_handler(handler):
				return _fail(registry.last_error)
	return true


func register_command_ports(
	router: ScenarioCommandRouter,
	required_extension_ids: Dictionary
) -> bool:
	for extension_id: String in required_extension_ids:
		var descriptor: Variant = extensions.get(extension_id)
		if not (descriptor is Dictionary):
			return _fail("Required built-in scenario extension '%s' is unavailable" % extension_id)
		var script_paths: Variant = descriptor.get("commandPortScripts", [])
		if not (script_paths is Array):
			return _fail("Scenario extension '%s' has invalid command ports" % extension_id)
		for script_path_value: Variant in script_paths:
			var script_result := _trusted_script(
				str(script_path_value),
				extension_id,
				"command port"
			)
			if not bool(script_result.get("valid", false)):
				return false
			var port: Variant = script_result["script"].new()
			if not (port is ScenarioCommandPort):
				return _fail(
					"Scenario extension '%s' command port has the wrong type" % extension_id
				)
			if not str(port.port_id()).begins_with("%s." % extension_id):
				return _fail(
					"Scenario extension '%s' cannot register port '%s'" % [
						extension_id,
						port.port_id(),
					]
				)
			for command_id: String in port.owned_command_ids():
				if binding_owner("commands", command_id) != extension_id:
					return _fail(
						"Scenario extension '%s' port declares unregistered command '%s'" % [
							extension_id,
							command_id,
						]
					)
			if not router.register_port(port):
				return _fail(router.last_error)
	return true


func activate_providers(
	required_extension_ids: Dictionary,
	requirements: Array
) -> bool:
	providers_by_binding.clear()
	var configuration_by_extension: Dictionary = {}
	for requirement: Variant in requirements:
		if requirement is Dictionary:
			configuration_by_extension[str(requirement.get("id", ""))] = (
				requirement.get("configuration", {}).duplicate(true)
			)
	for extension_id: String in required_extension_ids:
		var descriptor: Variant = extensions.get(extension_id)
		if not (descriptor is Dictionary):
			return _fail("Required built-in scenario extension '%s' is unavailable" % extension_id)
		var script_paths: Variant = descriptor.get("providerScripts", [])
		if not (script_paths is Array):
			return _fail("Scenario extension '%s' has invalid providers" % extension_id)
		for script_path_value: Variant in script_paths:
			var script_result := _trusted_script(
				str(script_path_value),
				extension_id,
				"provider"
			)
			if not bool(script_result.get("valid", false)):
				return false
			var provider: Variant = script_result["script"].new()
			if not (provider is ScenarioExtensionProvider):
				return _fail(
					"Scenario extension '%s' provider has the wrong type" % extension_id
				)
			if not str(provider.provider_id()).begins_with("%s." % extension_id):
				return _fail(
					"Scenario extension '%s' cannot register provider '%s'" % [
						extension_id,
						provider.provider_id(),
					]
				)
			var configure_result: Dictionary = provider.configure(
				configuration_by_extension.get(extension_id, {})
			)
			if str(configure_result.get("status", "")) != "ok":
				return _fail(str(configure_result.get(
					"message",
					"Scenario extension provider configuration failed"
				)))
			for capability: String in provider.binding_ids():
				var provider_bindings: Variant = provider.binding_ids()[capability]
				if capability not in CAPABILITIES or not (provider_bindings is Array):
					return _fail(
						"Scenario extension provider '%s' declares invalid capability '%s'" % [
							provider.provider_id(),
							capability,
						]
					)
				for binding_id_value: Variant in provider_bindings:
					var binding_id := str(binding_id_value)
					if binding_owner(capability, binding_id) != extension_id:
						return _fail(
							"Scenario extension provider '%s' declares unregistered binding '%s'" % [
								provider.provider_id(),
								binding_id,
							]
						)
					var key := "%s:%s" % [capability, binding_id]
					if providers_by_binding.has(key):
						return _fail(
							"Scenario extension binding '%s' has more than one provider" % binding_id
						)
					providers_by_binding[key] = provider
	return true


func invoke_binding(
	capability: String,
	binding_id: String,
	payload: Dictionary,
	context: Object = null
) -> Dictionary:
	var provider: ScenarioExtensionProvider = providers_by_binding.get(
		"%s:%s" % [capability, binding_id]
	)
	if provider == null:
		return {
			"status": "error",
			"message": "Scenario extension binding '%s' has no active provider" % binding_id,
		}
	return provider.invoke(capability, binding_id, payload, context)


func _trusted_script(path: String, extension_id: String, role: String) -> Dictionary:
	if not path.begins_with("res://scripts/scenario_runtime/extensions/") \
			or not path.ends_with(".gd"):
		_fail(
			"Scenario extension '%s' %s must be a trusted built-in script" % [
				extension_id,
				role,
			]
		)
		return {"valid": false}
	var script: Variant = load(path)
	if not (script is GDScript):
		_fail("Scenario extension '%s' %s script is unavailable" % [extension_id, role])
		return {"valid": false}
	return {"valid": true, "script": script}


func _binding_id(entry: Variant) -> String:
	if entry is Dictionary:
		return str(entry.get("id", "")).strip_edges()
	return str(entry).strip_edges()


func _validate_schema(value: Variant, schema_value: Variant, context: String) -> Dictionary:
	if not (schema_value is Dictionary) or schema_value.is_empty():
		return {"valid": true}
	var schema: Dictionary = schema_value
	var expected_type := str(schema.get("type", ""))
	var type_valid := (
		(expected_type == "object" and value is Dictionary)
		or (expected_type == "array" and value is Array)
		or (expected_type == "string" and value is String)
		or (expected_type == "integer" and value is int)
		or (expected_type == "number" and (value is int or value is float))
		or (expected_type == "boolean" and value is bool)
		or expected_type.is_empty()
	)
	if not type_valid:
		return _invalid("%s must be a JSON %s" % [context, expected_type])
	var allowed_values: Variant = schema.get("enum", [])
	if allowed_values is Array and not allowed_values.is_empty() and value not in allowed_values:
		return _invalid("%s is not one of the allowed values" % context)
	if value is Dictionary:
		var properties: Variant = schema.get("properties", {})
		if not (properties is Dictionary):
			return _invalid("%s has an invalid built-in schema" % context)
		var required: Variant = schema.get("required", [])
		if required is Array:
			for required_name: Variant in required:
				if not value.has(str(required_name)):
					return _invalid("%s requires '%s'" % [context, required_name])
		for key: Variant in value.keys():
			if not properties.has(key):
				if schema.get("additionalProperties", true) == false:
					return _invalid("%s does not allow '%s'" % [context, key])
				continue
			var child_validation := _validate_schema(
				value[key],
				properties[key],
				"%s.%s" % [context, key]
			)
			if not bool(child_validation.get("valid", false)):
				return child_validation
	if value is Array and schema.get("items") is Dictionary:
		for index: int in range(value.size()):
			var item_validation := _validate_schema(
				value[index],
				schema["items"],
				"%s[%d]" % [context, index]
			)
			if not bool(item_validation.get("valid", false)):
				return item_validation
	if value is int or value is float:
		if schema.has("minimum") and value < schema["minimum"]:
			return _invalid("%s must be at least %s" % [context, schema["minimum"]])
		if schema.has("maximum") and value > schema["maximum"]:
			return _invalid("%s must be at most %s" % [context, schema["maximum"]])
	return {"valid": true}


func _is_namespaced(value: String) -> bool:
	var separator := value.find(".")
	return separator > 0 and separator < value.length() - 1


func _invalid(message: String) -> Dictionary:
	return {"valid": false, "message": message}


func _fail(message: String) -> bool:
	last_error = message
	return false
