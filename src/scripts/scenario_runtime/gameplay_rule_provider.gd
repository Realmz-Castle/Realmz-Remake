class_name GameplayRuleProvider
extends RefCounted

const VALID_DOMAINS := [
	"mapTime",
	"combat",
	"inventory",
	"character",
	"presentation",
	"persistence",
]
const VALID_OPTION_TYPES := ["boolean", "enum", "integer", "float"]

var id := ""
var api_version := 0
var domain := ""
var option_schema: Dictionary = {}
var default_options: Dictionary = {}


func configure(descriptor: Dictionary) -> Dictionary:
	id = str(descriptor.get("id", "")).strip_edges()
	api_version = int(descriptor.get("apiVersion", 0))
	domain = str(descriptor.get("domain", "")).strip_edges()
	option_schema = descriptor.get("options", {}).duplicate(true)
	default_options = descriptor.get("defaults", {}).duplicate(true)
	if id.is_empty() or id.find(".") <= 0:
		return _invalid("Gameplay rule provider requires a namespaced ID")
	if api_version <= 0:
		return _invalid("Gameplay rule provider '%s' requires a positive API version" % id)
	if domain not in VALID_DOMAINS:
		return _invalid("Gameplay rule provider '%s' has invalid domain '%s'" % [id, domain])
	if not (option_schema is Dictionary) or not (default_options is Dictionary):
		return _invalid("Gameplay rule provider '%s' has invalid option metadata" % id)
	for option_id: String in option_schema:
		var schema: Variant = option_schema[option_id]
		if not (schema is Dictionary):
			return _invalid("Provider '%s' option '%s' must be an object" % [id, option_id])
		if str(schema.get("type", "")) not in VALID_OPTION_TYPES:
			return _invalid("Provider '%s' option '%s' has an invalid type" % [id, option_id])
		if not default_options.has(option_id):
			return _invalid("Provider '%s' option '%s' requires a default" % [id, option_id])
	var validation := validate_options(default_options)
	if not bool(validation.get("valid", false)):
		return validation
	return {"valid": true}


func resolve_options(overrides: Dictionary) -> Dictionary:
	var resolved := default_options.duplicate(true)
	for option_id: String in overrides:
		if not option_schema.has(option_id):
			return {
				"status": "error",
				"message": "Provider '%s' does not define option '%s'" % [id, option_id],
			}
		resolved[option_id] = overrides[option_id]
	var validation := validate_options(resolved)
	if not bool(validation.get("valid", false)):
		return {"status": "error", "message": validation.get("message", "Invalid options")}
	return {"status": "ok", "options": resolved}


func validate_options(options: Dictionary) -> Dictionary:
	for option_id: String in option_schema:
		if not options.has(option_id):
			return _invalid("Provider '%s' is missing option '%s'" % [id, option_id])
		var schema: Dictionary = option_schema[option_id]
		var value: Variant = options[option_id]
		match str(schema.get("type", "")):
			"boolean":
				if not (value is bool):
					return _invalid(_type_message(option_id, "boolean"))
			"enum":
				var values: Variant = schema.get("values", [])
				if not (value is String) or not (values is Array) or value not in values:
					return _invalid("Provider '%s' option '%s' is outside its enum" % [id, option_id])
			"integer":
				if not (value is int or value is float) or int(value) != value:
					return _invalid(_type_message(option_id, "integer"))
				var range_error := _validate_range(option_id, int(value), schema)
				if not range_error.is_empty():
					return _invalid(range_error)
			"float":
				if not (value is int or value is float):
					return _invalid(_type_message(option_id, "number"))
				var range_error := _validate_range(option_id, float(value), schema)
				if not range_error.is_empty():
					return _invalid(range_error)
	for option_id: String in options:
		if not option_schema.has(option_id):
			return _invalid("Provider '%s' does not define option '%s'" % [id, option_id])
	return {"valid": true}


func descriptor() -> Dictionary:
	return {
		"id": id,
		"apiVersion": api_version,
		"domain": domain,
		"options": option_schema.duplicate(true),
		"defaults": default_options.duplicate(true),
	}


func _validate_range(option_id: String, value: Variant, schema: Dictionary) -> String:
	if schema.has("minimum") and value < schema["minimum"]:
		return "Provider '%s' option '%s' is below its minimum" % [id, option_id]
	if schema.has("maximum") and value > schema["maximum"]:
		return "Provider '%s' option '%s' is above its maximum" % [id, option_id]
	return ""


func _type_message(option_id: String, expected: String) -> String:
	return "Provider '%s' option '%s' must be a %s" % [id, option_id, expected]


func _invalid(message: String) -> Dictionary:
	return {"valid": false, "message": message}
