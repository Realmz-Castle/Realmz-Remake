extends Node


const RogueClass = preload("res://Data/Character Classes/Class_Assassin.gd")
const HumanRace = preload("res://Data/Character Races/Race_Human.gd")
const DefaultIcon = preload("res://scenes/UI/Main Menu/DefaultIcon.png")
const DefaultPortrait = preload("res://scenes/UI/Main Menu/DefaultPortrait.png")


class OpenLockSpell:
	extends Spell

	func _init() -> void:
		name = "Open Lock"
		description = "Opens ordinary locks."
		elements = [GameGlobal.ELEMENTS.MAGICAL]
		schools = ["Sorcerer"]
		school_levels = {"Sorcerer": 1}
		selection_costs = {"Sorcerer": 1}
		in_field = true
		max_plevel = 1
		sounds = ["claps.wav", "pops.wav"]

	func get_sp_cost(_power: int, _caster) -> int:
		return 0


class ResultBranchEncounter:
	extends RefCounted

	signal encounter_over

	var allow_spells := false
	var allow_items := false
	var allow_action := false
	var allow_speak := false
	var allow_stop := true
	var result_calls: Array[int] = []

	func result1() -> void:
		result_calls.append(0)

	func result2() -> void:
		result_calls.append(1)

	func result3() -> void:
		result_calls.append(2)

	func result4() -> void:
		result_calls.append(3)


var _automated_smoke := false
var _failures: Array[String] = []


func _ready() -> void:
	call_deferred("_start_playtest")


func _start_playtest() -> void:
	_automated_smoke = OS.get_cmdline_user_args().has("--smoke")
	if _automated_smoke:
		get_window().size = Vector2i(1152, 648)

	UI.show_only(UI.ow_hud)
	UI.ow_hud.textRect.show()
	await _wait_frames(2)

	GameGlobal.currentcampaign = "City of Bywater"
	GameGlobal.currentmap_name = "map_0"
	GameGlobal.stuff_done.clear()
	GameGlobal.restore_native_encounter_state({})

	var resources: CampaignResources = NodeAccess.__Resources()
	if resources.items_book.is_empty():
		resources.load_item_resources("res://shared_assets/items/")
	resources.load_sound_ressources("res://shared_assets/sounds/")
	resources.load_special_encounter_resources("City of Bywater")
	resources.special_encounters_book["result_branch_test"] = ResultBranchEncounter.new()
	_create_playtest_character()
	if not resources.special_encounters_book.has("native_nested_proof"):
		_finish_with_error("City of Bywater native encounter data did not load")
		return

	GameGlobal.currentSpecialEncounterName = "native_nested_proof"
	UI.ow_hud.encounterControl.initialize(GameGlobal.currentSpecialEncounterName)
	await _wait_frames(2)
	if _automated_smoke:
		await _run_smoke()
	else:
		UI.ow_hud.textRect.set_text(
			"Native encounter playtest: try the action, spoken-word, item, spell, "
			+ "and Pick Lock responses.",
			false
		)


func _run_smoke() -> void:
	var encounter = UI.ow_hud.encounterControl
	_expect(
		encounter.visible
			and encounter.actionButton.visible
			and encounter.speakButton.visible
			and encounter.spellButton.visible
			and encounter.itemButton.visible
			and encounter.skillbutton.visible
			and encounter.stopButton.visible,
		"the existing HUD exposes every configured response mode"
	)

	encounter.skillbutton.pressed.emit()
	await _wait_frames(2)
	_expect(encounter.useSkillRect.visible, "the native rogue-skill picker opens")
	encounter.useSkillRect.get_node("CancelButton").pressed.emit()
	await _wait_frames(2)
	_expect(
		encounter.visible and not encounter.useSkillRect.visible,
		"back-out returns to the active encounter"
	)
	encounter.itemButton.pressed.emit()
	await _wait_frames(2)
	_expect(encounter.useitemRect.visible, "the native item picker opens")
	encounter.useitemRect.get_node("CancelButton").pressed.emit()
	await _wait_frames(2)
	_expect(
		encounter.visible and not encounter.useitemRect.visible,
		"item back-out returns to the active encounter"
	)
	encounter.spellButton.pressed.emit()
	await _wait_frames(3)
	_expect(UI.ow_hud.spellcastMenu.visible, "the native spell picker opens")
	UI.ow_hud.spellcastMenu.get_node(
		"VBoxContainer/BottomContainer/AbortButton"
	).pressed.emit()
	await _wait_frames(3)
	_expect(
		encounter.visible and not UI.ow_hud.spellcastMenu.visible,
		"spell back-out returns to the active encounter"
	)

	encounter.actionButton.pressed.emit()
	if not await _wait_for_choices():
		_finish()
		return
	UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("inspect_door")
	if not await _wait_for_text("crest of Waterford"):
		_finish()
		return
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	await _wait_frames(2)
	_expect(
		GameGlobal.stuff_done.get("native_fixture_door_seen") == true,
		"an action result persists its campaign flag"
	)

	encounter.speakButton.pressed.emit()
	encounter.speakField.text = "waterford"
	encounter.speakButton.get_node("NinePatchRect/SpeakDoneButton").pressed.emit()
	if not await _wait_for_text("door swings inward"):
		_finish()
		return
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	await _wait_frames(3)
	_expect(
		encounter.visible
			and encounter.actionButton.visible
			and encounter.stopButton.visible
			and not encounter.speakButton.visible,
		"the HUD follows the encounter-to-encounter jump"
	)
	_expect(
		GameGlobal.stuff_done.get("map_0.mutation.waterford_door_open") == true
			and GameGlobal.stuff_done.get("map_0.script_X999.chance") == 0.0
			and GameGlobal.stuff_done.get("map_0.script_X999.replaced") == "STOP",
		"map and action-point mutations reach native campaign flags"
	)

	var encoded_state := JSON.stringify(GameGlobal.native_encounter_save_payload())
	var restored_value: Variant = JSON.parse_string(encoded_state)
	GameGlobal.restore_native_encounter_state({})
	_expect(GameGlobal.native_encounter_state.is_empty(), "native encounter state can be cleared")
	GameGlobal.restore_native_encounter_state(restored_value)
	_expect(
		GameGlobal.native_encounter_state.get("mapMutations", {}).has("waterford_door_open")
			and GameGlobal.native_encounter_state.get(
				"actionPointMutations",
				{}
			).has("waterford_door_action_point"),
		"normal save data restores native encounter mutations"
	)

	encounter.actionButton.pressed.emit()
	if not await _wait_for_choices():
		_finish()
		return
	UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("enter_passage")
	if not await _wait_for_text("passage continues"):
		_finish()
		return
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	await _wait_frames(3)
	_expect(
		GameGlobal.native_encounter_state.get("values", {}).get(
			"native_fixture_complete"
		) == true,
		"the active controller continues against restored state"
	)
	_expect(not encounter.visible, "the final result closes the encounter")

	encounter.initialize("native_nested_proof")
	await _wait_frames(2)
	_expect(
		encounter.speakButton.visible,
		"reopening a data-driven encounter starts at its entry definition"
	)
	encounter.stopButton.pressed.emit()
	await _wait_frames(2)
	_expect(not encounter.visible, "stop closes the encounter through the existing HUD")

	var random_branch: Variant = ScriptHelperFuncsClass.branch_on_random_divinity(
		2,
		1,
		1,
		0,
		""
	)
	_expect(
		ScriptHelperFuncsClass.is_complex_encounter_branch(random_branch)
			and random_branch.get("encounter") == "CE1",
		"random branches can target a complex encounter"
	)
	var absent_ally_branch: Variant = ScriptHelperFuncsClass.branch_NPC_in_party_Divinity(
		"Missing Ally",
		2,
		0,
		1,
		2
	)
	_expect(
		ScriptHelperFuncsClass.is_complex_encounter_branch(absent_ally_branch)
			and absent_ally_branch.get("encounter") == "CE2",
		"ally checks can target a complex encounter"
	)
	StateMachine.run_complex_encounter_branch(
		random_branch
	)
	await _wait_frames(2)
	_expect(
		encounter.visible
			and encounter.encounter_script
				== NodeAccess.__Resources().special_encounters_book.get("CE1"),
		"legacy map branches open a complex encounter through the existing HUD"
	)
	var transitioned := ScriptHelperFuncsClass.transition_complex_encounter_Divinity(2)
	await _wait_frames(2)
	_expect(
		transitioned
			and encounter.visible
			and encounter.encounter_script
				== NodeAccess.__Resources().special_encounters_book.get("CE2"),
		"legacy complex encounters can transition without closing the HUD"
	)
	encounter.stopButton.pressed.emit()
	await _wait_frames(2)
	_expect(not encounter.visible, "the transitioned legacy encounter closes normally")

	encounter.initialize("result_branch_test")
	await _wait_frames(2)
	var result_fixture: ResultBranchEncounter = encounter.encounter_script
	ScriptHelperFuncsClass.yesno_branch_Divinity(
		true,
		3,
		0,
		"Continue.",
		"Branch."
	)
	if not await _wait_for_choices():
		_finish()
		return
	UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("NO")
	await _wait_frames(2)
	var percent_branch: String = await ScriptHelperFuncsClass.branch_percent_chance_divinity(
		100,
		1,
		2,
		1,
		0
	)
	GameGlobal.stuff_done["quest_777"] = 0
	var quest_branch: String = await ScriptHelperFuncsClass.branch_on_quest_Divinity(
		777,
		0,
		2,
		2,
		0
	)
	var item_branch: String = await ScriptHelperFuncsClass.branch_item_possession_divinity(
		641,
		1,
		2,
		3,
		0
	)
	var direct_branch: String = await ScriptHelperFuncsClass.run_complex_result_Divinity(0)
	_expect(
		result_fixture.result_calls == [0, 1, 2, 3, 0]
			and percent_branch == "STOP"
			and quest_branch == "STOP"
			and item_branch == "STOP"
			and direct_branch == "STOP",
		"legacy branches execute the selected complex result row"
	)
	encounter.stopButton.pressed.emit()
	await _wait_frames(2)
	_expect(not encounter.visible, "the result-branch fixture closes normally")
	_finish()


func _create_playtest_character() -> void:
	var character: PlayerCharacter = GameGlobal.playerCharacterGD.new(
		{
			"name": "Native Encounter Rogue",
			"level": 1,
			"exp_tnl": 10000,
		},
		DefaultIcon,
		DefaultPortrait,
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
		character.stats[stat_name] = 80.0
	character.stats["maxHP"] = 30
	character.stats["curHP"] = 30
	character.stats["maxSP"] = 20
	character.stats["curSP"] = 20
	character.inventory.append(GameGlobal.generate_item("Necklace of Keys"))
	var spell := OpenLockSpell.new()
	character.spells = [[{
		"name": spell.name,
		"source": "",
		"script": spell,
	}]]
	GameGlobal.player_characters = [character]
	UI.ow_hud.fillCharactersRect()
	UI.ow_hud.selected_character = character


func _wait_for_choices() -> bool:
	for _frame: int in 120:
		await get_tree().process_frame
		var choices = UI.ow_hud.textRect.choicesContainer
		if choices.visible and choices.get_child_count() > 0:
			return true
	push_error("Native encounter playtest timed out waiting for choices")
	return false


func _wait_for_text(fragment: String) -> bool:
	for _frame: int in 120:
		await get_tree().process_frame
		if fragment in UI.ow_hud.textRect.textLabel.get_parsed_text():
			return true
	push_error("Native encounter playtest timed out waiting for text: %s" % fragment)
	return false


func _wait_frames(frame_count: int) -> void:
	for _frame: int in frame_count:
		await get_tree().process_frame


func _expect(condition: bool, description: String) -> void:
	if condition:
		print("PASS: %s" % description)
		return
	_failures.append(description)
	push_error("FAIL: %s" % description)


func _finish_with_error(message: String) -> void:
	_failures.append(message)
	push_error(message)
	_finish()


func _finish() -> void:
	if _failures.is_empty():
		print("Native encounter HUD smoke passed.")
		get_tree().quit(0)
		return
	printerr("Native encounter HUD smoke failed: %s" % "; ".join(_failures))
	get_tree().quit(1)
