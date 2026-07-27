extends Node

const SETTINGS_SCENE := preload(
	"res://scenes/UI/HUD/Settings/settings_rect.tscn"
)
const CHECKBOX_PATH := (
	"HBoxContainer/VBoxContainer/MusicSettingsRect/"
	+ "VBoxContainer/VolumeVbox/MapDebugCheckButton"
)
const TEST_SETTINGS_PATH := "user://map_debug_overlay_settings_test.cfg"

var failures: Array[String] = []


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	var original_settings_path := Paths.settingspath
	Paths.settingspath = TEST_SETTINGS_PATH
	_remove_test_settings()
	ConfigFile.new().save(TEST_SETTINGS_PATH)
	GameGlobal.map_debug_overlays_enabled = true

	var main: Control = get_parent() as Control
	var map: Map = main.get_node("Map") as Map

	var settings: NinePatchRect = SETTINGS_SCENE.instantiate() as NinePatchRect
	add_child(settings)
	await get_tree().process_frame
	settings.call("_initialize")
	var checkbox: CheckButton = settings.get_node(CHECKBOX_PATH)
	_expect(checkbox.button_pressed, "the checkbox defaults to showing overlays")

	checkbox.button_pressed = false
	await get_tree().process_frame
	_expect(
		not GameGlobal.map_debug_overlays_enabled,
		"unchecking updates the global setting"
	)
	_expect(not map.show_scripts, "unchecking hides AP rectangles and labels")
	_expect(not map.debuglabel.visible, "unchecking hides the map debug text")
	_expect(map.debuglabel.text.is_empty(), "unchecking clears stale debug text")
	_expect_saved_value(false, "unchecking persists the setting")

	checkbox.button_pressed = true
	await get_tree().process_frame
	_expect(
		GameGlobal.map_debug_overlays_enabled,
		"checking updates the global setting"
	)
	_expect(map.show_scripts, "checking restores AP rectangles and labels")
	_expect(map.debuglabel.visible, "checking restores the map debug text")
	_expect_saved_value(true, "checking persists the setting")

	Paths.settingspath = original_settings_path
	_remove_test_settings()
	settings.queue_free()
	await get_tree().process_frame
	_finish()


func _expect_saved_value(expected: bool, message: String) -> void:
	var config := ConfigFile.new()
	if config.load(TEST_SETTINGS_PATH) != OK:
		failures.append("%s: test settings file did not load" % message)
		return
	_expect(
		bool(config.get_value("SETTINGS", "show_map_debug_overlays", not expected))
			== expected,
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
		print("Map debug overlay settings smoke passed.")
		get_tree().quit(0)
		return
	for failure: String in failures:
		printerr("FAIL: %s" % failure)
	get_tree().quit(1)
