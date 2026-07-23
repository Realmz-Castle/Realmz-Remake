extends Node

const FreeFallScript = preload("res://shared_assets/spells/free_fall.gd")
const WaterworldScript = preload("res://shared_assets/spells/waterworld.gd")
const OgreHideScript = preload("res://shared_assets/spells/ogre_hide.gd")
const DiscoverSecretScript = preload("res://shared_assets/spells/discover_secret.gd")
const WizardEyeScript = preload("res://shared_assets/spells/wizard_eye.gd")
const ThoughtLaceScript = preload("res://shared_assets/spells/thought_lace.gd")
const SentryScript = preload("res://shared_assets/spells/sentry.gd")
const CharmFoeScript = preload("res://shared_assets/spells/charm_foe.gd")
const CommandAdapterScript = preload(
	"res://scripts/classic_runtime/classic_godot_command_adapter.gd"
)

var failures: Array[String] = []
var original_time := 0
var original_global_effects: Dictionary = {}
var original_conditions: Dictionary = {}
var original_campaign_global_script: Variant
var original_player_characters: Array = []
var original_player_allies: Array = []
var original_map_secrets: Dictionary = {}
var original_script_areas: Dictionary = {}
var original_explored_tiles: Array = []
var original_map_data: Array = []
var original_sight_dirs: Array = []


class PartyMemberStub:
	extends RefCounted
	var name := "Party member"
	var is_player_controlled: bool

	func _init(player_controlled: bool) -> void:
		is_player_controlled = player_controlled

	func get_stat(stat_name: String) -> float:
		return 1.0 if stat_name == "MultiplierMental" else 0.0


func _ready() -> void:
	call_deferred("_run_smoke")


func _run_smoke() -> void:
	await get_tree().process_frame
	original_time = GameGlobal.time
	original_global_effects = GameGlobal.global_effects.duplicate(true)
	original_conditions = GameGlobal.classic_party_conditions.duplicate(true)
	original_campaign_global_script = GameGlobal.campaign_global_script
	original_player_characters = GameGlobal.player_characters.duplicate()
	original_player_allies = GameGlobal.player_allies.duplicate()
	original_map_secrets = GameGlobal.map.mapsecrets.duplicate(true)
	original_script_areas = GameGlobal.map.mapscriptareas.duplicate(true)
	original_explored_tiles = GameGlobal.map.explored_tiles.duplicate(true)
	original_map_data = GameGlobal.map.mapdata.duplicate(true)
	original_sight_dirs = GameGlobal.map.exploration_sight_dirs.duplicate(true)

	GameGlobal.time = 3500
	GameGlobal.global_effects["FeatherFall"] = {"Duration": 0}
	GameGlobal.global_effects["WaterBreath"] = {"Duration": 0}
	GameGlobal.global_effects["Shielded"] = {"Duration": 0}
	GameGlobal.classic_party_conditions.clear()
	GameGlobal.campaign_global_script = {"has_on_time_pass": false}
	GameGlobal.player_characters.clear()
	GameGlobal.player_allies.clear()

	var command_adapter = CommandAdapterScript.new()
	var waterworld = WaterworldScript.new()
	_expect_equal(
		waterworld.apply_classic_duration(12),
		12,
		"Waterworld reaches the live Classic party-condition state"
	)
	_expect_equal(
		GameGlobal.global_effects["WaterBreath"]["Duration"],
		39700,
		"the exact counter is exposed through Remake's Water Breath duration"
	)
	_expect_equal(
		command_adapter.party_condition_status(1, GameGlobal.global_effects, 0),
		{"supported": true, "active": true},
		"scenario Waterworld checks see the newly cast condition"
	)
	_expect_equal(
		waterworld.apply_classic_duration(8),
		12,
		"a shorter Waterworld recast leaves the live condition unchanged"
	)

	var ogre_hide = OgreHideScript.new()
	_expect_equal(
		ogre_hide.apply_classic_duration(10),
		10,
		"Ogre Hide reaches the live Classic party-condition state"
	)
	_expect_equal(
		GameGlobal.global_effects["Shielded"]["Duration"],
		32500,
		"the exact counter is exposed through Remake's Shielded duration"
	)
	var enemy := PartyMemberStub.new(false)
	var party_member := PartyMemberStub.new(true)
	var protected_damage: Dictionary = GameGlobal.apply_classic_party_weapon_protection(
		{"Physical": 8, "Bonus_dmg": 1, "Chemical": 3, "total": 12},
		enemy,
		party_member
	)
	_expect_equal(
		protected_damage,
		{"Physical": 4, "Bonus_dmg": 0, "Chemical": 3, "total": 7},
		"Ogre Hide reduces an incoming enemy weapon hit without reducing elemental damage"
	)
	_expect_equal(
		GameGlobal.apply_classic_party_weapon_protection(
			{"Physical": 8, "Bonus_dmg": 1, "total": 9},
			party_member,
			party_member
		).get("total"),
		9,
		"Ogre Hide does not reduce a party member's friendly attack"
	)

	var free_fall = FreeFallScript.new()
	_expect_equal(
		free_fall.apply_classic_duration(5),
		5,
		"the native spell resource reaches the live Classic condition state"
	)
	_expect_equal(
		GameGlobal.global_effects["FeatherFall"]["Duration"],
		14500,
		"the exact counter is exposed through Remake's Feather Fall duration"
	)
	_expect_equal(
		free_fall.apply_classic_duration(3),
		5,
		"a shorter recast leaves the live condition unchanged"
	)

	GameGlobal.reduce_classic_party_conditions(2)
	_expect_equal(
		GameGlobal.classic_party_conditions.get("6"),
		3,
		"combat-round reduction updates the exact Classic counter"
	)

	var saved_conditions := GameGlobal.classic_party_conditions.duplicate(true)
	GameGlobal.classic_party_conditions.clear()
	GameGlobal.global_effects["FeatherFall"]["Duration"] = 0
	GameGlobal._restore_classic_party_conditions(saved_conditions)
	_expect_equal(
		GameGlobal.classic_party_conditions.get("6"),
		3,
		"the Classic counter survives its save payload round trip"
	)
	_expect_equal(
		GameGlobal.global_effects["FeatherFall"]["Duration"],
		7300,
		"restoring the exact counter also restores its native HUD duration"
	)

	GameGlobal.time = 3600
	GameGlobal._advance_classic_party_conditions(3500, GameGlobal.time)
	_expect_equal(
		GameGlobal.classic_party_conditions.get("6"),
		2,
		"crossing a game-hour boundary reduces the live condition once"
	)
	_expect_equal(
		GameGlobal.global_effects["FeatherFall"]["Duration"],
		7200,
		"hourly reduction remains synchronized with the native display"
	)

	var secret_position := Vector2i(89, 89)
	GameGlobal.map.mapsecrets[secret_position] = [0, "TestSecret", 0.25]
	GameGlobal.global_effects["Awareness"] = {"Duration": 0}
	_expect_equal(
		GameGlobal.map_secret_detection_succeeds(secret_position, 0.2),
		true,
		"a native secret roll below its detection chance succeeds"
	)
	_expect_equal(
		GameGlobal.map_secret_detection_succeeds(secret_position, 0.5),
		false,
		"a failed native secret roll remains hidden without Awareness"
	)
	var discover_secret = DiscoverSecretScript.new()
	_expect_equal(
		discover_secret.apply_classic_duration(7),
		7,
		"Discover Secret reaches the live Classic Awareness condition"
	)
	_expect_equal(
		GameGlobal.map_secret_detection_succeeds(secret_position, 0.5),
		true,
		"Classic Awareness guarantees the native secret-detection check"
	)
	GameGlobal.set_classic_search_enabled(true)
	_expect_equal(
		GameGlobal.classic_party_conditions.get("5"),
		-1,
		"the live Search control stores Classic's permanent signed toggle"
	)
	_expect_equal(
		GameGlobal.map_secret_detection_succeeds(secret_position, 1.0),
		true,
		"Search guarantees the native secret-detection check"
	)
	_expect_equal(
		command_adapter.party_condition_status(
			5,
			GameGlobal.global_effects,
			GameGlobal.classic_light_condition,
			GameGlobal.classic_party_conditions
		),
		{"supported": true, "active": true},
		"scenario condition branches read the exact Search slot"
	)
	var search_time_before := GameGlobal.time
	var expected_search_time := (
		search_time_before + roundi(4 * GameGlobal.time_scale)
	)
	GameGlobal.apply_classic_search_time_cost()
	_expect_equal(
		GameGlobal.time,
		expected_search_time,
		"each live Search pass pays Classic's four-tick time cost"
	)
	GameGlobal.reduce_classic_party_conditions(4)
	GameGlobal._advance_classic_party_conditions(3600, 7200)
	_expect_equal(
		GameGlobal.classic_party_conditions.get("5"),
		-1,
		"Search remains enabled across combat and field condition reduction"
	)
	var search_save := GameGlobal.classic_party_conditions.duplicate(true)
	GameGlobal.set_classic_search_enabled(false)
	GameGlobal._restore_classic_party_conditions(search_save)
	_expect_equal(
		GameGlobal.classic_party_conditions.get("5"),
		-1,
		"Search survives the normal party-condition save payload"
	)
	GameGlobal.set_classic_search_enabled(false)

	GameGlobal.global_effects["Scrying"] = {"Duration": 0}
	GameGlobal.map.exploration_sight_dirs = [Vector2(1, 0)]
	GameGlobal.map.mapdata = []
	for x in range(6):
		GameGlobal.map.mapdata.append([[{"blkview": x == 1}]])
	GameGlobal.map.explored_tiles = [[0, 0, 0, 0, 0, 0]]
	GameGlobal.map.explore_tiles_from_tilepos(Vector2.ZERO)
	_expect_equal(
		GameGlobal.map.explored_tiles[0][2],
		0,
		"ordinary exploration sight stops after a blocking tile"
	)
	var wizard_eye = WizardEyeScript.new()
	_expect_equal(
		wizard_eye.apply_classic_duration(12),
		12,
		"Wizard Eye reaches the live Classic Scrying condition"
	)
	GameGlobal.map.explored_tiles = [[0, 0, 0, 0, 0, 0]]
	GameGlobal.map.explore_tiles_from_tilepos(Vector2.ZERO)
	_expect_equal(
		GameGlobal.map.explored_tiles[0][5],
		1,
		"Wizard Eye lets the live exploration ray pass through blocking tiles"
	)

	GameGlobal.global_effects["CharmProt"] = {"Duration": 0}
	_expect_equal(
		GameGlobal.classic_party_charm_resistance_bonus(party_member),
		0,
		"party members receive no charm bonus without Thought Lace"
	)
	var thought_lace = ThoughtLaceScript.new()
	_expect_equal(
		thought_lace.apply_classic_duration(3),
		3,
		"Thought Lace reaches the live Classic Charm Protection condition"
	)
	_expect_equal(
		GameGlobal.classic_party_charm_resistance_bonus(party_member),
		50,
		"Thought Lace grants the source fifty-point charm-save bonus"
	)
	_expect_equal(
		GameGlobal.classic_party_charm_resistance_bonus(PartyMemberStub.new(false)),
		0,
		"party charm protection does not affect non-player combatants"
	)
	var charm_resolution: Dictionary = command_adapter.classic_field_spell_target_resolution(
		{"power": 1}, party_member, CharmFoeScript.new(), 100, 100, 50
	)
	_expect_equal(
		charm_resolution.get("preResistanceChance"),
		50,
		"compiled spell resolution receives the active Thought Lace bonus"
	)
	_expect_equal(
		charm_resolution.get("resisted"),
		true,
		"Thought Lace stops a matching charm roll in compiled spell resolution"
	)

	GameGlobal.global_effects["Sentry"] = {"Duration": 0}
	_expect_equal(
		GameGlobal.random_battles_allowed(),
		true,
		"wandering battles remain available without Sentry"
	)
	var sentry = SentryScript.new()
	_expect_equal(
		sentry.apply_classic_duration(48),
		48,
		"Sentry reaches the live Classic party condition"
	)
	_expect_equal(
		GameGlobal.random_battles_allowed(),
		false,
		"active Sentry suppresses wandering battles"
	)
	GameGlobal.map.mapscriptareas = {
		"SentryRandomBattle": {
			"scriptRectangle": [[50, 50], [50, 50]],
			"scriptToLoad": [],
			"chance": 1.0,
			"RR_Battle": {"battle_range": [-1, -1]},
		},
	}
	_expect_equal(
		await StateMachine.check_map_script(Vector2i(50, 50)),
		true,
		"the live map path skips an eligible wandering battle while Sentry is active"
	)

	GameGlobal.set_classic_party_condition(2, -1)
	GameGlobal.reduce_classic_party_conditions(10)
	GameGlobal._advance_classic_party_conditions(7200, 10800)
	_expect_equal(
		GameGlobal.classic_party_conditions.get("2"),
		-1,
		"permanent Dragon Hide survives both reduction paths"
	)
	_expect_equal(
		GameGlobal.global_effects["Shielded"]["Duration"],
		2147483647,
		"permanent Dragon Hide stays active for native HUD consumers"
	)
	_expect_equal(
		GameGlobal.apply_classic_party_weapon_protection(
			{"Physical": 8, "Bonus_dmg": 1, "total": 9},
			enemy,
			party_member
		).get("total"),
		4,
		"permanent Dragon Hide continues reducing enemy weapon damage"
	)
	GameGlobal.set_classic_party_condition(9, -1)
	var complete_condition_save := (
		GameGlobal.classic_party_conditions.duplicate(true)
	)
	GameGlobal.classic_party_conditions.clear()
	GameGlobal._restore_classic_party_conditions(complete_condition_save)
	_expect_equal(
		GameGlobal.classic_party_conditions.get("9"),
		-1,
		"the source-unused tenth slot is preserved without invented mechanics"
	)

	_finish()


func _expect_equal(actual: Variant, expected: Variant, description: String) -> void:
	if actual == expected:
		print("PASS: %s" % description)
		return
	failures.append("%s (expected %s, got %s)" % [description, expected, actual])
	push_error("FAIL: %s" % failures[-1])


func _finish() -> void:
	GameGlobal.time = original_time
	GameGlobal.global_effects = original_global_effects
	GameGlobal.classic_party_conditions = original_conditions
	GameGlobal.campaign_global_script = original_campaign_global_script
	GameGlobal.player_characters = original_player_characters
	GameGlobal.player_allies = original_player_allies
	GameGlobal.map.mapsecrets = original_map_secrets
	GameGlobal.map.mapscriptareas = original_script_areas
	GameGlobal.map.explored_tiles = original_explored_tiles
	GameGlobal.map.mapdata = original_map_data
	GameGlobal.map.exploration_sight_dirs = original_sight_dirs
	if failures.is_empty():
		print("Classic party-condition smoke passed.")
		get_tree().quit(0)
		return
	printerr("Classic party-condition smoke failed: %s" % "; ".join(failures))
	get_tree().quit(1)
