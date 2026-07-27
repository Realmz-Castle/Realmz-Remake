extends Node

const SETTINGS_SCENE := preload(
	"res://scenes/UI/HUD/Settings/settings_rect.tscn"
)
const CHECKBOX_PATH := (
	"HBoxContainer/VBoxContainer/MusicSettingsRect/"
	+ "VBoxContainer/VolumeVbox/MapDebugCheckButton"
)
const GAME_SPEED_BAR_PATH := (
	"HBoxContainer/VBoxContainer/MusicSettingsRect/"
	+ "VBoxContainer/VolumeVbox/GameSpeedLabel/GameSpeedHScrollBar"
)
const GAME_SPEED_LABEL_PATH := (
	"HBoxContainer/VBoxContainer/MusicSettingsRect/"
	+ "VBoxContainer/VolumeVbox/GameSpeedLabel/GameSpeedVLabel"
)
const TEST_SETTINGS_PATH := "user://settings_runtime_smoke.cfg"

var failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var original_settings_path := Paths.settingspath
	Paths.settingspath = TEST_SETTINGS_PATH
	_remove_test_settings()
	ConfigFile.new().save(TEST_SETTINGS_PATH)
	GameGlobal.map_debug_overlays_enabled = true
	GameGlobal.set_game_speed_percent(GameGlobal.DEFAULT_GAME_SPEED_PERCENT)

	var main: Control = get_parent() as Control
	var map: Map = main.get_node("Map") as Map

	var settings: NinePatchRect = SETTINGS_SCENE.instantiate() as NinePatchRect
	add_child(settings)
	await get_tree().process_frame
	settings.call("_initialize")
	var checkbox: CheckButton = settings.get_node(CHECKBOX_PATH)
	var speed_bar: HScrollBar = settings.get_node(GAME_SPEED_BAR_PATH)
	var speed_label: Label = settings.get_node(GAME_SPEED_LABEL_PATH)
	_expect(checkbox.button_pressed, "the checkbox defaults to showing overlays")
	_expect(
		is_equal_approx(speed_bar.value, GameGlobal.DEFAULT_GAME_SPEED_PERCENT),
		"the game speed slider defaults to one hundred percent"
	)
	_expect(speed_label.text == "100%", "the default game speed label is correct")

	checkbox.button_pressed = false
	await get_tree().process_frame
	_expect(
		not GameGlobal.map_debug_overlays_enabled,
		"unchecking updates the global setting"
	)
	_expect(not map.show_scripts, "unchecking hides AP rectangles and labels")
	_expect(not map.debuglabel.visible, "unchecking hides the map debug text")
	_expect(map.debuglabel.text.is_empty(), "unchecking clears stale debug text")
	_expect_saved_overlay_value(false, "unchecking persists the setting")

	checkbox.button_pressed = true
	await get_tree().process_frame
	_expect(
		GameGlobal.map_debug_overlays_enabled,
		"checking updates the global setting"
	)
	_expect(map.show_scripts, "checking restores AP rectangles and labels")
	_expect(map.debuglabel.visible, "checking restores the map debug text")
	_expect_saved_overlay_value(true, "checking persists the setting")

	speed_bar.value = GameGlobal.MAX_GAME_SPEED_PERCENT
	await get_tree().process_frame
	_expect(
		is_equal_approx(
			GameGlobal.game_speed_percent,
			GameGlobal.MAX_GAME_SPEED_PERCENT
		),
		"the slider applies the maximum game speed"
	)
	_expect(
		is_equal_approx(GameGlobal.gamespeed, 0.05),
		"four hundred percent uses a four-times-faster delay"
	)
	_expect(speed_label.text == "400%", "the maximum game speed label is correct")
	_expect_saved_game_speed(
		GameGlobal.MAX_GAME_SPEED_PERCENT,
		"the maximum game speed persists"
	)

	speed_bar.value = GameGlobal.MIN_GAME_SPEED_PERCENT
	await get_tree().process_frame
	_expect(
		is_equal_approx(GameGlobal.gamespeed, 0.8),
		"twenty-five percent uses a four-times-slower delay"
	)
	_expect(speed_label.text == "25%", "the minimum game speed label is correct")
	_expect_saved_game_speed(
		GameGlobal.MIN_GAME_SPEED_PERCENT,
		"the minimum game speed persists"
	)

	GameGlobal.set_game_speed_percent(GameGlobal.DEFAULT_GAME_SPEED_PERCENT)
	Paths.settingspath = original_settings_path
	_remove_test_settings()
	settings.queue_free()
	await get_tree().process_frame
	_finish()


func _expect_saved_overlay_value(expected: bool, message: String) -> void:
	var config := ConfigFile.new()
	if config.load(TEST_SETTINGS_PATH) != OK:
		failures.append("%s: test settings file did not load" % message)
		return
	_expect(
		bool(config.get_value("SETTINGS", "show_map_debug_overlays", not expected))
			== expected,
		message
	)


func _expect_saved_game_speed(expected: float, message: String) -> void:
	var config := ConfigFile.new()
	if config.load(TEST_SETTINGS_PATH) != OK:
		failures.append("%s: test settings file did not load" % message)
		return
	_expect(
		is_equal_approx(
			float(config.get_value("SETTINGS", "game_speed_percent", -1.0)),
			expected
		),
		message
	)


func _remove_test_settings() -> void:
	if not FileAccess.file_exists(TEST_SETTINGS_PATH):
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SETTINGS_PATH))


func _expect(condition: bool, message: String) -> void:
	if condition:
		print("PASS: %s" % message)
	else:
		failures.append(message)


func _finish() -> void:
	if failures.is_empty():
		print("Settings runtime smoke passed.")
		get_tree().quit(0)
		return
	for failure: String in failures:
		printerr("FAIL: %s" % failure)
	get_tree().quit(1)
