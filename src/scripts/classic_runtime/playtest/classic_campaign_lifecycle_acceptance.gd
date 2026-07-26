extends Node

const ACCEPTANCE_PROFILE := "Classic Lifecycle Acceptance"
const ACCEPTANCE_SAVE := "Launch Checkpoint"

var campaign_directory := ""
var acceptance_phase := ""
var profile_root := ""
var evidence_path := ""
var campaign_manifest: Dictionary = {}
var selection_state := ""
var selected_character := ""
var failures: Array[String] = []
var evidence: Dictionary = {}
var finishing := false


func _ready() -> void:
	call_deferred("_start_acceptance")


func _start_acceptance() -> void:
	_parse_arguments()
	if campaign_directory.is_empty():
		_fail("arguments", "Pass an installed Classic campaign directory")
	if acceptance_phase not in ["save", "continue"]:
		_fail("arguments", "Pass --save-phase or --continue-phase")
	if profile_root.is_empty():
		_fail("arguments", "Pass --profile-root=<temporary directory>")
	if failures.is_empty() and not _load_manifest():
		pass
	if not failures.is_empty():
		_finish()
		return

	if not _prepare_acceptance_profile():
		_finish()
		return
	if acceptance_phase == "save":
		await _run_save_phase()
	else:
		await _run_continue_phase()


func _parse_arguments() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--save-phase":
			acceptance_phase = "save"
		elif argument == "--continue-phase":
			acceptance_phase = "continue"
		elif argument.begins_with("--profile-root="):
			profile_root = argument.trim_prefix("--profile-root=")
		elif argument.begins_with("--evidence-path="):
			evidence_path = argument.trim_prefix("--evidence-path=")
		elif not argument.begins_with("--"):
			campaign_directory = argument
	campaign_directory = campaign_directory.replace("\\", "/").trim_suffix("/")
	profile_root = profile_root.replace("\\", "/").trim_suffix("/")
	evidence_path = evidence_path.replace("\\", "/")


func _load_manifest() -> bool:
	var manifest_path := campaign_directory.path_join("campaign.json")
	if not FileAccess.file_exists(manifest_path):
		_fail("manifest", "The installed campaign has no campaign.json")
		return false
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string(manifest_path)
	)
	if not (parsed is Dictionary):
		_fail("manifest", "campaign.json is not a JSON object")
		return false
	campaign_manifest = parsed
	if str(campaign_manifest.get("campaignKind", "")) != "classic-compiled":
		_fail("manifest", "The installed campaign is not a Classic package")
		return false
	var start: Variant = campaign_manifest.get("start")
	if not (start is Dictionary):
		_fail("manifest", "The Classic package has no start record")
		return false
	evidence = {
		"campaignId": str(campaign_manifest.get("id", "")),
		"directory": campaign_directory.get_file(),
		"name": str(campaign_manifest.get("name", "")),
		"phase": acceptance_phase,
		"manifestStart": _plain_position(start),
	}
	return true


func _prepare_acceptance_profile() -> bool:
	Paths.profilesfolderpath = profile_root.path_join("Profiles") + "/"
	Paths.settingspath = profile_root.path_join("override.cfg")
	var profile_path := Paths.profilesfolderpath.path_join(ACCEPTANCE_PROFILE)
	if acceptance_phase == "save" and DirAccess.dir_exists_absolute(profile_path):
		_fail("profile", "The save phase requires a new temporary profile root")
		return false
	if not DirAccess.dir_exists_absolute(profile_path):
		if not GameGlobal.create_new_profile(ACCEPTANCE_PROFILE, false):
			_fail("profile", "The disposable acceptance profile could not be created")
			return false
	GameGlobal.set_current_profile(ACCEPTANCE_PROFILE)
	return true


func _run_save_phase() -> void:
	if not await _launch_through_campaign_menu():
		_finish()
		return
	if not _verify_authored_start():
		_finish()
		return
	await _save_through_hud()


func _launch_through_campaign_menu() -> bool:
	var campaign_name := campaign_directory.get_file()
	Paths.campaignsfolderpath = campaign_directory.get_base_dir() + "/"
	var panel: Node = UI.main_menu.newCampaignPanel
	UI.main_menu._on_new_campaign_button_pressed()
	await get_tree().process_frame
	var campaign_index := _find_campaign_index(
		panel.campaignsItemList,
		campaign_name,
	)
	if campaign_index < 0:
		_fail("ui_discovery", "The package was not listed by the campaign menu")
		return false
	panel.campaignsItemList.select(campaign_index)
	panel._on_campaign_selected(campaign_index)
	await get_tree().process_frame

	var metadata: Variant = panel.campaignsItemList.get_item_metadata(
		campaign_index
	)
	var selection_rules: Dictionary = (
		metadata.get("selectionRules", {})
		if metadata is Dictionary
		else {}
	)
	selection_state = str(selection_rules.get("readinessState", ""))
	_verify(
		"ui_discovery",
		str(selection_rules.get("title", ""))
				== str(campaign_manifest.get("name", ""))
			and selection_state.begins_with("Ready")
			and bool(selection_rules.get("valid", false)),
		"The normal campaign menu discovers the package as ready",
	)
	if not failures.is_empty():
		return false

	var character_button := _first_eligible_character_button(
		panel.charPickRect.eligibleContainer.get_children()
	)
	if character_button == null:
		_fail(
			"ui_launch",
			"The campaign party rules did not admit any profile character",
		)
		return false
	var character: Variant = character_button.get("character")
	selected_character = str(character.get("name")) if character != null else ""
	panel.charPickRect._on_char_button_pressed(character_button)
	panel.charPickRect._on_AddButton_pressed()
	if panel.startButton.disabled:
		_fail("ui_launch", "The normal party picker did not enable Start")
		return false
	panel._on_StartButton_pressed()
	for _frame: int in 600:
		if is_instance_valid(GameGlobal.classic_campaign_session) \
				and StateMachine._state_name == "Exploration":
			break
		await get_tree().process_frame
	if not is_instance_valid(GameGlobal.classic_campaign_session):
		_fail("ui_launch", "The normal Start path did not create a Classic session")
		return false

	_verify(
		"ui_launch",
		GameGlobal.currentcampaign == campaign_name
			and StateMachine._state_name == "Exploration"
			and UI.ow_hud.visible,
		"The normal party and Start controls enter native exploration",
	)
	return failures.is_empty()


func _verify_authored_start() -> bool:
	var expected: Dictionary = campaign_manifest.get("start", {})
	var observed := _runtime_position()
	var native_position := _native_position()
	var expected_map := _native_map_name(expected)
	var map: Variant = NodeAccess.__Map()
	var map_drawable: bool = (
		map != null
			and map.map_size.x > 0
			and map.map_size.y > 0
			and not map.mapdata.is_empty()
	)
	_verify(
		"authored_start",
		_positions_match(expected, observed)
			and GameGlobal.currentmap_name == expected_map
			and native_position.x == int(expected.get("x", -1))
			and native_position.y == int(expected.get("y", -1))
			and map_drawable,
		"The compiled authored start is loaded as a drawable native map",
	)
	evidence["selectionState"] = selection_state
	evidence["selectedCharacter"] = selected_character
	evidence["nativeMapName"] = GameGlobal.currentmap_name
	evidence["nativePosition"] = {
		"x": native_position.x,
		"y": native_position.y,
	}
	evidence["runtimePosition"] = observed
	evidence["mapDrawable"] = map_drawable
	return failures.is_empty()


func _save_through_hud() -> void:
	UI.ow_hud._on_save_button_pressed()
	await get_tree().process_frame
	var save_control: SaveLoadCtrl = UI.ow_hud.saveloadCtrl
	if not save_control.visible:
		_fail("disk_save", "The normal HUD Save button did not open the controls")
		_finish()
		return
	save_control.new_save_lineedit.text = ACCEPTANCE_SAVE
	save_control.new_save_lineedit.text_changed.emit(ACCEPTANCE_SAVE)
	await get_tree().process_frame
	if save_control.create_save_button.disabled:
		_fail("disk_save", "The save-name field did not enable Create")
		_finish()
		return
	save_control.create_save_button.pressed.emit()
	await get_tree().process_frame

	var save_path := _save_path()
	var files := {
		"data": FileAccess.file_exists(save_path.path_join("data.json")),
		"shops": FileAccess.file_exists(save_path.path_join("shops.json")),
		"allies": FileAccess.file_exists(save_path.path_join("allies.json")),
		"mapExploration": FileAccess.file_exists(
			save_path.path_join("map_exploration.json")
		),
	}
	var save_data: Dictionary = (
		Utils.FileHandler.read_json_dic_from_file(
			save_path.path_join("data.json")
		)
		if bool(files["data"])
		else {}
	)
	var classic_payload: Variant = save_data.get("classic_runtime", {})
	var continuation_state := ""
	if classic_payload is Dictionary:
		continuation_state = str(
			classic_payload.get("continuationState", {}).get("state", "")
		)
	var saved_position: Dictionary = (
		classic_payload.get("runtimeState", {}).get("position", {})
		if classic_payload is Dictionary
		else {}
	)
	_verify(
		"disk_save",
		not files.values().has(false)
			and classic_payload is Dictionary
			and not classic_payload.is_empty()
			and continuation_state == "idle"
			and _positions_match(_runtime_position(), saved_position),
		"The normal Save controls persist native files and an idle Classic envelope",
	)
	evidence["saveFiles"] = files
	evidence["continuationState"] = continuation_state
	evidence["savedPosition"] = _plain_position(saved_position)
	_finish()


func _run_continue_phase() -> void:
	var campaign_name := campaign_directory.get_file()
	Paths.campaignsfolderpath = campaign_directory.get_base_dir() + "/"
	var save_data_path := _save_path().path_join("data.json")
	var save_data: Dictionary = (
		Utils.FileHandler.read_json_dic_from_file(save_data_path)
		if FileAccess.file_exists(save_data_path)
		else {}
	)
	var saved_classic: Variant = save_data.get("classic_runtime", {})
	var saved_position: Dictionary = (
		saved_classic.get("runtimeState", {}).get("position", {})
		if saved_classic is Dictionary
		else {}
	)
	var load_control: SaveLoadCtrl = UI.main_menu.loadgameCtrl
	UI.main_menu._on_load_button_pressed()
	await get_tree().process_frame

	var campaign_index := load_control.scenarios_panel.scenarios_list.find(
		campaign_name
	)
	if campaign_index < 0:
		_fail("disk_continue", "The saved campaign was not listed by Load")
		_finish()
		return
	load_control.scenarios_panel.scenarios_itemlist.select(campaign_index)
	load_control.scenarios_panel._on_scenarios_item_list_item_selected(
		campaign_index
	)
	await get_tree().process_frame

	var save_index := load_control.saves_panel.saves_list.find(ACCEPTANCE_SAVE)
	if save_index < 0:
		_fail("disk_continue", "The launch checkpoint was not listed by Load")
		_finish()
		return
	load_control.saves_panel.saves_itemlist.select(save_index)
	load_control.saves_panel._on_saves_item_list_item_selected(save_index)
	await get_tree().process_frame
	if load_control.preview_panel.load_button.disabled:
		_fail("disk_continue", "The selected checkpoint did not enable Load")
		_finish()
		return
	load_control.preview_panel.load_button.pressed.emit()
	for _frame: int in 600:
		if is_instance_valid(GameGlobal.classic_campaign_session) \
				and StateMachine._state_name == "Exploration":
			break
		await get_tree().process_frame
	if not is_instance_valid(GameGlobal.classic_campaign_session):
		_fail("disk_continue", "Load did not restore a Classic session")
		_finish()
		return

	var observed := _runtime_position()
	var native_position := _native_position()
	var session: ClassicCampaignSession = GameGlobal.classic_campaign_session
	var expected_map := str(save_data.get("currentmap_name", ""))
	var expected_native_position: Array = save_data.get("position", [])
	var native_matches := (
		expected_native_position.size() == 2
			and native_position.x == int(expected_native_position[0])
			and native_position.y == int(expected_native_position[1])
	)
	var map: Variant = NodeAccess.__Map()
	var map_drawable: bool = (
		map != null
			and map.map_size.x > 0
			and map.map_size.y > 0
			and not map.mapdata.is_empty()
	)
	_verify(
		"disk_continue",
		GameGlobal.currentcampaign == campaign_name
			and GameGlobal.cur_save_name == ACCEPTANCE_SAVE
			and StateMachine._state_name == "Exploration"
			and GameGlobal.currentmap_name == expected_map
			and native_matches
			and _positions_match(saved_position, observed)
			and not session.has_pending_continuation()
			and map_drawable,
		"A fresh process restores the saved native and Classic start state",
	)
	evidence["nativeMapName"] = GameGlobal.currentmap_name
	evidence["nativePosition"] = {
		"x": native_position.x,
		"y": native_position.y,
	}
	evidence["runtimePosition"] = observed
	evidence["mapDrawable"] = map_drawable
	evidence["pendingContinuation"] = session.has_pending_continuation()
	_finish()


func _find_campaign_index(item_list: ItemList, campaign_name: String) -> int:
	for item_index: int in item_list.item_count:
		var metadata: Variant = item_list.get_item_metadata(item_index)
		if metadata is Dictionary \
				and str(metadata.get("campaignName", "")) == campaign_name:
			return item_index
	return -1


func _first_eligible_character_button(buttons: Array[Node]) -> Button:
	for button: Node in buttons:
		if button is Button \
				and not button.disabled \
				and button.get("character") != null:
			return button
	return null


func _runtime_position() -> Dictionary:
	if not is_instance_valid(GameGlobal.classic_campaign_session):
		return {}
	var state: ClassicRuntimeState = (
		GameGlobal.classic_campaign_session.host.runtime.runtime_state
	)
	return {
		"levelType": state.level_type,
		"levelIndex": state.level_index,
		"x": state.x,
		"y": state.y,
	}


func _native_position() -> Vector2i:
	var character: Variant = NodeAccess.__Map().owcharacter
	if character == null:
		return Vector2i(-1, -1)
	return Vector2i(character.tile_position_x, character.tile_position_y)


func _native_map_name(position: Dictionary) -> String:
	var prefix := (
		"mapd_"
		if str(position.get("levelType", "land")) == "dungeon"
		else "map_"
	)
	return "%s%d" % [prefix, int(position.get("levelIndex", -1))]


func _positions_match(expected: Dictionary, observed: Dictionary) -> bool:
	return (
		str(expected.get("levelType", "")) == str(
			observed.get("levelType", "")
		)
			and int(expected.get("levelIndex", -1)) == int(
				observed.get("levelIndex", -2)
			)
			and int(expected.get("x", -1)) == int(observed.get("x", -2))
			and int(expected.get("y", -1)) == int(observed.get("y", -2))
	)


func _plain_position(position: Dictionary) -> Dictionary:
	return {
		"levelType": str(position.get("levelType", "")),
		"levelIndex": int(position.get("levelIndex", -1)),
		"x": int(position.get("x", -1)),
		"y": int(position.get("y", -1)),
	}


func _save_path() -> String:
	return (
		Paths.profilesfolderpath
		+ ACCEPTANCE_PROFILE
		+ "/Saves/"
		+ campaign_directory.get_file()
		+ "/"
		+ ACCEPTANCE_SAVE
	)


func _verify(stage: String, passed: bool, detail: String) -> void:
	if passed:
		print(
			"CLASSIC_CAMPAIGN_LIFECYCLE PASS: %s %s - %s"
			% [campaign_directory.get_file(), stage, detail]
		)
		return
	_fail(stage, detail)


func _fail(stage: String, detail: String) -> void:
	var message := "%s: %s" % [stage, detail]
	if not failures.has(message):
		failures.append(message)
	push_error(
		"CLASSIC_CAMPAIGN_LIFECYCLE FAIL: %s %s"
		% [campaign_directory.get_file(), message]
	)


func _finish() -> void:
	if finishing:
		return
	finishing = true
	evidence["status"] = "passed" if failures.is_empty() else "failed"
	evidence["errors"] = failures.duplicate()
	if not evidence_path.is_empty():
		DirAccess.make_dir_recursive_absolute(evidence_path.get_base_dir())
		var evidence_file := FileAccess.open(
			evidence_path,
			FileAccess.ModeFlags.WRITE,
		)
		if evidence_file == null:
			push_error(
				"Could not write lifecycle evidence: %s"
				% FileAccess.get_open_error()
			)
			failures.append("evidence: output file could not be written")
			evidence["status"] = "failed"
			evidence["errors"] = failures.duplicate()
		else:
			evidence_file.store_string(JSON.stringify(evidence, "\t", false))
			evidence_file.close()
	call_deferred("_quit_after_settle")


func _quit_after_settle() -> void:
	for _frame: int in 30:
		await get_tree().process_frame
	get_tree().quit(0 if failures.is_empty() else 1)
