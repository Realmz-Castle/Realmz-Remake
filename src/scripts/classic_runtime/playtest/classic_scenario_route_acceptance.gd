extends Node

const SoundResolutionScript = preload(
	"res://scripts/classic_runtime/classic_sound_resolution.gd"
)

const ACCEPTANCE_PROFILE := "Classic Scenario Route Acceptance"
const STEP_TIMEOUT_MSEC := 30000
const BATTLE_TIMEOUT_MSEC := 60000

var campaign_directory := ""
var route_path := ""
var profile_root := ""
var evidence_path := ""
var campaign_manifest: Dictionary = {}
var route: Dictionary = {}
var campaign_session: ClassicCampaignSession
var host: ClassicRuntimeHost
var failures: Array[String] = []
var completed_step_ids: Array[String] = []
var battle_step_ids: Array[String] = []
var victory_request_completed := false
var requested_battle_loot_item_ids: Array = []
var route_experience_award_completed := false
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
	if route.has("randomSeed"):
		seed(int(route["randomSeed"]))
		evidence["randomSeed"] = int(route["randomSeed"])

	for step_value: Variant in route.get("steps", []):
		if not (step_value is Dictionary):
			_fail("route", "A route step is not an object")
			break
		var step: Dictionary = step_value
		var step_succeeded := false
		print(
			"CLASSIC_SCENARIO_ROUTE STEP: %s"
				% str(step.get("id", "route"))
		)
		match str(step.get("kind", "")):
			"presentation":
				step_succeeded = await _run_presentation_step(step)
			"battle":
				step_succeeded = await _run_battle_step(step)
			"action-list":
				step_succeeded = await _run_action_list_step(step)
			"simple-choice":
				step_succeeded = await _run_action_list_step(step)
			"complex-item":
				step_succeeded = await _run_complex_item_step(step)
			"complex-word":
				step_succeeded = await _run_complex_word_step(step)
			_:
				_fail(
					str(step.get("id", "route")),
					"Unsupported route step kind '%s'" % str(step.get("kind", "")),
				)
		if not step_succeeded:
			break
		completed_step_ids.append(str(step.get("id", "")))
	if failures.is_empty():
		_verify_completion_runtime_contract()
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
		if not _step_messages_match(step):
			_fail(stage, "The compiled route messages no longer match their source IDs")
			return false
		if str(step.get("kind", "")) == "battle" \
				and not _battle_source_matches(step):
			_fail(stage, "The compiled battle formation no longer matches the route")
			return false
		if not _nested_battles_source_match(step):
			_fail(stage, "A chained battle formation no longer matches the route")
			return false
		if str(step.get("kind", "")) == "simple-choice" \
				and not _simple_choice_source_matches(step):
			_fail(stage, "The compiled simple-encounter response no longer matches the route")
			return false
		if str(step.get("kind", "")) == "complex-item" \
				and not _complex_item_source_matches(step):
			_fail(stage, "The compiled complex-item response no longer matches the route")
			return false
		if str(step.get("kind", "")) == "complex-word" \
				and not _complex_word_source_matches(step):
			_fail(stage, "The compiled spoken-word response no longer matches the route")
			return false
		if not _treasure_source_matches(step):
			_fail(stage, "The compiled treasure no longer matches the route")
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
	var monster_specs: Array = completion.get("monsters", [])
	var trigger_ids: Array[String] = []
	var extra_code_ids: Array[int] = []
	var verified_battle_ids: Array[int] = []
	var verified_monster_ids: Array[int] = []
	var classification := str(completion.get("classification", ""))
	var completion_valid := (
		not trigger_specs.is_empty()
			and not battle_ids.is_empty()
			and classification in [
				"source-anchor-only",
				"installed-runtime",
				"installed-runtime-with-source-authored-escape",
			]
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
	for monster_value: Variant in monster_specs:
		if not (monster_value is Dictionary):
			completion_valid = false
			continue
		var monster_spec: Dictionary = monster_value
		var monster_id := int(monster_spec.get("id", -1))
		var monster: Dictionary = campaign_session.install.bundle.get_monster(
			monster_id
		)
		verified_monster_ids.append(monster_id)
		completion_valid = completion_valid and not monster.is_empty()
		for field: String in ["displayName", "deathMacro"]:
			if not monster_spec.has(field):
				continue
			if field == "displayName":
				completion_valid = completion_valid \
					and str(monster.get(field, "")) == str(monster_spec.get(field, ""))
			else:
				completion_valid = completion_valid \
					and int(monster.get(field, -1)) == int(monster_spec.get(field, -2))
	completion_valid = (
		completion_valid
			and _messages_match(completion.get("messages", []))
	)
	var completion_evidence := {
		"triggerIds": trigger_ids,
		"extraCodeIds": extra_code_ids,
		"battleIds": verified_battle_ids,
		"classification": classification,
		"sourceVerified": completion_valid,
		"runtimeExercised": false,
	}
	if not monster_specs.is_empty():
		completion_evidence["monsterIds"] = verified_monster_ids
	evidence["completionAnchor"] = completion_evidence
	_verify(
		"completion-source-anchor",
		completion_valid,
		"The compiled completion chain and final battle remain source-identifiable",
	)
	return failures.is_empty()


func _run_presentation_step(step: Dictionary) -> bool:
	var stage := str(step.get("id", "presentation"))
	if not _move_to_position(stage, step.get("position", {})):
		return false
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
	if not await _wait_for_playthrough_completion(
		int(step.get("completionTimeoutMsec", STEP_TIMEOUT_MSEC))
	):
		_fail(
			stage,
			(
				"The presentation action list did not return to exploration: "
				+ "hostActive=%s state=%s map=%s position=%s "
				+ "pendingContinuation=%s lastResult=%s"
			) % [
				host.active,
				StateMachine._state_name,
				GameGlobal.currentmap_name,
				_native_position(),
				campaign_session.has_pending_continuation(),
				JSON.stringify(host.runtime.last_result),
			],
		)
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


func _run_complex_item_step(step: Dictionary) -> bool:
	var stage := str(step.get("id", "complex-item"))
	var encounter: Dictionary = step.get("encounter", {})
	var item_id := int(encounter.get("itemId", -1))
	if not _move_to_position(stage, step.get("position", {})):
		return false
	if not _party_has_classic_item(item_id):
		_fail(stage, "The required Classic response item is not in the party inventory")
		return false
	if not host.start_trigger(str(step.get("triggerId", ""))):
		_fail(stage, str(host.runtime.last_result))
		return false
	if not await _run_interaction_sequence(
		stage,
		step.get("prelude", []),
		step.get("picture", {}),
	):
		return false
	if not await _wait_for_choices():
		_fail(stage, "The authored complex encounter did not open")
		return false
	var prompt: Dictionary = encounter.get("prompt", {})
	if not UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
		str(prompt.get("prefix", ""))
	):
		_fail(stage, "The compiled complex encounter prompt changed")
		return false
	UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("item")
	var item_button := await _wait_for_encounter_item(item_id)
	if item_button == null:
		_fail(stage, "The native encounter item picker did not expose the source item")
		return false
	item_button.pressed.emit()
	if not await _run_interaction_sequence(
		stage,
		step.get("sequence", []),
		step.get("picture", {}),
	):
		return false
	if not await _wait_for_playthrough_completion():
		_fail(stage, "The complex-item result did not return to exploration")
		return false
	var item_consumed := not _party_has_classic_item(item_id)
	var expect_consumed := bool(encounter.get("consumeItem", false))
	var interaction_rows: Array = evidence.get("interactions", [])
	interaction_rows.append({
		"stepId": stage,
		"kind": "complex-item",
		"encounterId": int(encounter.get("id", -1)),
		"itemId": item_id,
		"itemConsumed": item_consumed,
	})
	evidence["interactions"] = interaction_rows
	_verify(
		stage,
		_verify_sound_contract(step)
			and item_consumed == expect_consumed
			and not campaign_session.has_pending_continuation()
			and StateMachine._state_name == "Exploration",
		str(step.get(
			"detail",
			"The installed complex encounter consumes its exact source item response",
		)),
	)
	return failures.is_empty()


func _run_complex_word_step(step: Dictionary) -> bool:
	var stage := str(step.get("id", "complex-word"))
	if not _move_to_position(stage, step.get("position", {})):
		return false
	if not host.start_trigger(str(step.get("triggerId", ""))):
		_fail(stage, str(host.runtime.last_result))
		return false
	if not await _run_interaction_sequence(
		stage,
		step.get("sequence", []),
		step.get("picture", {}),
	):
		return false
	if not await _wait_for_playthrough_completion():
		_fail(stage, "The spoken-word result did not return to exploration")
		return false
	var encounter: Dictionary = step.get("encounter", {})
	var interaction_rows: Array = evidence.get("interactions", [])
	interaction_rows.append({
		"stepId": stage,
		"kind": "complex-word",
		"encounterId": int(encounter.get("id", -1)),
		"spokenText": str(encounter.get("word", "")),
		"result": int(encounter.get("result", -1)),
	})
	evidence["interactions"] = interaction_rows
	_verify(
		stage,
		_verify_sound_contract(step)
			and not campaign_session.has_pending_continuation()
			and StateMachine._state_name == "Exploration",
		str(step.get(
			"detail",
			"The installed complex encounter accepts its exact spoken-word response",
		)),
	)
	return failures.is_empty()


func _run_battle_step(step: Dictionary) -> bool:
	var stage := str(step.get("id", "battle"))
	var battle_id := int(step.get("battleId", -1))
	if not _move_to_position(stage, step.get("position", {})):
		return false
	NodeAccess.__Resources().battles_book.erase("Battle_%d" % battle_id)
	var has_chained_battle := false
	for event_value: Variant in step.get("postVictory", []):
		if event_value is Dictionary \
				and str(event_value.get("kind", "")) == "battle":
			has_chained_battle = true
			NodeAccess.__Resources().battles_book.erase(
				"Battle_%d" % int(event_value.get("battleId", -1))
			)
	_prepare_route_party_for_battle()
	if not host.start_trigger(str(step.get("triggerId", ""))):
		_fail(stage, str(host.runtime.last_result))
		return false
	for message_value: Variant in step.get("messages", []):
		var message: Dictionary = message_value
		if not await _dismiss_message(str(message.get("prefix", ""))):
			_fail(stage, "The authored battle introduction did not open")
			return false
	if not await _wait_for_combat(battle_id):
		_fail(
			stage,
			(
				"The source battle did not enter native combat: "
				+ "hostActive=%s state=%s pendingContinuation=%s lastResult=%s"
			) % [
				host.active,
				StateMachine._state_name,
				campaign_session.has_pending_continuation(),
				JSON.stringify(host.runtime.last_result),
			],
		)
		return false

	var sounds_valid := _verify_sound_contract(step)
	var observation := _observe_active_battle(
		battle_id,
		step.get("creatures", []),
		step.get("allies", []),
	)
	var battle_evidence: Dictionary = observation.get("evidence", {})
	var formation_valid := sounds_valid and bool(observation.get("valid", false))
	_verify(
		stage,
		formation_valid,
		(
			"The compiled formation materializes on a drawable native battlefield"
			if formation_valid
			else "Native battle observation mismatch: %s" % JSON.stringify(
				battle_evidence
			)
		),
	)
	if not failures.is_empty():
		return false

	if not await _wait_for_route_victory_window():
		_fail(stage, "The native battle did not reach a stable player turn")
		return false
	victory_request_completed = false
	requested_battle_loot_item_ids = step.get("lootItemIds", []).duplicate()
	call_deferred("_request_victory")
	var battle_loot_ids: Array = step.get("lootItemIds", [])
	var reward_seen := await _close_victory_rewards(stage, battle_loot_ids)
	if not await _wait_for_victory_request_completion():
		_fail(stage, "The native victory coroutine did not finish")
		return false
	if reward_seen and not await _close_experience_level_ups():
		_fail(stage, "The native battle reward did not finish leveling")
		return false
	battle_evidence["rewardScreenPresented"] = reward_seen
	if has_chained_battle:
		_record_battle_evidence(stage, battle_evidence)
	if not await _run_interaction_sequence(
		stage,
		step.get("postVictory", []),
		step.get("picture", {}),
	):
		return false
	if not await _wait_for_playthrough_completion():
		_fail(stage, "The battle victory did not resume the source action list")
		return false
	var expected_position: Dictionary = step.get("end", step.get("position", {}))
	var native_position := _native_position()
	battle_evidence["returnMap"] = GameGlobal.currentmap_name
	battle_evidence["returnPosition"] = {
		"x": native_position.x,
		"y": native_position.y,
	}
	if not has_chained_battle:
		_record_battle_evidence(stage, battle_evidence)
	var expected_map := _native_map_name(expected_position)
	var expected_native_position := Vector2i(
		int(expected_position.get("x", -1)),
		int(expected_position.get("y", -1)),
	)
	var victory_valid: bool = (
		not StateMachine.is_combat_state()
			and StateMachine._state_name == "Exploration"
			and GameGlobal.currentmap_name == expected_map
			and native_position == expected_native_position
			and not campaign_session.has_pending_continuation()
	)
	_verify(
		"%s-victory" % stage,
		victory_valid,
		(
			"Native victory returns to the authored route with no pending continuation"
			if victory_valid
			else (
				"Native victory state mismatch: state=%s combat=%s map=%s expectedMap=%s "
				+ "position=%s expectedPosition=%s pendingContinuation=%s"
			) % [
				StateMachine._state_name,
				StateMachine.is_combat_state(),
				GameGlobal.currentmap_name,
				expected_map,
				native_position,
				expected_native_position,
				campaign_session.has_pending_continuation(),
			]
		),
	)
	return failures.is_empty()


func _run_action_list_step(step: Dictionary) -> bool:
	var stage := str(step.get("id", "action-list"))
	if not _move_to_position(stage, step.get("position", {})):
		return false
	for event_value: Variant in step.get("sequence", []):
		if event_value is Dictionary \
				and str(event_value.get("kind", "")) == "battle":
			NodeAccess.__Resources().battles_book.erase(
				"Battle_%d" % int(event_value.get("battleId", -1))
			)
	if not host.start_trigger(str(step.get("triggerId", ""))):
		_fail(stage, str(host.runtime.last_result))
		return false
	if not await _run_interaction_sequence(
		stage,
		step.get("sequence", []),
		step.get("picture", {}),
	):
		return false
	if not await _wait_for_playthrough_completion():
		_fail(
			stage,
			(
				"The action list did not return to exploration: "
				+ "hostActive=%s state=%s combat=%s map=%s position=%s "
				+ "pendingContinuation=%s lastResult=%s"
			) % [
				host.active,
				StateMachine._state_name,
				StateMachine.is_combat_state(),
				GameGlobal.currentmap_name,
				_native_position(),
				campaign_session.has_pending_continuation(),
				JSON.stringify(host.runtime.last_result),
			],
		)
		return false

	var expected_position: Dictionary = step.get("end", step.get("position", {}))
	var native_position := _native_position()
	var runtime_position := _runtime_position()
	var trigger_percentages_valid := _verify_step_trigger_percentages(
		stage,
		step.get("triggerPercentages", []),
	)
	var expected_map := _native_map_name(expected_position)
	var expected_native_position := Vector2i(
		int(expected_position.get("x", -1)),
		int(expected_position.get("y", -1)),
	)
	var action_list_valid := (
		_verify_sound_contract(step)
			and trigger_percentages_valid
			and not campaign_session.has_pending_continuation()
			and StateMachine._state_name == "Exploration"
			and _positions_match(expected_position, runtime_position)
			and GameGlobal.currentmap_name == expected_map
			and native_position == expected_native_position
	)
	_verify(
		stage,
		action_list_valid,
		(
			str(step.get(
				"detail",
				"The installed action list completes through the native UI",
			))
			if action_list_valid
			else (
				"Action-list state mismatch: state=%s map=%s expectedMap=%s "
					+ "nativePosition=%s expectedPosition=%s runtimePosition=%s "
					+ "pendingContinuation=%s"
			) % [
				StateMachine._state_name,
				GameGlobal.currentmap_name,
				expected_map,
				native_position,
				expected_native_position,
				JSON.stringify(runtime_position),
				campaign_session.has_pending_continuation(),
			]
		),
	)
	return failures.is_empty()


func _verify_step_trigger_percentages(
	stage: String,
	specifications_value: Variant,
) -> bool:
	if not (specifications_value is Array):
		return false
	var rows: Array = evidence.get("triggerPercentageChecks", [])
	var valid := true
	for specification_value: Variant in specifications_value:
		if not (specification_value is Dictionary):
			valid = false
			continue
		var specification: Dictionary = specification_value
		var observed := host.runtime.runtime_state.get_trigger_percent(
			str(specification.get("levelType", "land")),
			int(specification.get("levelIndex", 0)),
			int(specification.get("triggerId", -1)),
			-1,
		)
		var expected := int(specification.get("percent", -1))
		rows.append({
			"stepId": stage,
			"levelType": str(specification.get("levelType", "land")),
			"levelIndex": int(specification.get("levelIndex", 0)),
			"triggerId": int(specification.get("triggerId", -1)),
			"percent": observed,
		})
		valid = valid and observed == expected
	evidence["triggerPercentageChecks"] = rows
	return valid


func _run_interaction_sequence(
	stage: String,
	sequence_value: Variant,
	default_picture_value: Variant,
) -> bool:
	if not (sequence_value is Array):
		_fail(stage, "The interaction sequence is not an array")
		return false
	if sequence_value.is_empty():
		return true
	var interaction_rows: Array = evidence.get("interactions", [])
	for event_index: int in sequence_value.size():
		var event_value: Variant = sequence_value[event_index]
		if not (event_value is Dictionary):
			_fail(stage, "An interaction event is not an object")
			return false
		var event: Dictionary = event_value
		print(
			"CLASSIC_SCENARIO_ROUTE EVENT: %s - %s"
				% [stage, str(event.get("kind", ""))]
		)
		match str(event.get("kind", "")):
			"message":
				var prefix := str(event.get("prefix", ""))
				if not await _wait_for_message(prefix):
					var visible_text := ""
					if UI.ow_hud.textRect.visible:
						visible_text = UI.ow_hud.textRect.textLabel.get_parsed_text()
					_fail(
						stage,
						(
							"The authored message '%s' did not open in source order; "
							+ "visible text was '%s'"
						) % [prefix, visible_text.left(160)],
					)
					return false
				if bool(event.get("picture", false)):
					var picture_value: Variant = event.get(
						"pictureSpec",
						default_picture_value,
					)
					if not _verify_picture(picture_value):
						_fail(stage, "The authored picture did not render with its message")
						return false
				interaction_rows.append({
					"stepId": stage,
					"kind": "message",
					"messageId": int(event.get("id", -1)),
					"prefix": prefix,
				})
				if event_index + 1 < sequence_value.size():
					var next_event: Variant = sequence_value[event_index + 1]
					if next_event is Dictionary \
							and str(next_event.get("kind", "")) == "battle":
						_prepare_route_party_for_battle()
				UI.ow_hud.textRect.disablerButton.pressed.emit()
			"click":
				var click_prompt := str(event.get("prefix", "Click Mouse"))
				if not await _wait_for_message(click_prompt):
					_fail(stage, "The authored click prompt did not open")
					return false
				if bool(event.get("picture", false)) \
						and not _verify_picture(
							event.get("pictureSpec", default_picture_value)
						):
					_fail(stage, "The authored click picture did not render")
					return false
				interaction_rows.append({
					"stepId": stage,
					"kind": "click",
					"prefix": click_prompt,
				})
				UI.ow_hud.textRect.disablerButton.pressed.emit()
			"choice":
				if not await _wait_for_choices():
					_fail(stage, "The authored choice did not open")
					return false
				var expected_labels: Variant = event.get("labels", [])
				if expected_labels is Array \
						and not expected_labels.is_empty() \
						and _choice_labels() != expected_labels:
					_fail(stage, "The authored choice labels changed")
					return false
				var answer := str(event.get("answer", ""))
				if answer not in ["YES", "NO"]:
					_fail(stage, "The route choice answer must be YES or NO")
					return false
				interaction_rows.append({
					"stepId": stage,
					"kind": "choice",
					"answer": answer,
					"labels": _choice_labels(),
				})
				UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed(answer)
			"encounter-choice":
				if not await _wait_for_choices():
					_fail(stage, "The authored encounter choice did not open")
					return false
				var encounter_labels: Variant = event.get("labels", [])
				if encounter_labels is Array \
						and not encounter_labels.is_empty() \
						and _choice_labels() != encounter_labels:
					_fail(stage, "The authored encounter choice labels changed")
					return false
				var token := str(event.get("token", ""))
				if token.is_empty():
					_fail(stage, "The route encounter choice token is empty")
					return false
				interaction_rows.append({
					"stepId": stage,
					"kind": "encounter-choice",
					"token": token,
					"labels": _choice_labels(),
				})
				UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed(token)
			"encounter-word":
				if not await _wait_for_choices():
					_fail(stage, "The authored spoken-word encounter did not open")
					return false
				var word_labels: Variant = event.get("labels", [])
				if word_labels is Array \
						and not word_labels.is_empty() \
						and _choice_labels() != word_labels:
					_fail(stage, "The authored spoken-word choices changed")
					return false
				var prompt_prefix := str(event.get("promptPrefix", ""))
				if not UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
					prompt_prefix
				):
					_fail(stage, "The compiled spoken-word prompt changed")
					return false
				var entered_text := str(event.get("text", ""))
				if entered_text.is_empty():
					_fail(stage, "The route spoken-word response is empty")
					return false
				var observed_word_labels := _choice_labels()
				UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("word")
				if not await _submit_encounter_word(entered_text):
					_fail(stage, "The native encounter speech input did not accept the response")
					return false
				interaction_rows.append({
					"stepId": stage,
					"kind": "encounter-word",
					"text": entered_text,
					"labels": observed_word_labels,
				})
			"encounter-repeat-boundary":
				if not await _wait_for_choices():
					_fail(stage, "The authored encounter did not repeat after fallthrough")
					return false
				var repeat_result: Dictionary = host.runtime.last_result
				var repeat_payload: Dictionary = repeat_result.get("payload", {})
				var repeat_prompt := str(event.get("promptPrefix", ""))
				var repeat_labels: Variant = event.get("labels", [])
				var repeat_valid: bool = (
					str(repeat_result.get("command", "")) == "start_encounter"
						and int(repeat_payload.get("encounterId", -1))
							== int(event.get("encounterId", -2))
						and int(repeat_payload.get("remainingAttempts", -1))
							== int(event.get("remainingAttempts", -2))
						and bool(
							repeat_payload.get("encounter", {}).get(
								"canBackOut",
								true,
							)
						) == bool(event.get("canBackOut", false))
						and UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(
							repeat_prompt
						)
				)
				if repeat_labels is Array and not repeat_labels.is_empty():
					repeat_valid = repeat_valid \
						and _choice_labels() == repeat_labels
				if not repeat_valid:
					_fail(
						stage,
						"The source-authored encounter fallthrough boundary changed",
					)
					return false
				interaction_rows.append({
					"stepId": stage,
					"kind": "encounter-repeat-boundary",
					"encounterId": int(repeat_payload.get("encounterId", -1)),
					"remainingAttempts": int(
						repeat_payload.get("remainingAttempts", -1)
					),
					"canBackOut": bool(
						repeat_payload.get("encounter", {}).get(
							"canBackOut",
							false,
						)
					),
					"sourceAuthoredRepeat": true,
					"acceptanceEscape": "injected-stop-token",
				})
				# The scenario omits Classic's break-encounter-loop opcode, so
				# the source repeats this prompt 126 more times. The acceptance
				# route records that boundary, then injects the adapter's normal
				# cancel outcome solely to continue testing the downstream path.
				UI.ow_hud.textRect.choicesContainer._on_choice_button_pressed("STOP")
			"experience":
				if not await _wait_for_treasure():
					_fail(
						stage,
						"The authored experience award at sequence index %d did not open"
							% event_index,
					)
					return false
				var expected_experience := int(event.get("amount", 0))
				if not _treasure_classic_item_ids().is_empty() \
						or int(UI.ow_hud.treasureControl.exp_gain) \
							!= expected_experience:
					_fail(stage, "The native experience award no longer matches its source")
					return false
				interaction_rows.append({
					"stepId": stage,
					"kind": "experience",
					"amount": expected_experience,
				})
				if not await _close_route_experience_award():
					_fail(stage, "The native experience award did not finish leveling")
					return false
			"level-up":
				if not await _wait_for_level_up():
					_fail(stage, "The authored level-up did not open")
					return false
				var selected_count := (
					GameGlobal.last_picked_characters.size()
					if GameGlobal.last_picked_characters is Array
					else 0
				)
				interaction_rows.append({
					"stepId": stage,
					"kind": "level-up",
					"selectedCount": selected_count,
				})
				UI.ow_hud.levelupCtrl._on_close_button_pressed()
				await get_tree().process_frame
			"treasure":
				if not await _wait_for_treasure():
					_fail(stage, "The authored treasure did not open")
					return false
				var expected_item_ids: Array = event.get("itemIds", [])
				var observed_item_ids := _treasure_classic_item_ids()
				var treasure_valid := _integer_arrays_match(
					observed_item_ids,
					expected_item_ids,
				)
				if event.has("exp"):
					treasure_valid = treasure_valid \
						and int(UI.ow_hud.treasureControl.exp_gain) \
							== int(event.get("exp", 0))
				if not treasure_valid:
					_fail(stage, "The native treasure no longer matches its source record")
					return false
				var loot_item_ids: Array = event.get(
					"lootItemIds",
					expected_item_ids,
				)
				if bool(event.get("lootItems", false)) \
						and not await _loot_classic_items(loot_item_ids):
					_fail(stage, "The authored treasure items could not be taken")
					return false
				var experience_gain := int(UI.ow_hud.treasureControl.exp_gain)
				interaction_rows.append({
					"stepId": stage,
					"kind": "treasure",
					"treasureId": int(event.get("id", -1)),
					"itemIds": observed_item_ids,
					"experience": experience_gain,
				})
				UI.ow_hud.treasureControl.find_child("ButtonDone").pressed.emit()
				if experience_gain > 0 and not await _close_experience_level_ups():
					_fail(stage, "The authored treasure did not finish leveling")
					return false
			"map":
				var map_id := int(event.get("id", -1))
				var map_notice := str(event.get("prefix", ""))
				if not await _wait_for_message(map_notice) \
						or not host.runtime.runtime_state.is_map_owned(map_id):
					_fail(stage, "The authored player map was not granted")
					return false
				interaction_rows.append({
					"stepId": stage,
					"kind": "map",
					"mapId": map_id,
					"prefix": map_notice,
				})
				UI.ow_hud.textRect.disablerButton.pressed.emit()
			"battle":
				var battle_id := int(event.get("battleId", -1))
				_prepare_route_party_for_battle()
				if not await _wait_for_combat(battle_id):
					_fail(
						stage,
						(
							"The chained source battle did not enter native combat: "
							+ "battleId=%d hostActive=%s state=%s "
							+ "pendingContinuation=%s activeBattle=%s "
							+ "activeClassicId=%s nativeClassicId=%s lastResult=%s"
						) % [
							battle_id,
							host.active,
							StateMachine._state_name,
							campaign_session.has_pending_continuation(),
							str(StateMachine.combat_state.cur_battle_data.get(
								"battlename",
								"",
							)),
							str(StateMachine.combat_state.cur_battle_data.get(
								"classicBattleId",
								"",
							)),
							str(NodeAccess.__Resources().battles_book.get(
								"Battle_%d" % battle_id,
								{},
							).get("classicBattleId", "")),
							JSON.stringify(host.runtime.last_result),
						],
					)
					return false
				var observation := _observe_active_battle(
					battle_id,
					event.get("creatures", []),
					event.get("allies", []),
				)
				if not bool(observation.get("valid", false)):
					_fail(
						stage,
						"The chained native battle no longer matches its source: %s"
							% JSON.stringify(observation.get("evidence", {})),
					)
					return false
				if not await _wait_for_route_victory_window():
					_fail(
						stage,
						"The chained native battle %d did not reach a stable player turn"
							% battle_id,
					)
					return false
				victory_request_completed = false
				requested_battle_loot_item_ids = (
					event.get("lootItemIds", []).duplicate()
				)
				call_deferred("_request_victory")
				var chained_loot_ids: Array = event.get("lootItemIds", [])
				var reward_seen := await _close_victory_rewards(
					stage,
					chained_loot_ids,
				)
				if not await _wait_for_victory_request_completion():
					_fail(stage, "The chained native victory coroutine did not finish")
					return false
				if reward_seen and not await _close_experience_level_ups():
					_fail(stage, "The chained native battle reward did not finish leveling")
					return false
				var battle_evidence: Dictionary = observation.get("evidence", {})
				battle_evidence["rewardScreenPresented"] = reward_seen
				_record_battle_evidence(
					"%s:%s" % [stage, str(event.get("id", battle_id))],
					battle_evidence,
				)
				interaction_rows.append({
					"stepId": stage,
					"kind": "battle",
					"battleId": battle_id,
				})
			_:
				_fail(
					stage,
					"Unsupported interaction kind '%s'" % str(event.get("kind", "")),
				)
				return false
	evidence["interactions"] = interaction_rows
	return true


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
	return _battle_spec_source_matches(step)


func _battle_spec_source_matches(specification: Dictionary) -> bool:
	var battle_id := int(specification.get("battleId", -1))
	var battle: Dictionary = campaign_session.install.bundle.get_battle(battle_id)
	if battle.is_empty():
		return false
	var enemy_counts := {}
	var ally_counts := {}
	for monster_value: Variant in battle.get("grid", []):
		var raw_monster_id := int(monster_value)
		if raw_monster_id == 0:
			continue
		var monster_id := absi(raw_monster_id)
		var monster: Dictionary = campaign_session.install.bundle.get_monster(
			monster_id
		)
		var is_ally := raw_monster_id < 0 \
			or int(monster.get("traitor", 0)) == 0
		var counts: Dictionary = ally_counts if is_ally else enemy_counts
		counts[monster_id] = int(counts.get(monster_id, 0)) + 1
	for group_name: String in ["creatures", "allies"]:
		var counts: Dictionary = (
			ally_counts if group_name == "allies" else enemy_counts
		)
		var group_value: Variant = specification.get(group_name, [])
		if not (group_value is Array) or counts.size() != group_value.size():
			return false
		for creature_value: Variant in group_value:
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
			if creature.has("deathMacro") \
					and int(monster.get("deathMacro", -1)) \
						!= int(creature.get("deathMacro", -2)):
				return false
	var loot_item_ids: Variant = specification.get("lootItemIds", [])
	if not (loot_item_ids is Array):
		return false
	for item_value: Variant in loot_item_ids:
		var item_id := int(item_value)
		var carried_by_formation := false
		for monster_value: Variant in battle.get("grid", []):
			var monster_id := absi(int(monster_value))
			if monster_id == 0:
				continue
			var monster: Dictionary = campaign_session.install.bundle.get_monster(
				monster_id
			)
			for carried_value: Variant in monster.get("items", []):
				if int(carried_value) == item_id:
					carried_by_formation = true
					break
			if carried_by_formation:
				break
		if not carried_by_formation:
			return false
	return true


func _nested_battles_source_match(step: Dictionary) -> bool:
	for sequence_name: String in ["prelude", "postVictory", "sequence"]:
		var sequence_value: Variant = step.get(sequence_name, [])
		if not (sequence_value is Array):
			return false
		for event_value: Variant in sequence_value:
			if event_value is Dictionary \
					and str(event_value.get("kind", "")) == "battle" \
					and not _battle_spec_source_matches(event_value):
				return false
	return true


func _complex_item_source_matches(step: Dictionary) -> bool:
	var specification: Dictionary = step.get("encounter", {})
	var encounter: Dictionary = campaign_session.install.bundle.get_encounter(
		"complex",
		int(specification.get("id", -1)),
	)
	if encounter.is_empty() \
			or int(encounter.get("prompt", -1)) \
				!= int(specification.get("prompt", {}).get("id", -2)):
		return false
	var item_ids: Array = encounter.get("itemIds", [])
	var item_results: Array = encounter.get("itemResults", [])
	var expected_item_id := int(specification.get("itemId", -1))
	var item_index := -1
	for candidate_index: int in item_ids.size():
		if int(item_ids[candidate_index]) == expected_item_id:
			item_index = candidate_index
			break
	if item_index < 0 \
			or item_index >= item_results.size() \
			or int(item_results[item_index]) != int(specification.get("result", -1)):
		return false
	return _raw_actions_match(
		encounter.get("actions", []),
		specification.get("resultActions", []),
	)


func _complex_word_source_matches(step: Dictionary) -> bool:
	var specification: Dictionary = step.get("encounter", {})
	var encounter: Dictionary = campaign_session.install.bundle.get_encounter(
		"complex",
		int(specification.get("id", -1)),
	)
	if encounter.is_empty() \
			or int(encounter.get("prompt", -1)) \
				!= int(specification.get("prompt", {}).get("id", -2)) \
			or int(encounter.get("wordResult", 0)) \
				!= int(specification.get("result", -1)):
		return false
	var texts: Array = encounter.get("texts", [])
	var expected_word := str(specification.get("word", "")).to_lower()
	var source_word := str(texts[8]).left(40).to_lower() if texts.size() > 8 else ""
	var first_space := source_word.find(" ")
	if first_space >= 0:
		source_word = source_word.left(first_space)
	if source_word.is_empty() or not expected_word.begins_with(source_word):
		return false
	return _raw_actions_match(
		encounter.get("actions", []),
		specification.get("resultActions", []),
	)


func _simple_choice_source_matches(step: Dictionary) -> bool:
	var specification: Dictionary = step.get("encounter", {})
	var encounter: Dictionary = campaign_session.install.bundle.get_encounter(
		"simple",
		int(specification.get("id", -1)),
	)
	if encounter.is_empty() \
			or int(encounter.get("prompt", -1)) \
				!= int(specification.get("prompt", {}).get("id", -2)) \
			or not _string_arrays_match(
				encounter.get("texts", []),
				specification.get("choiceTexts", []),
			):
		return false
	var choice_index := int(specification.get("choiceIndex", -1))
	var choice_results: Array = encounter.get("choiceResults", [])
	if choice_index < 0 \
			or choice_index >= choice_results.size() \
			or int(choice_results[choice_index]) \
				!= int(specification.get("result", -1)):
		return false
	return _raw_actions_match(
		encounter.get("actions", []),
		specification.get("resultActions", []),
	)


func _step_messages_match(step: Dictionary) -> bool:
	var messages: Array = []
	for message_value: Variant in step.get("messages", []):
		messages.append(message_value)
	var encounter_value: Variant = step.get("encounter", {})
	if encounter_value is Dictionary:
		var prompt_value: Variant = encounter_value.get("prompt", {})
		if prompt_value is Dictionary and not prompt_value.is_empty():
			messages.append(prompt_value)
	for sequence_name: String in ["prelude", "postVictory", "sequence"]:
		var sequence_value: Variant = step.get(sequence_name, [])
		if not (sequence_value is Array):
			return false
		for event_value: Variant in sequence_value:
			if event_value is Dictionary \
					and str(event_value.get("kind", "")) == "message":
				messages.append(event_value)
	return _messages_match(messages)


func _treasure_source_matches(step: Dictionary) -> bool:
	for sequence_name: String in ["postVictory", "sequence"]:
		var sequence_value: Variant = step.get(sequence_name, [])
		if not (sequence_value is Array):
			return false
		for event_value: Variant in sequence_value:
			if not (event_value is Dictionary) \
					or str(event_value.get("kind", "")) != "treasure":
				continue
			var event: Dictionary = event_value
			var treasure: Dictionary = campaign_session.install.bundle.get_treasure(
				int(event.get("id", -1))
			)
			if treasure.is_empty() or not _integer_arrays_match(
				treasure.get("itemIds", []),
				event.get("sourceItemIds", event.get("itemIds", [])),
			):
				return false
			for field: String in ["exp", "gold", "gems", "jewelry"]:
				if event.has(field) \
						and int(treasure.get(field, 0)) != int(event.get(field, 0)):
					return false
	return true


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


func _raw_actions_match(actual_value: Variant, expected_value: Variant) -> bool:
	if not (actual_value is Array) or not (expected_value is Array):
		return false
	var actual: Array = actual_value
	var expected: Array = expected_value
	if actual.size() != expected.size():
		return false
	for action_index: int in expected.size():
		var actual_action: Dictionary = actual[action_index]
		var expected_action: Dictionary = expected[action_index]
		for field: String in ["slot", "rawCode", "id"]:
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


func _string_arrays_match(actual_value: Variant, expected_value: Variant) -> bool:
	if not (actual_value is Array) or not (expected_value is Array):
		return false
	var actual: Array = actual_value
	var expected: Array = expected_value
	if actual.size() != expected.size():
		return false
	for value_index: int in expected.size():
		if str(actual[value_index]) != str(expected[value_index]):
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


func _verify_completion_runtime_contract() -> bool:
	var completion: Dictionary = route.get("completionAnchor", {})
	if str(completion.get("classification", "")) not in [
		"installed-runtime",
		"installed-runtime-with-source-authored-escape",
	]:
		return true
	var runtime: Dictionary = completion.get("runtime", {})
	var expected_step_ids: Array = runtime.get("stepIds", [])
	var expected_position: Dictionary = runtime.get("position", {})
	var valid := _string_arrays_match(completed_step_ids, expected_step_ids)
	valid = valid and _positions_match(expected_position, _runtime_position())
	valid = valid and GameGlobal.currentmap_name == _native_map_name(expected_position)
	valid = valid and _native_position() == Vector2i(
		int(expected_position.get("x", -1)),
		int(expected_position.get("y", -1)),
	)
	var observed_quests: Array[int] = []
	for quest_value: Variant in runtime.get("questFlags", []):
		var quest_id := int(quest_value)
		observed_quests.append(quest_id)
		valid = valid and host.runtime.runtime_state.is_quest_set(quest_id)
	var observed_tiles: Array = []
	for tile_value: Variant in runtime.get("tileOverrides", []):
		if not (tile_value is Dictionary):
			valid = false
			continue
		var tile: Dictionary = tile_value
		var observed := host.runtime.runtime_state.get_tile(
			str(tile.get("levelType", "land")),
			int(tile.get("levelIndex", 0)),
			int(tile.get("x", 0)),
			int(tile.get("y", 0)),
			-2147483648,
		)
		observed_tiles.append({
			"levelType": str(tile.get("levelType", "land")),
			"levelIndex": int(tile.get("levelIndex", 0)),
			"x": int(tile.get("x", 0)),
			"y": int(tile.get("y", 0)),
			"value": observed,
		})
		valid = valid and observed == int(tile.get("value", 0))
	var observed_items: Array[int] = []
	for item_value: Variant in runtime.get("itemIds", []):
		var item_id := int(item_value)
		if _party_has_classic_item(item_id):
			observed_items.append(item_id)
		else:
			valid = false
	var observed_absent_items: Array[int] = []
	for item_value: Variant in runtime.get("absentItemIds", []):
		var item_id := int(item_value)
		if not _party_has_classic_item(item_id):
			observed_absent_items.append(item_id)
		else:
			valid = false
	var observed_trigger_percentages: Array = []
	for trigger_value: Variant in runtime.get("triggerPercentages", []):
		if not (trigger_value is Dictionary):
			valid = false
			continue
		var trigger: Dictionary = trigger_value
		var observed := host.runtime.runtime_state.get_trigger_percent(
			str(trigger.get("levelType", "land")),
			int(trigger.get("levelIndex", 0)),
			int(trigger.get("triggerId", -1)),
			-1,
		)
		observed_trigger_percentages.append({
			"levelType": str(trigger.get("levelType", "land")),
			"levelIndex": int(trigger.get("levelIndex", 0)),
			"triggerId": int(trigger.get("triggerId", -1)),
			"percent": observed,
		})
		valid = valid and observed == int(trigger.get("percent", -1))
	var observed_battle_ids: Array[int] = []
	var battle_rows: Array = evidence.get("battles", [])
	if battle_rows.is_empty() \
			and evidence.get("battle", {}) is Dictionary \
			and not evidence.get("battle", {}).is_empty():
		battle_rows.append(evidence.get("battle", {}))
	for battle_value: Variant in battle_rows:
		if battle_value is Dictionary:
			observed_battle_ids.append(int(battle_value.get("id", -1)))
	var expected_battle_ids: Array = runtime.get("battleIds", [])
	if not expected_battle_ids.is_empty():
		valid = valid and _integer_arrays_match(
			observed_battle_ids,
			expected_battle_ids,
		)
	var completion_evidence: Dictionary = evidence.get("completionAnchor", {})
	completion_evidence["runtimeExercised"] = valid
	completion_evidence["runtime"] = {
		"stepIds": completed_step_ids.duplicate(),
		"position": _runtime_position(),
		"questFlags": observed_quests,
		"tileOverrides": observed_tiles,
		"itemIds": observed_items,
		"absentItemIds": observed_absent_items,
		"triggerPercentages": observed_trigger_percentages,
		"battleIds": observed_battle_ids,
	}
	evidence["completionAnchor"] = completion_evidence
	_verify(
		"completion-runtime",
		valid,
		(
			"The installed completion route reaches its authored reward and epilogue state"
			if valid
			else "Installed completion state mismatch: %s" % JSON.stringify(
				completion_evidence["runtime"]
			)
		),
	)
	return failures.is_empty()


func _record_battle_evidence(
	step_id: String,
	battle_evidence: Dictionary,
) -> void:
	if not evidence.has("battle"):
		evidence["battle"] = battle_evidence
		battle_step_ids.append(step_id)
		return
	var battle_rows: Array = evidence.get("battles", [])
	if battle_rows.is_empty():
		var first_battle: Dictionary = evidence["battle"].duplicate(true)
		first_battle["stepId"] = battle_step_ids[0]
		battle_rows.append(first_battle)
	var next_battle := battle_evidence.duplicate(true)
	next_battle["stepId"] = step_id
	battle_rows.append(next_battle)
	battle_step_ids.append(step_id)
	evidence["battles"] = battle_rows


func _wait_for_choices() -> bool:
	var deadline := Time.get_ticks_msec() + STEP_TIMEOUT_MSEC
	await get_tree().process_frame
	while Time.get_ticks_msec() < deadline:
		var choices: Control = UI.ow_hud.textRect.choicesContainer
		if choices.visible and choices.get_child_count() > 0:
			return true
		await get_tree().create_timer(0.01).timeout
	return false


func _submit_encounter_word(entered_text: String) -> bool:
	var deadline := Time.get_ticks_msec() + STEP_TIMEOUT_MSEC
	while Time.get_ticks_msec() < deadline:
		var encounter_control: Control = UI.ow_hud.encounterControl
		if encounter_control.visible \
				and encounter_control.speakButton.visible \
				and encounter_control.speakButton.get_child(0).visible:
			encounter_control.speakField.text = entered_text
			var done_button := encounter_control.find_child(
				"SpeakDoneButton",
				true,
				false,
			) as Button
			if done_button == null:
				return false
			done_button.pressed.emit()
			return true
		await get_tree().create_timer(0.01).timeout
	return false


func _wait_for_encounter_item(item_id: int) -> Button:
	for _frame: int in 600:
		var item_menu: Control = UI.ow_hud.encounterControl.useitemRect
		if item_menu.visible:
			for child: Node in item_menu.itemsContainer.get_children():
				if not (child is Button):
					continue
				var instance_value: Variant = child.get_meta(
					"item_instance",
					null,
				)
				if instance_value is ItemInstance \
						and NodeAccess.__Resources().item_classic_ids(
							instance_value
						).has(item_id):
					return child
		await get_tree().process_frame
	return null


func _wait_for_treasure() -> bool:
	var deadline := Time.get_ticks_msec() + STEP_TIMEOUT_MSEC
	while Time.get_ticks_msec() < deadline:
		if UI.ow_hud.treasureControl.visible:
			return true
		await get_tree().create_timer(0.01).timeout
	return false


func _wait_for_level_up() -> bool:
	var deadline := Time.get_ticks_msec() + STEP_TIMEOUT_MSEC
	while Time.get_ticks_msec() < deadline:
		var level_up_window: Window = UI.ow_hud.levelupCtrl.get_parent()
		if level_up_window.visible:
			return true
		await get_tree().create_timer(0.01).timeout
	return false


func _close_experience_level_ups() -> bool:
	var deadline := Time.get_ticks_msec() + STEP_TIMEOUT_MSEC
	while Time.get_ticks_msec() < deadline:
		var level_up_window: Window = UI.ow_hud.levelupCtrl.get_parent()
		if level_up_window.visible:
			UI.ow_hud.levelupCtrl._on_close_button_pressed()
			await get_tree().process_frame
			continue
		if not UI.ow_hud.treasureControl.visible:
			return true
		await get_tree().process_frame
	return false


func _close_route_experience_award() -> bool:
	route_experience_award_completed = false
	UI.ow_hud.treasureControl.done_looting.connect(
		_on_route_experience_award_completed,
		CONNECT_ONE_SHOT,
	)
	UI.ow_hud.treasureControl.find_child("ButtonDone").pressed.emit()
	var deadline := Time.get_ticks_msec() + STEP_TIMEOUT_MSEC
	while Time.get_ticks_msec() < deadline:
		var level_up_window: Window = UI.ow_hud.levelupCtrl.get_parent()
		if level_up_window.visible:
			UI.ow_hud.levelupCtrl._on_close_button_pressed()
			await get_tree().process_frame
			continue
		if route_experience_award_completed:
			return true
		await get_tree().process_frame
	return false


func _on_route_experience_award_completed() -> void:
	route_experience_award_completed = true


func _choice_labels() -> Array[String]:
	var labels: Array[String] = []
	for child: Node in UI.ow_hud.textRect.choicesContainer.get_children():
		if child is Label:
			labels.append(str(child.text))
	return labels


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


func _loot_classic_items(item_ids: Array) -> bool:
	var character: PlayerCharacter = GameGlobal.player_characters[0]
	UI.ow_hud.selected_character = character
	for item_value: Variant in item_ids:
		var item_id := int(item_value)
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


func _party_has_classic_item(item_id: int) -> bool:
	for character: PlayerCharacter in GameGlobal.player_characters:
		for item: ItemInstance in character.inventory_instances():
			if NodeAccess.__Resources().item_classic_ids(item).has(item_id):
				return true
	return false


func _prepare_route_party_for_battle() -> void:
	# The acceptance driver must regain control before enemy AI starts. Apply a
	# process-local initiative floor to generated Classic bestiary records;
	# installed campaign files and ordinary gameplay resources are unchanged.
	var creature_book: Dictionary = NodeAccess.__Resources().crea_book
	for bestiary_key: Variant in creature_book:
		var entry_value: Variant = creature_book[bestiary_key]
		if not (entry_value is Dictionary):
			continue
		var entry: Dictionary = entry_value
		var data_value: Variant = entry.get("data", {})
		var has_classic_id: bool = entry.has("classicMonsterId") \
			or (
				data_value is Dictionary
				and data_value.has("classicMonsterId")
			)
		if not has_classic_id or not (entry.get("stats", {}) is Dictionary):
			continue
		var stats: Dictionary = entry.get("stats", {})
		stats["Dexterity"] = -100000
		entry["stats"] = stats
		creature_book[bestiary_key] = entry
	for character: PlayerCharacter in GameGlobal.player_characters:
		character.life_status = 0
		character.stats["maxHP"] = maxi(
			int(character.stats.get("maxHP", 0)),
			100000,
		)
		character.stats["curHP"] = int(character.stats["maxHP"])
		character.stats["Dexterity"] = maxi(
			int(character.stats.get("Dexterity", 0)),
			100000,
		)


func _move_to_position(stage: String, position: Dictionary) -> bool:
	host.runtime.runtime_state.set_location(
		str(position.get("levelType", "land")),
		int(position.get("levelIndex", 0)),
		int(position.get("x", 0)),
		int(position.get("y", 0)),
	)
	var expected_map := _native_map_name(position)
	if GameGlobal.currentmap_name != expected_map:
		var transition_result := host.activate_start_location()
		if str(transition_result.get("status", "")) == "error" \
				or GameGlobal.currentmap_name != expected_map:
			_fail(
				stage,
				str(transition_result.get(
					"message",
					"The native route map could not be loaded",
				)),
			)
			return false
	var tile_position := Vector2i(
		int(position.get("x", 0)),
		int(position.get("y", 0)),
	)
	var map: Node = NodeAccess.__Map()
	for character: Node in [map.focuscharacter, map.owcharacter]:
		if character != null and character.has_method("set_tile_position"):
			character.set_tile_position(Vector2(tile_position))
	map.explore_tiles_from_tilepos(tile_position)
	return true


func _classic_enemy_count(monster_id: int) -> int:
	return _classic_combatant_count(monster_id, false)


func _classic_ally_count(monster_id: int) -> int:
	return _classic_combatant_count(monster_id, true)


func _classic_combatant_count(monster_id: int, ally: bool) -> int:
	var count := 0
	for button: Variant in StateMachine.combat_state.all_battle_creatures_btns:
		if not (button is Object):
			continue
		var creature: Variant = button
		if button is CombatCreaButton:
			creature = button.creature
		if creature is Object \
				and int(creature.get_meta("classic_monster_id", -1)) == monster_id \
				and (int(creature.get("curFaction")) == 0) == ally:
			count += 1
	return count


func _observe_active_battle(
	battle_id: int,
	creatures_value: Variant,
	allies_value: Variant = [],
) -> Dictionary:
	var native_battle: Dictionary = NodeAccess.__Resources().battles_book.get(
		"Battle_%d" % battle_id,
		{},
	)
	var roster_valid := int(native_battle.get("classicBattleId", -1)) == battle_id
	var expected_enemy_count := 0
	var observed_creatures: Array = []
	var creatures: Array = creatures_value if creatures_value is Array else []
	for creature_value: Variant in creatures:
		if not (creature_value is Dictionary):
			roster_valid = false
			continue
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
	var expected_ally_count := 0
	var observed_allies: Array = []
	var allies: Array = allies_value if allies_value is Array else []
	for ally_value: Variant in allies:
		if not (ally_value is Dictionary):
			roster_valid = false
			continue
		var ally: Dictionary = ally_value
		var monster_id := int(ally.get("monsterId", -1))
		var expected_count := int(ally.get("count", 0))
		var observed_count := _classic_ally_count(monster_id)
		expected_ally_count += expected_count
		roster_valid = roster_valid and observed_count == expected_count
		observed_allies.append({
			"monsterId": monster_id,
			"displayName": str(ally.get("displayName", "")),
			"count": observed_count,
		})
	roster_valid = roster_valid and native_battle.get("Creatures", []).size() \
		== expected_enemy_count + expected_ally_count
	var battle_evidence := {
		"id": battle_id,
		"creatures": observed_creatures,
		"allies": observed_allies,
		"battlefieldDrawable": _temporary_battlefield_is_drawable(),
	}
	return {
		"valid": roster_valid and bool(battle_evidence["battlefieldDrawable"]),
		"evidence": battle_evidence,
	}


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


func _wait_for_route_victory_window() -> bool:
	var deadline := Time.get_ticks_msec() + STEP_TIMEOUT_MSEC
	while Time.get_ticks_msec() < deadline:
		var active_button: Variant = StateMachine.cb_decide_state.current_active_creabutton
		if StateMachine.is_combat_state() \
				and active_button is Object \
				and is_instance_valid(active_button):
			var creature: Variant = active_button
			if active_button is CombatCreaButton:
				creature = active_button.creature
			if creature is Creature and creature.is_crea_player_controlled():
				await get_tree().process_frame
				return StateMachine.is_combat_state()
		await get_tree().create_timer(0.01).timeout
	return false


func _request_victory() -> void:
	_mark_required_loot_carriers_defeated()
	await GameGlobal.end_battle("won")
	requested_battle_loot_item_ids.clear()
	victory_request_completed = true


func _mark_required_loot_carriers_defeated() -> void:
	if requested_battle_loot_item_ids.is_empty():
		return
	for button_value: Variant in StateMachine.combat_state.all_battle_creatures_btns:
		if not (button_value is Object):
			continue
		var creature: Variant = button_value
		if button_value is CombatCreaButton:
			creature = button_value.creature
		if not (creature is Creature) or int(creature.curFaction) == 0:
			continue
		var carries_required_item := false
		for item: ItemInstance in creature.inventory_instances():
			for item_id_value: Variant in requested_battle_loot_item_ids:
				if NodeAccess.__Resources().item_classic_ids(item).has(
					int(item_id_value)
				):
					carries_required_item = true
					break
			if carries_required_item:
				break
		if carries_required_item \
				and not StateMachine.combat_state.battle_dead_enemies.has(creature):
			StateMachine.combat_state.battle_dead_enemies.append(creature)


func _wait_for_victory_request_completion() -> bool:
	var deadline := Time.get_ticks_msec() + STEP_TIMEOUT_MSEC
	while Time.get_ticks_msec() < deadline:
		var level_up_window: Window = UI.ow_hud.levelupCtrl.get_parent()
		if level_up_window.visible:
			UI.ow_hud.levelupCtrl._on_close_button_pressed()
			await get_tree().process_frame
			continue
		if UI.ow_hud.alliesWindow.visible:
			UI.ow_hud.alliesCtrl.okbutton.pressed.emit()
			await get_tree().process_frame
			continue
		if victory_request_completed:
			return true
		await get_tree().create_timer(0.01).timeout
	return false


func _close_victory_rewards(
	stage := "battle",
	loot_item_ids: Array = [],
) -> bool:
	var deadline := Time.get_ticks_msec() + STEP_TIMEOUT_MSEC
	while Time.get_ticks_msec() < deadline:
		if UI.ow_hud.treasureControl.visible:
			var loot_valid := loot_item_ids.is_empty() \
				or await _loot_classic_items(loot_item_ids)
			UI.ow_hud.treasureControl.find_child("ButtonDone").pressed.emit()
			await get_tree().process_frame
			if UI.ow_hud.alliesWindow.visible:
				UI.ow_hud.alliesCtrl.okbutton.pressed.emit()
			if not loot_valid:
				_fail(
					stage,
					"The required Classic battle loot could not be taken",
				)
			return true
		if not StateMachine.is_combat_state() and not host.active:
			return false
		await get_tree().create_timer(0.01).timeout
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
	var deadline := Time.get_ticks_msec() + BATTLE_TIMEOUT_MSEC
	while Time.get_ticks_msec() < deadline:
		if StateMachine.is_combat_state() \
				and int(StateMachine.combat_state.cur_battle_data.get(
					"classicBattleId",
					-1,
				)) == battle_id:
			return true
		await get_tree().create_timer(0.01).timeout
	return false


func _wait_for_playthrough_completion(
	timeout_msec := STEP_TIMEOUT_MSEC,
) -> bool:
	var deadline := Time.get_ticks_msec() + timeout_msec
	while Time.get_ticks_msec() < deadline:
		if not host.active \
				and not StateMachine.is_combat_state() \
				and StateMachine._state_name == "Exploration":
			return true
		await get_tree().create_timer(0.01).timeout
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
	MusicStreamPlayer.stop()
	MusicStreamPlayer.stream = null
	GameGlobal.stop_classic_campaign_runtime()
	host = null
	campaign_session = null
	for _frame: int in 120:
		await get_tree().process_frame
	get_tree().quit(0 if failures.is_empty() else 1)
