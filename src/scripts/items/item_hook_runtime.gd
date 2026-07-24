class_name ItemHookRuntime
extends RefCounted

const HOOK_SPECS := {
	"equip": {
		"source": "_on_equipping_source",
		"method": "_on_equipping",
		"parameters": ["character", "item", "instance", "definition"],
		"aliases": {
			"_character": "character",
			"_item": "item",
			"_instance": "instance",
			"_definition": "definition",
		},
	},
	"unequip": {
		"source": "_on_unequipping_source",
		"method": "_on_unequipping",
		"parameters": ["character", "item", "instance", "definition"],
		"aliases": {
			"_character": "character",
			"_item": "item",
			"_instance": "instance",
			"_definition": "definition",
		},
	},
	"field_use": {
		"source": "_on_field_use_source",
		"method": "_on_field_use",
		"parameters": ["character", "item", "instance", "definition"],
		"aliases": {
			"_character": "character",
			"_item": "item",
			"_instance": "instance",
			"_definition": "definition",
		},
	},
	"combat_use": {
		"source": "_on_combat_use_source",
		"method": "_on_combat_use",
		"parameters": ["character", "item", "instance", "definition"],
		"aliases": {
			"_character": "character",
			"_item": "item",
			"_instance": "instance",
			"_definition": "definition",
		},
	},
	"drop": {
		"source": "_on_drop_source",
		"method": "_on_drop",
		"parameters": ["character", "item", "instance", "definition"],
		"aliases": {
			"_character": "character",
			"_item": "item",
			"_instance": "instance",
			"_definition": "definition",
		},
	},
	"melee_accuracy": {
		"source": "_calculate_melee_accuracy_source",
		"method": "_calculate_melee_accuracy",
		"parameters": [
			"attacker",
			"defender",
			"item",
			"instance",
			"definition",
		],
		"aliases": {
			"_attacker": "attacker",
			"_defender": "defender",
			"_weapon": "item",
			"_instance": "instance",
			"_definition": "definition",
		},
	},
	"melee_attack": {
		"source": "_calculate_melee_attack_source",
		"method": "_calculate_melee_attack",
		"parameters": [
			"attacker",
			"defender",
			"item",
			"instance",
			"definition",
			"is_crit",
			"crit_mult",
		],
		"aliases": {
			"_attacker": "attacker",
			"_defender": "defender",
			"_weapon": "item",
			"_instance": "instance",
			"_definition": "definition",
			"_is_crit": "is_crit",
			"_crit_mult": "crit_mult",
		},
	},
}

var last_errors: Array[String] = []
var _compiled_hooks: Dictionary = {}
var _compiled_traits: Dictionary = {}
var _compiled_custom_spells: Dictionary = {}


func clear() -> void:
	last_errors.clear()
	_compiled_hooks.clear()
	_compiled_traits.clear()
	_compiled_custom_spells.clear()


func has_hook(definition: ItemDefinition, hook_kind: String) -> bool:
	if definition == null or not HOOK_SPECS.has(hook_kind):
		return false
	var sources: Dictionary = definition.hooks().get("sources", {})
	return sources.has(str(HOOK_SPECS[hook_kind]["source"]))


func invoke(
	definition: ItemDefinition,
	instance: ItemInstance,
	hook_kind: String,
	arguments: Array,
	legacy_view: Dictionary,
) -> Dictionary:
	last_errors.clear()
	if definition == null or instance == null:
		return _failure("Item hook requires a definition and instance")
	if definition.definition_id != instance.definition_id:
		return _failure(
			"Item hook definition %s does not own instance %s"
			% [definition.definition_id, instance.instance_id]
		)
	if not HOOK_SPECS.has(hook_kind):
		return _failure("Unknown item hook kind '%s'" % hook_kind)
	if not has_hook(definition, hook_kind):
		return {
			"ok": true,
			"handled": false,
			"value": null,
			"errors": [],
		}
	var spec: Dictionary = HOOK_SPECS[hook_kind]
	var expected_context_count := int(spec["parameters"].size()) - 3
	if hook_kind in ["melee_accuracy", "melee_attack"]:
		expected_context_count = int(spec["parameters"].size()) - 3
	if arguments.size() != expected_context_count:
		return _failure(
			"Item hook '%s' expected %d context arguments, received %d"
			% [hook_kind, expected_context_count, arguments.size()]
		)
	var script := _compiled_hook(definition, hook_kind)
	if script == null:
		return {
			"ok": false,
			"handled": true,
			"value": null,
			"errors": last_errors.duplicate(),
		}
	var call_arguments: Array = []
	match hook_kind:
		"melee_accuracy":
			call_arguments = [
				arguments[0],
				arguments[1],
				legacy_view,
				instance,
				definition,
			]
		"melee_attack":
			call_arguments = [
				arguments[0],
				arguments[1],
				legacy_view,
				instance,
				definition,
				arguments[2],
				arguments[3],
			]
		_:
			call_arguments = [
				arguments[0],
				legacy_view,
				instance,
				definition,
			]
	return {
		"ok": true,
		"handled": true,
		"value": script.callv(str(spec["method"]), call_arguments),
		"errors": [],
	}


func trait_bindings(
	definition: ItemDefinition,
	inflicted := false,
) -> Dictionary:
	last_errors.clear()
	if definition == null:
		return _failure("Item trait resolution requires a definition")
	var hooks := definition.hooks()
	var collection_name := "meleeInflictedTraits" if inflicted else "traits"
	var descriptors: Variant = hooks.get(collection_name, [])
	if not (descriptors is Array):
		return _failure(
			"Item definition %s has an invalid %s descriptor collection"
			% [definition.definition_id, collection_name]
		)
	var bindings: Array[Dictionary] = []
	for descriptor_index: int in descriptors.size():
		var descriptor_value: Variant = descriptors[descriptor_index]
		if not (descriptor_value is Array) or descriptor_value.size() < 2:
			return _failure(
				"Item definition %s %s[%d] is invalid"
				% [definition.definition_id, collection_name, descriptor_index]
			)
		var descriptor: Array = descriptor_value
		var trait_name := str(descriptor[0])
		var script := _trait_script(definition, trait_name)
		if script == null:
			return {
				"ok": false,
				"bindings": [],
				"errors": last_errors.duplicate(),
			}
		var arguments: Variant = descriptor[1]
		bindings.append({
			"name": trait_name,
			"script": script,
			"arguments": arguments.duplicate(true)
				if arguments is Array or arguments is Dictionary else arguments,
			"chance": float(descriptor[2]) if descriptor.size() > 2 else 1.0,
		})
	return {"ok": true, "bindings": bindings, "errors": []}


func custom_spell_script(definition: ItemDefinition) -> GDScript:
	last_errors.clear()
	if definition == null:
		_failure("Custom item spell resolution requires a definition")
		return null
	var sources: Dictionary = definition.hooks().get("sources", {})
	var source_value: Variant = sources.get("custom_spell_source")
	if not (source_value is String) or str(source_value).strip_edges().is_empty():
		return null
	if _compiled_custom_spells.has(definition.definition_id):
		return _compiled_custom_spells[definition.definition_id]
	var script := _compile_source(
		str(source_value),
		"custom spell",
		definition.definition_id,
	)
	if script != null:
		_compiled_custom_spells[definition.definition_id] = script
	return script


func _compiled_hook(
	definition: ItemDefinition,
	hook_kind: String,
) -> GDScript:
	var cache_key := "%s\n%s" % [definition.definition_id, hook_kind]
	if _compiled_hooks.has(cache_key):
		return _compiled_hooks[cache_key]
	var spec: Dictionary = HOOK_SPECS[hook_kind]
	var sources: Dictionary = definition.hooks().get("sources", {})
	var source_field := str(spec["source"])
	var source_value: Variant = sources.get(source_field)
	if not (source_value is String):
		_failure(
			"Item definition %s hook %s is not source text"
			% [definition.definition_id, source_field]
		)
		return null
	var wrapper := "static func %s(%s):\n" % [
		spec["method"],
		", ".join(spec["parameters"]),
	]
	for alias_name: Variant in spec["aliases"]:
		wrapper += "\tvar %s = %s\n" % [
			alias_name,
			spec["aliases"][alias_name],
		]
	wrapper += _indent_source(str(source_value))
	var script := _compile_source(
		wrapper,
		"hook %s" % source_field,
		definition.definition_id,
	)
	if script != null:
		_compiled_hooks[cache_key] = script
	return script


func _trait_script(
	definition: ItemDefinition,
	trait_name: String,
) -> GDScript:
	var cache_key := "%s\n%s" % [definition.definition_id, trait_name]
	if _compiled_traits.has(cache_key):
		return _compiled_traits[cache_key]
	var script: GDScript = null
	if trait_name.ends_with(".gd"):
		var resource_path := "res://shared_assets/traits/%s" % trait_name
		var loaded: Variant = load(resource_path)
		if loaded is GDScript:
			script = loaded
		else:
			_failure(
				"Item definition %s trait resource %s could not be loaded"
				% [definition.definition_id, resource_path]
			)
	else:
		var source_field := "%s_source" % trait_name
		var sources: Dictionary = definition.hooks().get("sources", {})
		var source_value: Variant = sources.get(source_field)
		if source_value is String:
			script = _compile_source(
				str(source_value),
				"trait %s" % trait_name,
				definition.definition_id,
			)
		else:
			_failure(
				"Item definition %s trait %s has no source"
				% [definition.definition_id, trait_name]
			)
	if script != null:
		_compiled_traits[cache_key] = script
	return script


func _compile_source(
	source: String,
	kind: String,
	definition_id: String,
) -> GDScript:
	var script := GDScript.new()
	script.set_source_code(source)
	var reload_error := script.reload()
	if reload_error != OK:
		_failure(
			"Item definition %s %s failed to compile: %s"
			% [definition_id, kind, error_string(reload_error)]
		)
		return null
	return script


static func _indent_source(source: String) -> String:
	var lines := source.replace("\r\n", "\n").replace("\r", "\n").split("\n")
	while not lines.is_empty() and str(lines[0]).is_empty():
		lines.remove_at(0)
	while not lines.is_empty() and str(lines[-1]).is_empty():
		lines.remove_at(lines.size() - 1)
	if lines.is_empty():
		return "\tpass\n"
	var result := ""
	for line_value: Variant in lines:
		result += "\t%s\n" % str(line_value)
	return result


func _failure(message: String) -> Dictionary:
	last_errors.append(message)
	return {
		"ok": false,
		"handled": false,
		"value": null,
		"errors": last_errors.duplicate(),
	}
