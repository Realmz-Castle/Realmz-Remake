extends Node

const HostScript = preload("res://scripts/classic_runtime/classic_runtime_host.gd")
const AdapterScript = preload("res://scripts/classic_runtime/classic_godot_command_adapter.gd")
const AcceptanceAssets = preload(
	"res://scripts/classic_runtime/classic_acceptance_assets.gd"
)
const BundleScript = preload("res://scripts/classic_runtime/classic_campaign_bundle.gd")
const BestiaryMaterializerScript = preload(
	"res://scripts/classic_runtime/classic_bestiary_materializer.gd"
)
const CampaignPackageInstallerScript = preload(
	"res://scripts/classic_runtime/classic_campaign_package_installer.gd"
)
const CombatRoutRulesScript = preload(
	"res://scripts/classic_runtime/classic_combat_rout_rules.gd"
)
const RogueClass = preload("res://Data/Character Classes/Class_Assassin.gd")
const HumanRace = preload("res://Data/Character Races/Race_Human.gd")

const TRIGGER_ID := "Data DD:0:7"
const BATTLE_ID := 7
const ROUND_MESSAGE := "The battle-round macro runs."
const DEATH_MESSAGE := "The Arcanist's death macro runs."
const EXPECTED_MONSTER_IDS: Array[int] = [201, 202, 203, 204, 205]
const HOSTILE_MONSTER_IDS: Array[int] = [201, 202, 203, 205]

@export_dir var campaign_directory := \
	"res://scripts/classic_runtime/tests/fixtures/custom_monster_battle"
@export var native_campaign := "City of Bywater"

var host: ClassicRuntimeHost
var automated_smoke := false
var smoke_failures: Array[String] = []
var generated_root := ""
var playthrough_finished := false
var playthrough_result: Dictionary = {}


func _ready() -> void:
	call_deferred("_start_acceptance")


func _start_acceptance() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--smoke":
			automated_smoke = true
		else:
			campaign_directory = argument
	if automated_smoke:
		get_window().size = Vector2i(1100, 619)
	GameGlobal.gamespeed = 0.001
	seed(409)

	var resources: CampaignResources = NodeAccess.__Resources()
	GameGlobal.set_current_campaign(native_campaign)
	resources.load_campaign_ressources(native_campaign)
	_create_playtest_party()
	UI.show_only(UI.ow_hud)
	NodeAccess.__Map().show()

	var bundle = BundleScript.new()
	if not bundle.load_from_directory(campaign_directory):
		_fail("01_generated_bestiary", bundle.last_error)
		_finish()
		return
	generated_root = ProjectSettings.globalize_path(
		"user://classic-custom-monster-acceptance-%d" % Time.get_ticks_msec()
	)
	DirAccess.make_dir_recursive_absolute(generated_root)
	var materialize_result: Dictionary = BestiaryMaterializerScript.new().materialize(
		bundle,
		generated_root
	)
	if str(materialize_result.get("status", "")) != "ok":
		_fail("01_generated_bestiary", str(materialize_result))
		_finish()
		return
	resources.load_bestiary_resources(generated_root.path_join("Bestiary") + "/")
	_verify_stage(
		"01_generated_bestiary",
		int(materialize_result.get("generated", 0)) == EXPECTED_MONSTER_IDS.size()
			and _resources_have_definitions(resources),
		"all five compiled definitions load through Remake's campaign resource path"
	)
	if not smoke_failures.is_empty():
		_finish()
		return

	host = HostScript.new()
	add_child(host)
	host.configure(AdapterScript.new())
	host.playthrough_completed.connect(_on_playthrough_completed)
	host.playthrough_stopped.connect(_on_playthrough_stopped)
	if not host.load_campaign(campaign_directory):
		_fail("02_native_battle", host.runtime.bundle.last_error)
		_finish()
		return
	GameGlobal.register_classic_runtime_host(host)
	var start_result: Dictionary = host.activate_start_location()
	if str(start_result.get("status", "")) == "error":
		_fail("02_native_battle", str(start_result))
		_finish()
		return

	resources.battles_book.erase("Battle_%d" % BATTLE_ID)
	if not host.start_trigger(TRIGGER_ID):
		_fail("02_native_battle", str(host.runtime.last_result))
		_finish()
		return
	if not await _wait_for_combat():
		_fail("02_native_battle", "the compiled custom battle did not enter native combat")
		_finish()
		return

	var roster := _classic_roster()
	_verify_stage(
		"02_native_battle",
		roster.size() == EXPECTED_MONSTER_IDS.size()
			and _roster_has_expected_ids(roster),
		"Battle_7 creates the five compiled monsters on Remake's live combat grid"
	)
	_verify_stage(
		"03_live_definitions",
		_live_definitions_match(roster),
		"live creatures retain source factions, spells, equipment, saves, and combat metadata"
	)
	if not smoke_failures.is_empty():
		_finish()
		return
	var runner: Creature = roster[205]
	if not _stage_runner_near_exit(runner):
		_fail("04_native_actions", "no open Classic battlefield exit lane was available")
		_finish()
		return
	if not await _wait_for_runner_exit(runner):
		_fail("04_native_actions", "the active run threshold did not route Monster 205")
		_finish()
		return
	_verify_stage(
		"04_native_actions",
		CombatRoutRulesScript.is_routed(runner)
			and not _classic_roster().has(205)
			and _dead_enemy_ids().has(205),
		"native turns execute and the source run threshold resolves Monster 205 as a fled enemy"
	)
	if not await _wait_for_player_turn():
		_fail("05_round_macro", "native combat did not complete its first round")
		_finish()
		return
	StateMachine.cb_decide_state.end_active_creature_turn(true)
	if not await _dismiss_message(ROUND_MESSAGE):
		_fail("05_round_macro", "the second native round did not dispatch Extra Action Point 961")
		_finish()
		return
	_verify_stage(
		"05_round_macro",
		int(StateMachine.combat_state.cur_battle_round) == 2,
		"the compiled recurring macro runs after the first completed native round"
	)

	var hostiles_defeated := true
	var live_roster := _classic_roster()
	for monster_id: int in [201, 202, 203]:
		var hostile: Creature = live_roster.get(monster_id)
		if hostile != null:
			hostile.change_cur_hp(-999999999)
			hostiles_defeated = (
				hostiles_defeated
				and hostile.get_stat("curHP") <= 0
				and is_instance_valid(hostile.combat_button)
				and hostile.combat_button.creature == hostile
			)
		else:
			hostiles_defeated = false
	if not hostiles_defeated:
		_fail("06_death_macro", "the deterministic defeat setup did not reduce each hostile to zero HP")
		_finish()
		return
	var death_macro_completed := await _dismiss_message(DEATH_MESSAGE)
	if not death_macro_completed:
		_fail("06_death_macro", "the defeated Arcanist did not dispatch Extra Action Point 960")
		_finish()
		return
	_verify_stage(
		"06_death_macro",
		death_macro_completed,
		"native death processing queues and completes the compiled monster macro"
	)
	if not await _finish_victory_flow():
		_finish()
		return
	_verify_stage(
		"07_victory_resume",
		playthrough_finished
			and str(playthrough_result.get("status", "")) == "completed"
			and str(playthrough_result.get("reason", "")) == "keep-codes"
			and not StateMachine.is_combat_state()
			and GameGlobal.currentmap_name == "map_0",
		"victory completes loot and allies cleanup, then resumes the outer action list"
	)
	_finish()


func _create_playtest_party() -> void:
	var character: PlayerCharacter = GameGlobal.playerCharacterGD.new(
		{
			"name": "Custom Monster Acceptance Rogue",
			"level": 8,
			"exp_tnl": 10000,
		},
		AcceptanceAssets.player_icon(),
		AcceptanceAssets.classic_portrait_257(),
		RogueClass,
		HumanRace
	)
	character.base_stats["maxHP"] = 5000
	character.stats["maxHP"] = 5000
	character.stats["curHP"] = 5000
	character.base_stats["Dexterity"] = 1
	character.stats["Dexterity"] = 1
	GameGlobal.player_characters.clear()
	GameGlobal.player_allies.clear()
	GameGlobal.player_characters.append(character)
	UI.ow_hud.fillCharactersRect()
	UI.ow_hud.selected_character = character


func _classic_roster() -> Dictionary:
	var roster: Dictionary = {}
	if not StateMachine.is_combat_state():
		return roster
	for button: Variant in StateMachine.combat_state.all_battle_creatures_btns:
		if not is_instance_valid(button):
			continue
		var creature: Variant = button.get("creature")
		if creature is Object:
			var monster_id := int(creature.get_meta("classic_monster_id", -1))
			if monster_id >= 0:
				roster[monster_id] = creature
	return roster


func _resources_have_definitions(resources: CampaignResources) -> bool:
	for monster_id: int in EXPECTED_MONSTER_IDS:
		if not resources.crea_book.has("Classic Monster %d" % monster_id):
			return false
	return true


func _roster_has_expected_ids(roster: Dictionary) -> bool:
	for monster_id: int in EXPECTED_MONSTER_IDS:
		if not roster.has(monster_id):
			return false
	return true


func _live_definitions_match(roster: Dictionary) -> bool:
	var arcanist: Creature = roster.get(201)
	var skirmisher: Creature = roster.get(202)
	var summoner: Creature = roster.get(203)
	var turncoat: Creature = roster.get(204)
	var runner: Creature = roster.get(205)
	if arcanist == null or skirmisher == null or summoner == null \
			or turncoat == null or runner == null:
		return false
	for monster_id: int in HOSTILE_MONSTER_IDS:
		if int(roster[monster_id].curFaction) != 1:
			return false
	if int(turncoat.curFaction) != 0:
		return false
	if arcanist.get_stat("MaxActions") != 2 \
			or int(arcanist.get_meta("classic_death_macro", 0)) != 960 \
			or int(arcanist.get_meta("classic_magic_resistance", 0)) != 25 \
			or _spell_count(arcanist) != 2:
		return false
	if skirmisher.inventory.size() < 2 \
			or int(skirmisher.inventory[1].get("classic_item_slot", -1)) != 1 \
			or str(skirmisher.get_meta("classic_missile_item_name", "")) \
				!= "Staff of Fireballs +1":
		return false
	if int(summoner.get_meta("classic_can_summon", 0)) != 1 \
			or _spell_count(summoner) != 1:
		return false
	return int(runner.get_meta("classic_run_percent", 0)) == 101


func _spell_count(creature: Creature) -> int:
	var count := 0
	for school: Variant in creature.spells:
		if school is Array:
			count += school.size()
	return count


func _dead_enemy_ids() -> Array[int]:
	var result: Array[int] = []
	for creature: Variant in StateMachine.combat_state.battle_dead_enemies:
		if creature is Object:
			var monster_id := int(creature.get_meta("classic_monster_id", -1))
			if monster_id >= 0:
				result.append(monster_id)
	return result


func _wait_for_combat() -> bool:
	for _frame: int in 1200:
		if StateMachine.is_combat_state() \
				and int(StateMachine.combat_state.cur_battle_data.get(
					"classicBattleId", -1
				)) == BATTLE_ID \
				and StateMachine.combat_state.all_battle_creatures_btns.size() \
					== EXPECTED_MONSTER_IDS.size() + 1:
			return true
		await get_tree().process_frame
	return false


func _stage_runner_near_exit(runner: Creature) -> bool:
	# Classic retreats across its full 90x90 combat field. Keep the live check
	# bounded by staging the already-materialized runner one move from that edge.
	var map_size := Vector2i(GameGlobal.map.map_size)
	if map_size.x < 5 or map_size.y < 5:
		return false
	var enemy_center := Vector2.ZERO
	var enemy_count := 0
	for button: Variant in StateMachine.combat_state.all_battle_creatures_btns:
		if not is_instance_valid(button) or button.creature.curFaction == runner.curFaction:
			continue
		enemy_center += button.creature.position
		enemy_count += 1
	if enemy_count == 0:
		return false
	enemy_center /= enemy_count

	var candidates: Array[Vector2i] = []
	var horizontal_edge := map_size.x - 3 if enemy_center.x < map_size.x / 2.0 else 2
	var vertical_edge := map_size.y - 3 if enemy_center.y < map_size.y / 2.0 else 2
	for y: int in range(2, map_size.y - 2):
		candidates.append(Vector2i(horizontal_edge, y))
	for x: int in range(2, map_size.x - 2):
		candidates.append(Vector2i(x, vertical_edge))

	var combat_state: CombatState = StateMachine.combat_state
	var combat_button: CombatCreaButton = runner.combat_button
	for candidate: Vector2i in candidates:
		var direction := Vector2i((Vector2(candidate) - enemy_center).normalized().round())
		var destination := candidate + direction
		if direction == Vector2i.ZERO:
			continue
		if not combat_state.can_place_creature_at(runner, candidate):
			continue
		if not combat_state.can_place_creature_at(runner, destination):
			continue
		var move_check: Array = combat_state.on_trying_to_move_to_position(
			runner,
			destination,
			true
		)
		if not bool(move_check[0]):
			continue
		runner.position = candidate
		combat_button.set_creature_represented(runner)
		return true
	return false


func _wait_for_runner_exit(runner: Creature) -> bool:
	for _frame: int in 12000:
		if CombatRoutRulesScript.is_routed(runner) and not _classic_roster().has(205):
			return true
		await get_tree().process_frame
	return false


func _wait_for_player_turn(minimum_round := 0) -> bool:
	for _frame: int in 2400:
		if StateMachine._state_name == "CbDecideAction" \
				and StateMachine.combat_state.cur_battle_round >= minimum_round:
			var active: Variant = StateMachine.cb_decide_state.current_active_creabutton
			if is_instance_valid(active) \
					and StateMachine.combat_state.battle_creatures_yet_to_act_btns.has(
						active
					) \
					and active.creature.is_crea_player_controlled():
				return true
		await get_tree().process_frame
	return false


func _dismiss_message(prefix: String) -> bool:
	for _frame: int in 2400:
		if UI.ow_hud.textRect.visible \
				and UI.ow_hud.textRect.textLabel.get_parsed_text().begins_with(prefix):
			UI.ow_hud.textRect.disablerButton.pressed.emit()
			return true
		await get_tree().process_frame
	return false


func _finish_victory_flow() -> bool:
	if not await _wait_for_control(UI.ow_hud.treasureControl):
		_fail("07_victory_resume", "the native reward screen did not open")
		return false
	UI.ow_hud.treasureControl.find_child("ButtonDone").pressed.emit()
	if not await _wait_for_control(UI.ow_hud.alliesWindow):
		_fail("07_victory_resume", "the native allies screen did not open")
		return false
	UI.ow_hud.alliesCtrl.okbutton.pressed.emit()
	for _frame: int in 2400:
		if playthrough_finished:
			return true
		await get_tree().process_frame
	_fail("07_victory_resume", "the outer Classic trigger did not resume")
	return false


func _wait_for_control(control: Node) -> bool:
	for _frame: int in 2400:
		if control.visible:
			return true
		await get_tree().process_frame
	return false


func _on_playthrough_completed(result: Dictionary) -> void:
	playthrough_result = result.duplicate(true)
	playthrough_finished = true


func _on_playthrough_stopped(result: Dictionary) -> void:
	_fail("runtime", str(result.get("message", result)))
	playthrough_result = result.duplicate(true)
	playthrough_finished = true


func _verify_stage(stage_name: String, passed: bool, detail: String) -> void:
	if passed:
		print("CLASSIC_CUSTOM_MONSTER_STAGE PASS: %s - %s" % [stage_name, detail])
		return
	_fail(stage_name, detail)


func _fail(stage_name: String, detail: String) -> void:
	if not smoke_failures.has(stage_name):
		smoke_failures.append(stage_name)
	push_error("CLASSIC_CUSTOM_MONSTER_STAGE FAIL: %s - %s" % [stage_name, detail])


func _finish() -> void:
	if is_instance_valid(host):
		GameGlobal.clear_classic_runtime_host(host)
	if not generated_root.is_empty() and DirAccess.dir_exists_absolute(generated_root):
		var cleanup_error := CampaignPackageInstallerScript.new()._remove_directory(
			generated_root
		)
		if cleanup_error != OK:
			_fail("cleanup", "generated bestiary cleanup returned %s" % cleanup_error)
	if automated_smoke:
		get_tree().quit(0 if smoke_failures.is_empty() else 1)
	elif smoke_failures.is_empty():
		UI.ow_hud.textRect.show()
		UI.ow_hud.textRect.set_text(
			"Classic custom-monster battle acceptance complete.\n"
			+ "The generated bestiary fought through native turns, morale, death macros, "
			+ "rewards, and outer-script resumption."
		)
