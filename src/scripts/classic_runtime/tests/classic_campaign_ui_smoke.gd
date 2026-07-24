extends Node

const AcceptanceAssets = preload(
	"res://scripts/classic_runtime/classic_acceptance_assets.gd"
)
const CAMPAIGNS_DIRECTORY := \
	"res://scripts/classic_runtime/tests/fixtures/installed_campaigns/"
const CAMPAIGN_NAME := "campaign_ui_smoke"
const CAMPAIGN_TITLE := "Classic Campaign UI Smoke"
const EnchanterClass = preload("res://Data/Character Classes/Class_Enchanter.gd")
const HumanRace = preload("res://Data/Character Races/Race_Human.gd")

var failures: Array[String] = []
var original_campaigns_directory := ""
var original_profiles_directory := ""
var original_profile_folder_name := ""
var original_profile_characters: Array = []
var original_player_characters: Array = []
var temporary_profile_root := ""


func _ready() -> void:
	call_deferred("_run_smoke")


func _run_smoke() -> void:
	await get_tree().process_frame
	original_campaigns_directory = Paths.campaignsfolderpath
	original_profiles_directory = Paths.profilesfolderpath
	original_profile_folder_name = Paths.currentProfileFolderName
	original_profile_characters = GameGlobal.profile_characters_list.duplicate()
	original_player_characters = GameGlobal.player_characters.duplicate()
	Paths.campaignsfolderpath = CAMPAIGNS_DIRECTORY
	temporary_profile_root = (
		"user://classic-campaign-ui-smoke-%d" % Time.get_ticks_usec()
	)
	Paths.profilesfolderpath = temporary_profile_root.path_join("Profiles/")
	Paths.currentProfileFolderName = "Smoke Profile"
	var test_character := _create_character()
	var test_character_directory := (
		Paths.profilesfolderpath
		.path_join(Paths.currentProfileFolderName)
		.path_join("Characters")
		.path_join(test_character.name)
	)
	DirAccess.make_dir_recursive_absolute(test_character_directory)
	Utils.FileHandler.save_character(test_character_directory, test_character)
	GameGlobal.profile_characters_list = [test_character]
	GameGlobal.player_characters.clear()

	var panel: Node = UI.main_menu.newCampaignPanel
	UI.main_menu._on_new_campaign_button_pressed()
	_expect(
		panel.importClassicButton != null
			and panel.classicImportDialog.file_mode == FileDialog.FILE_MODE_OPEN_DIR
			and panel.classicImportDialog.access == FileDialog.ACCESS_FILESYSTEM,
		"campaign picker exposes a filesystem directory installer for Classic exports"
	)
	panel.request_classic_campaign_import(
		ProjectSettings.globalize_path("user://missing-classic-campaign-ui-export")
	)
	for _frame: int in 3:
		await get_tree().process_frame
	_expect(
		panel.classicImportStatusLabel.visible
			and panel.classicImportStatusLabel.text.contains(
				"Classic campaign export directory does not exist"
			),
		"campaign picker reports an invalid Classic export without changing discovery"
	)
	panel.classicImportResultDialog.hide()
	panel.request_classic_campaign_import(CAMPAIGNS_DIRECTORY.path_join(CAMPAIGN_NAME))
	await get_tree().process_frame
	_expect(
		panel.classicReplaceDialog.visible
			and panel.classicReplaceDialog.dialog_text.contains("already installed"),
		"campaign picker requires confirmation before replacing an installed campaign"
	)
	panel._on_ClassicReplaceDialog_canceled()
	panel.classicReplaceDialog.hide()
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
		item_text == "%s — Classic: Ready" % CAMPAIGN_TITLE,
		"campaign list shows the manifest title and readiness state"
	)
	_expect(
		panel._campaign_display_name("City of Bywater", null)
			== "City of Bywater — Native",
		"campaign list explicitly distinguishes native campaigns"
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
	_expect(
		panel.selectedCampaignDescrLabel.text.contains(
			"Party: Up to 6 characters; party total level 1 or lower."
		),
		"campaign selection shows the compiled party admission summary"
	)
	_expect(
		not panel.createCharacterButton.disabled,
		"ready Classic campaign offers scenario-aware character creation"
	)
	_expect(
		_profile_character("Cindred") != null
			and _profile_character("Midnight") != null
			and _profile_character("Traskelion") != null
			and GameGlobal.profile_characters_list.size() == 8,
		"selecting a ready Classic campaign adds the seven stock characters"
	)
	var stock_character_button := _character_button(
		panel.charPickRect.eligibleContainer.get_children(),
		"Tristan"
	)
	_expect(
		stock_character_button != null and not stock_character_button.disabled,
		"a Ready Classic campaign accepts a stock Classic character"
	)
	panel._on_CreateCharacterButton_pressed()
	await get_tree().process_frame
	var character_panel: Node = UI.main_menu.newCharacterPanel
	_expect(
		character_panel.visible and not panel.visible,
		"campaign creation opens the existing New Character panel"
	)
	_expect(
		character_panel.classicContextLabel.visible \
			and character_panel.genderOptionButton.visible \
			and character_panel.classic_campaign_name == CAMPAIGN_NAME,
		"New Character panel retains the selected Classic campaign context"
	)
	_expect(
		character_panel.raceitemlist.item_count > 0 \
			and character_panel.classitemlist.item_count > 0,
		"scenario-aware creation exposes eligible race and caste choices"
	)
	character_panel._on_CancelButton_pressed()
	await get_tree().process_frame
	_expect(
		panel.visible and panel.selectedCampaign == CAMPAIGN_NAME,
		"closing character creation returns to the selected campaign"
	)

	var live_rules: Dictionary = panel.selectedcampaign_onselect
	var original_rules := live_rules.duplicate(true)
	live_rules["bannedRaceIds"] = [1]
	live_rules["raceNames"] = ["Human"]
	panel.charPickRect.fill()
	await get_tree().process_frame
	var rejected_characters: Array[Node] = \
		panel.charPickRect.eligibleContainer.get_children()
	var rejected_test_character := _character_button(
		rejected_characters,
		"Campaign UI Test Enchanter"
	)
	_expect(
		rejected_test_character != null and rejected_test_character.disabled,
		"authored Classic restrictions disable an ineligible profile character"
	)
	_expect(
		rejected_test_character != null
			and rejected_test_character.tooltip_text.contains("Human")
			and rejected_test_character.tooltip_text.contains("banned"),
		"ineligible character exposes an actionable restriction reason"
	)
	live_rules.clear()
	live_rules.merge(original_rules, true)
	panel.charPickRect.fill()
	await get_tree().process_frame
	var eligible_characters: Array[Node] = panel.charPickRect.eligibleContainer.get_children()
	var eligible_test_character := _character_button(
		eligible_characters,
		"Campaign UI Test Enchanter"
	)
	_expect(
		eligible_test_character != null and not eligible_test_character.disabled,
		"ready Classic campaign accepts an eligible profile character"
	)
	if eligible_test_character == null or eligible_test_character.disabled:
		_finish()
		return
	panel.charPickRect._on_char_button_pressed(eligible_test_character)
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
	var search_button: Button = UI.ow_hud.classicSearchButton
	_expect(
		search_button.visible and search_button.toggle_mode,
		"normal Classic launch exposes the Search toggle"
	)
	search_button.button_pressed = true
	await get_tree().process_frame
	_expect(
		GameGlobal.classic_party_conditions.get("5") == -1 \
			and UI.ow_hud.globaleffectsRect.eye_sprite.animation \
				== &"Searching",
		"the Search toggle updates exact state and its native HUD indicator"
	)
	search_button.button_pressed = false
	await get_tree().process_frame
	_expect(
		GameGlobal.classic_party_conditions.get("5") == 0,
		"the Search toggle clears the exact Classic slot"
	)
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


func _profile_character(character_name: String) -> PlayerCharacter:
	for character: PlayerCharacter in GameGlobal.profile_characters_list:
		if character.name == character_name:
			return character
	return null


func _character_button(
	buttons: Array[Node],
	character_name: String
) -> Node:
	for button: Node in buttons:
		var character: Variant = button.get("character")
		if character != null and str(character.get("name")) == character_name:
			return button
	return null


func _create_character() -> PlayerCharacter:
	var character: PlayerCharacter = GameGlobal.playerCharacterGD.new(
		{
			"name": "Campaign UI Test Enchanter",
			"level": 1,
			"exp_tnl": 10000,
		},
		AcceptanceAssets.player_icon(),
		AcceptanceAssets.classic_portrait_257(),
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
	Paths.profilesfolderpath = original_profiles_directory
	Paths.currentProfileFolderName = original_profile_folder_name
	GameGlobal.profile_characters_list = original_profile_characters
	GameGlobal.player_characters = original_player_characters
	if not temporary_profile_root.is_empty():
		_remove_directory(temporary_profile_root)
	if failures.is_empty():
		print("Classic campaign UI smoke passed.")
		get_tree().quit(0)
		return
	printerr("Classic campaign UI smoke failed: %s" % "; ".join(failures))
	get_tree().quit(1)


func _remove_directory(path: String) -> void:
	var directory := DirAccess.open(path)
	if directory == null:
		return
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		if entry not in [".", ".."]:
			var entry_path := path.path_join(entry)
			if directory.current_is_dir():
				_remove_directory(entry_path)
			else:
				DirAccess.remove_absolute(entry_path)
		entry = directory.get_next()
	directory.list_dir_end()
	DirAccess.remove_absolute(path)
