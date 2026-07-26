extends Node

const SoundResolutionScript = preload(
	"res://scripts/classic_runtime/classic_sound_resolution.gd"
)

const ACCEPTANCE_PROFILE := "Classic Scenario Route Acceptance"
const STEP_TIMEOUT_MSEC := 30000

var campaign_directory := ""
var route_path := ""
var profile_root := ""
var evidence_path := ""
var campaign_manifest: Dictionary = {}
var route: Dictionary = {}
var campaign_session: ClassicCampaignSession
var host: ClassicRuntimeHost
var failures: Array[String] = []
var evidence: Dictionary = {
	"schemaVersion": 1,
	"stages": [],
}
var finishing := false


func _ready() -> void:
	call_deferred("_start_acceptance")


func _start_acceptance() -> void:
	_parse_arguments()
	if not _load_inputs() or not _prepare_profile():
		_finish()
		return
	if not await _launch_through_campaign_menu():
		_finish()
		return
	if not _verify_authored_start():
		_finish()
		return
	if not _verify_source_contract():
		_finish()
		return

	for step_value: Variant in route.get("steps", []):
		if not (step_value is Dictionary):
			_fail("route", "A route step is not an object")
			break
		var step: Dictionary = step_value
		match str(step.get("kind", "")):
			"presentation":
				if not await _run_presentation_step(step):
					break
			"battle":
				if not await _run_battle_step(step):
					break
			_:
				_fail(
					str(step.get("id", "route")),
					"Unsupported route step kind '%s'" % str(step.get("kind", "")),
				)
				break
	_finish()


func _parse_arguments() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--route="):
			route_path = argument.trim_prefix("--route=")
		elif argument.begins_with("--profile-root="):
			profile_root = argument.trim_prefix("--profile-root=")
		elif argument.begins_with("--evidence-path="):
			evidence_path = argument.trim_prefix("--evidence-path=")
		elif not argument.begins_with("--"):
			campaign_directory = argument
	campaign_directory = campaign_directory.replace("\\", "/").trim_suffix("/")
	route_path = route_path.replace("\\", "/")
	profile_root = profile_root.replace("\\", "/").trim_suffix("/")
	evidence_path = evidence_path.replace("\\", "/")


func _load_inputs() -> bool:
	if campaign_directory.is_empty():
		_fail("arguments", "Pass an installed Classic campaign directory")
	if route_path.is_empty():
		_fail("arguments", "Pass --route=<route JSON>")
	if profile_root.is_empty():
		_fail("arguments", "Pass --profile-root=<temporary directory>")
	if evidence_path.is_empty():
		_fail("arguments", "Pass --evidence-path=<result JSON>")
	if not failures.is_empty():
		return false

	var manifest_value: Variant = _read_json(
		campaign_directory.path_join("campaign.json")
	)
	if not (manifest_value is Dictionary):
		_fail("manifest", "campaign.json is not a JSON object")
		return false
	campaign_manifest = manifest_value
	var route_value: Variant = _read_json(route_path)
	if not (route_value is Dictionary):
		_fail("route", "The route definition is not a JSON object")
		return false
	route = route_value

	var campaign_id := str(campaign_manifest.get("id", ""))
	evidence.merge({
		"routeId": str(route.get("routeId", "")),
		"campaignId": campaign_id,
		"campaignName": str(campaign_manifest.get("name", "")),
		"campaignDirectory": campaign_directory.get_file(),
	})
	if str(campaign_manifest.get("campaignKind", "")) != "classic-compiled":
		_fail("manifest", "The installed campaign is not a Classic package")
	if int(route.get("schemaVersion", 0)) != 1:
		_fail("route", "The route definition does not use schema version 1")
	if str(route.get("campaignId", "")) != campaign_id:
		_fail("route", "The route definition targets a different campaign")
	if str(route.get("campaignDirectory", "")) != campaign_directory.get_file():
		_fail("route", "The route definition targets a different directory")
	return failures.is_empty()


func _prepare_profile() -> bool:
	Paths.profilesfolderpath = profile_root.path_join("Profiles") + "/"
	Paths.settingspath = profile_root.path_join("override.cfg")
	var profile_path := Paths.profilesfolderpath.path_join(ACCEPTANCE_PROFILE)
	if DirAccess.dir_exists_absolute(profile_path):
		_fail("profile", "The acceptance route requires a new temporary profile root")
		return false
	if not GameGlobal.create_new_profile(ACCEPTANCE_PROFILE, false):
		_fail("profile", "The disposable acceptance profile could not be created")
		return false
	GameGlobal.set_current_profile(ACCEPTANCE_PROFILE)
	return true


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
		_fail("ui-discovery", "The package was not listed by the campaign menu")
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
	var selection_state := str(selection_rules.get("readinessState", ""))
	evidence["selectionState"] = selection_state
	_verify(
		"ui-discovery",
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
		_fail("ui-launch", "The campaign rules did not admit a profile character")
		return false
	var character: Variant = character_button.get("character")
	evidence["selectedCharacter"] = (
		str(character.get("name")) if character != null else ""
	)
	panel.charPickRect._on_char_button_pressed(character_button)
	panel.charPickRect._on_AddButton_pressed()
	if panel.startButton.disabled:
		_fail("ui-launch", "The normal party picker did not enable Start")
		return false
	panel._on_StartButton_pressed()
	for _frame: int in 600:
		if is_instance_valid(GameGlobal.classic_campaign_session) \
				and StateMachine._state_name == "Exploration":
			break
		await get_tree().process_frame
	if not is_instance_valid(GameGlobal.classic_campaign_session):
		_fail("ui-launch", "The normal Start path did not create a Classic session")
		return false

	campaign_session = GameGlobal.classic_campaign_session
	host = campaign_session.host
	host.playthrough_stopped.connect(_on_playthrough_stopped)
	_verify(
		"ui-launch",
		GameGlobal.currentcampaign == campaign_name
			and StateMachine._state_name == "Exploration"
			and UI.ow_hud.visible,
		"The normal party and Start controls enter native exploration",
	)
	return failures.is_empty()


func _verify_authored_start() -> bool:
	var expected: Dictionary = route.get("start", {})
	var manifest_start: Dictionary = campaign_manifest.get("start", {})
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
	evidence["authoredStart"] = {
		"map": GameGlobal.currentmap_name,
		"nativePosition": {"x": native_position.x, "y": native_position.y},
		"runtimePosition": observed,
		"mapDrawable": map_drawable,
	}
	_verify(
		"authored-start",
		_positions_match(expected, manifest_start)
			and _positions_match(expected, observed)
			and GameGlobal.currentmap_name == expected_map
			and native_position == Vector2i(
				int(expected.get("x", -1)),
				int(expected.get("y", -1)),
			)
			and map_drawable,
		"The source and manifest start agree on a drawable native map",
	)
	return failures.is_empty()


func _verify_source_contract() -> bool:
	for step_value: Variant in route.get("steps", []):
		if not (step_value is Dictionary):
			return false
		var step: Dictionary = step_value
		var stage := "%s-source" % str(step.get("id", "step"))
		var trigger: Dictionary = campaign_session.install.bundle.get_trigger(
			str(step.get("triggerId", ""))
		)
		if trigger.is_empty() or not _actions_match(
			trigger.get("actions", []),
			step.get("actions", []),
		):
			_fail(stage, "The compiled trigger no longer matches the route contract")
			return false
		if not _dispatcher_noops_match(
			trigger,
			step.get("dispatcherNoops", []),
		):
			_fail(stage, "The compiled dispatcher fall-through evidence changed")
			return false
		if not _messages_match(step.get("messages", [])):
			_fail(stage, "The compiled route messages no longer match their source IDs")
			return false
		if str(step.get("kind", "")) == "battle" \
				and not _battle_source_matches(step):
			_fail(stage, "The compiled battle formation no longer matches the route")
			return false
		_verify(
			stage,
			true,
			"The route step matches its compiled source records",
		)

	return _verify_completion_source_contract()


func _verify_completion_source_contract() -> bool:
	var completion: Dictionary = route.get("completionAnchor", {})
	var trigger_specs: Array = completion.get("triggers", [])
	var extra_code_specs: Array = completion.get("extraCodes", [])
	var battle_ids: Array = completion.get("battleIds", [])
	var trigger_ids: Array[String] = []
	var extra_code_ids: Array[int] = []
	var verified_battle_ids: Array[int] = []
	var completion_valid := (
		not trigger_specs.is_empty()
			and not battle_ids.is_empty()
			and str(completion.get("classification", ""))
				== "source-anchor-only"
	)
	for trigger_value: Variant in trigger_specs:
		if not (trigger_value is Dictionary):
			completion_valid = false
			continue
		var trigger_spec: Dictionary = trigger_value
		var trigger_id := str(trigger_spec.get("triggerId", ""))
		var trigger: Dictionary = campaign_session.install.bundle.get_trigger(
			trigger_id
		)
		trigger_ids.append(trigger_id)
		completion_valid = (
			completion_valid
				and not trigger.is_empty()
				and _actions_match(
					trigger.get("actions", []),
					trigger_spec.get("actions", []),
				)
		)
	for extra_code_value: Variant in extra_code_specs:
		if not (extra_code_value is Dictionary):
			completion_valid = false
			continue
		var extra_code_spec: Dictionary = extra_code_value
		var extra_code_id := int(extra_code_spec.get("id", -1))
		var extra_code: Dictionary = (
			campaign_session.install.bundle.get_extra_code(extra_code_id)
		)
		extra_code_ids.append(extra_code_id)
		completion_valid = (
			completion_valid
				and not extra_code.is_empty()
				and _integer_arrays_match(
					extra_code.get("values", []),
					extra_code_spec.get("values", []),
				)
		)
	for battle_id_value: Variant in battle_ids:
		var battle_id := absi(int(battle_id_value))
		verified_battle_ids.append(battle_id)
		completion_valid = (
			completion_valid
				and not campaign_session.install.bundle.get_battle(
					battle_id
				).is_empty()
		)
	completion_valid = (
		completion_valid
			and _messages_match(completion.get("messages", []))
	)
	evidence["completionAnchor"] = {
		"triggerIds": trigger_ids,
		"extraCodeIds": extra_code_ids,
		"battleIds": verified_battle_ids,
		"classification": str(completion.get("classification", "")),
		"sourceVerified": completion_valid,
		"runtimeExercised": false,
	}
	_verify(
		"completion-source-anchor",
		completion_valid,
		"The compiled completion chain and final battle remain source-identifiable",
	)
	return failures.is_empty()


func _run_presentation_step(step: Dictionary) -> bool:
	var stage := str(step.get("id", "presentation"))
	_move_to_position(step.get("position", {}))
	if not host.start_trigger(str(step.get("triggerId", ""))):
		_fail(stage, str(host.runtime.last_result))
		return false

	var messages: Array = step.get("messages", [])
	for message_index: int in messages.size():
		var message: Dictionary = messages[message_index]
		if not await _wait_for_message(str(message.get("prefix", ""))):
			_fail(stage, "The authored message did not open in source order")
			return false
		if message_index == 0 and not _verify_picture(step.get("picture", {})):
			_fail(stage, "The authored picture did not render in the native HUD")
			return false
		UI.ow_hud.textRect.disablerButton.pressed.emit()
	if not await _wait_for_playthrough_completion():
		_fail(stage, "The presentation action list did not return to exploration")
		return false

	var sounds_valid := _verify_sound_contract(step)
	_verify(
		stage,
		sounds_valid
			and not campaign_session.has_pending_continuation()
			and StateMachine._state_name == "Exploration",
		str(step.get(
			"detail",
			"The installed presentation completes through the native UI",
		)),
	)
	return failures.is_empty()


func _run_battle_step(step: Dictionary) -> bool:
	var stage := str(step.get("id", "battle"))
	var battle_id := int(step.get("battleId", -1))
	_move_to_position(step.get("position", {}))
	NodeAccess.__Resources().battles_book.erase("Battle_%d" % battle_id)
	if not host.start_trigger(str(step.get("triggerId", ""))):
		_fail(stage, str(host.runtime.last_result))
		return false
	for message_value: Variant in step.get("messages", []):
		var message: Dictionary = message_value
		if not await _dismiss_message(str(message.get("prefix", ""))):
			_fail(stage, "The authored battle introduction did not open")
			return false
	if not await _wait_for_combat(battle_id):
		_fail(stage, "The source battle did not enter native combat")
		return false

	var sounds_valid := _verify_sound_contract(step)
	var native_battle: Dictionary = NodeAccess.__Resources().battles_book.get(
		"Battle_%d" % battle_id,
		{},
	)
	var roster_valid := int(native_battle.get("classicBattleId", -1)) == battle_id
	var expected_enemy_count := 0
	var observed_creatures: Array = []
	for creature_value: Variant in step.get("creatures", []):
		var creature: Dictionary = creature_value
		var monster_id := int(creature.get("monsterId", -1))
		var expected_count := int(creature.get("count", 0))
		var observed_count := _classic_enemy_count(monster_id)
		expected_enemy_count += expected_count
		roster_valid = roster_valid and observed_count == expected_count
		observed_creatures.append({
			"monsterId": monster_id,
			"displayName": str(creature.get("displayName", "")),
			"count": observed_count,
		})
	roster_valid = roster_valid \
		and native_battle.get("Creatures", []).size() == expected_enemy_count
	evidence["battle"] = {
		"id": battle_id,
		"creatures": observed_creatures,
		"battlefieldDrawable": _temporary_battlefield_is_drawable(),
	}
	_verify(
		stage,
		sounds_valid
			and roster_valid
			and bool(evidence["battle"]["battlefieldDrawable"]),
		"The compiled formation materializes on a drawable native battlefield",
	)
	if not failures.is_empty():
		return false

	call_deferred("_request_victory")
	var reward_seen := await _close_victory_rewards()
	if not await _wait_for_playthrough_completion():
		_fail(stage, "The battle victory did not resume the source action list")
		return false
	var expected_position: Dictionary = step.get("position", {})
	var native_position := _native_position()
	evidence["battle"]["rewardScreenPresented"] = reward_seen
	evidence["battle"]["returnMap"] = GameGlobal.currentmap_name
	evidence["battle"]["returnPosition"] = {
		"x": native_position.x,
		"y": native_position.y,
	}
	_verify(
		"%s-victory" % stage,
		not StateMachine.is_combat_state()
			and StateMachine._state_name == "Exploration"
			and GameGlobal.currentmap_name == _native_map_name(expected_position)
			and native_position == Vector2i(
				int(expected_position.get("x", -1)),
				int(expected_position.get("y", -1)),
			)
			and not campaign_session.has_pending_continuation(),
		"Native victory returns to the authored route with no pending continuation",
	)
	return failures.is_empty()


func _verify_sound_contract(step: Dictionary) -> bool:
	var sound_rows: Array = evidence.get("soundResolutions", [])
	var sounds_valid := true
	for sound_value: Variant in step.get("sounds", []):
		if not (sound_value is Dictionary):
			sounds_valid = false
			continue
		var expected: Dictionary = sound_value
		var sound_id := int(expected.get("id", 0))
		var sound: Dictionary = campaign_session.install.bundle.get_sound(sound_id)
		var resolution: Dictionary = SoundResolutionScript.resolve(
			sound_id,
			sound,
			SfxIdDivinity.mapping,
		)
		var valid := str(resolution.get("status", "")) \
			== str(expected.get("status", ""))
		for field: String in [
			"nativeName",
			"runtimeMediaPath",
			"classicBehaviorIfAbsent",
		]:
			if expected.has(field) \
					and str(resolution.get(field, "")) != str(expected.get(field, "")):
				valid = false
		sounds_valid = sounds_valid and valid
		var sound_row := {
			"stepId": str(step.get("id", "")),
			"id": sound_id,
			"status": str(resolution.get("status", "")),
			"playable": bool(resolution.get("playable", false)),
			"waitForCompletion": bool(
				resolution.get("waitForCompletion", false)
			),
			"classicBehaviorIfAbsent": str(
				resolution.get("classicBehaviorIfAbsent", "")
			),
		}
		for field: String in [
			"nativeName",
			"runtimeMediaPath",
			"runtimeMediaType",
		]:
			if resolution.has(field):
				sound_row[field] = str(resolution.get(field, ""))
		sound_rows.append(sound_row)
	evidence["soundResolutions"] = sound_rows
	return sounds_valid


func _dispatcher_noops_match(
	trigger: Dictionary,
	specifications_value: Variant
) -> bool:
	if not (specifications_value is Array):
		return false
	var specifications: Array = specifications_value
	if specifications.is_empty():
		return true
	var evidence_rows: Array = evidence.get("dispatcherNoops", [])
	for specification_value: Variant in specifications:
		if not (specification_value is Dictionary):
			return false
		var specification: Dictionary = specification_value
		var expected_slot := int(specification.get("slot", -1))
		var expected_raw_code := int(specification.get("rawCode", 0))
		var matched_action: Dictionary = {}
		for action_value: Variant in trigger.get("actions", []):
			if action_value is Dictionary \
					and int(action_value.get("slot", -1)) == expected_slot \
					and int(action_value.get("rawCode", 0)) == expected_raw_code:
				matched_action = action_value
				break
		if matched_action.is_empty() \
				or not campaign_session.install.bundle.is_dispatcher_noop(
					trigger,
					matched_action,
				):
			return false
		evidence_rows.append({
			"triggerId": str(trigger.get("id", "")),
			"slot": expected_slot,
			"rawCode": expected_raw_code,
			"sourceVerified": true,
		})
	evidence["dispatcherNoops"] = evidence_rows
	return true


func _battle_source_matches(step: Dictionary) -> bool:
	var battle_id := int(step.get("battleId", -1))
	var battle: Dictionary = campaign_session.install.bundle.get_battle(battle_id)
	if battle.is_empty():
		return false
	var counts := {}
	for monster_value: Variant in battle.get("grid", []):
		var monster_id := int(monster_value)
		if monster_id == 0:
			continue
		counts[monster_id] = int(counts.get(monster_id, 0)) + 1
	for creature_value: Variant in step.get("creatures", []):
		if not (creature_value is Dictionary):
			return false
		var creature: Dictionary = creature_value
		var monster_id := int(creature.get("monsterId", -1))
		var monster: Dictionary = campaign_session.install.bundle.get_monster(
			monster_id
		)
		if int(counts.get(monster_id, 0)) != int(creature.get("count", 0)) \
				or str(monster.get("displayName", "")) \
					!= str(creature.get("displayName", "")):
			return false
	return counts.size() == step.get("creatures", []).size()


func _actions_match(actual_value: Variant, expected_value: Variant) -> bool:
	if not (actual_value is Array) or not (expected_value is Array):
		return false
	var actual: Array = actual_value
	var expected: Array = expected_value
	if actual.size() != expected.size():
		return false
	for action_index: int in expected.size():
		var actual_action: Dictionary = actual[action_index]
		var expected_action: Dictionary = expected[action_index]
		for field: String in ["slot", "code", "id"]:
			if int(actual_action.get(field, -999999)) \
					!= int(expected_action.get(field, -999999)):
				return false
	return true


func _integer_arrays_match(actual_value: Variant, expected_value: Variant) -> bool:
	if not (actual_value is Array) or not (expected_value is Array):
		return false
	var actual: Array = actual_value
	var expected: Array = expected_value
	if actual.size() != expected.size():
		return false
	for value_index: int in expected.size():
		if int(actual[value_index]) != int(expected[value_index]):
			return false
	return true


func _messages_match(messages_value: Variant) -> bool:
	if not (messages_value is Array):
		return false
	for message_value: Variant in messages_value:
		if not (message_value is Dictionary):
			return false
		var expected: Dictionary = message_value
		var message: Dictionary = campaign_session.install.bundle.get_message(
			int(expected.get("id", -1))
		)
		if not str(message.get("text", "")).begins_with(
			str(expected.get("prefix", ""))
		):
			return false
	return true


func _verify_picture(picture_value: Variant) -> bool:
	if not (picture_value is Dictionary):
		return false
	var expected: Dictionary = picture_value
	var picture: Dictionary = campaign_session.install.bundle.get_picture(
		int(expected.get("id", -1))
	)
	var runtime_path: String = campaign_session.command_adapter.runtime_media_path(
		picture,
		"image/",
	)
	var texture: Texture2D = UI.ow_hud.pictureRect.pictxtrect.texture
	return (
		UI.ow_hud.pictureRect.visible
			and not runtime_path.is_empty()
			and texture != null
			and texture.get_size() == Vector2(
				int(expected.get("width", 0)),
				int(expected.get("height", 0)),
			)
	)


func _move_to_position(position: Dictionary) -> void:
	host.runtime.runtime_state.set_location(
		str(position.get("levelType", "land")),
		int(position.get("levelIndex", 0)),
		int(position.get("x", 0)),
		int(position.get("y", 0)),
	)
	var tile_position := Vector2i(
		int(position.get("x", 0)),
		int(position.get("y", 0)),
	)
	var map: Node = NodeAccess.__Map()
	for character: Node in [map.focuscharacter, map.owcharacter]:
		if character != null and character.has_method("set_tile_position"):
			character.set_tile_position(Vector2(tile_position))
	map.explore_tiles_from_tilepos(tile_position)


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


func _request_victory() -> void:
	await GameGlobal.end_battle("won")


func _close_victory_rewards() -> bool:
	for _frame: int in 600:
		if UI.ow_hud.treasureControl.visible:
			UI.ow_hud.treasureControl.find_child("ButtonDone").pressed.emit()
			await get_tree().process_frame
			if UI.ow_hud.alliesWindow.visible:
				UI.ow_hud.alliesCtrl.okbutton.pressed.emit()
			return true
		if not StateMachine.is_combat_state() and not host.active:
			return false
		await get_tree().process_frame
	return false


func _dismiss_message(prefix: String) -> bool:
	if not await _wait_for_message(prefix):
		return false
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	return true


func _wait_for_message(prefix: String) -> bool:
	var deadline := Time.get_ticks_msec() + STEP_TIMEOUT_MSEC
	while Time.get_ticks_msec() < deadline:
		if UI.ow_hud.textRect.visible \
				and UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
					prefix
				):
			return true
		await get_tree().create_timer(0.01).timeout
	return false


func _wait_for_combat(battle_id: int) -> bool:
	for _frame: int in 600:
		if StateMachine.is_combat_state() \
				and int(StateMachine.combat_state.cur_battle_data.get(
					"classicBattleId",
					-1,
				)) == battle_id:
			return true
		await get_tree().process_frame
	return false


func _wait_for_playthrough_completion() -> bool:
	for _frame: int in 600:
		if not host.active:
			return true
		await get_tree().process_frame
	return false


func _find_campaign_index(item_list: ItemList, campaign_name: String) -> int:
	for item_index: int in item_list.item_count:
		var metadata: Variant = item_list.get_item_metadata(item_index)
		if metadata is Dictionary \
				and metadata.get("campaignName") == campaign_name:
			return item_index
	return -1


func _first_eligible_character_button(buttons: Array[Node]) -> Node:
	for button: Node in buttons:
		var character: Variant = button.get("character")
		if character != null and not bool(button.get("disabled")):
			return button
	return null


func _runtime_position() -> Dictionary:
	var state: ClassicRuntimeState = host.runtime.runtime_state
	return {
		"levelType": state.level_type,
		"levelIndex": state.level_index,
		"x": state.x,
		"y": state.y,
	}


func _native_position() -> Vector2i:
	var character: Variant = NodeAccess.__Map().owcharacter
	return Vector2i(character.tile_position_x, character.tile_position_y)


func _native_map_name(position: Dictionary) -> String:
	return (
		"map_%d" if str(position.get("levelType", "land")) == "land"
		else "mapd_%d"
	) % int(position.get("levelIndex", 0))


func _positions_match(left: Dictionary, right: Dictionary) -> bool:
	return (
		str(left.get("levelType", "")) == str(right.get("levelType", ""))
			and int(left.get("levelIndex", -1))
				== int(right.get("levelIndex", -2))
			and int(left.get("x", -1)) == int(right.get("x", -2))
			and int(left.get("y", -1)) == int(right.get("y", -2))
	)


func _read_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		return null
	return JSON.parse_string(FileAccess.get_file_as_string(path))


func _verify(stage: String, passed: bool, detail: String) -> void:
	evidence["stages"].append({
		"id": stage,
		"status": "passed" if passed else "failed",
		"detail": detail,
	})
	if passed:
		print("CLASSIC_SCENARIO_ROUTE PASS: %s - %s" % [stage, detail])
	else:
		_fail(stage, detail)


func _fail(stage: String, detail: String) -> void:
	var failure := "%s: %s" % [stage, detail]
	if not failures.has(failure):
		failures.append(failure)
	push_error("CLASSIC_SCENARIO_ROUTE FAIL: %s" % failure)


func _on_playthrough_stopped(result: Dictionary) -> void:
	_fail("runtime", str(result.get("message", result)))


func _finish() -> void:
	if finishing:
		return
	finishing = true
	evidence["status"] = "passed" if failures.is_empty() else "failed"
	evidence["failures"] = failures
	if not evidence_path.is_empty():
		var parent := evidence_path.get_base_dir()
		if not parent.is_empty():
			DirAccess.make_dir_recursive_absolute(parent)
		var file := FileAccess.open(evidence_path, FileAccess.WRITE)
		if file != null:
			file.store_string(JSON.stringify(evidence, "\t") + "\n")
			file.close()
	if failures.is_empty():
		print("CLASSIC_SCENARIO_ROUTE PASS: %s" % str(evidence.get("routeId", "")))
	else:
		print("CLASSIC_SCENARIO_ROUTE FAIL: %s" % str(evidence.get("routeId", "")))
	SfxPlayer.stop()
	SfxPlayer.stream = null
	GameGlobal.stop_classic_campaign_runtime()
	host = null
	campaign_session = null
	for _frame: int in 30:
		await get_tree().process_frame
	get_tree().quit(0 if failures.is_empty() else 1)
