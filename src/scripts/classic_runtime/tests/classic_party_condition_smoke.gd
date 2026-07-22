extends Node

const FreeFallScript = preload("res://shared_assets/spells/free_fall.gd")
const DiscoverSecretScript = preload("res://shared_assets/spells/discover_secret.gd")

var failures: Array[String] = []
var original_time := 0
var original_global_effects: Dictionary = {}
var original_conditions: Dictionary = {}
var original_map_secrets: Dictionary = {}


func _ready() -> void:
	call_deferred("_run_smoke")


func _run_smoke() -> void:
	await get_tree().process_frame
	original_time = GameGlobal.time
	original_global_effects = GameGlobal.global_effects.duplicate(true)
	original_conditions = GameGlobal.classic_party_conditions.duplicate(true)
	original_map_secrets = GameGlobal.map.mapsecrets.duplicate(true)

	GameGlobal.time = 3500
	GameGlobal.global_effects["FeatherFall"] = {"Duration": 0}
	GameGlobal.classic_party_conditions.clear()

	var free_fall = FreeFallScript.new()
	_expect_equal(
		free_fall.apply_classic_duration(5),
		5,
		"the native spell resource reaches the live Classic condition state"
	)
	_expect_equal(
		GameGlobal.global_effects["FeatherFall"]["Duration"],
		14500,
		"the exact counter is exposed through Remake's Feather Fall duration"
	)
	_expect_equal(
		free_fall.apply_classic_duration(3),
		5,
		"a shorter recast leaves the live condition unchanged"
	)

	GameGlobal.reduce_classic_party_conditions(2)
	_expect_equal(
		GameGlobal.classic_party_conditions.get("6"),
		3,
		"combat-round reduction updates the exact Classic counter"
	)

	var saved_conditions := GameGlobal.classic_party_conditions.duplicate(true)
	GameGlobal.classic_party_conditions.clear()
	GameGlobal.global_effects["FeatherFall"]["Duration"] = 0
	GameGlobal._restore_classic_party_conditions(saved_conditions)
	_expect_equal(
		GameGlobal.classic_party_conditions.get("6"),
		3,
		"the Classic counter survives its save payload round trip"
	)
	_expect_equal(
		GameGlobal.global_effects["FeatherFall"]["Duration"],
		7300,
		"restoring the exact counter also restores its native HUD duration"
	)

	GameGlobal.time = 3600
	GameGlobal._advance_classic_party_conditions(3500, GameGlobal.time)
	_expect_equal(
		GameGlobal.classic_party_conditions.get("6"),
		2,
		"crossing a game-hour boundary reduces the live condition once"
	)
	_expect_equal(
		GameGlobal.global_effects["FeatherFall"]["Duration"],
		7200,
		"hourly reduction remains synchronized with the native display"
	)

	var secret_position := Vector2i(89, 89)
	GameGlobal.map.mapsecrets[secret_position] = [0, "TestSecret", 0.25]
	GameGlobal.global_effects["Awareness"] = {"Duration": 0}
	_expect_equal(
		GameGlobal.map_secret_detection_succeeds(secret_position, 0.2),
		true,
		"a native secret roll below its detection chance succeeds"
	)
	_expect_equal(
		GameGlobal.map_secret_detection_succeeds(secret_position, 0.5),
		false,
		"a failed native secret roll remains hidden without Awareness"
	)
	var discover_secret = DiscoverSecretScript.new()
	_expect_equal(
		discover_secret.apply_classic_duration(7),
		7,
		"Discover Secret reaches the live Classic Awareness condition"
	)
	_expect_equal(
		GameGlobal.map_secret_detection_succeeds(secret_position, 0.5),
		true,
		"Classic Awareness guarantees the native secret-detection check"
	)

	_finish()


func _expect_equal(actual: Variant, expected: Variant, description: String) -> void:
	if actual == expected:
		print("PASS: %s" % description)
		return
	failures.append("%s (expected %s, got %s)" % [description, expected, actual])
	push_error("FAIL: %s" % failures[-1])


func _finish() -> void:
	GameGlobal.time = original_time
	GameGlobal.global_effects = original_global_effects
	GameGlobal.classic_party_conditions = original_conditions
	GameGlobal.map.mapsecrets = original_map_secrets
	if failures.is_empty():
		print("Classic party-condition smoke passed.")
		get_tree().quit(0)
		return
	printerr("Classic party-condition smoke failed: %s" % "; ".join(failures))
	get_tree().quit(1)
