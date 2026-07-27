extends Node

const MusicSettingsScript = preload("res://scripts/audio/music_settings.gd")

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	await get_tree().process_frame
	if not UI.main_menu.initial_profile_ready:
		await UI.main_menu.initial_profile_loaded
	var profile_settings := ConfigFile.new()
	var profile_path := (
		Paths.profilesfolderpath
		+ Paths.currentProfileFolderName
		+ "/profile_settings.cfg"
	)
	_expect(
		profile_settings.load(profile_path) == OK,
		"the selected profile audio settings load"
	)
	var expected_music_db := MusicSettingsScript.volume_db_from_setting(
		float(profile_settings.get_value("VOLUME", "volume_music", 50.0))
	)
	var expected_sound_db := MusicSettingsScript.volume_db_from_setting(
		float(profile_settings.get_value("VOLUME", "volume_sound", 50.0))
	)
	_expect(
		is_equal_approx(MusicStreamPlayer.volume_db, expected_music_db),
		"startup applies the selected profile music volume"
	)
	_expect(
		is_equal_approx(SfxPlayer.volume_db, expected_sound_db),
		"startup applies the selected profile sound volume"
	)
	var resources := NodeAccess.__Resources()
	_expect(resources != null, "audio resources are available")
	if resources != null and not resources.sounds_book.has("camp.wav"):
		# Main loads shared sounds with the selected campaign; the isolated
		# smoke has no campaign, so initialize that same shared sound catalog.
		resources.load_sound_ressources("res://shared_assets/sounds/")
	_expect(
		resources != null and resources.sounds_book.has("camp.wav"),
		"camp.wav is loaded"
	)
	_expect(
		resources != null and resources.musics_book.has("camp.mod"),
		"camp.mod is loaded"
	)
	if not _failures.is_empty():
		_finish()
		return

	MusicStreamPlayer.set_type_music_choice("Camp", "camp.mod")
	SfxPlayer.stop()
	SfxPlayer.stream = null
	GameGlobal.camping = true
	UI.ow_hud._play_camp_audio()
	await get_tree().process_frame

	_expect(
		SfxPlayer.stream == resources.sounds_book["camp.wav"],
		"entering camp plays the Classic camp sound"
	)
	_expect(
		str(MusicStreamPlayer.currently_playing.get("path", "")).ends_with(
			"camp.mod"
		),
		"entering camp selects the Camp music"
	)
	_finish()


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("Audio runtime smoke passed")
		get_tree().quit(0)
		return
	for failure: String in _failures:
		push_error("Audio runtime smoke failed: %s" % failure)
	get_tree().quit(1)
