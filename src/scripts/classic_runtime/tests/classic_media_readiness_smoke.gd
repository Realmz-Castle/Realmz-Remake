extends Node

const BundleScript = preload("res://scripts/classic_runtime/classic_campaign_bundle.gd")
const ReadinessScript = preload("res://scripts/classic_runtime/classic_campaign_readiness.gd")
const FIXTURE := \
	"res://scripts/classic_runtime/tests/fixtures/providence_authoritative_export"

var failures := 0


func _ready() -> void:
	_test_contract_validation()
	_test_media_classification()
	if failures > 0:
		push_error("Classic media readiness smoke failed with %d failure(s)." % failures)
		get_tree().quit(1)
		return
	print("Classic media readiness smoke passed.")
	get_tree().quit()


func _test_contract_validation() -> void:
	var bundle = _fixture_bundle(false)
	if bundle == null:
		return
	bundle.documents["scripts"]["triggers"][-1]["actions"][0][
		"mediaRequiredForProgression"
	] = "yes"
	_expect(
		not bundle._validate_document_contract(),
		"bundle contract rejects a non-boolean media readiness marker"
	)
	_expect(
		bundle.last_error.contains("mediaRequiredForProgression"),
		"invalid media marker reports its action field"
	)


func _test_media_classification() -> void:
	var optional_bundle = _fixture_bundle(false)
	if optional_bundle == null:
		return
	var optional_report: Dictionary = ReadinessScript.new().inspect(optional_bundle)
	_expect(bool(optional_report.get("ready", false)), "missing optional media remains launchable")
	_expect_equal(
		optional_report.get("totals", {}).get("progressionBlockers"),
		0,
		"optional media produces no progression blockers"
	)
	for expected: Array in [
		["missing-picture", 9000],
		["unresolved-sound-identity", 9001],
		["missing-player-map", 9002],
	]:
		_expect(
			_has_diagnostic(
				optional_report,
				str(expected[0]),
				int(expected[1]),
				"fidelity-fallback"
			),
			"optional media reports %s with source context" % expected[0]
		)

	var required_bundle = _fixture_bundle(true)
	if required_bundle == null:
		return
	var required_report: Dictionary = ReadinessScript.new().inspect(required_bundle)
	_expect(
		not bool(required_report.get("ready", true)),
		"missing progression-required media blocks launch"
	)
	_expect_equal(
		required_report.get("totals", {}).get("progressionBlockers"),
		3,
		"each required media reference produces one blocker"
	)
	for expected: Array in [
		["missing-picture", 9000],
		["unresolved-sound-identity", 9001],
		["missing-player-map", 9002],
	]:
		_expect(
			_has_diagnostic(
				required_report,
				str(expected[0]),
				int(expected[1]),
				"progression-blocker"
			),
			"required media reports %s with source context" % expected[0]
		)


func _fixture_bundle(required_for_progression: bool):
	var bundle = BundleScript.new()
	if not bundle.load_from_directory(FIXTURE):
		_expect(false, "producer fixture loads: %s" % bundle.last_error)
		return null
	var triggers: Array = bundle.documents["scripts"]["triggers"]
	triggers.append_array([
		_media_trigger(9000, 27, 32767, required_for_progression),
		_media_trigger(9001, 9, 32767, required_for_progression),
		_media_trigger(9002, 29, 19, required_for_progression),
	])
	_expect(
		bundle._validate_document_contract(),
		"bundle contract accepts boolean media readiness markers: %s" % bundle.last_error
	)
	bundle._build_indexes()
	return bundle


func _media_trigger(
	record_index: int,
	code: int,
	reference_id: int,
	required_for_progression: bool
) -> Dictionary:
	return {
		"id": "Data DD:media-readiness:%d" % record_index,
		"source": "Data DD",
		"recordIndex": record_index,
		"levelType": "land",
		"levelIndex": 0,
		"active": true,
		"coordinate": {"x": 0, "y": 0},
		"actions": [{
			"slot": 0,
			"rawCode": code,
			"code": code,
			"id": reference_id,
			"label": "Media readiness proof",
			"category": "Media",
			"gosub": false,
			"mediaRequiredForProgression": required_for_progression,
		}],
	}


func _has_diagnostic(
	report: Dictionary,
	code: String,
	record_index: int,
	classification: String
) -> bool:
	for value: Variant in report.get("diagnostics", []):
		if (
			value is Dictionary
			and str(value.get("code", "")) == code
			and str(value.get("source", "")) == "Data DD"
			and int(value.get("recordIndex", -1)) == record_index
			and int(value.get("slot", -1)) == 0
			and str(value.get("classification", "")) == classification
		):
			return true
	return false


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
		return
	failures += 1
	push_error("FAIL: %s" % label)


func _expect_equal(actual: Variant, expected: Variant, label: String) -> void:
	_expect(actual == expected, "%s (expected %s, got %s)" % [label, expected, actual])
