extends RefCounted


const SCHEMA_VERSION := 1
const MAX_RESULT_ROUTES := 32

var _encounters: Dictionary = {}
var _state: Dictionary = {}
var _current_encounter_id := ""


func configure(document: Dictionary, encounter_id: String, campaign_state: Dictionary) -> Dictionary:
	var validation := validate_document(document)
	if validation.get("status") != "ok":
		return validation

	_encounters = document["encounters"].duplicate(true)
	_state = campaign_state
	_ensure_state_shape()
	return enter_encounter(encounter_id)


func validate_document(document: Dictionary) -> Dictionary:
	if int(document.get("schemaVersion", -1)) != SCHEMA_VERSION:
		return _error("Native encounter data must use schemaVersion %d" % SCHEMA_VERSION)
	var encounters_value: Variant = document.get("encounters")
	if not encounters_value is Dictionary or encounters_value.is_empty():
		return _error("Native encounter data must contain an encounters dictionary")

	var encounters: Dictionary = encounters_value
	for encounter_id_value: Variant in encounters:
		var encounter_id := str(encounter_id_value)
		var encounter_value: Variant = encounters[encounter_id_value]
		if not encounter_value is Dictionary:
			return _error("Native encounter %s must be a dictionary" % encounter_id)
		var encounter: Dictionary = encounter_value
		var results_value: Variant = encounter.get("results", {})
		if not results_value is Dictionary:
			return _error("Native encounter %s results must be a dictionary" % encounter_id)
		var result_ids: Dictionary = results_value
		var responses_value: Variant = encounter.get("responses", {})
		if not responses_value is Dictionary:
			return _error("Native encounter %s responses must be a dictionary" % encounter_id)
		for response_kind_value: Variant in responses_value:
			var rules_value: Variant = responses_value[response_kind_value]
			if not rules_value is Array:
				return _error(
					"Native encounter %s response %s must be an array" % [
						encounter_id,
						str(response_kind_value),
					]
				)
			for rule_value: Variant in rules_value:
				if not rule_value is Dictionary:
					return _error("Native encounter %s has an invalid response rule" % encounter_id)
				var rule: Dictionary = rule_value
				for result_key: String in ["result", "successResult", "failureResult"]:
					if rule.has(result_key) and not result_ids.has(str(rule[result_key])):
						return _error(
							"Native encounter %s response references missing result %s" % [
								encounter_id,
								str(rule[result_key]),
							]
						)
		var fallback_result := str(encounter.get("fallbackResult", ""))
		if not fallback_result.is_empty() and not result_ids.has(fallback_result):
			return _error(
				"Native encounter %s references missing fallback result %s" % [
					encounter_id,
					fallback_result,
				]
			)
		for result_id_value: Variant in result_ids:
			var result_id := str(result_id_value)
			var result_value: Variant = result_ids[result_id_value]
			if not result_value is Dictionary:
				return _error("Native encounter %s result %s must be a dictionary" % [
					encounter_id,
					result_id,
				])
			var result: Dictionary = result_value
			for route_key: String in ["nextResult", "otherwise"]:
				if result.has(route_key) and not result_ids.has(str(result[route_key])):
					return _error(
						"Native encounter %s result %s references missing result %s" % [
							encounter_id,
							result_id,
							str(result[route_key]),
						]
					)
			var next_encounter := str(result.get("nextEncounter", ""))
			if not next_encounter.is_empty() and not encounters.has(next_encounter):
				return _error(
					"Native encounter %s result %s references missing encounter %s" % [
						encounter_id,
						result_id,
						next_encounter,
					]
				)
	return {"status": "ok"}


func enter_encounter(encounter_id: String) -> Dictionary:
	if not _encounters.has(encounter_id):
		return _error("Native encounter %s was not found" % encounter_id)
	_current_encounter_id = encounter_id
	return {
		"status": "ok",
		"encounterId": _current_encounter_id,
	}


func get_current_encounter_id() -> String:
	return _current_encounter_id


func get_current_encounter() -> Dictionary:
	return _encounters.get(_current_encounter_id, {})


func get_allowed_responses() -> Dictionary:
	var encounter := get_current_encounter()
	var configured_value: Variant = encounter.get("allow", {})
	var configured: Dictionary = configured_value if configured_value is Dictionary else {}
	var responses_value: Variant = encounter.get("responses", {})
	var responses: Dictionary = responses_value if responses_value is Dictionary else {}
	return {
		"action": bool(configured.get("action", responses.has("action"))),
		"spokenWord": bool(configured.get("spokenWord", responses.has("spokenWord"))),
		"spell": bool(configured.get("spell", responses.has("spell"))),
		"item": bool(configured.get("item", responses.has("item"))),
		"rogueSkill": bool(configured.get("rogueSkill", responses.has("rogueSkill"))),
		"stop": bool(configured.get("stop", true)),
	}


func get_action_choices() -> Array:
	var choices: Array = []
	for rule: Dictionary in _response_rules("action"):
		var choice_id := str(rule.get("id", rule.get("value", "")))
		if choice_id.is_empty():
			continue
		choices.append({
			"id": choice_id,
			"label": str(rule.get("label", choice_id)),
		})
	return choices


func get_skill_configuration(skill_name: String) -> Dictionary:
	for rule: Dictionary in _response_rules("rogueSkill"):
		if _matches(rule, skill_name):
			return rule.duplicate(true)
	return {}


func respond(response_kind: String, value: Variant, context := {}) -> Dictionary:
	if _current_encounter_id.is_empty():
		return _error("No native encounter is active")

	var result_id := ""
	var matched_rule: Dictionary = {}
	for rule: Dictionary in _response_rules(response_kind):
		if _matches(rule, value):
			matched_rule = rule
			break

	if response_kind == "rogueSkill" and not matched_rule.is_empty():
		var stat := float(context.get("stat", 0.0))
		var difficulty := float(matched_rule.get("difficulty", 0.0))
		var roll := float(context.get("roll", randf() * 100.0))
		var succeeds := roll < clampf(stat - difficulty, 0.0, 100.0)
		result_id = str(matched_rule.get(
			"successResult" if succeeds else "failureResult",
			""
		))
		context["skillSucceeded"] = succeeds
	elif not matched_rule.is_empty():
		result_id = str(matched_rule.get("result", ""))

	if result_id.is_empty():
		result_id = str(get_current_encounter().get("fallbackResult", ""))
	if result_id.is_empty():
		return _error(
			"Native encounter %s has no result for %s response %s" % [
				_current_encounter_id,
				response_kind,
				str(value),
			]
		)
	return _resolve_result(result_id, context)


func _resolve_result(initial_result_id: String, context: Dictionary) -> Dictionary:
	var encounter_id := _current_encounter_id
	var encounter := get_current_encounter()
	var results: Dictionary = encounter.get("results", {})
	var result_id := initial_result_id
	var route_count := 0
	var routed_effects: Array = []

	while route_count < MAX_RESULT_ROUTES:
		route_count += 1
		if not results.has(result_id):
			return _error("Native encounter %s result %s was not found" % [
				encounter_id,
				result_id,
			])
		var result: Dictionary = results[result_id]
		var branch_target := _branch_target(result, context)
		if not branch_target.is_empty():
			result_id = branch_target
			continue

		var next_result := str(result.get("nextResult", ""))
		if not next_result.is_empty():
			_record_result(encounter_id, result_id, result)
			routed_effects.append_array(_effect_array(result.get("effects", [])))
			result_id = next_result
			continue

		_record_result(encounter_id, result_id, result)
		routed_effects.append_array(_effect_array(result.get("effects", [])))
		var next_encounter := str(result.get("nextEncounter", ""))
		if not next_encounter.is_empty():
			var enter_result := enter_encounter(next_encounter)
			if enter_result.get("status") != "ok":
				return enter_result
		return {
			"status": "ok",
			"encounterId": encounter_id,
			"resultId": result_id,
			"effects": routed_effects,
			"nextEncounter": next_encounter,
			"close": bool(result.get("close", next_encounter.is_empty())),
			"context": context,
		}
	return _error("Native encounter result routing exceeded %d steps" % MAX_RESULT_ROUTES)


func _branch_target(result: Dictionary, context: Dictionary) -> String:
	var branches_value: Variant = result.get("branches", [])
	if branches_value is Array:
		for branch_value: Variant in branches_value:
			if not branch_value is Dictionary:
				continue
			var branch: Dictionary = branch_value
			var condition_value: Variant = branch.get("condition", {})
			if condition_value is Dictionary and _condition_matches(condition_value, context):
				return str(branch.get("result", ""))
	return str(result.get("otherwise", "")) if result.has("branches") else ""


func _condition_matches(condition: Dictionary, context: Dictionary) -> bool:
	if condition.has("all"):
		for child: Variant in condition["all"]:
			if not child is Dictionary or not _condition_matches(child, context):
				return false
		return true
	if condition.has("any"):
		for child: Variant in condition["any"]:
			if child is Dictionary and _condition_matches(child, context):
				return true
		return false
	if condition.has("not"):
		var child_value: Variant = condition["not"]
		return child_value is Dictionary and not _condition_matches(child_value, context)

	var source := str(condition.get("source", "encounterState"))
	var key := str(condition.get("key", ""))
	var actual: Variant = null
	match source:
		"context":
			actual = context.get(key)
		"flag":
			var flags_value: Variant = context.get("flags", {})
			if flags_value is Dictionary:
				actual = flags_value.get(key)
		"resultCount":
			actual = int(_state["resultCounts"].get(key, 0))
		_:
			actual = _state["values"].get(key)

	if condition.has("equals"):
		return actual == condition["equals"]
	if condition.has("notEquals"):
		return actual != condition["notEquals"]
	if condition.has("atLeast"):
		return float(actual) >= float(condition["atLeast"])
	return bool(actual)


func _record_result(encounter_id: String, result_id: String, result: Dictionary) -> void:
	var result_key := "%s/%s" % [encounter_id, result_id]
	_state["resultCounts"][result_key] = int(_state["resultCounts"].get(result_key, 0)) + 1
	for effect: Dictionary in _effect_array(result.get("effects", [])):
		var effect_type := str(effect.get("type", ""))
		var mutation_id := str(effect.get("id", ""))
		match effect_type:
			"setState":
				if not mutation_id.is_empty():
					_state["values"][mutation_id] = effect.get("value")
			"mapMutation":
				if not mutation_id.is_empty():
					_state["mapMutations"][mutation_id] = effect.duplicate(true)
			"actionPointMutation":
				if not mutation_id.is_empty():
					_state["actionPointMutations"][mutation_id] = effect.duplicate(true)


func _response_rules(response_kind: String) -> Array:
	var responses_value: Variant = get_current_encounter().get("responses", {})
	if not responses_value is Dictionary:
		return []
	var rules_value: Variant = responses_value.get(response_kind, [])
	return rules_value if rules_value is Array else []


func _matches(rule: Dictionary, value: Variant) -> bool:
	var candidate := _normalized(value)
	var configured_values: Array = []
	if rule.has("values") and rule["values"] is Array:
		configured_values = rule["values"]
	elif rule.has("value"):
		configured_values = [rule["value"]]
	elif rule.has("id"):
		configured_values = [rule["id"]]
	elif rule.has("skill"):
		configured_values = [rule["skill"]]
	for configured: Variant in configured_values:
		if _normalized(configured) == candidate:
			return true
	return false


func _normalized(value: Variant) -> String:
	return str(value).strip_edges().to_lower()


func _effect_array(value: Variant) -> Array:
	var effects: Array = []
	if not value is Array:
		return effects
	for effect: Variant in value:
		if effect is Dictionary:
			effects.append(effect.duplicate(true))
	return effects


func _ensure_state_shape() -> void:
	for key: String in ["values", "resultCounts", "mapMutations", "actionPointMutations"]:
		if not _state.get(key) is Dictionary:
			_state[key] = {}


func _error(message: String) -> Dictionary:
	return {
		"status": "error",
		"message": message,
	}
