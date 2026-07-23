extends Node

const CAMPAIGNS_DIRECTORY := \
	"res://scripts/classic_runtime/tests/fixtures/installed_campaigns/"
const CAMPAIGN_NAME := "campaign_ui_smoke"
const CAMPAIGN_TITLE := "Classic Campaign UI Smoke"
const EnchanterClass = preload("res://Data/Character Classes/Class_Enchanter.gd")
const HumanRace = preload("res://Data/Character Races/Race_Human.gd")
const DefaultIcon = preload("res://scenes/UI/Main Menu/DefaultIcon.png")
const DefaultPortrait = preload("res://scenes/UI/Main Menu/DefaultPortrait.png")

var failures: Array[String] = []
var original_campaigns_directory := ""
var original_profile_characters: Array = []
var original_player_characters: Array = []


func _ready() -> void:
	call_deferred("_run_smoke")


func _run_smoke() -> void:
	await get_tree().process_frame
	original_campaigns_directory = Paths.campaignsfolderpath
	original_profile_characters = GameGlobal.profile_characters_list.duplicate()
	original_player_characters = GameGlobal.player_characters.duplicate()
	Paths.campaignsfolderpath = CAMPAIGNS_DIRECTORY
	GameGlobal.profile_characters_list = [_create_character()]
	GameGlobal.player_characters.clear()

	var panel: Node = UI.main_menu.newCampaignPanel
	UI.main_menu._on_new_campaign_button_pressed()
	var invalid_index := _find_campaign_index(panel.campaignsItemList, "invalid_campaign")
	_expect(invalid_index >= 0, "invalid Classic package remains visible in the campaign list")
	if invalid_index >= 0:
		panel.campaignsItemList.select(invalid_index)
		panel._on_campaign_selected(invalid_index)
		_expect(panel.startButton.disabled, "invalid Classic package cannot retain an enabled Start button")
		var invalid_description: String = panel.selectedCampaignDescrLabel.text
		_expect(
			invalid_description.contains("Cannot start:")
				and invalid_description.contains("Unsupported classic campaign format"),
			"invalid Classic package shows an actionable diagnostic"
		)

	var campaign_index := _find_campaign_index(panel.campaignsItemList, CAMPAIGN_NAME)
	_expect(campaign_index >= 0, "compiled campaign is discovered by the normal campaign list")
	if campaign_index < 0:
		_finish()
		return

	var item_text: String = panel.campaignsItemList.get_item_text(campaign_index)
	_expect(
		item_text == "%s — Ready" % CAMPAIGN_TITLE,
		"campaign list shows the manifest title and readiness state"
	)
	panel.campaignsItemList.select(campaign_index)
	panel._on_campaign_selected(campaign_index)
	_expect(
		panel.selectedCampaignNameLabel.text == CAMPAIGN_TITLE,
		"campaign selection shows the manifest title"
	)
	_expect(
		panel.selectedCampaignDescrLabel.text.contains("Classic format v1 (realmz-7.1)"),
		"campaign selection shows the bundle version"
	)
	_expect(
		panel.selectedCampaignDescrLabel.text.contains("Status: Ready"),
		"campaign selection shows its readiness summary"
	)

	await get_tree().process_frame
	var eligible_characters: Array[Node] = panel.charPickRect.eligibleContainer.get_children()
	_expect(
		eligible_characters.size() == 1 and not eligible_characters[0].disabled,
		"ready Classic campaign accepts an eligible profile character"
	)
	if eligible_characters.is_empty() or eligible_characters[0].disabled:
		_finish()
		return
	panel.charPickRect._on_char_button_pressed(eligible_characters[0])
	panel.charPickRect._on_AddButton_pressed()
	_expect(not panel.startButton.disabled, "party selection enables the normal Start button")
	if panel.startButton.disabled:
		_finish()
		return

	panel._on_StartButton_pressed()
	for _frame: int in 4:
		await get_tree().process_frame
	_expect(GameGlobal.currentcampaign == CAMPAIGN_NAME, "normal launch selects the compiled campaign")
	_expect(
		is_instance_valid(GameGlobal.classic_campaign_session),
		"normal launch creates the Classic compatibility session"
	)
	_expect(StateMachine._state_name == "Exploration", "normal launch enters Exploration")
	_expect(GameGlobal.currentmap_name == "map_0", "normal launch enters the compiled start map")
	var map: Node = NodeAccess.__Map()
	_expect(
		Vector2i(map.owcharacter.tile_position_x, map.owcharacter.tile_position_y)
			== Vector2i(2, 1),
		"normal launch uses the compiled start coordinates"
	)
	_expect(map.visible and UI.ow_hud.visible, "normal launch presents the native map and HUD")
	var learned_darts: Dictionary = GameGlobal.player_characters[0].spells[1][0]
	_expect(
		learned_darts.get("classicSpellId") == 3208,
		"normal Classic launch assigns the Enchanter Magic Darts identity"
	)
	_expect(
		learned_darts.get("resourceName") == "Classic Magic Darts Enchanter"
			and learned_darts.get("script").get_max_damage(1, null) == 4,
		"normal Classic launch selects the 1-4 Enchanter resource"
	)
	_expect(
		is_instance_valid(UI.ow_hud.classicPlayerMapRect),
		"normal HUD provides the standalone Classic player-map panel"
	)
	await _test_runtime_player_map_display()
	await _test_acquired_player_map_browser()
	_finish()


func _test_runtime_player_map_display() -> void:
	var session: Node = GameGlobal.classic_campaign_session
	var bundle: Object = session.install.bundle
	var adapter: Object = session.command_adapter
	var original_root: String = bundle.root_directory
	bundle.root_directory = "res://Campaigns/City of Bywater"
	UI.ow_hud.classicPlayerMapRect.call_deferred("close_map")
	var result: Dictionary = await adapter.execute_command("give_map", {
		"mapId": 7,
		"display": true,
		"mapRecord": {
			"id": 7,
			"primaryName": "The Old Road",
			"note": "The old road crosses the river north of town.",
			"runtimeMedia": {
				"path": "Splash Images/0.png",
				"mediaType": "image/png",
			},
		},
	})
	bundle.root_directory = original_root
	_expect(
		result.get("runtimeMediaPath") == "Splash Images/0.png",
		"opcode 29 uses decoded player-map media before native minimaps"
	)
	_expect(
		UI.ow_hud.classicPlayerMapRect.map_name_label.text == "The Old Road",
		"opcode 29 presents the compiled player-map name"
	)
	_expect(
		UI.ow_hud.classicPlayerMapRect.map_note_label.text
			== "The old road crosses the river north of town.",
		"opcode 29 presents the compiled player-map note"
	)
	_expect(
		StateMachine._state_name == "Exploration" \
			and not UI.ow_hud.classicPlayerMapRect.visible,
		"closing a Classic player map restores exploration"
	)


func _test_acquired_player_map_browser() -> void:
	var session: Node = GameGlobal.classic_campaign_session
	var bundle: Object = session.install.bundle
	var runtime_state: Object = session.host.runtime.runtime_state
	var original_root: String = bundle.root_directory
	var original_player_maps: Dictionary = bundle.player_maps_by_id.duplicate(true)
	UI.ow_hud._on_minimaps_button_pressed()
	_expect(
		StateMachine._state_name == "ExMenus" \
			and StateMachine.ex_menu_state.cur_menu_name == "MiniMapsMenu",
		"Maps/Notes keeps the native minimap fallback without acquired Classic records"
	)
	StateMachine.exit_ex_menu_state({})
	await get_tree().process_frame
	bundle.root_directory = "res://Campaigns/City of Bywater"
	bundle.player_maps_by_id = {
		3: {
			"id": 3,
			"primaryName": "The River Note",
			"note": "Follow the river when no drawn map survives.",
		},
		5: {
			"id": 5,
			"show": -200,
			"primaryName": "The Archivist's Note",
			"scrollingText": {
				"resourceType": "TEXT",
				"resourceId": -200,
				"text": "The first archive lies beyond the old road.\n\n"
					+ "Seek the stone bridge before nightfall.",
			},
		},
		7: {
			"id": 7,
			"primaryName": "The Old Road",
			"note": "The old road crosses the river north of town.",
			"runtimeMedia": {
				"path": "Splash Images/0.png",
				"mediaType": "image/png",
			},
		},
		9: {
			"id": 9,
			"primaryName": "Unacquired Map",
		},
	}
	runtime_state.set_map_owned(3)
	runtime_state.set_map_owned(5)
	runtime_state.set_map_owned(7)
	UI.ow_hud._on_minimaps_button_pressed()
	_expect(
		StateMachine._state_name == "ExMenus" \
			and StateMachine.ex_menu_state.cur_menu_name == "ClassicPlayerMapMenu",
		"Maps/Notes opens acquired Classic maps through the standalone panel"
	)
	_expect(
		UI.ow_hud.classicPlayerMapRect.current_map_record.get("id") == 3,
		"Maps/Notes begins with the lowest acquired Classic map ID"
	)
	_expect(
		UI.ow_hud.classicPlayerMapRect.missing_media_label.visible,
		"Maps/Notes keeps an acquired note browseable without decoded art"
	)
	UI.ow_hud.classicPlayerMapRect._on_next_button_pressed()
	_expect(
		UI.ow_hud.classicPlayerMapRect.current_map_record.get("id") == 5 \
			and UI.ow_hud.classicPlayerMapRect.scrolling_text_label.visible \
			and not UI.ow_hud.classicPlayerMapRect.map_texture_rect.visible,
		"Maps/Notes presents acquired scrolling-text player maps"
	)
	_expect(
		UI.ow_hud.classicPlayerMapRect.scrolling_text_label.text.contains(
			"Seek the stone bridge before nightfall."
		),
		"Maps/Notes preserves multiline scrolling-text content"
	)
	UI.ow_hud.classicPlayerMapRect._on_next_button_pressed()
	_expect(
		UI.ow_hud.classicPlayerMapRect.current_map_record.get("id") == 7 \
			and UI.ow_hud.classicPlayerMapRect.map_texture_rect.visible \
			and not UI.ow_hud.classicPlayerMapRect.scrolling_text_label.visible,
		"Maps/Notes advances to acquired decoded player-map art"
	)
	UI.ow_hud.classicPlayerMapRect._on_done_button_pressed()
	await get_tree().process_frame
	_expect(
		StateMachine._state_name == "Exploration" \
			and not UI.ow_hud.classicPlayerMapRect.visible,
		"closing the Maps/Notes Classic catalog restores exploration"
	)
	bundle.root_directory = original_root
	bundle.player_maps_by_id = original_player_maps


func _find_campaign_index(item_list: ItemList, campaign_name: String) -> int:
	for item_index: int in item_list.item_count:
		var metadata: Variant = item_list.get_item_metadata(item_index)
		if metadata is Dictionary and metadata.get("campaignName") == campaign_name:
			return item_index
	return -1


func _create_character() -> PlayerCharacter:
	var character: PlayerCharacter = GameGlobal.playerCharacterGD.new(
		{
			"name": "Campaign UI Test Enchanter",
			"level": 1,
			"exp_tnl": 10000,
		},
		DefaultIcon,
		DefaultPortrait,
		EnchanterClass,
		HumanRace
	)
	var magic_darts = load("res://shared_assets/spells/magic_darts.gd").new()
	character.add_spell_drom_dict({
		"name": magic_darts.name,
		"source": magic_darts.generate_json_string(),
		"script": magic_darts,
	}, 2)
	return character


func _expect(condition: bool, description: String) -> void:
	if condition:
		print("PASS: %s" % description)
		return
	failures.append(description)
	push_error("FAIL: %s" % description)


func _finish() -> void:
	Paths.campaignsfolderpath = original_campaigns_directory
	GameGlobal.profile_characters_list = original_profile_characters
	GameGlobal.player_characters = original_player_characters
	if failures.is_empty():
		print("Classic campaign UI smoke passed.")
		get_tree().quit(0)
		return
	printerr("Classic campaign UI smoke failed: %s" % "; ".join(failures))
	get_tree().quit(1)
