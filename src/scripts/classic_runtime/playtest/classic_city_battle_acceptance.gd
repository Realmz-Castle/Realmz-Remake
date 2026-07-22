extends Node

const AdapterScript = preload("res://scripts/classic_runtime/classic_godot_command_adapter.gd")
const CampaignSessionScript = preload(
	"res://scripts/classic_runtime/classic_campaign_session.gd"
)
const RogueClass = preload("res://Data/Character Classes/Class_Assassin.gd")
const HumanRace = preload("res://Data/Character Races/Race_Human.gd")
const DefaultIcon = preload("res://scenes/UI/Main Menu/DefaultIcon.png")
const DefaultPortrait = preload("res://scenes/UI/Main Menu/DefaultPortrait.png")

const TRIGGER_ID := "Data DD:0:30"
# The trigger's action ID 85 selects Extra Code row 85, which resolves Battle 45.
const BATTLE_ID := 45
const MONSTER_ID := 80
const EXPECTED_ENEMY_COUNT := 24
const TRIGGER_POSITION := Vector2i(2, 44)
const FIRST_MESSAGE := "In this hut there is a wounded goblin"
const SECOND_MESSAGE := "You search his body and turn up a map"
const MAP_GAINED_MESSAGE := "You gain a map"
const RETURN_MESSAGE := "Among the items, you find a sack"
const MUTATED_TRIGGER_ID := "Data DD:0:17"

@export var campaign_directory := ""
@export var native_campaign := "City of Bywater"

var campaign_session: ClassicCampaignSession
var host: ClassicRuntimeHost
var automated_smoke := false
var smoke_failures: Array[String] = []


func _ready() -> void:
	call_deferred("_start_playtest")


func _start_playtest() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--smoke":
			automated_smoke = true
		else:
			campaign_directory = argument
	if automated_smoke:
		get_window().size = Vector2i(1100, 619)
	if campaign_directory.is_empty():
		_fail("load_bundle", "Pass a fresh City of Bywater bundle directory")
		_finish_smoke()
		return

	var resources: CampaignResources = NodeAccess.__Resources()
	GameGlobal.set_current_campaign(native_campaign)
	resources.load_campaign_ressources(native_campaign)
	_create_playtest_party()
	UI.show_only(UI.ow_hud)
	NodeAccess.__Map().show()

	if not _load_session():
		_finish_smoke()
		return
	var start_result := campaign_session.activate_start_location()
	_move_to_trigger()
	_verify_stage(
		"01_city_entry",
		str(start_result.get("status", "")) != "error"
			and GameGlobal.currentmap_name == "map_0"
			and _native_position() == TRIGGER_POSITION,
		"the fresh City bundle enters native map_0 at the authored battle trigger"
	)
	if not smoke_failures.is_empty():
		_finish_smoke()
		return

	if not _verify_native_monster_mapping(resources):
		_finish_smoke()
		return
	resources.battles_book.erase("Battle_%d" % BATTLE_ID)
	if not host.start_trigger(TRIGGER_ID):
		_fail("start_trigger", str(host.runtime.last_result))
		_finish_smoke()
		return

	if not await _dismiss_message(FIRST_MESSAGE):
		_fail("02_authored_presentation", "the first authored message did not open")
		_finish_smoke()
		return
	if not await _dismiss_message(SECOND_MESSAGE):
		_fail("02_authored_presentation", "the second authored message did not open")
		_finish_smoke()
		return
	if not await _dismiss_message(MAP_GAINED_MESSAGE):
		_fail("02_authored_presentation", "the acquired-map notice did not open")
		_finish_smoke()
		return
	if not await _wait_for_combat():
		_fail("03_source_battle", _combat_diagnostic())
		_finish_smoke()
		return

	var battle: Dictionary = resources.battles_book.get("Battle_%d" % BATTLE_ID, {})
	_verify_stage(
		"02_authored_presentation",
		host.runtime.runtime_state.is_map_owned(4),
		"the pre-battle action list acquires City player map 4"
	)
	_verify_stage(
		"03_source_battle",
		int(battle.get("classicBattleId", -1)) == BATTLE_ID
			and battle.get("Creatures", []).size() == EXPECTED_ENEMY_COUNT
			and _classic_enemy_count(MONSTER_ID) == EXPECTED_ENEMY_COUNT,
		"the compiled 24-Krise formation materializes into the native battle roster"
	)
	if not automated_smoke:
		await _wait_frames(120)

	call_deferred("_request_victory")
	if automated_smoke:
		await _finish_victory_and_reload()


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


func _finish_victory_and_reload() -> void:
	if not await _wait_for_treasure():
		_fail("04_victory", "the battle reward screen did not open")
		_finish_smoke()
		return
	UI.ow_hud.treasureControl.find_child("ButtonDone").pressed.emit()
	if not await _wait_for_allies():
		_fail("04_victory", "the post-battle allies screen did not open")
		_finish_smoke()
		return
	UI.ow_hud.alliesCtrl.okbutton.pressed.emit()
	if not await _dismiss_message(RETURN_MESSAGE):
		_fail("05_outer_resume", "the authored post-battle message did not open")
		_finish_smoke()
		return
	if not await _wait_for_treasure():
		_fail("05_outer_resume", "authored treasure 11 did not open")
		_finish_smoke()
		return
	if not await _loot_item("Personal Items"):
		_fail("05_outer_resume", "treasure 11 did not offer mapped item 807")
		_finish_smoke()
		return
	UI.ow_hud.treasureControl.find_child("ButtonDone").pressed.emit()
	if not await _wait_for_playthrough_completion():
		_fail("05_outer_resume", "the City action list did not complete")
		_finish_smoke()
		return

	var state: ClassicRuntimeState = host.runtime.runtime_state
	var action_point_override := state.get_action_point_override(MUTATED_TRIGGER_ID)
	_verify_stage(
		"04_victory",
		not StateMachine.is_combat_state() and GameGlobal.currentmap_name == "map_0",
		"native victory cleanup returns the party to City exploration"
	)
	_verify_stage(
		"05_outer_resume",
		state.get_trigger_percent("land", 0, 17, -1) == 100
			and not action_point_override.is_empty(),
		"victory awards mapped treasure 11, then applies both authored map mutations"
	)

	var save_result: Dictionary = campaign_session.make_save_result()
	var serialized := JSON.stringify(save_result.get("payload", {}))
	var saved_payload: Variant = JSON.parse_string(serialized)
	_verify_stage(
		"06_save_envelope",
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
		"07_session_reload",
		str(restore_result.get("status", "")) == "ok"
			and str(start_result.get("status", "")) != "error"
			and GameGlobal.currentmap_name == "map_0"
			and _native_position() == TRIGGER_POSITION
			and restored_state.is_map_owned(4)
			and acquired_maps.size() == 1
			and int(acquired_maps[0].get("record", {}).get("id", -1)) == 4
			and restored_state.get_trigger_percent("land", 0, 17, -1) == 100
			and not restored_override.is_empty()
			and not campaign_session.has_pending_continuation(),
		"a fresh session restores the City map, acquired map, and post-battle mutations"
	)
	_finish_smoke()


func _request_victory() -> void:
	await GameGlobal.end_battle("won")


func _move_to_trigger() -> void:
	host.runtime.runtime_state.set_location(
		"land",
		0,
		TRIGGER_POSITION.x,
		TRIGGER_POSITION.y
	)
	var map: Node = NodeAccess.__Map()
	for character: Node in [map.focuscharacter, map.owcharacter]:
		if character != null and character.has_method("set_tile_position"):
			character.set_tile_position(Vector2(TRIGGER_POSITION))
	map.explore_tiles_from_tilepos(TRIGGER_POSITION)


func _create_playtest_party() -> void:
	var character: PlayerCharacter = GameGlobal.playerCharacterGD.new(
		{
			"name": "City Acceptance Rogue",
			"level": 8,
			"exp_tnl": 10000,
		},
		DefaultIcon,
		DefaultPortrait,
		RogueClass,
		HumanRace
	)
	GameGlobal.player_characters.clear()
	GameGlobal.player_allies.clear()
	GameGlobal.player_characters.append(character)
	UI.ow_hud.fillCharactersRect()
	UI.ow_hud.selected_character = character


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


func _dismiss_message(prefix: String) -> bool:
	for _frame: int in 600:
		if UI.ow_hud.textRect.visible \
				and UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(prefix):
			UI.ow_hud.textRect.disablerButton.pressed.emit()
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


func _loot_item(item_name: String) -> bool:
	var container: GridContainer = UI.ow_hud.treasureControl.itemsContainer
	if container.get_child_count() != 1:
		return false
	var character: PlayerCharacter = GameGlobal.player_characters[0]
	UI.ow_hud.selected_character = character
	var item_button: Button = container.get_child(0)
	item_button.pressed.emit()
	await get_tree().process_frame
	for item: Dictionary in character.inventory:
		if str(item.get("name", "")) == item_name:
			return true
	return false


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
		"City battle acceptance complete.\n"
		+ "Battle 45 returned to exploration and its authored mutations survived reload."
	)
