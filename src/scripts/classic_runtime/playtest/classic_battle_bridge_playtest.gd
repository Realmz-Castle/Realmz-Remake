extends Node

const HostScript = preload("res://scripts/classic_runtime/classic_runtime_host.gd")
const AdapterScript = preload("res://scripts/classic_runtime/classic_godot_command_adapter.gd")
const AcceptanceAssets = preload(
	"res://scripts/classic_runtime/classic_acceptance_assets.gd"
)
const RogueClass = preload("res://Data/Character Classes/Class_Assassin.gd")
const HumanRace = preload("res://Data/Character Races/Race_Human.gd")

const OUTER_TRIGGER := "Data DD:0:200"
const COMBAT_MACRO_TRIGGER := "Data ED3:macro:900"
const COMBAT_SPAWN_TRIGGER := "Data ED3:macro:901"
const BATTLE_ID := 24
const RETURN_MESSAGE := "The party returns to the snowy road."

@export_dir var campaign_directory := \
	"res://scripts/classic_runtime/tests/fixtures/native_battle_bridge"
@export var native_campaign := "City of Bywater"

var host: ClassicRuntimeHost
var automated_smoke := false
var smoke_failures: Array[String] = []
var smoke_capture_directory := ""
var initial_position := Vector2i.ZERO


func _ready() -> void:
	call_deferred("_start_playtest")


func _start_playtest() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--smoke":
			automated_smoke = true
		elif argument.begins_with("--capture="):
			smoke_capture_directory = argument.trim_prefix("--capture=")
		else:
			campaign_directory = argument
	if automated_smoke:
		get_window().size = Vector2i(1100, 619)

	var resources: CampaignResources = NodeAccess.__Resources()
	GameGlobal.set_current_campaign(native_campaign)
	resources.load_campaign_ressources(native_campaign)
	_create_playtest_party()
	UI.show_only(UI.ow_hud)
	NodeAccess.__Map().show()

	host = HostScript.new()
	add_child(host)
	host.configure(AdapterScript.new())
	host.playthrough_completed.connect(_on_playthrough_completed)
	host.playthrough_stopped.connect(_on_playthrough_stopped)
	if not host.load_campaign(campaign_directory):
		_fail("load_bundle", host.runtime.bundle.last_error)
		_finish_smoke()
		return

	var start_result := host.activate_start_location()
	initial_position = Vector2i(
		host.runtime.runtime_state.x,
		host.runtime.runtime_state.y
	)
	_verify_stage(
		"01_native_map",
		str(start_result.get("status", "")) != "error"
			and GameGlobal.currentmap_name == "map_0"
			and _native_position() == initial_position,
		"the compiled fixture starts at its native map position"
	)
	if not smoke_failures.is_empty():
		_finish_smoke()
		return

	if not host.start_trigger(OUTER_TRIGGER):
		_fail("start_outer_trigger", str(host.runtime.last_result))
		_finish_smoke()
		return
	if not await _wait_for_combat():
		_fail("02_native_battle", "the native combat state did not initialize")
		_finish_smoke()
		return

	var roster_before := StateMachine.combat_state.all_battle_creatures_btns.size()
	_verify_stage(
		"02_native_battle",
		int(StateMachine.combat_state.cur_battle_data.get("classicBattleId", -1)) == BATTLE_ID
			and roster_before == 4
			and host.runtime.runtime_state.get_landlook("land", 0, 0) == 10,
		"Battle_24 starts through the real combat state after the persistent landlook change"
	)
	if not automated_smoke:
		await _wait_frames(90)

	var spawn_actor: Variant = StateMachine.combat_state.all_battle_creatures_btns[0]
	var spawn_creature: Variant = spawn_actor.get("creature")
	var spawn_result: Dictionary = await host.run_queued_combat_macro(
		{"triggerId": COMBAT_SPAWN_TRIGGER},
		{
			"actorFaction": int(spawn_creature.get("curFaction")),
			"actorPosition": spawn_creature.get("position"),
		}
	)
	var roster_after_spawn := StateMachine.combat_state.all_battle_creatures_btns.size()
	var spawn_presentation: Dictionary = \
		host.command_adapter.last_classic_spawn_presentation
	_verify_stage(
		"03_spawn_presentation",
		bool(spawn_result.get("handled", false))
			and str(spawn_result.get("result", {}).get("status", "")) == "completed"
			and roster_after_spawn == roster_before + 2
			and int(spawn_presentation.get("animated", 0)) == 2
			and int(spawn_presentation.get("soundRepeats", 0)) == 2
			and spawn_presentation.get("events", []) == [
				{"spawnIndex": 0, "event": "sound", "soundId": 640},
				{"spawnIndex": 0, "event": "conjuration"},
				{"spawnIndex": 1, "event": "sound", "soundId": 640},
				{"spawnIndex": 1, "event": "conjuration"},
			],
		"opcode 124 reveals two native combatants in Classic sound-then-effect order"
	)
	await _capture_smoke_stage("03_spawn_presentation")

	var macro_result: Dictionary = await host.run_queued_combat_macro({
		"triggerId": COMBAT_MACRO_TRIGGER,
	})
	var roster_after := StateMachine.combat_state.all_battle_creatures_btns.size()
	_verify_stage(
		"04_combat_macro",
		bool(macro_result.get("handled", false))
			and str(macro_result.get("result", {}).get("status", "")) == "completed"
			and roster_after == roster_before - 2
			and StateMachine.combat_state.battle_dead_enemies.size() == 4,
		"the compiled combat macro removes the original and conjured Zombies through native roster and reward handling"
	)
	if not automated_smoke:
		await _wait_frames(90)

	call_deferred("_request_victory")
	if automated_smoke:
		await _finish_victory_smoke()


func _request_victory() -> void:
	await GameGlobal.end_battle("won")


func _finish_victory_smoke() -> void:
	if not await _wait_for_treasure():
		_fail("05_victory_cleanup", "the victory loot screen did not open")
		_finish_smoke()
		return
	UI.ow_hud.treasureControl.find_child("ButtonDone").pressed.emit()
	if not await _wait_for_allies():
		_fail("05_victory_cleanup", "the post-battle allies screen did not open")
		_finish_smoke()
		return
	UI.ow_hud.alliesCtrl.okbutton.pressed.emit()
	if not await _wait_for_return_message():
		_fail("06_outer_resume", "the outer action list did not resume")
		_finish_smoke()
		return
	_verify_stage(
		"05_victory_cleanup",
		not StateMachine.is_combat_state() and GameGlobal.currentmap_name == "map_0",
		"victory completes the native loot and allies sequence before returning to exploration"
	)
	_verify_stage(
		"06_outer_resume",
		UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(RETURN_MESSAGE),
		"victory resumes the authored outer message"
	)
	UI.ow_hud.textRect.disablerButton.pressed.emit()
	if not await _wait_for_playthrough_completion():
		_fail("07_map_return", "the outer action list did not complete")
		_finish_smoke()


func _on_playthrough_completed(result: Dictionary) -> void:
	_verify_stage(
		"07_map_return",
		str(result.get("status", "")) == "completed"
			and str(result.get("reason", "")) == "keep-codes"
			and GameGlobal.currentmap_name == "map_0"
			and _native_position() == initial_position
			and Vector2i(
				host.runtime.runtime_state.x,
				host.runtime.runtime_state.y
			) == initial_position
			and host.runtime.runtime_state.get_landlook("land", 0, 0) == 10
			and _native_map_uses_tileset("landlook-10"),
		"the party returns to the same native tile with the persistent landlook intact"
	)
	if automated_smoke:
		call_deferred("_finish_smoke")
	else:
		UI.ow_hud.textRect.show()
		UI.ow_hud.textRect.set_text(
			"Classic map/battle bridge playtest complete.\n"
			+ "The combat macro changed the live roster, victory resumed the outer action list, "
			+ "and the party returned to its original snowy map tile."
		)


func _on_playthrough_stopped(result: Dictionary) -> void:
	_fail("runtime", str(result.get("message", result)))
	if automated_smoke:
		call_deferred("_finish_smoke")


func _create_playtest_party() -> void:
	var character: PlayerCharacter = GameGlobal.playerCharacterGD.new(
		{
			"name": "Battle Bridge Rogue",
			"level": 6,
			"exp_tnl": 10000,
		},
		AcceptanceAssets.player_icon(),
		AcceptanceAssets.classic_portrait_257(),
		RogueClass,
		HumanRace
	)
	GameGlobal.player_characters.clear()
	GameGlobal.player_allies.clear()
	GameGlobal.player_characters.append(character)
	UI.ow_hud.fillCharactersRect()
	UI.ow_hud.selected_character = character


func _native_position() -> Vector2i:
	var character: Variant = NodeAccess.__Map().owcharacter
	return Vector2i(character.tile_position_x, character.tile_position_y)


func _native_map_uses_tileset(tileset_name: String) -> bool:
	for column: Array in NodeAccess.__Map().mapdata:
		for cell: Array in column:
			for tile: Dictionary in cell:
				if str(tile.get("tileset_name", "")) == tileset_name:
					return true
	return false


func _wait_for_combat() -> bool:
	for _frame: int in 600:
		if StateMachine.is_combat_state() \
				and int(StateMachine.combat_state.cur_battle_data.get(
					"classicBattleId", -1
				)) == BATTLE_ID \
				and StateMachine.combat_state.all_battle_creatures_btns.size() == 4:
			return true
		await get_tree().process_frame
	return false


func _wait_for_treasure() -> bool:
	for _frame: int in 600:
		if UI.ow_hud.treasureControl.visible:
			return true
		await get_tree().process_frame
	return false


func _wait_for_allies() -> bool:
	for _frame: int in 600:
		if UI.ow_hud.alliesWindow.visible:
			return true
		await get_tree().process_frame
	return false


func _wait_for_return_message() -> bool:
	for _frame: int in 600:
		if UI.ow_hud.textRect.visible \
				and UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(RETURN_MESSAGE):
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


func _verify_stage(stage_name: String, passed: bool, detail: String) -> void:
	if passed:
		print("CLASSIC_BATTLE_STAGE PASS: %s - %s" % [stage_name, detail])
		return
	_fail(stage_name, detail)


func _fail(stage_name: String, detail: String) -> void:
	if not smoke_failures.has(stage_name):
		smoke_failures.append(stage_name)
	push_error("CLASSIC_BATTLE_STAGE FAIL: %s - %s" % [stage_name, detail])


func _finish_smoke() -> void:
	get_tree().quit(0 if smoke_failures.is_empty() else 1)


func _capture_smoke_stage(stage_name: String) -> void:
	if smoke_capture_directory.is_empty():
		return
	DirAccess.make_dir_recursive_absolute(smoke_capture_directory)
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var file_name := "battle_bridge_%s.png" % stage_name.to_snake_case()
	var error := image.save_png(smoke_capture_directory.path_join(file_name))
	if error != OK:
		_fail("capture:%s" % stage_name, "the visual fixture could not be saved")
