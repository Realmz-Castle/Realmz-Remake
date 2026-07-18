extends Node

const HostScript = preload("res://scripts/classic_runtime/classic_runtime_host.gd")
const AdapterScript = preload("res://scripts/classic_runtime/classic_godot_command_adapter.gd")
const RogueClass = preload("res://Data/Character Classes/Class_Assassin.gd")
const HumanRace = preload("res://Data/Character Races/Race_Human.gd")

@export_dir var campaign_directory := \
	"res://scripts/classic_runtime/tests/fixtures/cob_vertical_slice"
@export var trigger_id := "Data DD:0:0"
@export var playtest_label := "guard-house"
@export var test_rogue_stat := -1.0
@export var test_rogue_hp := 30

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
	if automated_smoke:
		get_window().size = Vector2i(1152, 648)

	UI.show_only(UI.ow_hud)
	UI.ow_hud.textRect.show()
	await _wait_frames(2)
	if test_rogue_stat >= 0.0:
		var resources: CampaignResources = NodeAccess.__Resources()
		if resources.items_book.is_empty():
			resources.load_item_resources("res://shared_assets/items/")
		GameGlobal.player_characters.clear()
		var rogue := _make_playtest_rogue()
		GameGlobal.player_characters.append(rogue)
		UI.ow_hud.selected_character = rogue
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
	var message := "Classic playtest stopped: %s" % result.get("message", result)
	push_error(message)
	_show_status(message, true)


func _show_status(message: String, is_error: bool) -> void:
	var color := "red" if is_error else "green"
	UI.ow_hud.textRect.set_text("[color=%s]%s[/color]" % [color, message], false)


func _run_automated_smoke() -> void:
	if trigger_id == "Data DD:5:3":
		await _run_trap_smoke()
		return
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


func _run_trap_smoke() -> void:
	var money_before: Array = GameGlobal.money_pool.duplicate()
	var choices_ready := await _wait_for_choices()
	_verify_smoke_stage(
		"01_trap_prompt",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
			"You see a small notch carved into the wall"
		),
		"source-backed trapped chest prompt is visible"
	)
	_verify_smoke_stage(
		"02_armed_trap_choices",
		choices_ready
			and UI.ow_hud.textRect.choicesContainer.get_child_count() == 6
			and _choice_menu_fits_map_area(),
		"Detect Trap, Pick Lock, and back-out are visible"
	)
	if not choices_ready:
		get_tree().quit(1)
		return
	var rogue: Object = GameGlobal.player_characters[0]
	var hp_before := int(rogue.get_stat("curHP"))
	UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("rogue:6")
	await _wait_frames(3)
	var hp_after := int(rogue.get_stat("curHP"))
	_verify_smoke_stage(
		"03_trap_damage",
		hp_before - hp_after >= 4
			and hp_before - hp_after <= 12
			and UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
				"A trap is sprung!"
			),
		"Pick Lock springs the trap and damages the selected rogue"
	)
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	var retry_ready := await _wait_for_choices()
	_verify_smoke_stage(
		"04_sprung_trap_choices",
		retry_ready and UI.ow_hud.textRect.choicesContainer.get_child_count() == 4,
		"sprung trap leaves Pick Lock and back-out available"
	)
	if not retry_ready:
		get_tree().quit(1)
		return
	rogue.stats["Pick_Lock"] = 100.0
	var successful_seed := 0
	for candidate_seed: int in 100:
		seed(candidate_seed)
		if randi_range(1, 100) <= 90:
			successful_seed = candidate_seed
			break
	seed(successful_seed)
	UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("rogue:6")
	await _wait_frames(3)
	_verify_smoke_stage(
		"05_lock_open_feedback",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with("The lock is now open"),
		"the sprung chest can be unlocked"
	)
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	await _wait_frames(3)
	_verify_smoke_stage(
		"06_treasure_result_text",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
			"You hear a click as a trap disarms"
		),
		"the source-backed treasure result text is visible"
	)
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	var treasure_ready := await _wait_for_treasure()
	var money_after: Array = GameGlobal.money_pool.duplicate()
	var money_delta := [
		int(money_after[0]) - int(money_before[0]),
		int(money_after[1]) - int(money_before[1]),
		int(money_after[2]) - int(money_before[2]),
	]
	_verify_smoke_stage(
		"07_native_treasure_ui",
		treasure_ready
			and UI.ow_hud.treasureControl.itemsContainer.get_child_count() == 5
			and money_delta == [0, 5, 2],
		"five classic items and the treasure money reach Remake's loot UI"
	)
	if not treasure_ready:
		get_tree().quit(1)
		return
	var exp_before: int = rogue.exp_tnl
	UI.ow_hud.treasureControl.find_child("ButtonDone").pressed.emit()
	await _wait_frames(5)
	var persisted_trap: Dictionary = \
		host.runtime.interpreter.runtime_state.get_effective_thief_encounter(
			host.runtime.bundle.get_thief_encounter(1)
		)
	_verify_smoke_stage(
		"08_trap_playthrough_complete",
		"Classic trapped-chest playtest complete" \
			in UI.ow_hud.textRect.textLabel.get_parsed_text()
			and not bool(persisted_trap.get("typeFlags", [])[9])
			and rogue.exp_tnl == exp_before - 600
			and host.runtime.interpreter.runtime_state.get_trigger_percent(
				"land", 5, 3, 100
			) == -1,
		"loot closes after applying experience and consuming the action point"
	)
	get_tree().quit(0 if smoke_failures.is_empty() else 1)


func _make_playtest_rogue() -> PlayerCharacter:
	var rogue: PlayerCharacter = GameGlobal.playerCharacterGD.new(
		{
			"name": "Test Rogue",
			"level": 1,
			"exp_tnl": 10000,
		},
		null,
		null,
		RogueClass,
		HumanRace
	)
	for stat_name: String in [
		"Acrobatics",
		"Detect_Trap",
		"Disable_Trap",
		"Force_Lock",
		"Pick_Lock",
	]:
		rogue.stats[stat_name] = test_rogue_stat
	rogue.stats["maxHP"] = test_rogue_hp
	rogue.stats["curHP"] = test_rogue_hp
	return rogue


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


func _wait_for_treasure() -> bool:
	for _frame: int in 180:
		await get_tree().process_frame
		if UI.ow_hud.treasureControl.visible:
			return true
	push_error(
		"Classic trapped-chest smoke timed out waiting for the treasure UI; HUD text: %s" %
		UI.ow_hud.textRect.textLabel.get_parsed_text()
	)
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
