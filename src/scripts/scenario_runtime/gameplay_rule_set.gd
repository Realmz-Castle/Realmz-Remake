class_name GameplayRuleSet
extends RefCounted

const SAVE_SCHEMA_VERSION := 1
const DOMAINS := [
	"mapTime",
	"combat",
	"inventory",
	"character",
	"presentation",
	"persistence",
]

var preset_id := ""
var domains: Dictionary = {}


func configure(resolved_preset_id: String, resolved_domains: Dictionary) -> void:
	preset_id = resolved_preset_id
	domains = resolved_domains.duplicate(true)


func provider_id(domain: String) -> String:
	return str(domains.get(domain, {}).get("providerId", ""))


func options(domain: String) -> Dictionary:
	return domains.get(domain, {}).get("options", {}).duplicate(true)


func snapshot() -> Dictionary:
	return {
		"schemaVersion": SAVE_SCHEMA_VERSION,
		"presetId": preset_id,
		"domains": domains.duplicate(true),
		"locked": true,
	}


static func validate_snapshot(value: Variant) -> Dictionary:
	if not (value is Dictionary):
		return _invalid("Saved gameplay rules must be a dictionary")
	var snapshot: Dictionary = value
	if int(snapshot.get("schemaVersion", 0)) != SAVE_SCHEMA_VERSION:
		return _invalid("Saved gameplay rule schema is not supported")
	if snapshot.get("locked") != true:
		return _invalid("Saved gameplay rules must be playthrough-locked")
	var saved_domains: Variant = snapshot.get("domains")
	if not (saved_domains is Dictionary):
		return _invalid("Saved gameplay rule domains are invalid")
	for domain: String in DOMAINS:
		var selection: Variant = saved_domains.get(domain)
		if not (selection is Dictionary):
			return _invalid("Saved gameplay rules are missing domain '%s'" % domain)
		if not (selection.get("providerId") is String) \
				or str(selection.get("providerId")).is_empty():
			return _invalid("Saved gameplay domain '%s' is missing its provider" % domain)
		if int(selection.get("apiVersion", 0)) <= 0:
			return _invalid("Saved gameplay domain '%s' has an invalid API version" % domain)
		if not (selection.get("options") is Dictionary):
			return _invalid("Saved gameplay domain '%s' has invalid options" % domain)
	return {"valid": true}


static func _invalid(message: String) -> Dictionary:
	return {"valid": false, "message": message}
