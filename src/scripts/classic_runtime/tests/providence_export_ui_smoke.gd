extends Node

const AcceptanceAssets = preload(
	"res://scripts/classic_runtime/classic_acceptance_assets.gd"
)
const InstallerScript = preload(
	"res://scripts/classic_runtime/classic_campaign_package_installer.gd"
)
const PRODUCER_EXPORT := \
	"res://scripts/classic_runtime/tests/fixtures/providence_authoritative_export"
const CAMPAIGN_NAME := "providence_authoritative_export"
const CAMPAIGN_TITLE := "Providence Ownership Proof"
const RogueClass = preload("res://Data/Character Classes/Class_Assassin.gd")
const ElfRace = preload("res://Data/Character Races/Race_Elf.gd")

var failures: Array[String] = []
var installer: ClassicCampaignPackageInstaller
var temporary_root := ""
var artifact_directory := ""
var original_campaigns_directory := ""
var original_profile_characters: Array = []
var original_player_characters: Array = []


func _ready() -> void:
	call_deferred("_run_smoke")


func _run_smoke() -> void:
	await get_tree().process_frame
	get_window().size = Vector2i(1100, 619)
	original_campaigns_directory = Paths.campaignsfolderpath
	original_profile_characters = GameGlobal.profile_characters_list.duplicate()
	original_player_characters = GameGlobal.player_characters.duplicate()

	installer = InstallerScript.new()
	temporary_root = OS.get_user_data_dir().path_join(
		"providence-export-ui-smoke-%d" % Time.get_ticks_msec()
	)
	artifact_directory = OS.get_temp_dir().path_join("realmz-remake-producer-smoke")
	installer._remove_directory(artifact_directory)
	var make_artifacts_error := DirAccess.make_dir_recursive_absolute(artifact_directory)
	_expect(make_artifacts_error == OK, "the visual smoke artifact directory is available")
	if make_artifacts_error != OK:
		_finish()
		return

	var campaigns_directory := temporary_root.path_join("Campaigns")
	var install_result: Dictionary = installer.install_export(
		PRODUCER_EXPORT,
		campaigns_directory
	)
	_expect(
		str(install_result.get("status", "")) == "ok",
		"the unmodified producer export installs through the package lifecycle"
	)
	_expect(
		str(install_result.get("readinessState", "")) == "Ready with fallbacks",
		"the installed producer export reports its bounded native fallbacks"
	)
	if str(install_result.get("status", "")) != "ok":
		_finish()
		return

	Paths.campaignsfolderpath = campaigns_directory.replace("\\", "/").trim_suffix("/") + "/"
	GameGlobal.profile_characters_list = [_create_character()]
	GameGlobal.player_characters.clear()
	var panel: Node = UI.main_menu.newCampaignPanel
	UI.main_menu._on_new_campaign_button_pressed()
	var campaign_index := _find_campaign_index(panel.campaignsItemList, CAMPAIGN_NAME)
	_expect(campaign_index >= 0, "the normal campaign list discovers the installed export")
	if campaign_index < 0:
		_finish()
		return
	_expect(
		panel.campaignsItemList.get_item_text(campaign_index) \
			== "%s — Ready with fallbacks" % CAMPAIGN_TITLE,
		"the campaign list presents the producer title and readiness state"
	)
	panel.campaignsItemList.select(campaign_index)
	panel._on_campaign_selected(campaign_index)
	await get_tree().process_frame
	var eligible_characters: Array[Node] = panel.charPickRect.eligibleContainer.get_children()
	var eligibility_detail := "missing party entry" if eligible_characters.is_empty() \
		else str(eligible_characters[0].tooltip_text)
	_expect(
		eligible_characters.size() == 1 and not eligible_characters[0].disabled,
		"the installed campaign accepts an eligible party member: %s" \
			% eligibility_detail
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
	await _wait_for_view()
	var session: Node = GameGlobal.classic_campaign_session
	_expect(
		is_instance_valid(session),
		"normal launch creates a Classic compatibility session"
	)
	if not is_instance_valid(session):
		_finish()
		return
	var runtime_state: Object = session.host.runtime.runtime_state
	var adapter: Object = session.command_adapter
	var land_image := _capture_map_image()
	_save_artifact(land_image, "01-land.png")
	_verify_stage(
		"01_land_launch",
		GameGlobal.currentcampaign == CAMPAIGN_NAME
			and StateMachine._state_name == "Exploration"
			and GameGlobal.currentmap_name == "map_0"
			and runtime_state.level_type == "land"
			and _native_map_is_visible("map_0", "Outdoor")
			and not land_image.is_empty(),
		"the normal campaign flow renders producer land:0 through native map_0"
	)

	# This fixture has no authored map-transfer action. Exercise the same state and
	# adapter boundary used by a Classic Dungeon Move without claiming action coverage.
	runtime_state.set_location("dungeon", 0, 4, 5)
	runtime_state.set_dungeon_view(2, true)
	var map_port := MapPort.new()
	map_port.configure({"scenarioPortRuntime": adapter})
	var dungeon_result: Dictionary = await map_port.execute("teleport", {
		"levelType": "dungeon",
		"levelIndex": 0,
		"x": 4,
		"y": 5,
		"heading": runtime_state.heading,
		"multiView": runtime_state.multi_view,
		"viewType": runtime_state.view_type,
		"recheckDestination": false,
	})
	await _wait_for_view()
	var dungeon_image := _capture_map_image()
	_save_artifact(dungeon_image, "02-dungeon.png")
	_verify_stage(
		"02_dungeon_transition",
		str(dungeon_result.get("status", "")) != "error"
			and GameGlobal.currentmap_name == "mapd_0"
			and runtime_state.level_type == "dungeon"
			and _native_map_is_visible("mapd_0", "Indoor")
			and not dungeon_image.is_empty(),
		"the compatibility adapter renders producer dungeon:0 through native mapd_0"
	)
	_verify_stage(
		"03_visible_map_change",
		not land_image.is_empty()
			and not dungeon_image.is_empty()
			and land_image.save_png_to_buffer() != dungeon_image.save_png_to_buffer(),
		"the rendered producer land and dungeon regions differ"
	)

	runtime_state.set_location("land", 0, 10, 12)
	var return_result: Dictionary = await map_port.execute("teleport", {
		"levelType": "land",
		"levelIndex": 0,
		"x": 10,
		"y": 12,
		"recheckDestination": false,
	})
	await _wait_for_view()
	var returned_land_image := _capture_map_image()
	_save_artifact(returned_land_image, "03-returned-land.png")
	_verify_stage(
		"04_land_return",
		str(return_result.get("status", "")) != "error"
			and GameGlobal.currentmap_name == "map_0"
			and runtime_state.level_type == "land"
			and _native_map_is_visible("map_0", "Outdoor")
			and not returned_land_image.is_empty(),
		"the compatibility adapter returns to visible producer land:0"
	)
	_verify_stage(
		"05_visible_return",
		not dungeon_image.is_empty()
			and not returned_land_image.is_empty()
			and dungeon_image.save_png_to_buffer() != returned_land_image.save_png_to_buffer(),
		"the rendered return to land differs from the dungeon view"
	)
	print("PROVIDENCE_EXPORT_ARTIFACTS: %s" % artifact_directory)
	_finish()


func _native_map_is_visible(map_name: String, map_type: String) -> bool:
	var resources: CampaignResources = NodeAccess.__Resources()
	var map: Node = NodeAccess.__Map()
	if not resources.maps_book.has(map_name) or map == null:
		return false
	var map_entry: Array = resources.maps_book[map_name]
	if map_entry.is_empty() or map.mapdata != map_entry[0] or map.maptype != map_type:
		return false
	for column: Array in map.mapdata:
		for cell: Array in column:
			for tile: Dictionary in cell:
				if tile.get("texture") is Texture2D:
					return map.visible and UI.ow_hud.visible
	return false


func _capture_map_image() -> Image:
	var image := get_viewport().get_texture().get_image()
	if image == null or image.is_empty():
		return Image.new()
	var map_size := Vector2i(mini(832, image.get_width()), mini(448, image.get_height()))
	if map_size.x <= 0 or map_size.y <= 0:
		return Image.new()
	return image.get_region(Rect2i(Vector2i.ZERO, map_size))


func _save_artifact(image: Image, file_name: String) -> void:
	var save_error := image.save_png(artifact_directory.path_join(file_name)) \
		if not image.is_empty() else ERR_INVALID_DATA
	_expect(save_error == OK, "the %s render capture is written" % file_name)


func _wait_for_view() -> void:
	for _frame: int in 12:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw


func _find_campaign_index(item_list: ItemList, campaign_name: String) -> int:
	for item_index: int in item_list.item_count:
		var metadata: Variant = item_list.get_item_metadata(item_index)
		if metadata is Dictionary and metadata.get("campaignName") == campaign_name:
			return item_index
	return -1


func _create_character() -> PlayerCharacter:
	return GameGlobal.playerCharacterGD.new(
		{
			"name": "Producer Export Test Rogue",
			"level": 1,
			"exp_tnl": 10000,
		},
		AcceptanceAssets.elf_player_icon(),
		AcceptanceAssets.elf_player_portrait(),
		RogueClass,
		ElfRace
	)


func _verify_stage(stage_name: String, passed: bool, detail: String) -> void:
	if passed:
		print("PROVIDENCE_EXPORT_STAGE PASS: %s - %s" % [stage_name, detail])
		return
	failures.append(stage_name)
	push_error("PROVIDENCE_EXPORT_STAGE FAIL: %s - %s" % [stage_name, detail])


func _expect(condition: bool, description: String) -> void:
	if condition:
		print("PASS: %s" % description)
		return
	failures.append(description)
	push_error("FAIL: %s" % description)


func _finish() -> void:
	GameGlobal.stop_classic_campaign_runtime()
	Paths.campaignsfolderpath = original_campaigns_directory
	GameGlobal.profile_characters_list = original_profile_characters
	GameGlobal.player_characters = original_player_characters
	if installer != null and not temporary_root.is_empty():
		installer._remove_directory(temporary_root)
	if failures.is_empty():
		print("Providence producer export UI smoke passed.")
		get_tree().quit(0)
		return
	printerr("Providence producer export UI smoke failed: %s" % "; ".join(failures))
	get_tree().quit(1)
