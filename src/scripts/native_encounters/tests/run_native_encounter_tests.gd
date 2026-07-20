extends SceneTree


const NativeEncounterRuntimeScript = preload(
	"res://scripts/native_encounters/native_encounter_runtime.gd"
)
const NativeEncounterBookScript = preload(
	"res://scripts/native_encounters/native_encounter_book.gd"
)
const NativeEncounterBranchScript = preload(
	"res://scripts/native_encounters/native_encounter_branch.gd"
)
const FIXTURE_PATH := (
	"res://Campaigns/City of Bywater/Special Encounters/encounters.json"
)

var _failures: Array[String] = []


func _initialize() -> void:
	var document := _read_fixture()
	if document.is_empty():
		_finish()
		return
	_test_loader()
	_test_response_modes(document)
	_test_nested_route_and_state_round_trip(document)
	_test_legacy_complex_encounter_branch()
	_test_validation_rejects_missing_results(document)
	_finish()


func _test_loader() -> void:
	var book := NativeEncounterBookScript.new()
	var loaded: Dictionary = book.load_file(FIXTURE_PATH)
	_expect(loaded.get("status") == "ok", "the native encounter book loads JSON")
	_expect(
		loaded.get("encounterIds", []).has("native_nested_proof"),
		"the loader exposes encounter identifiers"
	)
func _test_response_modes(document: Dictionary) -> void:
	var action_runtime: RefCounted = _configured_runtime(document, {})
	_expect(not action_runtime.get_action_choices().is_empty(), "action choices are exposed")
	var action_result: Dictionary = action_runtime.respond(
		"action",
		"inspect_door",
		{"flags": {}}
	)
	_expect(action_result.get("resultId") == "first_inspection", "action routes to a result")
	_expect(not bool(action_result.get("close", true)), "an encounter can remain open")

	var repeat_runtime: RefCounted = _configured_runtime(document, {})
	var repeat_result: Dictionary = repeat_runtime.respond(
		"action",
		"inspect_door",
		{"flags": {"native_fixture_door_seen": true}}
	)
	_expect(repeat_result.get("resultId") == "already_seen", "flag conditions route results")

	for response: Dictionary in [
		{"kind": "spokenWord", "value": "  WATERFORD  "},
		{"kind": "spell", "value": "Open Lock"},
		{"kind": "item", "value": "Necklace of Keys"},
	]:
		var runtime: RefCounted = _configured_runtime(document, {})
		var outcome: Dictionary = runtime.respond(response["kind"], response["value"], {})
		_expect(outcome.get("resultId") == "open", "%s responses match" % response["kind"])

	var skill_runtime: RefCounted = _configured_runtime(document, {})
	var skill_result: Dictionary = skill_runtime.respond(
		"rogueSkill",
		"Pick_Lock",
		{"stat": 80.0, "roll": 10.0}
	)
	_expect(skill_result.get("resultId") == "open", "rogue skill success routes correctly")
	var failed_skill_runtime: RefCounted = _configured_runtime(document, {})
	var failed_skill: Dictionary = failed_skill_runtime.respond(
		"rogueSkill",
		"Pick_Lock",
		{"stat": 20.0, "roll": 10.0}
	)
	_expect(failed_skill.get("resultId") == "locked", "rogue skill failure routes correctly")


func _test_nested_route_and_state_round_trip(document: Dictionary) -> void:
	var state: Dictionary = {}
	var runtime: RefCounted = _configured_runtime(document, state)
	var opened: Dictionary = runtime.respond("spokenWord", "waterford", {})
	_expect(opened.get("nextEncounter") == "native_nested_followup", "results can jump encounters")
	_expect(
		runtime.get_current_encounter_id() == "native_nested_followup",
		"the nested encounter becomes active"
	)
	_expect(
		state.get("values", {}).get("native_fixture_door_open") == true,
		"encounter result state is recorded"
	)
	_expect(
		state.get("mapMutations", {}).has("waterford_door_open"),
		"map mutations are recorded"
	)
	_expect(
		state.get("actionPointMutations", {}).has("waterford_door_action_point"),
		"action-point mutations are recorded"
	)

	var restored_value: Variant = JSON.parse_string(JSON.stringify(state))
	var restored_state: Dictionary = restored_value if restored_value is Dictionary else {}
	var restored_runtime := NativeEncounterRuntimeScript.new()
	var configured: Dictionary = restored_runtime.configure(
		document,
		"native_nested_followup",
		restored_state
	)
	_expect(configured.get("status") == "ok", "saved encounter state reloads")
	_expect(
		restored_state.get("mapMutations", {}).has("waterford_door_open"),
		"map mutations survive save serialization"
	)
	_expect(
		restored_state.get("actionPointMutations", {}).has("waterford_door_action_point"),
		"action-point mutations survive save serialization"
	)
	var completed: Dictionary = restored_runtime.respond("action", "enter_passage", {})
	_expect(completed.get("resultId") == "complete", "the restored nested encounter can finish")
	_expect(bool(completed.get("close", false)), "the final result closes the encounter")


func _test_validation_rejects_missing_results(document: Dictionary) -> void:
	var invalid := document.duplicate(true)
	invalid["encounters"]["native_nested_followup"]["responses"]["action"][0]["result"] = "missing"
	var validation: Dictionary = NativeEncounterRuntimeScript.new().validate_document(invalid)
	_expect(validation.get("status") == "error", "missing response results are rejected")


func _test_legacy_complex_encounter_branch() -> void:
	var branch: Dictionary = NativeEncounterBranchScript.create(2)
	_expect(
		NativeEncounterBranchScript.is_branch(branch),
		"legacy scripts can request a native complex encounter"
	)
	_expect(branch.get("encounter") == "CE2", "complex encounter requests retain their target")
	_expect(
		not NativeEncounterBranchScript.is_branch({"kind": "complexEncounter"}),
		"complex encounter requests require a target"
	)


func _configured_runtime(document: Dictionary, state: Dictionary) -> RefCounted:
	var runtime := NativeEncounterRuntimeScript.new()
	var configured: Dictionary = runtime.configure(document, "native_nested_proof", state)
	_expect(configured.get("status") == "ok", "fixture configures")
	return runtime


func _read_fixture() -> Dictionary:
	var file := FileAccess.open(FIXTURE_PATH, FileAccess.READ)
	if file == null:
		_failures.append("fixture can be opened")
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		_failures.append("fixture is valid JSON")
		return {}
	return parsed


func _expect(condition: bool, description: String) -> void:
	if not condition:
		_failures.append(description)


func _finish() -> void:
	if _failures.is_empty():
		print("Native encounter tests passed")
		quit(0)
		return
	for failure: String in _failures:
		push_error("Native encounter test failed: %s" % failure)
	quit(1)
