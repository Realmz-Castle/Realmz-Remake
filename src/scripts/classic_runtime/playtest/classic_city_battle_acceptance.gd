extends Node

const AdapterScript = preload(
	"res://scripts/scenario_runtime/godot/scenario_godot_services.gd"
)
const AcceptanceAssets = preload(
	"res://scripts/classic_runtime/classic_acceptance_assets.gd"
)
const CampaignSessionScript = preload(
	"res://scripts/classic_runtime/classic_campaign_session.gd"
)
const RogueClass = preload("res://Data/Character Classes/Class_Assassin.gd")
const HumanRace = preload("res://Data/Character Races/Race_Human.gd")

const TRIGGER_ID := "Data DD:0:30"
# The trigger's action ID 85 selects Extra Code row 85, which resolves Battle 45.
const BATTLE_ID := 45
const MONSTER_ID := 80
const EXPECTED_ENEMY_COUNT := 24
const TRIGGER_POSITION := Vector2i(2, 44)
const DRAGON_TRIGGER_ID := "Data DD:0:67"
const DRAGON_BATTLE_ID := 176
const DRAGON_MONSTER_ID := 39
const DRAGON_TRIGGER_POSITION := Vector2i(29, 24)
const DRAGON_INTRO_MESSAGE := "You emerge into the musty confines of a large cavern"
const DRAGON_BATTLE_MESSAGE := "You stand toe-to-toe with a blue dragon"
const GUARD_TRIGGER_ID := "Data DD:0:0"
const GUARD_POSITION := Vector2i(9, 17)
const GUARD_INTRO_MESSAGE := "You enter the guard house outside the main gate"
const GUARD_OUTCOME_MESSAGE := "He bids you farewell"
const SPLASH_TRIGGER_ID := "Data DD:0:76"
const SPLASH_POSITION := Vector2i(2, 2)
const SPLASH_PICTURE_ID := 32128
const SPLASH_MESSAGES: Array[String] = [
	"Welcome to \"The City of Bywater\"",
	"Once you have registered this copy of Realmz, you will be able to play the entire scenario",
	"Once you have registered this copy of Realmz, you will also be able to play test",
	"Other scenarios utilize the capabilities of the Realmz scenario driver",
]
const SPLASH_SOUND_NAMES: Array[String] = [
	"heal.wav",
	"heal.wav",
	"hallelujah.wav",
]
const GUARD_CHOICES: Array[String] = [
	"Attempt to bribe your way into the castle.",
	"Show him an invitation to the castle.",
	"Show him a forged invitation.",
	"Kindly bid him farewell and leave the guardhouse.",
]
const SHOP_TRIGGER_ID := "Data DD:0:29"
const SHOP_POSITION := Vector2i(38, 13)
const SHOP_NAME := "classic_shop_4"
const SHOP_MESSAGE := "You have walked into a tannery"
const SHOP_ITEM_ID := 806
const QUEST_TRIGGER_ID := "Data DD:0:17"
const QUEST_POSITION := Vector2i(10, 6)
const QUEST_MAP_ID := 3
const QUEST_ITEM_ID := 807
const QUEST_REWARD_ITEM_IDS: Array[int] = [210, 434]
const QUEST_OFFER_MESSAGES: Array[String] = [
	"You have entered the blacksmith's shop",
	"\"Hello.  Good people, what can I do for you today?\"",
	"\"I cannot get the King's men to rout out these foul vermin",
	"If you were to send these foul sluk",
]
const QUEST_ACCEPT_MESSAGE := "The blacksmith hands you a map"
const QUEST_COMPLETE_MESSAGES: Array[String] = [
	"The blacksmith weeps as you hand him his son's possessions",
	"\"But alas, I am old and withered",
]
const FIRST_MESSAGE := "In this hut there is a wounded goblin"
const SECOND_MESSAGE := "You search his body and turn up a map"
const MAP_GAINED_MESSAGE := "You gain a map"
const RETURN_MESSAGE := "Among the items, you find a sack"
const MUTATED_TRIGGER_ID := QUEST_TRIGGER_ID
const ACCEPTANCE_PROFILE := "City Acceptance"
const ACCEPTANCE_SAVE := "Post Battle"

@export var campaign_directory := ""
@export var native_campaign := "City of Bywater"

var campaign_session: ClassicCampaignSession
var host: ClassicRuntimeHost
var automated_smoke := false
var launch_through_ui := false
var interactive_overworld := false
var presentation_only := false
var winter_smoke := false
var dragon_smoke := false
var acceptance_phase := ""
var profile_root := ""
var smoke_capture_directory := ""
var smoke_failures: Array[String] = []


func _ready() -> void:
	call_deferred("_start_playtest")


func _start_playtest() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--smoke":
			automated_smoke = true
		elif argument == "--ui-launch":
			launch_through_ui = true
		elif argument == "--overworld-demo":
			interactive_overworld = true
			launch_through_ui = true
		elif argument == "--presentation-only":
			presentation_only = true
		elif argument == "--winter-smoke":
			winter_smoke = true
		elif argument == "--dragon-smoke":
			dragon_smoke = true
		elif argument == "--save-phase":
			acceptance_phase = "save"
			launch_through_ui = true
		elif argument == "--continue-phase":
			acceptance_phase = "continue"
			launch_through_ui = true
		elif argument.begins_with("--profile-root="):
			profile_root = argument.trim_prefix("--profile-root=")
		elif argument.begins_with("--capture="):
			smoke_capture_directory = argument.trim_prefix("--capture=")
		else:
			campaign_directory = argument
	if automated_smoke:
		get_window().size = Vector2i(1100, 619)
	if campaign_directory.is_empty():
		_fail("load_bundle", "Pass a fresh City of Bywater bundle directory")
		_finish_smoke()
		return
	campaign_directory = campaign_directory.replace("\\", "/").trim_suffix("/")
	if not acceptance_phase.is_empty():
		if not _prepare_acceptance_profile():
			_finish_smoke()
			return
		if acceptance_phase == "continue":
			await _continue_installed_campaign()
			return

	var resources: CampaignResources = NodeAccess.__Resources()
	var start_result := {"status": "ok"}
	if launch_through_ui:
		if not await _launch_installed_campaign():
			_finish_smoke()
			return
	else:
		GameGlobal.set_current_campaign(native_campaign)
		resources.load_campaign_ressources(native_campaign)
		_create_playtest_party()
		UI.show_only(UI.ow_hud)
		NodeAccess.__Map().show()
		if not _load_session():
			_finish_smoke()
			return
		start_result = campaign_session.activate_start_location()
		StateMachine.transition_to("Exploration")
	_verify_stage(
		"01_city_entry",
		str(start_result.get("status", "")) != "error"
			and GameGlobal.currentmap_name == "map_0"
			and _native_position() == Vector2i(2, 1),
		"the fresh City bundle enters native map_0 at its authored start"
	)
	if not smoke_failures.is_empty():
		_finish_smoke()
		return
	if interactive_overworld:
		print("CLASSIC_CITY_DEMO READY: City of Bywater map_0 at (2, 1)")
		if automated_smoke:
			_finish_smoke()
		return
	if winter_smoke:
		await _verify_winter_timed_encounter()
		_finish_smoke()
		return
	if dragon_smoke:
		await _verify_dragon_battle()
		_finish_smoke()
		return
	if not await _present_city_splash():
		_finish_smoke()
		return
	if presentation_only:
		_finish_smoke()
		return
	if not await _complete_guard_house_encounter():
		_finish_smoke()
		return
	if not await _use_tannery_shop():
		_finish_smoke()
		return
	if not await _accept_blacksmith_quest():
		_finish_smoke()
		return
	if not await _browse_acquired_player_maps():
		_finish_smoke()
		return
	_move_to_trigger()

	if not _verify_native_monster_mapping(resources):
		_finish_smoke()
		return
	resources.battles_book.erase("Battle_%d" % BATTLE_ID)
	if not host.start_trigger(TRIGGER_ID):
		_fail("start_trigger", str(host.runtime.last_result))
		_finish_smoke()
		return

	if not await _dismiss_message(FIRST_MESSAGE):
		_fail("08_authored_presentation", "the first authored message did not open")
		_finish_smoke()
		return
	if not await _dismiss_message(SECOND_MESSAGE):
		_fail("08_authored_presentation", "the second authored message did not open")
		_finish_smoke()
		return
	if not await _dismiss_message(MAP_GAINED_MESSAGE):
		_fail("08_authored_presentation", "the acquired-map notice did not open")
		_finish_smoke()
		return
	if not await _wait_for_combat():
		_fail("09_source_battle", _combat_diagnostic())
		_finish_smoke()
		return

	var battle: Dictionary = resources.battles_book.get("Battle_%d" % BATTLE_ID, {})
	_verify_stage(
		"08_authored_presentation",
		host.runtime.runtime_state.is_map_owned(4),
		"the pre-battle action list acquires City player map 4"
	)
	_verify_stage(
		"09_source_battle",
		int(battle.get("classicBattleId", -1)) == BATTLE_ID
			and battle.get("Creatures", []).size() == EXPECTED_ENEMY_COUNT
			and _classic_enemy_count(MONSTER_ID) == EXPECTED_ENEMY_COUNT,
		"the compiled 24-Krise formation materializes into the native battle roster"
	)
	_verify_stage(
		"09_battlefield",
		_temporary_battlefield_is_drawable(),
		"the temporary battle map has visible terrain and a matching exploration grid"
	)
	if not automated_smoke:
		await _wait_frames(120)

	call_deferred("_request_victory")
	if automated_smoke:
		await _finish_victory_and_reload()


func _prepare_acceptance_profile() -> bool:
	if profile_root.is_empty():
		_fail("acceptance_profile", "Pass --profile-root=<temporary directory>")
		return false
	profile_root = profile_root.replace("\\", "/").trim_suffix("/")
	Paths.profilesfolderpath = profile_root + "/Profiles/"
	Paths.settingspath = profile_root + "/override.cfg"
	var profile_path := Paths.profilesfolderpath + ACCEPTANCE_PROFILE
	if acceptance_phase == "save" and DirAccess.dir_exists_absolute(profile_path):
		_fail("acceptance_profile", "the save phase requires a new temporary profile root")
		return false
	if not DirAccess.dir_exists_absolute(profile_path):
		if not GameGlobal.create_new_profile(ACCEPTANCE_PROFILE, false):
			_fail("acceptance_profile", "the disposable acceptance profile could not be created")
			return false
	GameGlobal.set_current_profile(ACCEPTANCE_PROFILE)
	if acceptance_phase == "continue":
		var character := _profile_acceptance_character()
		var deferred_ids: Array[String] = []
		if character != null:
			for item_value: Dictionary in character.deferred_item_inventory:
				deferred_ids.append(str(item_value.get("definitionId", "")))
		_verify_stage(
			"12a_profile_inventory_deferred",
			character != null
				and deferred_ids.has(_classic_definition_id(SHOP_ITEM_ID))
				and deferred_ids.has(_classic_definition_id(QUEST_ITEM_ID)),
			"campaign-owned profile items remain serialized until their catalog loads"
		)
		if not smoke_failures.is_empty():
			return false
	return true


func _continue_installed_campaign() -> void:
	var campaigns_directory := campaign_directory.get_base_dir()
	var campaign_name := campaign_directory.get_file()
	Paths.campaignsfolderpath = campaigns_directory + "/"
	var load_control: SaveLoadCtrl = UI.main_menu.loadgameCtrl
	UI.main_menu._on_load_button_pressed()
	await get_tree().process_frame

	var campaign_index := load_control.scenarios_panel.scenarios_list.find(campaign_name)
	if campaign_index < 0:
		_fail("13_disk_continue", "the saved campaign was not listed by the main-menu Load window")
		_finish_smoke()
		return
	load_control.scenarios_panel.scenarios_itemlist.select(campaign_index)
	load_control.scenarios_panel._on_scenarios_item_list_item_selected(campaign_index)
	await get_tree().process_frame

	var save_index := load_control.saves_panel.saves_list.find(ACCEPTANCE_SAVE)
	if save_index < 0:
		_fail("13_disk_continue", "the persisted City save was not listed by the Load window")
		_finish_smoke()
		return
	load_control.saves_panel.saves_itemlist.select(save_index)
	load_control.saves_panel._on_saves_item_list_item_selected(save_index)
	await get_tree().process_frame
	if load_control.preview_panel.load_button.disabled:
		_fail("13_disk_continue", "the selected City save did not enable the normal Load button")
		_finish_smoke()
		return
	load_control.preview_panel.load_button.pressed.emit()
	for _frame: int in 600:
		if is_instance_valid(GameGlobal.classic_campaign_session) \
				and StateMachine._state_name == "Exploration":
			break
		await get_tree().process_frame
	if not is_instance_valid(GameGlobal.classic_campaign_session):
		_fail("13_disk_continue", "Continue did not restore a Classic campaign session")
		_finish_smoke()
		return

	campaign_session = GameGlobal.classic_campaign_session
	host = campaign_session.host
	host.playthrough_stopped.connect(_on_playthrough_stopped)
	var restored_state: ClassicRuntimeState = host.runtime.runtime_state
	var restored_override := restored_state.get_action_point_override(MUTATED_TRIGGER_ID)
	var shop: Dictionary = GameGlobal.get_shop(SHOP_NAME)
	var profile_character := _profile_acceptance_character()
	var profile_inventory_restored := (
		profile_character != null
			and profile_character.deferred_item_inventory.is_empty()
			and _character_has_classic_item(profile_character, SHOP_ITEM_ID)
			and _character_has_classic_item(profile_character, QUEST_ITEM_ID)
	)
	var continue_evidence := {
		"campaign": GameGlobal.currentcampaign,
		"save": GameGlobal.cur_save_name,
		"map": GameGlobal.currentmap_name,
		"position": _native_position(),
		"map3": restored_state.is_map_owned(QUEST_MAP_ID),
		"map4": restored_state.is_map_owned(4),
		"map0": restored_state.is_map_owned(0),
		"mapEntries": campaign_session.acquired_player_map_entries().size(),
		"triggerPercent": restored_state.get_trigger_percent("land", 0, 17, -1),
		"actionOverride": not restored_override.is_empty(),
		"shopItem": _party_has_classic_item(SHOP_ITEM_ID),
		"questItem": _party_has_classic_item(QUEST_ITEM_ID),
		"profileInventoryRestored": profile_inventory_restored,
		"shopQuantity": _shop_stock_quantity(shop),
		"pendingContinuation": campaign_session.has_pending_continuation(),
	}
	var continue_valid := (
		GameGlobal.currentcampaign == campaign_name
			and GameGlobal.cur_save_name == ACCEPTANCE_SAVE
			and GameGlobal.currentmap_name == "map_0"
			and _native_position() == TRIGGER_POSITION
			and restored_state.is_map_owned(QUEST_MAP_ID)
			and restored_state.is_map_owned(4)
			and restored_state.is_map_owned(0)
			and campaign_session.acquired_player_map_entries().size() == 3
			and restored_state.get_trigger_percent("land", 0, 17, -1) == 100
			and not restored_override.is_empty()
			and _party_has_classic_item(SHOP_ITEM_ID)
			and _party_has_classic_item(QUEST_ITEM_ID)
			and profile_inventory_restored
			and _shop_stock_quantity(shop) == 83
			and not campaign_session.has_pending_continuation()
	)
	_verify_stage(
		"13_disk_continue",
		continue_valid,
		(
			"a fresh process restores the native and Classic post-battle state from disk"
			if continue_valid
			else "fresh-process state mismatch: %s" % str(continue_evidence)
		)
	)
	if not smoke_failures.is_empty():
		_finish_smoke()
		return
	await _complete_blacksmith_quest()


func _present_city_splash() -> bool:
	_move_to_position(SPLASH_POSITION)
	if not host.start_trigger(SPLASH_TRIGGER_ID):
		_fail("01a_city_splash_picture", str(host.runtime.last_result))
		return false
	if not await _wait_for_picture_message(SPLASH_MESSAGES[0]):
		_fail("01a_city_splash_picture", "the authored splash and welcome text did not open")
		return false

	var picture: Dictionary = host.runtime.bundle.get_picture(SPLASH_PICTURE_ID)
	var runtime_path: String = campaign_session.command_adapter.runtime_media_path(
		picture,
		"image/"
	)
	var texture: Texture2D = UI.ow_hud.pictureRect.pictxtrect.texture
	_verify_stage(
		"01a_city_splash_picture",
		not runtime_path.is_empty()
			and texture != null
			and texture.get_size() == Vector2(320, 320),
		"AP 76 presents Providence's decoded 320x320 City PICT in the native HUD"
	)
	if not smoke_failures.is_empty():
		return false
	await _capture_smoke_stage("01a_city_splash_picture")

	var sound_book: Dictionary = NodeAccess.__Resources().sounds_book
	var resolved_sound_count := 0
	for message_index: int in SPLASH_MESSAGES.size():
		if message_index > 0 \
				and not await _wait_for_picture_message(SPLASH_MESSAGES[message_index]):
			_fail(
				"01b_city_splash_order",
				"the splash did not remain visible for authored message %d" % (message_index + 1)
			)
			return false
		if message_index < SPLASH_SOUND_NAMES.size():
			var sound_name := SPLASH_SOUND_NAMES[message_index]
			if sound_book.has(sound_name) and SfxPlayer.stream == sound_book[sound_name]:
				resolved_sound_count += 1
		UI.ow_hud.textRect.disablerButton.pressed.emit()

	if not await _wait_for_playthrough_completion():
		_fail("01b_city_splash_order", "the splash action list did not complete")
		return false
	_verify_stage(
		"01b_city_splash_order",
		not UI.ow_hud.pictureRect.visible,
		"the four source messages remain over the splash until Redraw Screen restores the map"
	)
	_verify_stage(
		"01c_city_splash_sounds",
		resolved_sound_count == SPLASH_SOUND_NAMES.size(),
		"the splash's three referenced stock sounds resolve through Remake's native sound library"
	)
	return smoke_failures.is_empty()


func _capture_smoke_stage(stage_name: String) -> void:
	if smoke_capture_directory.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(smoke_capture_directory)
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var file_name := "city_acceptance_%s.png" % stage_name.to_snake_case()
	var error := image.save_png(smoke_capture_directory.path_join(file_name))
	if error != OK:
		_fail("capture:%s" % stage_name, "the visual fixture could not be saved")


func _complete_guard_house_encounter() -> bool:
	_move_to_position(GUARD_POSITION)
	if not host.start_trigger(GUARD_TRIGGER_ID):
		_fail("02_guard_house_prompt", str(host.runtime.last_result))
		return false
	if not await _dismiss_message(GUARD_INTRO_MESSAGE):
		_fail("02_guard_house_prompt", "the authored guard-house introduction did not open")
		return false
	if not await _wait_for_choices():
		_fail("02_guard_house_prompt", "the guard-house choices did not open")
		return false
	_verify_stage(
		"02_guard_house_prompt",
		_choice_labels() == GUARD_CHOICES and _has_stop_choice(),
		"the installed campaign presents four source choices plus the stop control"
	)
	UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("4")
	if not await _dismiss_message(GUARD_OUTCOME_MESSAGE):
		_fail("03_guard_house_outcome", "the selected guard-house result did not open")
		return false
	if not await _wait_for_playthrough_completion():
		_fail("03_guard_house_outcome", "the selected simple-encounter result did not complete")
		return false
	_verify_stage(
		"03_guard_house_outcome",
		not campaign_session.has_pending_continuation(),
		"the selected Data ED result returns cleanly to exploration"
	)
	return smoke_failures.is_empty()


func _use_tannery_shop() -> bool:
	_move_to_position(SHOP_POSITION)
	if not host.start_trigger(SHOP_TRIGGER_ID):
		_fail("04_tannery_service", str(host.runtime.last_result))
		return false
	if not await _dismiss_message(SHOP_MESSAGE):
		_fail("04_tannery_service", "the authored tannery introduction did not open")
		return false
	if not await _wait_for_playthrough_completion():
		_fail("04_tannery_service", "the tannery action list did not complete")
		return false
	if not GameGlobal.shops_dict.has(SHOP_NAME):
		_fail("04_tannery_service", "compiled shop 4 did not enter native shop state")
		return false

	var native_shop: Dictionary = GameGlobal.get_shop(SHOP_NAME)
	_verify_stage(
		"04_tannery_service",
		GameGlobal.currentShop == SHOP_NAME
			and UI.ow_hud.shopButton.visible
			and not UI.ow_hud.shopButton.disabled
			and is_equal_approx(float(native_shop.get("buy_rate", -1.0)), 1.0)
			and is_equal_approx(float(native_shop.get("sell_rate", -1.0)), 1.0)
			and _shop_stock_row_count(native_shop) == 17
			and _shop_stock_quantity(native_shop) == 84,
		"shop 4 exposes the contextual HUD control and all authored stock"
	)
	if not smoke_failures.is_empty():
		return false

	var character: PlayerCharacter = GameGlobal.player_characters[0]
	character.money[0] = 100
	GameGlobal.money_pool[0] = 0
	UI.ow_hud.selected_character = character
	await UI.ow_hud._on_shop_button_pressed()
	var inventory: InventoryControl = UI.ow_hud.inventoryRect
	if not await _wait_for_shop():
		_fail("05_tannery_purchase", "the contextual HUD shop button did not open the shop")
		return false
	var shop: ShopRect = inventory.shopRect
	if shop.weapons.size() != 2 \
			or shop.armor.size() != 4 \
			or shop.limbs.size() != 4 \
			or shop.magic.size() != 3 \
			or shop.supplies.size() != 4:
		_fail("05_tannery_purchase", "the native shop did not preserve its five stock categories")
		return false
	shop._on_ShopButton_pressed("Supplies")
	var stock_index := _shop_stock_index(shop.supplies, SHOP_ITEM_ID)
	if stock_index < 0:
		_fail("05_tannery_purchase", "the native shop did not expose Classic item 806")
		return false
	var stock: Array = shop.supplies[stock_index]
	var item: ItemInstance = stock[0]
	var item_view := NodeAccess.__Resources().legacy_item_view_for_adapter(item)
	var original_quantity := int(stock[1])
	var price := shop.price_for(item)
	inventory.inventoryScrollRight._drop_data(Vector2.ZERO, [item, "Shop"])
	await get_tree().process_frame
	_verify_stage(
		"05_tannery_purchase",
		int(item_view.get("classicItemId", 0)) == SHOP_ITEM_ID
			and _party_has_classic_item(SHOP_ITEM_ID)
			and int(shop.supplies[stock_index][1]) == original_quantity - 1
			and int(native_shop["Supplies"][stock_index][1]) == original_quantity - 1
			and character.money[0] == 100 - price,
		"the native shop purchases Classic item 806 and persists its reduced stock"
	)
	shop._on_LeaveShopButton_pressed()
	UI.ow_hud._on_InventoryButton_pressed()
	await get_tree().process_frame
	return smoke_failures.is_empty()


func _accept_blacksmith_quest() -> bool:
	_move_to_position(QUEST_POSITION)
	if not host.start_trigger(QUEST_TRIGGER_ID):
		_fail("06_quest_offer", str(host.runtime.last_result))
		return false
	for message_prefix: String in QUEST_OFFER_MESSAGES:
		if not await _dismiss_message(message_prefix):
			_fail("06_quest_offer", "the authored blacksmith request did not complete")
			return false
	if not await _wait_for_choices():
		_fail("06_quest_offer", "the blacksmith response choices did not open")
		return false
	_verify_stage(
		"06_quest_offer",
		_choice_labels() == ["Avenge his son", "Wish him luck"],
		"the blacksmith request uses its authored Data OD response labels"
	)
	UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("YES")
	if not await _dismiss_message(QUEST_ACCEPT_MESSAGE):
		_fail(
			"07_quest_acceptance",
			"the authored quest acceptance did not open (active=%s, result=%s, text=%s)" % [
				host.active,
				host.runtime.last_result,
				UI.ow_hud.textRect.textLabel.get_parsed_text(),
			]
		)
		return false
	if not await _dismiss_message(MAP_GAINED_MESSAGE):
		_fail("07_quest_acceptance", "the acquired-map notice did not open")
		return false
	if not await _wait_for_playthrough_completion():
		_fail("07_quest_acceptance", "the quest-offer action list did not complete")
		return false
	var state: ClassicRuntimeState = host.runtime.runtime_state
	_verify_stage(
		"07_quest_acceptance",
		state.is_map_owned(QUEST_MAP_ID)
			and state.get_trigger_percent("land", 0, 17, 0) == -1,
		"acceptance grants player map 3 and retires the initial blacksmith action"
	)
	return smoke_failures.is_empty()


func _browse_acquired_player_maps() -> bool:
	UI.ow_hud._on_minimaps_button_pressed()
	await get_tree().process_frame
	var map_panel: Control = UI.ow_hud.classicPlayerMapRect
	var texture: Texture2D = map_panel.map_texture_rect.texture
	_verify_stage(
		"07a_player_map_browser",
		StateMachine._state_name == "ExMenus"
			and StateMachine.ex_menu_state.cur_menu_name == "ClassicPlayerMapMenu"
			and int(map_panel.current_map_record.get("id", -1)) == 0
			and map_panel.map_texture_rect.visible
			and texture != null
			and texture.get_size() == Vector2(320, 320),
		"Maps/Notes opens the initially owned City map as a terrain-composed 320x320 view"
	)
	if not smoke_failures.is_empty():
		return false

	for _entry_index: int in map_panel.map_entries.size():
		if int(map_panel.current_map_record.get("id", -1)) == QUEST_MAP_ID:
			break
		map_panel._on_next_button_pressed()
	texture = map_panel.map_texture_rect.texture
	_verify_stage(
		"07b_acquired_player_map",
		int(map_panel.current_map_record.get("id", -1)) == QUEST_MAP_ID
			and map_panel.map_texture_rect.visible
			and texture != null
			and texture.get_size() == Vector2(320, 320)
			and map_panel.map_note_label.text.begins_with(
				"The location where they found the son of the blacksmith"
			),
		"Maps/Notes browses the newly acquired source map with its terrain, marker, and note"
	)
	map_panel._on_done_button_pressed()
	await get_tree().process_frame
	_verify_stage(
		"07c_player_map_close",
		StateMachine._state_name == "Exploration" and not map_panel.visible,
		"closing the standalone map restores exploration"
	)
	return smoke_failures.is_empty()


func _launch_installed_campaign() -> bool:
	var campaigns_directory := campaign_directory.get_base_dir()
	var campaign_name := campaign_directory.get_file()
	Paths.campaignsfolderpath = campaigns_directory + "/"
	var character := _new_playtest_character()
	if acceptance_phase == "save":
		var character_path := (
			Paths.profilesfolderpath
			+ GameGlobal.currentprofile
			+ "/Characters/"
			+ character.name
		)
		DirAccess.make_dir_recursive_absolute(character_path)
		Utils.FileHandler.save_character(character_path, character)
	GameGlobal.profile_characters_list = [character]
	GameGlobal.player_characters.clear()

	var panel: Node = UI.main_menu.newCampaignPanel
	UI.main_menu._on_new_campaign_button_pressed()
	await get_tree().process_frame
	var campaign_index := _find_campaign_index(panel.campaignsItemList, campaign_name)
	if campaign_index < 0:
		_fail("00_ui_launch", "the installed City package was not listed by the campaign menu")
		return false
	panel.campaignsItemList.select(campaign_index)
	panel._on_campaign_selected(campaign_index)
	await get_tree().process_frame
	var metadata: Variant = panel.campaignsItemList.get_item_metadata(campaign_index)
	var selection_rules: Dictionary = metadata.get("selectionRules", {}) \
		if metadata is Dictionary else {}
	_verify_stage(
		"00_ui_discovery",
		str(selection_rules.get("title", "")).begins_with("City of Bywater")
			and str(selection_rules.get("readinessState", "")).begins_with("Ready")
			and bool(selection_rules.get("valid", false)),
		"the normal campaign menu discovers the clean install as ready"
	)
	if not smoke_failures.is_empty():
		return false

	var eligible_characters: Array[Node] = panel.charPickRect.eligibleContainer.get_children()
	var acceptance_character_button := _find_character_button(
		eligible_characters,
		"City Acceptance Rogue"
	)
	if acceptance_character_button == null or acceptance_character_button.disabled:
		_fail("00_ui_launch", "the normal party picker did not accept the test character")
		return false
	panel.charPickRect._on_char_button_pressed(acceptance_character_button)
	panel.charPickRect._on_AddButton_pressed()
	if panel.startButton.disabled:
		_fail("00_ui_launch", "the normal party picker did not enable Start")
		return false
	panel._on_StartButton_pressed()
	for _frame: int in 120:
		if is_instance_valid(GameGlobal.classic_campaign_session) \
				and StateMachine._state_name == "Exploration":
			break
		await get_tree().process_frame
	if not is_instance_valid(GameGlobal.classic_campaign_session):
		_fail("00_ui_launch", "the normal Start path did not create a Classic session")
		return false
	campaign_session = GameGlobal.classic_campaign_session
	host = campaign_session.host
	host.playthrough_stopped.connect(_on_playthrough_stopped)
	_verify_stage(
		"00_ui_launch",
		GameGlobal.currentcampaign == campaign_name
			and StateMachine._state_name == "Exploration"
			and GameGlobal.currentmap_name == "map_0"
			and _native_position() == Vector2i(2, 1),
		"the normal party and Start controls enter the compiled City start location"
	)
	return smoke_failures.is_empty()


func _find_campaign_index(item_list: ItemList, campaign_name: String) -> int:
	for item_index: int in item_list.item_count:
		var metadata: Variant = item_list.get_item_metadata(item_index)
		if metadata is Dictionary and metadata.get("campaignName") == campaign_name:
			return item_index
	return -1


func _find_character_button(
	buttons: Array[Node],
	character_name: String
) -> Node:
	for button: Node in buttons:
		var character: Variant = button.get("character")
		if character != null and str(character.get("name")) == character_name:
			return button
	return null


func _load_session() -> bool:
	campaign_session = CampaignSessionScript.new()
	add_child(campaign_session)
	var load_result: Dictionary = campaign_session.load_installed_campaign(
		campaign_directory.get_base_dir(),
		campaign_directory.get_file(),
		AdapterScript.new()
	)
	if str(load_result.get("status", "")) != "ok":
		_fail("load_bundle", str(load_result.get("message", "unknown error")))
		return false
	host = campaign_session.host
	GameGlobal.classic_campaign_session = campaign_session
	GameGlobal.register_classic_runtime_host(host)
	host.playthrough_stopped.connect(_on_playthrough_stopped)
	return true


func _verify_native_monster_mapping(resources: CampaignResources) -> bool:
	var native_monster: Dictionary = resources.crea_book.get("Krise 80", {})
	var native_data: Dictionary = native_monster.get("data", {})
	var compiled: Dictionary = campaign_session.install.bundle.get_monster(MONSTER_ID)
	_verify_stage(
		"source_monster_mapping",
		int(native_data.get("id", -1)) == MONSTER_ID
			and str(native_data.get("name", "")) == str(compiled.get("displayName", "")),
		"compiled Monster 80 maps to Remake's existing Krise 80 bestiary entry"
	)
	return smoke_failures.is_empty()


func _temporary_battlefield_is_drawable() -> bool:
	var battle_map: Map = NodeAccess.__Map()
	if GameGlobal.currentmap_name != "temporary_zoomed_map":
		return false
	var columns := int(battle_map.map_size.x)
	var rows := int(battle_map.map_size.y)
	if columns <= 0 or rows <= 0 or battle_map.display_explored_only:
		return false
	if battle_map.explored_tiles.size() != rows:
		return false
	for explored_row: Array in battle_map.explored_tiles:
		if explored_row.size() != columns:
			return false
	var battle_origin := Vector2i(GameGlobal.pos_when_battle_started) * 3
	if battle_origin.x < 0 or battle_origin.y < 0:
		return false
	if battle_origin.x >= columns or battle_origin.y >= rows:
		return false
	var terrain_stack: Array = battle_map.mapdata[battle_origin.x][battle_origin.y]
	return not terrain_stack.is_empty() and terrain_stack[0].get("texture") != null


func _finish_victory_and_reload() -> void:
	if not await _wait_for_treasure():
		_fail("10_victory", "the battle reward screen did not open")
		_finish_smoke()
		return
	UI.ow_hud.treasureControl.find_child("ButtonDone").pressed.emit()
	if GameGlobal.player_allies.is_empty():
		await get_tree().process_frame
		if UI.ow_hud.alliesWindow.visible:
			_fail("10_victory", "victory opened ally management for an empty ally roster")
			_finish_smoke()
			return
	else:
		if not await _wait_for_allies():
			_fail("10_victory", "the post-battle allies screen did not open")
			_finish_smoke()
			return
		UI.ow_hud.alliesCtrl.okbutton.pressed.emit()
	if not await _dismiss_message(RETURN_MESSAGE):
		_fail("11_outer_resume", "the authored post-battle message did not open")
		_finish_smoke()
		return
	if not await _wait_for_treasure():
		_fail("11_outer_resume", "authored treasure 11 did not open")
		_finish_smoke()
		return
	if not await _loot_classic_item(QUEST_ITEM_ID):
		_fail("11_outer_resume", "treasure 11 did not offer mapped item 807")
		_finish_smoke()
		return
	UI.ow_hud.treasureControl.find_child("ButtonDone").pressed.emit()
	if not await _wait_for_playthrough_completion():
		_fail("11_outer_resume", "the City action list did not complete")
		_finish_smoke()
		return

	var state: ClassicRuntimeState = host.runtime.runtime_state
	var action_point_override := state.get_action_point_override(MUTATED_TRIGGER_ID)
	_verify_stage(
		"10_victory",
		not StateMachine.is_combat_state() and GameGlobal.currentmap_name == "map_0",
		"native victory cleanup returns the party to City exploration"
	)
	_verify_stage(
		"11_outer_resume",
		state.get_trigger_percent("land", 0, 17, -1) == 100
			and not action_point_override.is_empty(),
		"victory awards mapped treasure 11, then applies both authored map mutations"
	)
	if acceptance_phase == "save":
		await _save_mid_quest_and_exit()
		return

	var save_result: Dictionary = campaign_session.make_save_result()
	var serialized := JSON.stringify(save_result.get("payload", {}))
	var saved_payload: Variant = JSON.parse_string(serialized)
	_verify_stage(
		"12_mid_quest_save",
		str(save_result.get("status", "")) == "ok"
			and saved_payload is Dictionary
			and saved_payload.get("continuationState", {}).get("state", "") == "idle",
		"the post-battle City state serializes through the normal Classic save envelope"
	)
	if not (saved_payload is Dictionary):
		_finish_smoke()
		return

	GameGlobal.classic_campaign_session = null
	campaign_session.clear()
	campaign_session.queue_free()
	await get_tree().process_frame
	if not _load_session():
		_finish_smoke()
		return
	var restore_result: Dictionary = campaign_session.restore_save_payload(saved_payload)
	var start_result: Dictionary = campaign_session.activate_start_location(true)
	var restored_state: ClassicRuntimeState = host.runtime.runtime_state
	var restored_override := restored_state.get_action_point_override(MUTATED_TRIGGER_ID)
	var acquired_maps := campaign_session.acquired_player_map_entries()
	_verify_stage(
		"13_mid_quest_reload",
		str(restore_result.get("status", "")) == "ok"
			and str(start_result.get("status", "")) != "error"
			and GameGlobal.currentmap_name == "map_0"
			and _native_position() == TRIGGER_POSITION
			and restored_state.is_map_owned(QUEST_MAP_ID)
			and restored_state.is_map_owned(4)
			and restored_state.is_map_owned(0)
			and acquired_maps.size() == 3
			and restored_state.get_trigger_percent("land", 0, 17, -1) == 100
			and not restored_override.is_empty()
			and not campaign_session.has_pending_continuation(),
		"a fresh session restores both quest maps, item 807, and the blacksmith rewrite"
	)
	if not smoke_failures.is_empty():
		_finish_smoke()
		return
	await _complete_blacksmith_quest()


func _save_mid_quest_and_exit() -> void:
	UI.ow_hud._on_save_button_pressed()
	await get_tree().process_frame
	var save_control: SaveLoadCtrl = UI.ow_hud.saveloadCtrl
	if not save_control.visible:
		_fail("12_disk_save", "the normal HUD Save button did not open the save controls")
		_finish_smoke()
		return
	save_control.new_save_lineedit.text = ACCEPTANCE_SAVE
	save_control.new_save_lineedit.text_changed.emit(ACCEPTANCE_SAVE)
	await get_tree().process_frame
	if save_control.create_save_button.disabled:
		_fail("12_disk_save", "the normal save-name field did not enable Create")
		_finish_smoke()
		return
	save_control.create_save_button.pressed.emit()
	await get_tree().process_frame

	var save_path := (
		Paths.profilesfolderpath
		+ GameGlobal.currentprofile
		+ "/Saves/"
		+ GameGlobal.currentcampaign
		+ "/"
		+ ACCEPTANCE_SAVE
	)
	var data_path := save_path + "/data.json"
	var save_data: Dictionary = Utils.FileHandler.read_json_dic_from_file(data_path) \
		if FileAccess.file_exists(data_path) else {}
	var classic_payload: Variant = save_data.get("classic_runtime", {})
	_verify_stage(
		"12_disk_save",
		FileAccess.file_exists(data_path)
			and FileAccess.file_exists(save_path + "/shops.json")
			and FileAccess.file_exists(save_path + "/allies.json")
			and FileAccess.file_exists(save_path + "/map_exploration.json")
			and classic_payload is Dictionary
			and classic_payload.get("continuationState", {}).get("state", "") == "idle",
		"the normal Save controls persist native files and the Classic envelope"
	)
	_finish_smoke()


func _complete_blacksmith_quest() -> void:
	_move_to_position(QUEST_POSITION)
	if not host.start_trigger(QUEST_TRIGGER_ID):
		_fail("14_quest_turn_in", str(host.runtime.last_result))
		_finish_smoke()
		return
	for message_prefix: String in QUEST_COMPLETE_MESSAGES:
		if not await _dismiss_message(message_prefix):
			_fail("14_quest_turn_in", "the authored blacksmith completion did not open")
			_finish_smoke()
			return
	if not await _wait_for_treasure():
		_fail("14_quest_turn_in", "authored treasure 19 did not open")
		_finish_smoke()
		return
	var reward_ids := _treasure_classic_item_ids()
	_verify_stage(
		"14_quest_turn_in",
		not _party_has_classic_item(QUEST_ITEM_ID)
			and reward_ids == QUEST_REWARD_ITEM_IDS
			and UI.ow_hud.treasureControl.exp_gain == 800,
		"turn-in consumes item 807 and presents treasure 19's two items and experience "
			+ "(has807=%s, rewardIds=%s, experience=%d)" % [
				_party_has_classic_item(QUEST_ITEM_ID),
				reward_ids,
				UI.ow_hud.treasureControl.exp_gain,
			]
	)
	if not await _loot_classic_items(QUEST_REWARD_ITEM_IDS):
		_fail("14_quest_turn_in", "the party could not take both blacksmith rewards")
		_finish_smoke()
		return
	UI.ow_hud.treasureControl.find_child("ButtonDone").pressed.emit()
	if not await _wait_for_playthrough_completion():
		_fail("15_quest_complete", "the blacksmith reward action list did not complete")
		_finish_smoke()
		return
	_verify_stage(
		"15_quest_complete",
		not _party_has_classic_item(QUEST_ITEM_ID)
			and _party_has_classic_item(210)
			and _party_has_classic_item(434)
			and not campaign_session.has_pending_continuation(),
		"the installed quest completes in exploration with its rewards in inventory"
	)
	_finish_smoke()


func _request_victory() -> void:
	await GameGlobal.end_battle("won")


func _move_to_trigger() -> void:
	_move_to_position(TRIGGER_POSITION)


func _move_to_position(position: Vector2i) -> void:
	host.runtime.runtime_state.set_location("land", 0, position.x, position.y)
	var map: Node = NodeAccess.__Map()
	for character: Node in [map.focuscharacter, map.owcharacter]:
		if character != null and character.has_method("set_tile_position"):
			character.set_tile_position(Vector2(position))
	map.explore_tiles_from_tilepos(position)


func _create_playtest_party() -> void:
	var character := _new_playtest_character()
	GameGlobal.player_characters.clear()
	GameGlobal.player_allies.clear()
	GameGlobal.player_characters.append(character)
	UI.ow_hud.fillCharactersRect()
	UI.ow_hud.selected_character = character


func _new_playtest_character() -> PlayerCharacter:
	return GameGlobal.playerCharacterGD.new(
		{
			"name": "City Acceptance Rogue",
			"level": 8,
			"exp_tnl": 10000,
		},
		AcceptanceAssets.player_icon(),
		AcceptanceAssets.classic_portrait_257(),
		RogueClass,
		HumanRace
	)


func _classic_enemy_count(monster_id: int) -> int:
	var count := 0
	for button: Variant in StateMachine.combat_state.all_battle_creatures_btns:
		if not (button is Object):
			continue
		var creature: Variant = button.get("creature")
		if creature is Object \
				and int(creature.get_meta("classic_monster_id", -1)) == monster_id:
			count += 1
	return count


func _native_position() -> Vector2i:
	var character: Variant = NodeAccess.__Map().owcharacter
	return Vector2i(character.tile_position_x, character.tile_position_y)


func _verify_winter_timed_encounter() -> void:
	const WINTER_DAY_START := 3 * 86400
	const WINTER_MESSAGE := "You arrived in Bywater just in time"
	GameGlobal.time = WINTER_DAY_START - 1
	GameGlobal.pass_time(1)

	var winter_message_presented := false
	for _frame: int in 600:
		if UI.ow_hud.textRect.visible \
				and UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
					WINTER_MESSAGE
				):
			winter_message_presented = true
			break
		await get_tree().process_frame

	var state: ClassicRuntimeState = host.runtime.runtime_state
	var snow_tiles := 0
	var original_tiles := 0
	for column_value: Variant in NodeAccess.__Map().mapdata:
		if not (column_value is Array):
			continue
		for stack_value: Variant in column_value:
			if not (stack_value is Array):
				continue
			for tile_value: Variant in stack_value:
				if not (tile_value is Dictionary):
					continue
				var tileset_name := str(tile_value.get("tileset_name", ""))
				if tileset_name == "landlook-10":
					snow_tiles += 1
				elif tileset_name in ["ForestDay", "landlook-0"]:
					original_tiles += 1
	_verify_stage(
		"00_winter_timed_encounter",
		winter_message_presented
			and state.get_landlook("land", 0, -1) == 10
			and snow_tiles > 0
			and original_tiles == 0,
		(
			"day-3 XAP 163 applies snow to map_0 "
			+ "(message=%s, state=%d, snow=%d, original=%d)"
		) % [
			str(winter_message_presented),
			state.get_landlook("land", 0, -1),
			snow_tiles,
			original_tiles,
		]
	)
	if winter_message_presented:
		UI.ow_hud.textRect.disablerButton.pressed.emit()


func _verify_dragon_battle() -> void:
	_move_to_position(DRAGON_TRIGGER_POSITION)
	var resources: CampaignResources = NodeAccess.__Resources()
	var character: PlayerCharacter = GameGlobal.player_characters[0]
	GameGlobal.gamespeed = 0.001
	character.base_stats["Dexterity"] = 100
	character.base_stats["AccuracyMelee"] = 100
	character.base_stats["MaxActions"] = 5
	character.base_stats["MaxMovement"] = 20
	character.recalculate_stats()
	var dagger: ItemInstance = GameGlobal.generate_item("Dagger")
	if dagger == null \
			or not character.add_inventory_item(dagger) \
			or not character.equip_item(dagger):
		_fail("00_melee_item", "the acceptance character could not equip a native Dagger")
		return
	if not resources.spells_book.has("Flame Missile"):
		_fail("00_spell_default", "the shared Flame Missile resource is unavailable")
		return
	character.add_spell_from_spells_book("Flame Missile", 1)
	var spell_menu: SpellsMenu = UI.ow_hud.spellcastMenu
	spell_menu.initialize(character)
	await get_tree().process_frame
	var default_spell_visible := false
	for spell_button: Node in spell_menu.spelllistContainer.get_children():
		if spell_button is Button and spell_button.text == "Flame Missile":
			default_spell_visible = true
			break
	_verify_stage(
		"00_spell_default",
		spell_menu.picked_level == 1
			and spell_menu.slevelbutton1.button_pressed
			and default_spell_visible,
		"the spell picker selects and displays level 1 on open"
	)
	spell_menu.hide()
	if not smoke_failures.is_empty():
		return

	resources.battles_book.erase("Battle_%d" % DRAGON_BATTLE_ID)
	if not host.start_trigger(DRAGON_TRIGGER_ID):
		_fail("00_dragon_battle", str(host.runtime.last_result))
		return
	if not await _dismiss_message(DRAGON_INTRO_MESSAGE):
		_fail("00_dragon_battle", "the authored cavern message did not open")
		return
	if not await _dismiss_message(DRAGON_BATTLE_MESSAGE):
		_fail("00_dragon_battle", "the authored blue-dragon message did not open")
		return

	var entered_combat := false
	for _frame: int in 600:
		if StateMachine.is_combat_state() \
				and int(StateMachine.combat_state.cur_battle_data.get(
					"classicBattleId", -1
				)) == DRAGON_BATTLE_ID:
			entered_combat = true
			break
		await get_tree().process_frame
	var battle: Dictionary = resources.battles_book.get(
		"Battle_%d" % DRAGON_BATTLE_ID,
		{}
	)
	_verify_stage(
		"00_dragon_battle",
		entered_combat
			and battle.get("Creatures", []).size() == 1
			and _classic_enemy_count(DRAGON_MONSTER_ID) == 1
			and not UI.ow_hud.treasureControl.visible
			and not UI.ow_hud.alliesWindow.visible,
		"AP 67 enters battle 176 with its single blue dragon before rewards"
	)
	if not entered_combat or not smoke_failures.is_empty():
		return
	await _verify_dragon_auto_melee(character)


func _verify_dragon_auto_melee(character: PlayerCharacter) -> void:
	var dragon: Creature
	for button: CombatCreaButton in StateMachine.combat_state.all_battle_creatures_btns:
		if int(button.creature.get_meta("classic_monster_id", -1)) == DRAGON_MONSTER_ID:
			dragon = button.creature
			break
	if dragon == null:
		_fail("00_combat_auto", "the blue dragon combatant is unavailable")
		return
	var dragon_spell_names: Array[String] = []
	for spell_level: Array in dragon.spells:
		for learned_spell: Dictionary in spell_level:
			dragon_spell_names.append(str(learned_spell.get("name", "")))
	var has_all_breath_spells := true
	for breath_spell: String in [
		"Acid Breath",
		"Flame Breath",
		"Frost Breath",
		"Lightning Breath",
	]:
		if not dragon_spell_names.has(breath_spell):
			has_all_breath_spells = false
			break
	_verify_stage(
		"00_dragon_spells",
		has_all_breath_spells,
		"the shared blue dragon loads all four stock Realmz breath spells"
	)
	if not smoke_failures.is_empty():
		return

	# The authored relative formation can place this one-character smoke farther
	# away than its ordinary round budget. Give the focused Auto check enough
	# movement to prove the reachable-target move-and-attack boundary in one
	# turn; ordinary battles still stop Auto when their real budget is spent.
	var route: Array = GameGlobal.map.find_path(
		character.position,
		dragon.position,
		true,
		false,
		false,
		character,
		true
	)
	var required_movement := route.size() + 2
	character.used_movepoints -= maxi(
		0,
		required_movement - character.get_movement_left()
	)
	var initial_hp := float(dragon.get_stat("curHP"))
	var auto_presses := 0
	for _frame: int in 1200:
		if float(dragon.get_stat("curHP")) < initial_hp:
			break
		if not StateMachine.is_combat_state():
			break
		if StateMachine._state_name != "CbDecideAction":
			await get_tree().process_frame
			continue
		var active_button: CombatCreaButton = (
			StateMachine.cb_decide_state.current_active_creabutton
		)
		if is_instance_valid(active_button) \
				and active_button.creature == character \
				and auto_presses == 0:
			# The focused smoke starts before OWHUDControl's ordinary wiring
			# callback, so reproduce the same panel owner assignment here.
			UI.ow_hud.combatBRPanel.hud = UI.ow_hud
			UI.ow_hud.combatBRPanel.autobutton.pressed.emit()
			auto_presses += 1
		await get_tree().process_frame
	_verify_stage(
		"00_combat_auto",
		auto_presses == 1
			and character.used_apr > 0
			and float(dragon.get_stat("curHP")) < initial_hp,
		"one Auto press advances the player into range and lands an equipped-weapon melee attack"
	)


func _dismiss_message(prefix: String) -> bool:
	for _frame: int in 600:
		if UI.ow_hud.textRect.visible \
				and UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(prefix):
			UI.ow_hud.textRect.disablerButton.pressed.emit()
			return true
		await get_tree().process_frame
	return false


func _wait_for_picture_message(prefix: String) -> bool:
	for _frame: int in 600:
		var texture: Texture2D = UI.ow_hud.pictureRect.pictxtrect.texture
		if UI.ow_hud.pictureRect.visible \
				and texture != null \
				and UI.ow_hud.textRect.visible \
				and UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(prefix):
			return true
		await get_tree().process_frame
	return false


func _wait_for_combat() -> bool:
	for _frame: int in 600:
		if StateMachine.is_combat_state() \
				and int(StateMachine.combat_state.cur_battle_data.get(
					"classicBattleId", -1
				)) == BATTLE_ID \
				and StateMachine.combat_state.all_battle_creatures_btns.size() \
					== EXPECTED_ENEMY_COUNT + 1:
			return true
		await get_tree().process_frame
	return false


func _combat_diagnostic() -> String:
	var resources: CampaignResources = NodeAccess.__Resources()
	var battle: Dictionary = resources.battles_book.get("Battle_%d" % BATTLE_ID, {})
	var roster_size := -1
	var active_battle_id := -1
	if StateMachine.is_combat_state():
		roster_size = StateMachine.combat_state.all_battle_creatures_btns.size()
		active_battle_id = int(StateMachine.combat_state.cur_battle_data.get(
			"classicBattleId", -1
		))
	return (
		"compiled Battle %d did not enter native combat " % BATTLE_ID
		+ "(state=%s, activeBattle=%d, roster=%d, materializedCreatures=%d, runtime=%s)"
	) % [
		StateMachine._state_name,
		active_battle_id,
		roster_size,
		battle.get("Creatures", []).size(),
		host.runtime.last_result,
	]


func _wait_for_treasure() -> bool:
	for _frame: int in 600:
		if UI.ow_hud.treasureControl.visible:
			return true
		await get_tree().process_frame
	return false


func _wait_for_choices() -> bool:
	for _frame: int in 600:
		await get_tree().process_frame
		var choices: Control = UI.ow_hud.textRect.choicesContainer
		if choices.visible and choices.get_child_count() > 0:
			return true
	return false


func _wait_for_inventory() -> bool:
	for _frame: int in 600:
		await get_tree().process_frame
		if UI.ow_hud.inventoryRect.visible and StateMachine._state_name == "ExMenus":
			return true
	return false


func _wait_for_shop() -> bool:
	for _frame: int in 600:
		await get_tree().process_frame
		if UI.ow_hud.inventoryRect.shopRect.visible:
			return true
	return false


func _choice_labels() -> Array[String]:
	var labels: Array[String] = []
	for child: Node in UI.ow_hud.textRect.choicesContainer.get_children():
		if child is Label:
			labels.append(str(child.text))
	return labels


func _has_stop_choice() -> bool:
	for child: Node in UI.ow_hud.textRect.choicesContainer.get_children():
		if child.get_node_or_null("TextureRect/Container/Button") is Button:
			return true
	return false


func _shop_stock_row_count(shop: Dictionary) -> int:
	var count := 0
	for category: String in ["Weapons", "Armor", "Limbs", "Magic", "Supplies"]:
		count += shop.get(category, []).size()
	return count


func _shop_stock_quantity(shop: Dictionary) -> int:
	var count := 0
	for category: String in ["Weapons", "Armor", "Limbs", "Magic", "Supplies"]:
		for stock: Array in shop.get(category, []):
			count += int(stock[1])
	return count


func _shop_stock_index(stock_rows: Array, classic_item_id: int) -> int:
	for stock_index: int in stock_rows.size():
		var stock: Array = stock_rows[stock_index]
		var item_value: Variant = stock[0]
		var item_view: Dictionary = (
			NodeAccess.__Resources().legacy_item_view_for_adapter(item_value)
			if item_value is ItemInstance else item_value
		)
		if int(item_view.get("classicItemId", 0)) == classic_item_id:
			return stock_index
	return -1


func _loot_classic_item(item_id: int) -> bool:
	var container: GridContainer = UI.ow_hud.treasureControl.itemsContainer
	if container.get_child_count() != 1:
		return false
	var character: PlayerCharacter = GameGlobal.player_characters[0]
	UI.ow_hud.selected_character = character
	var item_button: Button = container.get_child(0)
	item_button.pressed.emit()
	await get_tree().process_frame
	for item: ItemInstance in character.inventory_instances():
		if NodeAccess.__Resources().item_classic_ids(item).has(item_id):
			return true
	return false


func _loot_classic_items(item_ids: Array[int]) -> bool:
	var character: PlayerCharacter = GameGlobal.player_characters[0]
	UI.ow_hud.selected_character = character
	for item_id: int in item_ids:
		var found := false
		for item_button: Button in UI.ow_hud.treasureControl.itemsContainer.get_children():
			var item := _treasure_button_item(item_button)
			if int(item.get("classicItemId", 0)) != item_id:
				continue
			item_button.pressed.emit()
			await get_tree().process_frame
			found = _party_has_classic_item(item_id)
			break
		if not found:
			return false
	return true


func _treasure_classic_item_ids() -> Array[int]:
	var item_ids: Array[int] = []
	for item_button: Button in UI.ow_hud.treasureControl.itemsContainer.get_children():
		var item := _treasure_button_item(item_button)
		item_ids.append(int(item.get("classicItemId", 0)))
	return item_ids


func _treasure_button_item(item_button: Button) -> Dictionary:
	var instance_value: Variant = item_button.get_meta("item_instance", null)
	if instance_value is ItemInstance:
		return NodeAccess.__Resources().legacy_item_view_for_adapter(instance_value)
	var connections := item_button.pressed.get_connections()
	if connections.is_empty():
		return {}
	var arguments: Array = connections[0]["callable"].get_bound_arguments()
	if arguments.is_empty():
		return {}
	if arguments[0] is ItemInstance:
		return NodeAccess.__Resources().legacy_item_view_for_adapter(arguments[0])
	return arguments[0] if arguments[0] is Dictionary else {}


func _party_has_classic_item(item_id: int) -> bool:
	for character: PlayerCharacter in GameGlobal.player_characters:
		if _character_has_classic_item(character, item_id):
			return true
	return false


func _character_has_classic_item(
	character: PlayerCharacter,
	item_id: int,
) -> bool:
	for item: ItemInstance in character.inventory_instances():
		if NodeAccess.__Resources().item_classic_ids(item).has(item_id):
			return true
	return false


func _profile_acceptance_character() -> PlayerCharacter:
	for character: PlayerCharacter in GameGlobal.profile_characters_list:
		if character.name == "City Acceptance Rogue":
			return character
	return null


func _classic_definition_id(item_id: int) -> String:
	return "classic:scenario-city-of-bywater-classic:%d" % item_id


func _wait_for_allies() -> bool:
	for _frame: int in 600:
		if UI.ow_hud.alliesWindow.visible:
			return true
		await get_tree().process_frame
	return false


func _wait_for_playthrough_completion() -> bool:
	for _frame: int in 600:
		if not host.active:
			return true
		await get_tree().process_frame
	return false


func _wait_frames(frame_count: int) -> void:
	for _frame: int in frame_count:
		await get_tree().process_frame


func _on_playthrough_stopped(result: Dictionary) -> void:
	_fail("runtime", str(result.get("message", result)))
	if automated_smoke:
		call_deferred("_finish_smoke")


func _verify_stage(stage_name: String, passed: bool, detail: String) -> void:
	if passed:
		print("CLASSIC_CITY_BATTLE PASS: %s - %s" % [stage_name, detail])
		return
	_fail(stage_name, detail)


func _fail(stage_name: String, detail: String) -> void:
	if not smoke_failures.has(stage_name):
		smoke_failures.append(stage_name)
	push_error("CLASSIC_CITY_BATTLE FAIL: %s - %s" % [stage_name, detail])


func _finish_smoke() -> void:
	if automated_smoke:
		get_tree().quit(0 if smoke_failures.is_empty() else 1)
		return
	UI.ow_hud.textRect.show()
	UI.ow_hud.textRect.set_text(
		"City installed-route acceptance complete.\n"
		+ "The route covered an encounter, shop, quest, Battle 45, reload, and reward."
	)
