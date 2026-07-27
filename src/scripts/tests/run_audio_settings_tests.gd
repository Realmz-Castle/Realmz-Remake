extends SceneTree

const MusicSettingsScript = preload("res://scripts/audio/music_settings.gd")

var _failures: Array[String] = []


func _init() -> void:
	_expect_equal(
		MusicSettingsScript.default_music_choice("Forest"),
		"outdoor.mod",
		"missing profile music uses the native Forest default"
	)
	var shipped_profile := ConfigFile.new()
	_expect_equal(
		shipped_profile.load(
			"res://Profiles/Default Profile/profile_settings.cfg"
		),
		OK,
		"the shipped default profile settings load"
	)
	_expect_equal(
		shipped_profile.get_value("MUSIC", "Forest", "No Music"),
		MusicSettingsScript.default_music_choice("Forest"),
		"the shipped default profile selects Outdoor music for Forest maps"
	)
	_expect_equal(
		float(shipped_profile.get_value("VOLUME", "volume_sound", -1.0)),
		100.0,
		"the shipped default profile starts with audible sound"
	)
	_expect_equal(
		float(shipped_profile.get_value("VOLUME", "volume_music", -1.0)),
		100.0,
		"the shipped default profile starts with audible music"
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
	_expect_equal(
		MusicSettingsScript.setting_from_volume_db(-50.0),
		0.0,
		"a silent runtime volume displays as zero percent"
	)
	_expect_equal(
		MusicSettingsScript.setting_from_volume_db(-25.0),
		50.0,
		"a half-volume runtime setting displays as fifty percent"
	)
	_expect_equal(
		MusicSettingsScript.setting_from_volume_db(0.0),
		100.0,
		"the maximum runtime volume displays as one hundred percent"
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
