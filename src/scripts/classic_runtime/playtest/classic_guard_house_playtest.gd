extends Node

const HostScript = preload("res://scripts/classic_runtime/classic_runtime_host.gd")
const AdapterScript = preload("res://scripts/classic_runtime/classic_godot_command_adapter.gd")

@export_dir var campaign_directory := \
	"res://scripts/classic_runtime/tests/fixtures/cob_vertical_slice"
@export var trigger_id := "Data DD:0:0"

var host: Node
var automated_smoke := false
var smoke_failures: Array[String] = []


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
		"Classic guard-house playtest complete.\nReason: %s" % result.get("reason", "completed"),
		false
	)


func _on_playthrough_stopped(result: Dictionary) -> void:
	_show_status("Classic playtest stopped: %s" % result.get("message", result), true)


func _show_status(message: String, is_error: bool) -> void:
	var color := "red" if is_error else "green"
	UI.ow_hud.textRect.set_text("[color=%s]%s[/color]" % [color, message], false)


func _run_automated_smoke() -> void:
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
		choices_ready and UI.ow_hud.textRect.choicesContainer.get_child_count() == 8,
		"four classic choices are visible"
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


func _wait_frames(frame_count: int) -> void:
	for _frame: int in frame_count:
		await get_tree().process_frame


func _wait_for_choices() -> bool:
	for _frame: int in 60:
		await get_tree().process_frame
		var choices: Control = UI.ow_hud.textRect.choicesContainer
		if choices.visible and choices.get_child_count() > 0:
			return true
	push_error("Classic guard-house smoke timed out waiting for encounter choices")
	return false


func _verify_smoke_stage(stage_name: String, passed: bool, detail: String) -> void:
	if passed:
		print("CLASSIC_PLAYTEST_STAGE PASS: %s - %s" % [stage_name, detail])
		return
	smoke_failures.append(stage_name)
	push_error("CLASSIC_PLAYTEST_STAGE FAIL: %s - %s" % [stage_name, detail])
