extends SceneTree

const MusicSettingsScript = preload("res://scripts/audio/music_settings.gd")

var _failures: Array[String] = []


func _init() -> void:
	_expect_equal(
		MusicSettingsScript.default_music_choice("Forest"),
		"outdoor.mod",
		"missing profile music uses the native Forest default"
	)
	_expect_equal(
		MusicSettingsScript.default_music_choice("Camp"),
		"camp.mod",
		"missing profile music uses the native Camp default"
	)
	var profile_choices: Dictionary = (
		MusicSettingsScript.DEFAULT_MUSIC_BY_TYPE.duplicate()
	)
	profile_choices["Forest"] = "No Music"
	_expect_equal(
		MusicSettingsScript.default_music_choice("Forest"),
		"outdoor.mod",
		"profile choices do not mutate the native defaults"
	)
	_expect_equal(
		MusicSettingsScript.volume_db_from_setting(50.0),
		-25.0,
		"profile load and the settings slider share one volume conversion"
	)
	_expect_equal(
		MusicSettingsScript.volume_db_from_setting(100.0),
		0.0,
		"the maximum music setting resolves to zero decibels"
	)
	_finish()


func _expect_equal(actual: Variant, expected: Variant, message: String) -> void:
	if actual == expected:
		return
	_failures.append("%s: expected %s, got %s" % [
		message,
		str(expected),
		str(actual),
	])


func _finish() -> void:
	if _failures.is_empty():
		print("Audio settings tests passed")
		quit(0)
		return
	for failure: String in _failures:
		push_error(failure)
	quit(1)
