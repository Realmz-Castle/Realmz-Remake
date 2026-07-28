class_name GameplayRuleRegistry
extends RefCounted

const BUILTIN_CATALOG := "res://scripts/scenario_runtime/rules/catalog.json"

var providers: Dictionary = {}
var presets: Dictionary = {}
var last_error := ""


func load_builtin_catalog() -> bool:
	last_error = ""
	var file := FileAccess.open(BUILTIN_CATALOG, FileAccess.READ)
	if file == null:
		return _fail("Built-in gameplay rule catalog is unavailable")
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return _fail("Built-in gameplay rule catalog must be a JSON object")
	for descriptor: Variant in parsed.get("providers", []):
		if not (descriptor is Dictionary) or not register_provider_descriptor(descriptor):
			return false
	for preset: Variant in parsed.get("presets", []):
		if not (preset is Dictionary) or not register_preset(preset):
			return false
	return true


func register_provider_descriptor(descriptor: Dictionary) -> bool:
	var provider := GameplayRuleProvider.new()
	var validation := provider.configure(descriptor)
	if not bool(validation.get("valid", false)):
		return _fail(str(validation.get("message", "Invalid gameplay rule provider")))
	if providers.has(provider.id):
		return _fail("Duplicate gameplay rule provider ID '%s'" % provider.id)
	providers[provider.id] = provider
	return true


func register_preset(descriptor: Dictionary) -> bool:
	var id := str(descriptor.get("id", "")).strip_edges()
	if id.is_empty() or id.find(".") <= 0:
		return _fail("Gameplay rule presets require a namespaced ID")
	if presets.has(id):
		return _fail("Duplicate gameplay rule preset ID '%s'" % id)
	var selections: Variant = descriptor.get("domains")
	if not (selections is Dictionary):
		return _fail("Gameplay rule preset '%s' requires domain selections" % id)
	for domain: String in GameplayRuleSet.DOMAINS:
		if not (selections.get(domain) is Dictionary):
			return _fail("Gameplay rule preset '%s' is missing domain '%s'" % [id, domain])
		var provider_id := str(selections[domain].get("providerId", ""))
		var provider: GameplayRuleProvider = providers.get(provider_id)
		if provider == null:
			return _fail("Gameplay rule preset '%s' requires unavailable provider '%s'" % [id, provider_id])
		if provider.domain != domain:
			return _fail("Gameplay rule preset '%s' assigns provider '%s' to the wrong domain" % [id, provider_id])
	presets[id] = descriptor.duplicate(true)
	return true


func resolve(preset_id: String, overrides := {}) -> Dictionary:
	var preset: Variant = presets.get(preset_id)
	if not (preset is Dictionary):
		return {"status": "error", "message": "Gameplay rule preset '%s' is unavailable" % preset_id}
	if not (overrides is Dictionary):
		return {"status": "error", "message": "Gameplay rule overrides must be a dictionary"}
	var resolved_domains: Dictionary = {}
	for domain: String in GameplayRuleSet.DOMAINS:
		var base_selection: Dictionary = preset["domains"][domain]
		var override: Dictionary = overrides.get(domain, {})
		var provider_id := str(override.get("providerId", base_selection["providerId"]))
		var provider: GameplayRuleProvider = providers.get(provider_id)
		if provider == null:
			return {"status": "error", "message": "Gameplay provider '%s' is unavailable" % provider_id}
		if provider.domain != domain:
			return {"status": "error", "message": "Gameplay provider '%s' cannot serve domain '%s'" % [provider_id, domain]}
		var base_options: Dictionary = base_selection.get("options", {})
		var option_overrides: Dictionary = base_options.duplicate(true)
		if override.get("options") is Dictionary:
			option_overrides.merge(override["options"], true)
		var option_result := provider.resolve_options(option_overrides)
		if str(option_result.get("status", "")) != "ok":
			return option_result
		resolved_domains[domain] = {
			"providerId": provider.id,
			"apiVersion": provider.api_version,
			"options": option_result["options"],
		}
	var ruleset := GameplayRuleSet.new()
	ruleset.configure(preset_id, resolved_domains)
	return {"status": "ok", "ruleset": ruleset}


func restore(snapshot: Dictionary) -> Dictionary:
	var validation := GameplayRuleSet.validate_snapshot(snapshot)
	if not bool(validation.get("valid", false)):
		return {"status": "error", "message": validation.get("message", "Invalid gameplay rules")}
	var restored_domains: Dictionary = {}
	for domain: String in GameplayRuleSet.DOMAINS:
		var selection: Dictionary = snapshot["domains"][domain]
		var provider_id := str(selection["providerId"])
		var provider: GameplayRuleProvider = providers.get(provider_id)
		if provider == null:
			return {"status": "error", "message": "Saved gameplay provider '%s' is unavailable" % provider_id}
		if provider.api_version != int(selection["apiVersion"]):
			return {"status": "error", "message": "Saved gameplay provider '%s' has an incompatible API version" % provider_id}
		var option_validation := provider.validate_options(selection["options"])
		if not bool(option_validation.get("valid", false)):
			return {"status": "error", "message": option_validation.get("message", "Invalid saved options")}
		restored_domains[domain] = selection.duplicate(true)
	var ruleset := GameplayRuleSet.new()
	ruleset.configure(str(snapshot.get("presetId", "")), restored_domains)
	return {"status": "ok", "ruleset": ruleset}


func catalog() -> Dictionary:
	var provider_descriptors: Array = []
	for provider: GameplayRuleProvider in providers.values():
		provider_descriptors.append(provider.descriptor())
	provider_descriptors.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return str(left["id"]) < str(right["id"])
	)
	var preset_descriptors: Array = presets.values()
	preset_descriptors.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return str(left["id"]) < str(right["id"])
	)
	return {
		"schemaVersion": 1,
		"providers": provider_descriptors,
		"presets": preset_descriptors,
	}


func _fail(message: String) -> bool:
	last_error = message
	return false
