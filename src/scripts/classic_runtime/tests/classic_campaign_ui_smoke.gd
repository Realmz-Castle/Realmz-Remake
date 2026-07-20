extends Node

const CAMPAIGNS_DIRECTORY := \
	"res://scripts/classic_runtime/tests/fixtures/installed_campaigns/"
const CAMPAIGN_NAME := "campaign_ui_smoke"
const CAMPAIGN_TITLE := "Classic Campaign UI Smoke"
const RogueClass = preload("res://Data/Character Classes/Class_Assassin.gd")
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
	_expect(
		is_instance_valid(UI.ow_hud.classicPlayerMapRect),
		"normal HUD provides the standalone Classic player-map panel"
	)
	await _test_runtime_player_map_display()
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


func _find_campaign_index(item_list: ItemList, campaign_name: String) -> int:
	for item_index: int in item_list.item_count:
		var metadata: Variant = item_list.get_item_metadata(item_index)
		if metadata is Dictionary and metadata.get("campaignName") == campaign_name:
			return item_index
	return -1


func _create_character() -> PlayerCharacter:
	return GameGlobal.playerCharacterGD.new(
		{
			"name": "Campaign UI Test Rogue",
			"level": 1,
			"exp_tnl": 10000,
		},
		DefaultIcon,
		DefaultPortrait,
		RogueClass,
		HumanRace
	)


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
