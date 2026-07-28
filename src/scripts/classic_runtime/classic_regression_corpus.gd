class_name ClassicRegressionCorpus
extends RefCounted

const BundleScript = preload(
	"res://scripts/classic_runtime/classic_campaign_bundle.gd"
)
const ExecutionAuditScript = preload(
	"res://scripts/classic_runtime/classic_execution_audit.gd"
)
const InterpreterScript = preload(
	"res://scripts/scenario_runtime/handlers/classic_opcode_runtime.gd"
)
const StateScript = preload(
	"res://scripts/classic_runtime/classic_runtime_state.gd"
)

const SCHEMA_VERSION := 1
const SUITE_VERSION := 1
const DEFAULT_MANIFEST := (
	"res://scripts/classic_runtime/tests/fixtures/"
	+ "classic_regression_corpus.json"
)
const CLASSIFICATIONS := [
	"fixture-proven",
	"source-backed",
	"inferred",
	"malformed",
	"unknown",
]


func run(manifest_path: String = DEFAULT_MANIFEST) -> Dictionary:
	var parsed := _read_json(manifest_path)
	if not bool(parsed.get("ok", false)):
		return _empty_report(
			manifest_path,
			_failure(
				"",
				"",
				manifest_path,
				str(parsed.get("message", "Corpus manifest could not be read"))
			)
		)
	return run_manifest(parsed["value"], manifest_path)


func run_manifest(
	manifest: Dictionary,
	manifest_path: String = "<memory>"
) -> Dictionary:
	var failures: Array = []
	var scenarios: Array = []
	var domains: Dictionary = {}
	var contexts: Dictionary = {}
	var classifications := _empty_classifications()
	if int(manifest.get("schemaVersion", 0)) != SCHEMA_VERSION:
		failures.append(_failure(
			"",
			"",
			manifest_path,
			"Corpus manifest schemaVersion must be %d" % SCHEMA_VERSION
		))
	var members: Variant = manifest.get("members", [])
	if not (members is Array) or members.size() < 3:
		failures.append(_failure(
			"",
			"",
			manifest_path,
			"Corpus manifest must contain at least three scenario members"
		))
	else:
		for member_value: Variant in members:
			if not (member_value is Dictionary):
				failures.append(_failure(
					"",
					"",
					manifest_path,
					"Corpus member is not a dictionary"
				))
				continue
			var scenario_report := _run_member(member_value)
			scenarios.append(scenario_report)
			failures.append_array(scenario_report.get("failures", []))
			for domain_value: Variant in scenario_report.get("domains", []):
				domains[str(domain_value)] = true
			for context_value: Variant in scenario_report.get(
				"executionContexts",
				{}
			):
				var context := str(context_value)
				contexts[context] = int(contexts.get(context, 0)) + int(
					scenario_report["executionContexts"][context].get(
						"actions",
						0
					)
				)
			for classification: String in CLASSIFICATIONS:
				classifications[classification].append_array(
					scenario_report.get("classifications", {}).get(
						classification,
						[]
					)
				)
	var required_domains: Variant = manifest.get("requiredDomains", [])
	if required_domains is Array:
		for domain_value: Variant in required_domains:
			var domain := str(domain_value)
			if not domains.has(domain):
				failures.append(_failure(
					"",
					"",
					manifest_path,
					"Corpus did not execute required domain '%s'" % domain
				))
	var required_contexts: Variant = manifest.get("requiredContexts", [])
	if required_contexts is Array:
		for context_value: Variant in required_contexts:
			var context := str(context_value)
			if not contexts.has(context):
				failures.append(_failure(
					"",
					"",
					manifest_path,
					"Corpus did not inventory required execution context '%s'"
					% context
				))
	return {
		"schemaVersion": SCHEMA_VERSION,
		"suiteVersion": SUITE_VERSION,
		"corpusId": str(manifest.get("id", "")),
		"manifestPath": manifest_path,
		"ok": failures.is_empty(),
		"scenarios": scenarios,
		"domains": _sorted_keys(domains),
		"executionContexts": contexts,
		"classifications": classifications,
		"classificationCounts": _classification_counts(classifications),
		"failures": failures,
	}


func format_failure(failure: Dictionary) -> String:
	var scenario_id := str(failure.get("scenarioId", ""))
	var case_id := str(failure.get("caseId", ""))
	var record_id := str(failure.get("recordId", ""))
	var parts: Array[String] = []
	if not scenario_id.is_empty():
		parts.append("[%s]" % scenario_id)
	if not case_id.is_empty():
		parts.append("[%s]" % case_id)
	if not record_id.is_empty():
		parts.append("[%s]" % record_id)
	parts.append(str(failure.get("message", "Unknown corpus failure")))
	return " ".join(parts)


func _run_member(member: Dictionary) -> Dictionary:
	var scenario_id := str(member.get("scenarioId", ""))
	var scenario_name := str(member.get("name", scenario_id))
	var bundle_path := str(member.get("bundlePath", ""))
	var failures: Array = []
	var cases: Array = []
	var executed_keys: Dictionary = {}
	var domains: Dictionary = {}
	var bundle = BundleScript.new()
	if scenario_id.is_empty() or bundle_path.is_empty():
		failures.append(_failure(
			scenario_id,
			"",
			bundle_path,
			"Corpus member requires scenarioId and bundlePath"
		))
		return _member_report(
			member,
			cases,
			domains,
			{},
			_empty_classifications(),
			failures
		)
	if str(member.get("availability", "")) != "repository-reduced-fixture":
		failures.append(_failure(
			scenario_id,
			"",
			bundle_path,
			"Corpus member must declare repository-reduced-fixture availability"
		))
	if str(member.get("legalNote", "")).strip_edges().is_empty():
		failures.append(_failure(
			scenario_id,
			"",
			bundle_path,
			"Corpus member must document its legal/provenance boundary"
		))
	if not bundle.load_from_directory(bundle_path):
		failures.append(_failure(
			scenario_id,
			"",
			"campaign.json",
			"Bundle loader rejected %s: %s" % [bundle_path, bundle.last_error]
		))
		return _member_report(
			member,
			cases,
			domains,
			{},
			_empty_classifications(),
			failures
		)
	if str(bundle.manifest.get("campaignKind", "")) != "classic-compiled":
		failures.append(_failure(
			scenario_id,
			"",
			"campaign.json",
			"Corpus member is not a classic-compiled campaign bundle"
		))
	if str(bundle.manifest.get("id", "")) != scenario_id:
		failures.append(_failure(
			scenario_id,
			"",
			"campaign.json",
			"Loaded campaign id '%s' does not match corpus member"
			% str(bundle.manifest.get("id", ""))
		))
	if str(bundle.manifest.get("name", "")) != scenario_name:
		failures.append(_failure(
			scenario_id,
			"",
			"campaign.json",
			"Loaded campaign name '%s' does not match corpus member"
			% str(bundle.manifest.get("name", ""))
		))
	var audit: Dictionary = ExecutionAuditScript.new().inspect(bundle)
	for context_value: Variant in member.get("expectedContexts", []):
		var context := str(context_value)
		if not audit.get("contexts", {}).has(context):
			failures.append(_failure(
				scenario_id,
				"",
				"classic/scripts.json",
				"Execution audit did not inventory expected context '%s'"
				% context
			))
	for case_value: Variant in member.get("cases", []):
		if not (case_value is Dictionary):
			failures.append(_failure(
				scenario_id,
				"",
				"classic/scripts.json",
				"Scenario case is not a dictionary"
			))
			continue
		var case_report := _run_case(
			scenario_id,
			bundle,
			case_value
		)
		cases.append(case_report)
		failures.append_array(case_report.get("failures", []))
		if bool(case_report.get("ok", false)):
			for domain_value: Variant in case_value.get("domains", []):
				domains[str(domain_value)] = true
			for key_value: Variant in case_report.get("executedKeys", []):
				executed_keys[str(key_value)] = true
	var classifications := _classify_actions(
		scenario_id,
		bundle,
		audit,
		executed_keys
	)
	return _member_report(
		member,
		cases,
		domains,
		audit.get("contexts", {}),
		classifications,
		failures
	)


func _run_case(
	scenario_id: String,
	bundle: ClassicCampaignBundle,
	case_data: Dictionary
) -> Dictionary:
	var case_id := str(case_data.get("id", ""))
	var trigger_id := str(case_data.get("triggerId", ""))
	var failures: Array = []
	var state = StateScript.new()
	state.configure_from_bundle(bundle)
	var setup: Variant = case_data.get("setup", {})
	if setup is Dictionary:
		var position: Variant = setup.get("position", {})
		if position is Dictionary and not position.is_empty():
			state.level_type = str(
				position.get("levelType", state.level_type)
			)
			state.set_position(
				int(position.get("levelIndex", state.level_index)),
				int(position.get("x", state.x)),
				int(position.get("y", state.y))
			)
		for quest_value: Variant in setup.get("questFlags", []):
			state.set_quest_flag(int(quest_value))
	var interpreter = InterpreterScript.new()
	interpreter.configure(bundle, state)
	var start_slot := int(case_data.get("startSlot", 0))
	var execution_context: Variant = case_data.get("executionContext", {})
	if not (execution_context is Dictionary):
		execution_context = {}
	if not interpreter.begin_trigger(
		trigger_id,
		start_slot,
		execution_context
	):
		failures.append(_failure(
			scenario_id,
			case_id,
			trigger_id,
			"Interpreter could not begin trigger at slot %d: %s"
			% [start_slot, interpreter.last_error]
		))
		return {
			"id": case_id,
			"recordId": trigger_id,
			"ok": false,
			"steps": [],
			"trace": [],
			"executedKeys": [],
			"failures": failures,
		}
	var step_results: Array = []
	var steps: Variant = case_data.get("steps", [])
	if not (steps is Array):
		steps = []
	for step_index: int in range(steps.size()):
		var step: Variant = steps[step_index]
		if not (step is Dictionary):
			failures.append(_failure(
				scenario_id,
				case_id,
				trigger_id,
				"Step %d is not a dictionary" % step_index
			))
			continue
		var result: Dictionary
		match str(step.get("operation", "run")):
			"resumeEncounter":
				result = interpreter.resume_encounter(
					int(step.get("choice", 0))
				)
			_:
				result = interpreter.run_until_yield()
		step_results.append(result)
		var mismatches: Array[String] = []
		_compare_subset(
			result,
			step.get("expect", {}),
			"",
			mismatches
		)
		for one_of_value: Variant in step.get("oneOf", []):
			if not (one_of_value is Dictionary):
				continue
			var path := str(one_of_value.get("path", ""))
			var choices: Variant = one_of_value.get("values", [])
			var actual: Variant = _value_at_path(result, path)
			var matched_choice := false
			if choices is Array:
				for choice: Variant in choices:
					if _values_equal(actual, choice):
						matched_choice = true
						break
			if not matched_choice:
				mismatches.append(
					"%s expected one of %s, got %s"
					% [path, choices, actual]
				)
		for mismatch: String in mismatches:
			failures.append(_failure(
				scenario_id,
				case_id,
				trigger_id,
				"Step %d %s" % [step_index, mismatch]
			))
	var expected_trace: Variant = case_data.get("expectedTrace", [])
	if expected_trace is Array and not expected_trace.is_empty() \
			and not _values_equal(interpreter.trace, expected_trace):
		failures.append(_failure(
			scenario_id,
			case_id,
			trigger_id,
			"Trace mismatch: expected %s, got %s"
			% [expected_trace, interpreter.trace]
		))
	var snapshot := state.snapshot()
	for assertion_value: Variant in case_data.get("stateAssertions", []):
		if not (assertion_value is Dictionary):
			continue
		var path := str(assertion_value.get("path", ""))
		var actual: Variant = _value_at_path(snapshot, path)
		var expected: Variant = assertion_value.get("equals")
		if not _values_equal(actual, expected):
			failures.append(_failure(
				scenario_id,
				case_id,
				trigger_id,
				"State %s expected %s, got %s"
				% [path, expected, actual]
			))
	if case_data.has("expectedCallStackDepth") \
			and interpreter.call_stack.size() != int(
				case_data["expectedCallStackDepth"]
			):
		failures.append(_failure(
			scenario_id,
			case_id,
			trigger_id,
			"Call stack expected depth %d, got %d"
			% [
				int(case_data["expectedCallStackDepth"]),
				interpreter.call_stack.size(),
			]
		))
	var executed_keys: Dictionary = {}
	for trace_value: Variant in interpreter.trace:
		if not (trace_value is Dictionary):
			continue
		executed_keys[_action_key(
			str(trace_value.get("triggerId", "")),
			int(trace_value.get("slot", -1)),
			int(trace_value.get("code", 0))
		)] = true
	return {
		"id": case_id,
		"recordId": trigger_id,
		"ok": failures.is_empty(),
		"steps": step_results,
		"trace": interpreter.trace.duplicate(true),
		"executedKeys": _sorted_keys(executed_keys),
		"failures": failures,
	}


func _classify_actions(
	scenario_id: String,
	bundle: ClassicCampaignBundle,
	audit: Dictionary,
	executed_keys: Dictionary
) -> Dictionary:
	var classifications := _empty_classifications()
	for action_value: Variant in audit.get("actions", []):
		if not (action_value is Dictionary):
			continue
		var action: Dictionary = action_value
		var confidence := _record_confidence(bundle, action)
		var classification := "unknown"
		var action_key := _action_key(
			str(action.get("recordId", "")),
			int(action.get("slot", -1)),
			int(action.get("code", 0))
		)
		if executed_keys.has(action_key):
			classification = "fixture-proven"
		elif _is_malformed_action(action, audit.get("diagnostics", [])) \
				or confidence == "malformed":
			classification = "malformed"
		elif confidence in ["inferred", "heuristic"]:
			classification = "inferred"
		elif str(action.get("support", "")) == "unknown" \
				or confidence in ["", "unknown"]:
			classification = "unknown"
		else:
			classification = "source-backed"
		classifications[classification].append({
			"scenarioId": scenario_id,
			"recordId": str(action.get("recordId", "")),
			"source": str(action.get("source", "")),
			"recordIndex": int(action.get("recordIndex", -1)),
			"slot": int(action.get("slot", -1)),
			"opcode": int(action.get("code", 0)),
			"confidence": confidence,
			"executionContexts": action.get(
				"executionContexts",
				[]
			).duplicate(),
		})
	return classifications


func _record_confidence(
	bundle: ClassicCampaignBundle,
	action: Dictionary
) -> String:
	var record: Dictionary = {}
	match str(action.get("storageContext", "")):
		"data-ed-result":
			record = bundle.get_encounter(
				"simple",
				int(action.get("recordIndex", -1))
			)
		"data-ed2-result":
			record = bundle.get_encounter(
				"complex",
				int(action.get("recordIndex", -1))
			)
		_:
			record = bundle.get_trigger(str(action.get("recordId", "")))
	var provenance: Variant = record.get("provenance", {})
	return str(provenance.get("confidence", "")) \
		if provenance is Dictionary else ""


func _is_malformed_action(action: Dictionary, diagnostics: Array) -> bool:
	for diagnostic_value: Variant in diagnostics:
		if not (diagnostic_value is Dictionary):
			continue
		var code := str(diagnostic_value.get("code", ""))
		if not code.contains("malformed"):
			continue
		if str(diagnostic_value.get("source", "")) \
				== str(action.get("source", "")) \
				and int(diagnostic_value.get("recordIndex", -1)) \
				== int(action.get("recordIndex", -1)):
			return true
	return false


func _compare_subset(
	actual: Variant,
	expected: Variant,
	path: String,
	mismatches: Array[String]
) -> void:
	if expected is Dictionary:
		if not (actual is Dictionary):
			mismatches.append(
				"%s expected dictionary, got %s" % [path, actual]
			)
			return
		for key_value: Variant in expected:
			var key := str(key_value)
			var child_path := key if path.is_empty() else "%s.%s" % [path, key]
			if not actual.has(key_value):
				mismatches.append("%s is missing" % child_path)
				continue
			_compare_subset(
				actual[key_value],
				expected[key_value],
				child_path,
				mismatches
			)
		return
	if expected is Array:
		if not (actual is Array):
			mismatches.append(
				"%s expected array, got %s" % [path, actual]
			)
			return
		if actual.size() != expected.size():
			mismatches.append(
				"%s expected %d entries, got %d"
				% [path, expected.size(), actual.size()]
			)
			return
		for index: int in range(expected.size()):
			_compare_subset(
				actual[index],
				expected[index],
				"%s[%d]" % [path, index],
				mismatches
			)
		return
	if not _values_equal(actual, expected):
		mismatches.append("%s expected %s, got %s" % [path, expected, actual])


func _values_equal(actual: Variant, expected: Variant) -> bool:
	if (actual is int or actual is float) \
			and (expected is int or expected is float):
		return float(actual) == float(expected)
	if actual is Array and expected is Array:
		if actual.size() != expected.size():
			return false
		for index: int in range(actual.size()):
			if not _values_equal(actual[index], expected[index]):
				return false
		return true
	if actual is Dictionary and expected is Dictionary:
		if actual.size() != expected.size():
			return false
		for key: Variant in actual:
			if not expected.has(key) \
					or not _values_equal(actual[key], expected[key]):
				return false
		return true
	return actual == expected


func _value_at_path(value: Variant, path: String) -> Variant:
	var current: Variant = value
	for segment: String in path.split(".", false):
		if current is Dictionary and current.has(segment):
			current = current[segment]
		else:
			return null
	return current


func _member_report(
	member: Dictionary,
	cases: Array,
	domains: Dictionary,
	contexts: Dictionary,
	classifications: Dictionary,
	failures: Array
) -> Dictionary:
	return {
		"scenarioId": str(member.get("scenarioId", "")),
		"name": str(member.get("name", "")),
		"bundlePath": str(member.get("bundlePath", "")),
		"availability": str(member.get("availability", "")),
		"legalNote": str(member.get("legalNote", "")),
		"suiteVersion": SUITE_VERSION,
		"ok": failures.is_empty(),
		"cases": cases,
		"domains": _sorted_keys(domains),
		"executionContexts": contexts,
		"classifications": classifications,
		"classificationCounts": _classification_counts(classifications),
		"failures": failures,
	}


func _empty_report(manifest_path: String, failure: Dictionary) -> Dictionary:
	return {
		"schemaVersion": SCHEMA_VERSION,
		"suiteVersion": SUITE_VERSION,
		"corpusId": "",
		"manifestPath": manifest_path,
		"ok": false,
		"scenarios": [],
		"domains": [],
		"executionContexts": {},
		"classifications": _empty_classifications(),
		"classificationCounts": _classification_counts(
			_empty_classifications()
		),
		"failures": [failure],
	}


func _empty_classifications() -> Dictionary:
	var result: Dictionary = {}
	for classification: String in CLASSIFICATIONS:
		result[classification] = []
	return result


func _classification_counts(classifications: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for classification: String in CLASSIFICATIONS:
		result[classification] = classifications.get(
			classification,
			[]
		).size()
	return result


func _failure(
	scenario_id: String,
	case_id: String,
	record_id: String,
	message: String
) -> Dictionary:
	return {
		"scenarioId": scenario_id,
		"caseId": case_id,
		"recordId": record_id,
		"message": message,
	}


func _read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {
			"ok": false,
			"message": "Could not open %s" % path,
		}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return {
			"ok": false,
			"message": "%s is not a JSON object" % path,
		}
	return {"ok": true, "value": parsed}


func _action_key(record_id: String, slot: int, opcode: int) -> String:
	return "%s|%d|%d" % [record_id, slot, opcode]


func _sorted_keys(values: Dictionary) -> Array:
	var result: Array = values.keys()
	result.sort()
	return result
