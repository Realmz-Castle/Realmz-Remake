extends Node

const HostScript = preload("res://scripts/classic_runtime/classic_runtime_host.gd")
const AdapterScript = preload("res://scripts/classic_runtime/classic_godot_command_adapter.gd")
const RogueClass = preload("res://Data/Character Classes/Class_Assassin.gd")
const SorcererClass = preload("res://Data/Character Classes/Class_Sorcerer.gd")
const HumanRace = preload("res://Data/Character Races/Race_Human.gd")


class CaveInSpell:
	extends Spell

	var classic_spell_class := 6

	func _init() -> void:
		name = "Dig Hole"
		description = "Opens earth and debris by magical means."
		elements = [GameGlobal.ELEMENTS.MAGICAL]
		schools = ["Sorcerer"]
		school_levels = {"Sorcerer": 1}
		selection_costs = {"Sorcerer": 1}
		in_field = true
		max_plevel = 1

	func get_sp_cost(_power: int, _caster) -> int:
		return 5


class PowerDrainSpell:
	extends Spell

	func _init() -> void:
		name = "Power Drain"
		elements = [GameGlobal.ELEMENTS.MAGICAL]
		resist = RESIST_TYPE.IGNORE_MRES_DODGE
		proj_hit = GFX.SPHERE
		sounds = ["boing.wav", "electric energize.wav"]

	func get_damage_roll(power: int, _caster) -> int:
		var damage := 0
		for _roll: int in power:
			damage += randi_range(5, 8)
		return damage

@export_dir var campaign_directory := \
	"res://scripts/classic_runtime/tests/fixtures/cob_vertical_slice"
@export var trigger_id := "Data DD:0:0"
@export var start_slot := 0
@export var playtest_label := "guard-house"
@export var test_rogue_stat := -1.0
@export var test_rogue_hp := 30
@export var test_max_movement := -1.0
@export var test_party_size := 1
@export var test_spell_name := ""
@export var test_effect_spell_name := ""
@export var test_item_name := ""

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
	if test_rogue_stat >= 0.0 \
			or test_max_movement >= 0.0 \
			or not test_spell_name.is_empty() \
			or not test_effect_spell_name.is_empty() \
			or not test_item_name.is_empty():
		var resources: CampaignResources = NodeAccess.__Resources()
		if test_rogue_stat >= 0.0 and resources.items_book.is_empty():
			resources.load_item_resources("res://shared_assets/items/")
		if not test_effect_spell_name.is_empty():
			if resources.sounds_book.is_empty():
				resources.load_sound_ressources("res://shared_assets/sounds/")
			var effect_spell := PowerDrainSpell.new()
			resources.spells_book[effect_spell.name] = {
				"name": effect_spell.name,
				"source": "",
				"script": effect_spell,
			}
		GameGlobal.player_characters.clear()
		var first_character: PlayerCharacter
		for index: int in max(1, test_party_size):
			var character: PlayerCharacter = _make_playtest_rogue() \
				if test_rogue_stat >= 0.0 else _make_playtest_spellcaster()
			if test_party_size > 1:
				character.name = "%s %d" % [character.name, index + 1]
			GameGlobal.player_characters.append(character)
			if first_character == null:
				first_character = character
		var character_panels: Array[Node] = UI.ow_hud.charsVContainer.get_children()
		if character_panels.size() == GameGlobal.player_characters.size():
			for index: int in character_panels.size():
				character_panels[index].set_character(GameGlobal.player_characters[index])
				character_panels[index].update_display()
		else:
			UI.ow_hud.fillCharactersRect()
		UI.ow_hud.selected_character = first_character
	host = HostScript.new()
	add_child(host)
	host.configure(AdapterScript.new())
	host.playthrough_completed.connect(_on_playthrough_completed)
	host.playthrough_stopped.connect(_on_playthrough_stopped)
	if not host.load_campaign(campaign_directory):
		_show_status("Classic campaign load failed: %s" % host.runtime.bundle.last_error, true)
		return
	if not host.start_trigger(trigger_id, start_slot):
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
	if playtest_label == "character-pick":
		await _run_character_pick_smoke()
		return
	if playtest_label == "misc-selection":
		await _run_misc_selection_smoke()
		return
	if playtest_label == "party-health":
		await _run_party_health_smoke()
		return
	if playtest_label == "party-spell":
		await _run_party_spell_smoke()
		return
	if playtest_label == "experience":
		await _run_experience_smoke()
		return
	if trigger_id == "Data DD:6:28":
		await _run_complex_word_smoke()
		return
	if trigger_id == "Data DD:0:8":
		await _run_simple_option_smoke()
		return
	if not test_spell_name.is_empty():
		await _run_complex_spell_smoke()
		return
	if not test_item_name.is_empty():
		await _run_complex_item_smoke()
		return
	if trigger_id == "Data DD:5:3":
		await _run_trap_smoke()
		return
	if trigger_id == "Data DD:5:12":
		await _run_lock_smoke()
		return
	if trigger_id == "Data DD:0:19":
		await _run_complex_action_smoke()
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
			and UI.ow_hud.textRect.choicesContainer.get_child_count() == 10
			and _choice_menu_fits_map_area(),
		"four classic choices and back-out are visible within the map area"
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


func _run_experience_smoke() -> void:
	var treasure_ready := await _wait_for_treasure()
	var character: PlayerCharacter = GameGlobal.player_characters[0]
	var experience_before := character.exp_tnl
	_verify_smoke_stage(
		"01_experience_ui",
		treasure_ready
			and UI.ow_hud.treasureControl.exp_gain == 1500
			and UI.ow_hud.treasureControl.itemsContainer.get_child_count() == 0,
		"the source-backed experience total reaches Remake's loot UI"
	)
	if not treasure_ready:
		get_tree().quit(1)
		return
	UI.ow_hud.treasureControl.find_child("ButtonDone").pressed.emit()
	await _wait_frames(5)
	var patched_target: Dictionary = \
		host.runtime.interpreter.runtime_state.get_action_point_override("Data DD:1:31")
	var patched_actions: Array = patched_target.get("actions", [])
	_verify_smoke_stage(
		"02_experience_applied",
		character.exp_tnl == experience_before - 1500
			and "Classic experience playtest complete" \
				in UI.ow_hud.textRect.textLabel.get_parsed_text()
			and not patched_actions.is_empty()
			and int(patched_actions[0].get("id", 0)) == 522,
		"closing loot applies experience and completes the remaining action-point mutation"
	)
	get_tree().quit(0 if smoke_failures.is_empty() else 1)


func _run_party_health_smoke() -> void:
	await _wait_frames(3)
	var character: PlayerCharacter = GameGlobal.player_characters[0]
	_verify_smoke_stage(
		"01_party_damage",
		int(character.get_stat("curHP")) == test_rogue_hp - 1,
		"the source-backed fixed roll damages the playtest party member"
	)
	var completion_text: String = UI.ow_hud.textRect.textLabel.get_parsed_text()
	_verify_smoke_stage(
		"02_party_health_complete",
		"Classic party-health playtest complete" in completion_text,
		"the host completes after applying the party health change"
	)
	get_tree().quit(0 if smoke_failures.is_empty() else 1)


func _run_party_spell_smoke() -> void:
	await _wait_frames(3)
	_verify_smoke_stage(
		"01_party_spell_warning",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
			"As soon as you step into the hidden passage"
		),
		"the source-backed mental-attack warning is visible"
	)
	var hp_before: Array[int] = []
	for character: PlayerCharacter in GameGlobal.player_characters:
		hp_before.append(int(character.get_stat("curHP")))
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	var completed := false
	for _frame: int in 360:
		await get_tree().process_frame
		if "Classic party-spell playtest complete" \
				in UI.ow_hud.textRect.textLabel.get_parsed_text():
			completed = true
			break
	var damage_in_range := completed
	for index: int in GameGlobal.player_characters.size():
		var damage := hp_before[index] - int(
			GameGlobal.player_characters[index].get_stat("curHP")
		)
		damage_in_range = damage_in_range and damage >= 15 and damage <= 24
	_verify_smoke_stage(
		"02_party_spell_effect",
		damage_in_range,
		"Remake's spell animation completes and Power Drain affects every party member"
	)
	_verify_smoke_stage(
		"03_party_spell_selection",
		GameGlobal.last_picked_characters == GameGlobal.player_characters,
		"the party spell replaces Classic's transient selected set"
	)
	get_tree().quit(0 if smoke_failures.is_empty() else 1)


func _run_character_pick_smoke() -> void:
	await _wait_frames(3)
	_verify_smoke_stage(
		"01_pick_prompt",
		UI.ow_hud.textRect.textLabel.get_parsed_text() == "Who is so brave as to volunteer?",
		"the source-backed volunteer prompt is visible"
	)
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	var picker_ready := await _wait_for_character_picker()
	_verify_smoke_stage(
		"02_native_character_picker",
		picker_ready and UI.ow_hud.charsVContainer.get_child_count() == test_party_size,
		"Remake's character-panel picker opens for the requested party member"
	)
	if not picker_ready:
		get_tree().quit(1)
		return
	var first_panel: Node = UI.ow_hud.charsVContainer.get_child(0)
	first_panel.chara_small_panel_selected.emit()
	await _wait_frames(3)
	_verify_smoke_stage(
		"03_character_selected",
		GameGlobal.last_picked_characters == [GameGlobal.player_characters[0]]
			and UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
				"At the bottom of the shaft"
			),
		"the picked panel becomes Classic's transient selected set"
	)
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	var choices_ready := await _wait_for_choices()
	if choices_ready:
		UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("NO")
	await _wait_frames(3)
	_verify_smoke_stage(
		"04_character_pick_complete",
		choices_ready and "Classic character-pick playtest complete" \
			in UI.ow_hud.textRect.textLabel.get_parsed_text(),
		"declining the follow-up choice completes the source action point"
	)
	get_tree().quit(0 if smoke_failures.is_empty() else 1)


func _run_misc_selection_smoke() -> void:
	await _wait_frames(3)
	_verify_smoke_stage(
		"01_rockfall_warning",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
			"Large rocks break loose from the ceiling"
		),
		"the source-backed rockfall warning is visible"
	)
	var character: PlayerCharacter = GameGlobal.player_characters[0]
	var hp_before := int(character.get_stat("curHP"))
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	await _wait_frames(5)
	var hp_after := int(character.get_stat("curHP"))
	_verify_smoke_stage(
		"02_movement_selection_damage",
		GameGlobal.last_picked_characters == [character]
			and hp_before - hp_after >= 1
			and hp_before - hp_after <= 3,
		"the movement threshold selects and damages the slow party member"
	)
	_verify_smoke_stage(
		"03_misc_selection_complete",
		"Classic misc-selection playtest complete" \
			in UI.ow_hud.textRect.textLabel.get_parsed_text(),
		"the host completes after applying selected damage"
	)
	get_tree().quit(0 if smoke_failures.is_empty() else 1)


func _run_simple_option_smoke() -> void:
	await _wait_frames(3)
	_verify_smoke_stage(
		"01_tavern_text",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
			"You have entered a rather fine tavern"
		),
		"source-backed tavern introduction is visible"
	)
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	var choices_ready := await _wait_for_choices()
	_verify_smoke_stage(
		"02_tavern_choices",
		choices_ready
			and UI.ow_hud.textRect.choicesContainer.get_child_count() == 10
			and _choice_menu_fits_map_area(),
		"four tavern choices and back-out are visible"
	)
	if not choices_ready:
		get_tree().quit(1)
		return
	UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("4")
	await _wait_frames(3)
	_verify_smoke_stage(
		"03_barmaid_response",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
			"\"Oh, I don't really know much.\""
		),
		"the selected source result is visible"
	)
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	var reopened_choices_ready := await _wait_for_choices()
	var effective_tavern: Dictionary = \
		host.runtime.interpreter.runtime_state.get_effective_simple_encounter(
			host.runtime.bundle.get_encounter("simple", 3)
		)
	_verify_smoke_stage(
		"04_tavern_reopens",
		reopened_choices_ready
			and UI.ow_hud.textRect.choicesContainer.get_child_count() == 8
			and effective_tavern.get("choiceResults", []).map(
				func(value: Variant) -> int: return int(value)
			) == [1, 2, 3, 0]
			and int(host.runtime.interpreter.encounter_origins[-1].get(
				"remainingAttempts", 0
			)) == 99,
		"the barmaid choice is removed without consuming an attempt"
	)
	if not reopened_choices_ready:
		get_tree().quit(1)
		return
	UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("0")
	await _wait_frames(3)
	_verify_smoke_stage(
		"05_tavern_complete",
		"Classic tavern-option playtest complete" \
			in UI.ow_hud.textRect.textLabel.get_parsed_text(),
		"host completes after backing out of the reopened tavern"
	)
	get_tree().quit(0 if smoke_failures.is_empty() else 1)


func _run_complex_word_smoke() -> void:
	var choices_ready := await _wait_for_choices()
	_verify_smoke_stage(
		"01_complex_word_prompt",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
			"You are standing in the town archives"
		),
		"source-backed archive prompt is visible"
	)
	_verify_smoke_stage(
		"02_complex_word_choice",
		choices_ready
			and UI.ow_hud.textRect.choicesContainer.get_child_count() == 8
			and _choice_menu_fits_map_area(),
		"speak appears beside the two archive actions and back-out"
	)
	if not choices_ready:
		get_tree().quit(1)
		return
	UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("word")
	var speech_panel_ready := await _wait_for_speech_panel()
	_verify_smoke_stage(
		"03_native_speech_panel",
		speech_panel_ready and not UI.ow_hud.textRect.choicesContainer.visible,
		"Remake's encounter speech input opens in place of the choices"
	)
	if not speech_panel_ready:
		get_tree().quit(1)
		return
	var encounter_control: Control = UI.ow_hud.encounterControl
	var done_button: Button = encounter_control.speakButton.get_child(0).find_child(
		"SpeakDoneButton"
	)
	done_button.pressed.emit()
	var retry_ready := await _wait_for_choices()
	_verify_smoke_stage(
		"04_empty_phrase_returns",
		retry_ready and UI.ow_hud.textRect.choicesContainer.get_child_count() == 8,
		"an empty phrase returns to the encounter choices"
	)
	if not retry_ready:
		get_tree().quit(1)
		return
	UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("word")
	speech_panel_ready = await _wait_for_speech_panel()
	_verify_smoke_stage(
		"05_speech_panel_reopens",
		speech_panel_ready,
		"the speech input can be reopened after cancellation"
	)
	if not speech_panel_ready:
		get_tree().quit(1)
		return
	encounter_control.speakField.text = "WATERFORD"
	done_button.pressed.emit()
	await _wait_frames(3)
	_verify_smoke_stage(
		"06_complex_word_result",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
			"\"Waterford was supposed to be but a legend"
		),
		"case-insensitive speech selects the authored result"
	)
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	await _wait_frames(3)
	_verify_smoke_stage(
		"07_complex_word_continuation",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
			"\"I sought it out many years ago"
		),
		"the spoken-word result continues through its second source message"
	)
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	await _wait_frames(3)
	_verify_smoke_stage(
		"08_archive_map_notice",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
			"You gain a map, to view the map use Maps/Notes"
		)
			and host.runtime.interpreter.runtime_state.is_map_owned(2),
		"the result grants the source-backed Waterford map"
	)
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	var repeated_choices_ready := await _wait_for_choices()
	var effective_encounter: Dictionary = \
		host.runtime.interpreter.runtime_state.get_effective_complex_encounter(
			host.runtime.bundle.get_encounter("complex", 1)
		)
	var first_result_actions: Array = effective_encounter.get("actions", []).filter(
		func(action: Dictionary) -> bool: return int(action.get("slot", -1)) < 8
	)
	_verify_smoke_stage(
		"09_archive_reopens",
		repeated_choices_ready
			and UI.ow_hud.textRect.choicesContainer.get_child_count() == 8
			and first_result_actions.size() == 1
			and int(first_result_actions[0].get("rawCode", 0)) == 24,
		"the archive reopens with Result 1 replaced by Keep Codes"
	)
	if not repeated_choices_ready:
		get_tree().quit(1)
		return
	UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("back")
	await _wait_frames(3)
	_verify_smoke_stage(
		"10_complex_word_complete",
		"Classic spoken-word playtest complete" \
			in UI.ow_hud.textRect.textLabel.get_parsed_text(),
		"host completes after leaving the reopened archive"
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
			and UI.ow_hud.textRect.choicesContainer.get_child_count() == 12
			and _choice_menu_fits_map_area(),
		"rogue controls, encounter actions, and back-out are visible within the map area"
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


func _run_complex_action_smoke() -> void:
	var choices_ready := await _wait_for_choices()
	_verify_smoke_stage(
		"01_complex_action_prompt",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
			"This appears to be the site of a rather large cavern"
		),
		"source-backed cave-in prompt is visible"
	)
	_verify_smoke_stage(
		"02_complex_action_choices",
		choices_ready
			and UI.ow_hud.textRect.choicesContainer.get_child_count() == 8
			and _choice_menu_fits_map_area(),
		"three classic actions and back-out are visible within the map area"
	)
	if not choices_ready:
		get_tree().quit(1)
		return
	UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("action:1")
	await _wait_frames(3)
	_verify_smoke_stage(
		"03_complex_action_result",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
			"You have succeeded in uncovering the passage"
		),
		"selected action enters its Data ED2 result block"
	)
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	await _wait_frames(3)
	_verify_smoke_stage(
		"04_complex_action_continuation",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
			"The tunnel continues west"
		),
		"the result block continues to its second source message"
	)
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	await _wait_frames(3)
	_verify_smoke_stage(
		"05_complex_action_complete",
		"Classic cave-in playtest complete" \
			in UI.ow_hud.textRect.textLabel.get_parsed_text(),
		"host completes after the complex action result"
	)
	get_tree().quit(0 if smoke_failures.is_empty() else 1)


func _run_complex_spell_smoke() -> void:
	var caster: PlayerCharacter = GameGlobal.player_characters[0]
	var spell_points_before := int(caster.get_stat("curSP"))
	var choices_ready := await _wait_for_choices()
	_verify_smoke_stage(
		"01_complex_spell_prompt",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
			"This appears to be the site of a rather large cavern"
		),
		"source-backed cave-in prompt is visible"
	)
	_verify_smoke_stage(
		"02_complex_spell_choice",
		choices_ready
			and UI.ow_hud.textRect.choicesContainer.get_child_count() == 10
			and _choice_menu_fits_map_area(),
		"cast spell appears beside the three actions and back-out"
	)
	if not choices_ready:
		get_tree().quit(1)
		return
	UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("spell")
	var spell_menu_ready := await _wait_for_spell_menu()
	_verify_smoke_stage(
		"03_native_spell_menu",
		spell_menu_ready,
		"Remake's spell picker opens with the playtest caster's known spell"
	)
	if not spell_menu_ready:
		get_tree().quit(1)
		return
	var spell_menu: SpellsMenu = UI.ow_hud.spellcastMenu
	var spell_button: Button = spell_menu.spelllistContainer.get_child(0)
	spell_button.pressed.emit()
	await _wait_frames(2)
	_verify_smoke_stage(
		"04_spell_selected",
		spell_menu.picked_spell != null
			and spell_menu.picked_spell.name == test_spell_name
			and not spell_menu.castButton.disabled,
		"the shipped response spell can be selected and cast"
	)
	spell_menu.castButton.pressed.emit()
	await _wait_frames(3)
	_verify_smoke_stage(
		"05_complex_spell_result",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
			"You have succeeded in uncovering the passage"
		)
			and int(caster.get_stat("curSP")) == spell_points_before - 5,
		"the packed spell ID selects result 1 and consumes spell points"
	)
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	await _wait_frames(3)
	_verify_smoke_stage(
		"06_complex_spell_continuation",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
			"The tunnel continues west"
		),
		"the spell result continues through its Data ED2 block"
	)
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	await _wait_frames(3)
	_verify_smoke_stage(
		"07_complex_spell_complete",
		"Classic cave-in-spell playtest complete" \
			in UI.ow_hud.textRect.textLabel.get_parsed_text(),
		"host completes after the complex spell result"
	)
	get_tree().quit(0 if smoke_failures.is_empty() else 1)


func _run_complex_item_smoke() -> void:
	var holder: PlayerCharacter = GameGlobal.player_characters[0]
	var choices_ready := await _wait_for_choices()
	_verify_smoke_stage(
		"01_complex_item_prompt",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
			"The door to this chamber is locked"
		),
		"source-backed locked-door prompt is visible"
	)
	_verify_smoke_stage(
		"02_complex_item_choice",
		choices_ready
			and UI.ow_hud.textRect.choicesContainer.get_child_count() == 14
			and _choice_menu_fits_map_area(),
		"use item appears beside the rogue controls, actions, and back-out"
	)
	if not choices_ready:
		get_tree().quit(1)
		return
	UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("item")
	var item_menu_ready := await _wait_for_item_menu()
	_verify_smoke_stage(
		"03_native_item_menu",
		item_menu_ready,
		"Remake's encounter item picker opens with the carried key"
	)
	if not item_menu_ready:
		get_tree().quit(1)
		return
	var item_menu: Control = UI.ow_hud.encounterControl.useitemRect
	var item_button: Button = item_menu.itemsContainer.get_child(0)
	item_button.pressed.emit()
	await _wait_frames(3)
	_verify_smoke_stage(
		"04_complex_item_result",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
			"The lock is now open"
		)
			and holder.inventory.size() == 1,
		"the Necklace of Keys selects result 1 without consuming the key"
	)
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	await _wait_frames(3)
	_verify_smoke_stage(
		"05_complex_item_complete",
		"Classic complex-item playtest complete" \
			in UI.ow_hud.textRect.textLabel.get_parsed_text(),
		"host completes after the complex item result"
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
			and UI.ow_hud.textRect.choicesContainer.get_child_count() == 8
			and _choice_menu_fits_map_area(),
		"rogue controls, the chest action, and back-out are visible"
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
		retry_ready and UI.ow_hud.textRect.choicesContainer.get_child_count() == 6,
		"sprung trap leaves Pick Lock, the chest action, and back-out available"
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
	if test_max_movement >= 0.0:
		rogue.base_stats["MaxMovement"] = test_max_movement
		rogue.stats["MaxMovement"] = test_max_movement
	if not test_item_name.is_empty():
		rogue.inventory.append(GameGlobal.generate_item(test_item_name))
	return rogue


func _make_playtest_spellcaster() -> PlayerCharacter:
	var caster: PlayerCharacter = GameGlobal.playerCharacterGD.new(
		{
			"name": "Test Sorcerer",
			"level": 1,
			"exp_tnl": 10000,
		},
		null,
		null,
		SorcererClass,
		HumanRace
	)
	var spell := CaveInSpell.new()
	caster.spells = [[{
		"name": spell.name,
		"source": "",
		"script": spell,
	}]]
	caster.stats["maxSP"] = 20
	caster.stats["curSP"] = 20
	return caster


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


func _wait_for_character_picker() -> bool:
	for _frame: int in 120:
		await get_tree().process_frame
		if StateMachine.ex_menu_state.cur_menu_name == "PC_Pick" \
			and UI.ow_hud.charsVContainer.get_child_count() >= test_party_size:
			return true
	push_error("Classic character-pick smoke timed out waiting for Remake's party picker")
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


func _wait_for_spell_menu() -> bool:
	for _frame: int in 120:
		await get_tree().process_frame
		var spell_menu: SpellsMenu = UI.ow_hud.spellcastMenu
		if spell_menu.visible and spell_menu.spelllistContainer.get_child_count() > 0:
			return true
	push_error("Classic spell smoke timed out waiting for Remake's spell picker")
	return false


func _wait_for_item_menu() -> bool:
	for _frame: int in 120:
		await get_tree().process_frame
		var encounter_control: Control = UI.ow_hud.encounterControl
		var item_menu: Control = encounter_control.useitemRect
		if encounter_control.visible \
				and item_menu.visible \
				and item_menu.itemsContainer.get_child_count() > 0:
			return true
	push_error("Classic item smoke timed out waiting for Remake's encounter item picker")
	return false


func _wait_for_speech_panel() -> bool:
	for _frame: int in 120:
		await get_tree().process_frame
		var encounter_control: Control = UI.ow_hud.encounterControl
		if encounter_control.visible \
				and encounter_control.speakButton.visible \
				and encounter_control.speakButton.get_child(0).visible:
			return true
	push_error("Classic word smoke timed out waiting for Remake's speech input")
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
