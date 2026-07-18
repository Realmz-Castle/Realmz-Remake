extends Node

const HostScript = preload("res://scripts/classic_runtime/classic_runtime_host.gd")
const AdapterScript = preload("res://scripts/classic_runtime/classic_godot_command_adapter.gd")

@export_dir var campaign_directory := \
	"res://scripts/classic_runtime/tests/fixtures/cob_vertical_slice"
@export var trigger_id := "Data DD:0:0"
@export var playtest_label := "guard-house"
@export var test_rogue_stat := -1.0

var host: Node
var automated_smoke := false
var smoke_failures: Array[String] = []


class PlaytestRogue:
	extends RefCounted
	var name := "Test Rogue"
	var stat_value := 35.0

	func get_stat(_stat_name: String) -> float:
		return stat_value


func _ready() -> void:
	call_deferred("_start_playtest")


func _start_playtest() -> void:
	var user_arguments := OS.get_cmdline_user_args()
	for argument: String in user_arguments:
		if argument == "--smoke":
			automated_smoke = true
		else:
			campaign_directory = argument

	UI.show_only(UI.ow_hud)
	UI.ow_hud.textRect.show()
	if test_rogue_stat >= 0.0 and GameGlobal.player_characters.is_empty():
		var rogue := PlaytestRogue.new()
		rogue.stat_value = test_rogue_stat
		GameGlobal.player_characters.append(rogue)
	host = HostScript.new()
	add_child(host)
	host.configure(AdapterScript.new())
	host.playthrough_completed.connect(_on_playthrough_completed)
	host.playthrough_stopped.connect(_on_playthrough_stopped)
	if not host.load_campaign(campaign_directory):
		_show_status("Classic campaign load failed: %s" % host.runtime.bundle.last_error, true)
		return
	if not host.start_trigger(trigger_id):
		_show_status("Classic trigger failed to start: %s" % trigger_id, true)
		return
	if automated_smoke:
		call_deferred("_run_automated_smoke")


func _on_playthrough_completed(result: Dictionary) -> void:
	_show_status(
		"Classic %s playtest complete.\nReason: %s" % [
			playtest_label,
			result.get("reason", "completed"),
		],
		false
	)


func _on_playthrough_stopped(result: Dictionary) -> void:
	_show_status("Classic playtest stopped: %s" % result.get("message", result), true)


func _show_status(message: String, is_error: bool) -> void:
	var color := "red" if is_error else "green"
	UI.ow_hud.textRect.set_text("[color=%s]%s[/color]" % [color, message], false)


func _run_automated_smoke() -> void:
	if trigger_id == "Data DD:5:12":
		await _run_lock_smoke()
		return
	await _wait_frames(3)
	_verify_smoke_stage(
		"01_guard_house_text",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with("You enter the guard house"),
		"introductory classic message is visible"
	)
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	var choices_ready := await _wait_for_choices()
	_verify_smoke_stage(
		"02_simple_encounter_choices",
		choices_ready
			and UI.ow_hud.textRect.choicesContainer.get_child_count() == 8
			and _choice_menu_fits_map_area(),
		"four classic choices are visible within the map area"
	)
	if not choices_ready:
		get_tree().quit(1)
		return
	UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("4")
	await _wait_frames(3)
	_verify_smoke_stage(
		"03_selected_outcome_text",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with("He bids you farewell"),
		"selected encounter outcome is visible"
	)
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	await _wait_frames(3)
	_verify_smoke_stage(
		"04_playthrough_complete",
		"Classic guard-house playtest complete" in UI.ow_hud.textRect.textLabel.get_parsed_text(),
		"host reports completed playthrough"
	)
	get_tree().quit(0 if smoke_failures.is_empty() else 1)


func _run_lock_smoke() -> void:
	var choices_ready := await _wait_for_choices()
	_verify_smoke_stage(
		"01_lock_prompt",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
			"The door to this chamber is locked"
		),
		"source-backed complex encounter prompt is visible"
	)
	_verify_smoke_stage(
		"02_rogue_choices",
		choices_ready
			and UI.ow_hud.textRect.choicesContainer.get_child_count() == 8
			and _choice_menu_fits_map_area(),
		"three Data TD2 actions and back-out are visible within the map area"
	)
	if not choices_ready:
		get_tree().quit(1)
		return
	UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("back")
	await _wait_frames(3)
	_verify_smoke_stage(
		"03_lock_playthrough_complete",
		"Classic lock playtest complete" in UI.ow_hud.textRect.textLabel.get_parsed_text(),
		"host completes after leaving the complex encounter"
	)
	get_tree().quit(0 if smoke_failures.is_empty() else 1)


func _wait_frames(frame_count: int) -> void:
	for _frame: int in frame_count:
		await get_tree().process_frame


func _wait_for_choices() -> bool:
	for _frame: int in 60:
		await get_tree().process_frame
		var choices: Control = UI.ow_hud.textRect.choicesContainer
		if choices.visible and choices.get_child_count() > 0:
			return true
	push_error("Classic %s smoke timed out waiting for encounter choices" % playtest_label)
	return false


func _choice_menu_fits_map_area() -> bool:
	var choices: Control = UI.ow_hud.textRect.choicesContainer
	var map_area := choices.get_parent() as Control
	if map_area == null:
		return false
	var fits := choices.position.x >= 0.0 \
		and choices.position.y >= 0.0 \
		and choices.position.x + choices.size.x <= map_area.size.x \
		and choices.position.y + choices.size.y <= map_area.size.y
	if not fits:
		push_error(
			"Classic choice menu rect %s, anchors %s/%s/%s/%s, minimum %s does not fit map area %s" % [
				Rect2(choices.position, choices.size),
				choices.anchor_left,
				choices.anchor_top,
				choices.anchor_right,
				choices.anchor_bottom,
				choices.get_combined_minimum_size(),
				map_area.size,
			]
		)
	return fits


func _verify_smoke_stage(stage_name: String, passed: bool, detail: String) -> void:
	if passed:
		print("CLASSIC_PLAYTEST_STAGE PASS: %s - %s" % [stage_name, detail])
		return
	smoke_failures.append(stage_name)
	push_error("CLASSIC_PLAYTEST_STAGE FAIL: %s - %s" % [stage_name, detail])
