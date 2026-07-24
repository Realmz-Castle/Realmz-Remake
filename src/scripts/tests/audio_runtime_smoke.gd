extends Node

var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	await get_tree().process_frame
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
