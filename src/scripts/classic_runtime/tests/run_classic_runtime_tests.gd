extends SceneTree

const BundleScript = preload("res://scripts/classic_runtime/classic_campaign_bundle.gd")
const StateScript = preload("res://scripts/classic_runtime/classic_runtime_state.gd")
const InterpreterScript = preload("res://scripts/classic_runtime/classic_action_interpreter.gd")
const RogueResolverScript = preload("res://scripts/classic_runtime/classic_rogue_encounter_resolver.gd")
const InventoryRulesScript = preload("res://scripts/classic_runtime/classic_inventory_rules.gd")
const RuntimeScript = preload("res://scripts/classic_runtime/classic_runtime.gd")
const HostScript = preload("res://scripts/classic_runtime/classic_runtime_host.gd")
const GodotAdapterScript = preload("res://scripts/classic_runtime/classic_godot_command_adapter.gd")
const BattleRewardRulesScript = preload("res://scripts/battle_reward_rules.gd")
const ShopRulesScript = preload("res://scripts/shop_rules.gd")
const TemplePaymentScript = preload("res://scenes/UI/HUD/Temple/temple_payment.gd")
const SpellIdsScript = preload("res://scripts/spells_id_divinity.gd")
const ItemIdsScript = preload("res://scripts/item_id_divinity.gd")
const FIXTURE := "res://scripts/classic_runtime/tests/fixtures/cob_vertical_slice"
const WAR_IN_THE_SWORD_LANDS_GOSUB_FIXTURE := \
	"res://scripts/classic_runtime/tests/fixtures/war_in_the_sword_lands_gosub"
const TWIN_SANDS_OPCODE_25_FIXTURE := \
	"res://scripts/classic_runtime/tests/fixtures/twin_sands_opcode_25"
const COB_SPOKEN_WORD_FIXTURE := \
	"res://scripts/classic_runtime/tests/fixtures/cob_spoken_word"

var failures := 0


class GuardHouseAdapter:
	extends RefCounted
	var commands: Array = []

	func execute_command(command: String, payload: Dictionary) -> Dictionary:
		commands.append({"command": command, "payload": payload})
		if command == "start_encounter":
			return {"outcome": 4}
		if command == "check_party_item":
			return {"possessed": true}
		if command == "check_party_condition":
			return {"active": true}
		if command == "check_party_ally":
			return {"present": true}
		if command == "check_combat_monster":
			return {"present": true}
		return {}


class RejectingAdapter:
	extends RefCounted

	func execute_command(command: String, _payload: Dictionary) -> Dictionary:
		return {
			"status": "error",
			"message": "Rejected %s for test" % command,
		}


class RogueTestCharacter:
	extends RefCounted
	var name := "Test Rogue"
	var stat_value := 35.0
	var stat_values: Dictionary = {}
	var current_hp := 30
	var inventory: Array = []

	func get_stat(stat_name: String) -> float:
		if stat_values.has(stat_name):
			return float(stat_values[stat_name])
		match stat_name:
			"curHP":
				return current_hp
			"maxHP":
				return 30.0
			_:
				return stat_value

	func change_cur_hp(change: int) -> void:
		current_hp += change


class InventoryTestCharacter:
	extends RefCounted
	var name := "Inventory Test"
	var inventory: Array = []
	var money: Array = [0, 0, 0]
	var weight_limit := 100
	var unequip_count := 0

	func get_stat(stat_name: String) -> int:
		return weight_limit if stat_name == "Weight_Limit" else 0

	func unequip_item(item: Dictionary, _check_script := true) -> bool:
		unequip_count += 1
		item["equipped"] = 0
		return true

	func equip_item(item: Dictionary) -> bool:
		item["equipped"] = 1
		return true


class AllyTestCharacter:
	extends RefCounted
	var name := "Vodalian"


class CombatTestCreature:
	extends RefCounted
	var name: String
	var current_hp: int
	var curFaction: int
	var applied_traits: Array = []

	func _init(creature_name: String, hp: int, faction := 1) -> void:
		name = creature_name
		current_hp = hp
		curFaction = faction

	func get_stat(stat_name: String) -> int:
		return current_hp if stat_name == "curHP" else 0

	func add_trait(trait_script: Variant, args: Array) -> Variant:
		applied_traits.append({"script": trait_script, "args": args})
		return null


class CombatTestButton:
	extends RefCounted
	var creature: Variant

	func _init(represented_creature: Variant) -> void:
		creature = represented_creature


class CombatTestState:
	extends RefCounted
	var all_battle_creatures_btns: Array
	var battle_creatures_yet_to_act_btns: Array
	var battle_dead_enemies: Array = []
	var cur_battle_data: Dictionary = {"battleMacro": -1}

	func _init(combatants: Array) -> void:
		all_battle_creatures_btns = combatants.duplicate()
		battle_creatures_yet_to_act_btns = combatants.duplicate()

	func remove_cb_from_battle(combatant: Variant) -> void:
		all_battle_creatures_btns.erase(combatant)
		battle_creatures_yet_to_act_btns.erase(combatant)


func _init() -> void:
	var bundle = BundleScript.new()
	_expect(bundle.load_from_directory(FIXTURE), "CoB fixture loads: %s" % bundle.last_error)
	if not bundle.last_error.is_empty():
		_finish()
		return

	_test_bundle_indexes(bundle)
	_test_text_and_encounter(bundle)
	_test_evidence_backed_dispatcher_noop(bundle)
	_test_teleport(bundle)
	_test_dungeon_move(bundle)
	_test_look_direction(bundle)
	_test_view_modes_and_darkland(bundle)
	_test_random_level_mutations(bundle)
	_test_experience_award(bundle)
	_test_party_health_effect(bundle)
	_test_selected_character_pipeline(bundle)
	_test_misc_character_selection(bundle)
	_test_spell_effect_actions(bundle)
	_test_item_actions()
	_test_item_mutation_rules()
	_test_equipment_storage_rules()
	_test_quest_state_and_branch(bundle)
	_test_classic_stack_semantics()
	_test_shipped_gosub_chain()
	_test_shipped_opcode_25_mutation()
	_test_opcode_25_xap_copy()
	_test_modal_picture_actions()
	_test_party_state_actions()
	_test_priest_turning_actions()
	_test_combat_monster_presence_action()
	_test_combat_monster_destruction_action()
	_test_lower_undead_deanimation_action()
	_test_combat_monster_rout_action()
	_test_battle_round_macro_action()
	_test_forced_battle_end_action()
	_test_action_point_copy_mutations(bundle)
	_test_action_data_patch_variants()
	_test_choice_continuation(bundle)
	_test_battle_request(bundle)
	_test_shop_actions()
	_test_service_actions()
	_test_sound_and_treasure(bundle)
	_test_treasure_delivery(bundle)
	_test_map_mutations(bundle)
	_test_complex_encounter(bundle)
	_test_complex_action_choices(bundle)
	_test_complex_word_results()
	_test_encounter_lifecycle()
	_test_simple_encounter_mutation()
	_test_spoken_word_archive()
	_test_percent_branching()
	_test_difficulty_branching()
	_test_complex_spell_results(bundle)
	_test_complex_item_results(bundle)
	_test_shipped_lock_encounter(bundle)
	_test_shipped_trap_encounter(bundle)
	_test_battle_outcome(bundle)
	_test_state_snapshot(bundle)
	_test_godot_runtime_facade()
	_test_runtime_host()
	var user_arguments := OS.get_cmdline_user_args()
	if not user_arguments.is_empty():
		_test_full_bundle(str(user_arguments[0]))
	_finish()


func _test_bundle_indexes(bundle) -> void:
	_expect_equal(bundle.manifest.get("name"), "City of Bywater", "campaign identity")
	_expect_equal(bundle.get_map("land:0").get("width"), 90, "map index")
	_expect_equal(bundle.get_extra_action_point(100).get("source"), "Data ED3", "ED3 AP index")
	_expect_equal(bundle.get_triggers_at("land", 0, 9, 17).size(), 1, "coordinate trigger index")
	_expect_equal(bundle.get_treasure(11).get("itemIds", [])[0], 807, "treasure index")
	_expect_equal(bundle.get_item_text(801).get("identifiedName"), "Priest Scroll Case", "item text index")
	_expect_equal(bundle.get_encounter("simple", 0).get("prompt"), 51, "simple encounter index")
	_expect_equal(bundle.get_encounter("complex", 2).get("prompt"), 180, "complex encounter index")
	_expect_equal(bundle.get_thief_encounter(4).get("tumblers"), 2, "rogue encounter index")
	_expect_equal(bundle.get_thief_encounter(1).get("highDamage"), 12, "rogue trap index")
	_expect_equal(bundle.get_picture(32128), {}, "missing picture index")
	_expect_equal(bundle.get_monster(71), {}, "missing monster index")


func _test_text_and_encounter(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:0"), "begin CoB guard-house trigger")
	var text_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(text_result.get("status"), "yield", "text yields to Godot host")
	_expect_equal(text_result.get("command"), "show_text", "text command")
	_expect_equal(text_result.get("payload", {}).get("messageId"), 50, "text message id")
	_expect(
		str(text_result.get("payload", {}).get("message", {}).get("text", "")).begins_with("You enter the guard house"),
		"text message resolves through bundle index"
	)
	var encounter_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(encounter_result.get("command"), "start_encounter", "simple encounter command")
	_expect_equal(encounter_result.get("payload", {}).get("encounterId"), 0, "simple encounter id")
	_expect_equal(
		encounter_result.get("payload", {}).get("promptMessage", {}).get("id"),
		51,
		"simple encounter prompt resolves"
	)
	var outcome_result: Dictionary = interpreter.resume_encounter(4)
	_expect_equal(outcome_result.get("command"), "show_text", "encounter outcome runs selected code block")
	_expect_equal(outcome_result.get("payload", {}).get("messageId"), 61, "fourth outcome starts at slot 24")
	var completed_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(completed_result.get("reason"), "keep-codes", "encounter outcome reaches slot 31")


func _test_teleport(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:3"), "begin CoB teleport trigger")
	var result: Dictionary = interpreter.run_until_yield()
	var payload: Dictionary = result.get("payload", {})
	_expect_equal(result.get("command"), "teleport", "teleport command")
	_expect_equal(payload.get("levelIndex"), 5, "teleport level")
	_expect_equal(payload.get("x"), 6, "teleport x")
	_expect_equal(payload.get("y"), 83, "teleport y")
	_expect_equal(payload.get("recheckDestination"), false, "opcode 45 skips destination AP recheck")
	_expect_equal(interpreter.runtime_state.level_index, 5, "runtime position level updated")


func _test_dungeon_move(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:83"), "begin CoB dungeon entrance")
	var enter_result: Dictionary = interpreter.run_until_yield()
	var enter_payload: Dictionary = enter_result.get("payload", {})
	_expect_equal(enter_result.get("command"), "teleport", "dungeon move command")
	_expect_equal(enter_payload.get("levelType"), "dungeon", "dungeon move changes map family")
	_expect_equal(enter_payload.get("levelIndex"), 0, "dungeon entrance level")
	_expect_equal(enter_payload.get("x"), 33, "dungeon entrance x")
	_expect_equal(enter_payload.get("y"), 72, "dungeon entrance y")
	_expect_equal(enter_payload.get("heading"), 2, "dungeon entrance heading")
	_expect_equal(enter_payload.get("multiView"), true, "positive heading enables multiview")
	_expect_equal(interpreter.trace.size(), 1, "dungeon move stops before later AP slots")
	_expect_equal(interpreter.run_until_yield().get("reason"), "action-point-ended", "dungeon move ends AP")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:8:72"), "begin CoB single-view dungeon entrance")
	var single_view: Dictionary = interpreter.run_until_yield().get("payload", {})
	_expect_equal(single_view.get("levelType"), "dungeon", "single-view move enters dungeon")
	_expect_equal(single_view.get("levelIndex"), 1, "single-view dungeon level")
	_expect_equal(single_view.get("heading"), 4, "negative heading is stored as absolute")
	_expect_equal(single_view.get("multiView"), false, "negative heading disables multiview")
	_expect_equal(single_view.get("viewType"), StateScript.VIEW_3D, "negative heading selects fixed view")

	interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_location("dungeon", 0, 32, 72)
	interpreter.runtime_state.set_dungeon_view(3, false)
	_expect(interpreter.begin_trigger("Data DDD:0:1"), "begin CoB dungeon exit")
	var exit_payload: Dictionary = interpreter.run_until_yield().get("payload", {})
	_expect_equal(exit_payload.get("levelType"), "land", "dungeon exit changes map family")
	_expect_equal(exit_payload.get("levelIndex"), 0, "dungeon exit land level")
	_expect_equal(exit_payload.get("x"), 88, "dungeon exit x")
	_expect_equal(exit_payload.get("y"), 48, "dungeon exit y")
	_expect(not exit_payload.has("heading"), "land transfer omits dungeon view metadata")
	_expect_equal(interpreter.runtime_state.heading, 3, "land transfer preserves dormant dungeon heading")


func _test_look_direction(bundle) -> void:
	var interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_location("dungeon", 1, 20, 75)
	_expect(interpreter.begin_trigger("Data DDD:1:75"), "begin CoB fixed look direction")
	var fixed_result: Dictionary = interpreter.run_until_yield()
	var fixed_payload: Dictionary = fixed_result.get("payload", {})
	_expect_equal(fixed_result.get("command"), "set_view_direction", "look direction command")
	_expect_equal(fixed_payload.get("requestedHeading"), 1, "authored look direction")
	_expect_equal(fixed_payload.get("heading"), 1, "fixed look direction result")
	_expect_equal(fixed_payload.get("randomized"), false, "valid look direction is not randomized")
	_expect_equal(interpreter.runtime_state.heading, 1, "look direction updates runtime heading")
	var teleport_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(teleport_result.get("command"), "teleport", "look direction continues to next action")
	_expect_equal(interpreter.runtime_state.heading, 1, "teleport preserves selected heading")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:7:79"), "begin CoB south look direction")
	var south_payload: Dictionary = interpreter.run_until_yield().get("payload", {})
	_expect_equal(south_payload.get("heading"), 3, "second authored look direction")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:7:76"), "begin CoB random look direction")
	var random_payload: Dictionary = interpreter.run_until_yield().get("payload", {})
	_expect_equal(random_payload.get("requestedHeading"), -1, "random look direction sentinel")
	_expect_equal(random_payload.get("randomized"), true, "invalid direction requests random heading")
	_expect(
		int(random_payload.get("heading", 0)) >= 1 and int(random_payload.get("heading", 0)) <= 4,
		"random look direction stays within Classic's four headings"
	)


func _test_view_modes_and_darkland(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:7:72", 1), "begin CoB compass-off action")
	var compass_off: Dictionary = interpreter.run_until_yield()
	_expect_equal(compass_off.get("command"), "set_view_mode", "compass-off command")
	_expect_equal(compass_off.get("payload", {}).get("compassEnabled"), false, "compass disabled")
	_expect_equal(compass_off.get("payload", {}).get("warningId"), 99, "compass-off warning")
	_expect_equal(compass_off.get("payload", {}).get("redraw"), "walls", "compass redraws walls")
	_expect_equal(interpreter.runtime_state.compass_enabled, false, "compass state updated")
	_expect_equal(interpreter.run_until_yield().get("reason"), "keep-codes", "compass action continues")

	_expect(interpreter.begin_trigger("Data DD:7:73"), "begin CoB compass-on action")
	var compass_on: Dictionary = interpreter.run_until_yield()
	_expect_equal(compass_on.get("payload", {}).get("compassEnabled"), true, "compass enabled")
	_expect_equal(compass_on.get("payload", {}).get("warningId"), 98, "compass-on warning")
	_expect_equal(interpreter.runtime_state.compass_enabled, true, "enabled compass persists")

	_expect(interpreter.begin_trigger("Data DD:7:85"), "begin CoB allow-map action")
	var allow_map: Dictionary = interpreter.run_until_yield()
	_expect_equal(allow_map.get("command"), "set_view_mode", "allow-map command")
	_expect_equal(allow_map.get("payload", {}).get("multiView"), true, "allow map enables multiview")
	_expect_equal(allow_map.get("payload", {}).get("viewType"), StateScript.VIEW_3D, "allow map preserves current view")
	_expect_equal(allow_map.get("payload", {}).get("warningId"), 96, "allow-map warning")

	_expect(interpreter.begin_trigger("Data DD:7:84"), "begin CoB require-3D action")
	var require_3d: Dictionary = interpreter.run_until_yield()
	_expect_equal(require_3d.get("payload", {}).get("multiView"), false, "require 3D disables multiview")
	_expect_equal(require_3d.get("payload", {}).get("viewType"), StateScript.VIEW_3D, "require 3D selects 3D view")
	_expect_equal(require_3d.get("payload", {}).get("warningId"), 97, "require-3D warning")

	interpreter.runtime_state.view_type = StateScript.VIEW_MAP
	_expect(interpreter.begin_trigger("Data DD:7:84"), "begin require-3D from map view")
	var leave_map: Dictionary = interpreter.run_until_yield()
	_expect_equal(leave_map.get("payload", {}).get("previousViewType"), StateScript.VIEW_MAP, "map view uses signed Classic state")
	_expect_equal(leave_map.get("payload", {}).get("viewType"), StateScript.VIEW_3D, "map view returns to 3D")
	_expect_equal(leave_map.get("payload", {}).get("warningId"), 0, "unchanged multiview has no warning")

	interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_location("land", 4, 87, 27)
	_expect_equal(bundle.get_random_level("land", 4).get("isDark"), false, "fixture random-level baseline")
	_expect(interpreter.begin_trigger("Data DD:4:43", 1), "begin unchanged CoB darkland action")
	var unchanged_darkland: Dictionary = interpreter.run_until_yield()
	_expect_equal(unchanged_darkland.get("status"), "completed", "unchanged darkland completes")
	_expect_equal(unchanged_darkland.get("reason"), "darkland-unchanged", "unchanged darkland stops action point")
	_expect_equal(interpreter.trace.size(), 1, "unchanged darkland skips later text")

	_expect(interpreter.begin_trigger("Data DD:4:46", 2), "begin CoB darken-land action")
	var darken: Dictionary = interpreter.run_until_yield()
	_expect_equal(darken.get("command"), "set_map_darkness", "darkland command")
	_expect_equal(darken.get("payload", {}).get("previousDarkness"), 0, "darkland uses random-level baseline")
	_expect_equal(darken.get("payload", {}).get("darkness"), 1, "darkland stores authored value")
	_expect_equal(darken.get("payload", {}).get("dark"), true, "darkland adapter flag")
	_expect_equal(interpreter.runtime_state.get_darkland("land", 4, 0), 1, "darkness persists by map")
	var dark_text: Dictionary = interpreter.run_until_yield()
	_expect_equal(dark_text.get("payload", {}).get("messageId"), 849, "darkland continues to authored text")

	_expect(interpreter.begin_trigger("Data DD:4:43", 1), "begin CoB lighten-land action")
	var lighten: Dictionary = interpreter.run_until_yield()
	_expect_equal(lighten.get("payload", {}).get("previousDarkness"), 1, "lightland sees runtime override")
	_expect_equal(lighten.get("payload", {}).get("darkness"), 0, "lightland clears darkness")
	var light_text: Dictionary = interpreter.run_until_yield()
	_expect_equal(light_text.get("payload", {}).get("messageId"), -848, "lightland keeps authored text mode")
	_expect_equal(light_text.get("payload", {}).get("message", {}).get("id"), 848, "lightland resolves authored text")


func _test_random_level_mutations(bundle) -> void:
	var baseline: Dictionary = bundle.get_random_rectangle("land", 1, 17)
	_expect_equal(baseline.get("percent"), 0, "random rectangle fixture baseline percent")
	_expect_equal(
		baseline.get("battleRange", []).map(func(value: Variant) -> int: return int(value)),
		[158, 162],
		"random rectangle fixture battle range"
	)

	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:1:30", 3), "begin CoB random rectangle action")
	var rectangle_result: Dictionary = interpreter.run_until_yield()
	var rectangle_payload: Dictionary = rectangle_result.get("payload", {})
	_expect_equal(rectangle_result.get("command"), "set_random_encounter_rect", "random rectangle command")
	_expect_equal(rectangle_payload.get("levelType"), "land", "land rectangle target type")
	_expect_equal(rectangle_payload.get("levelIndex"), 1, "land rectangle target level")
	_expect_equal(rectangle_payload.get("rectIndex"), 17, "land rectangle target index")
	_expect_equal(
		rectangle_payload.get("previousRectangle", {}).get("battleRange", []).map(
			func(value: Variant) -> int: return int(value)
		),
		[158, 162],
		"random rectangle reports previous battle range"
	)
	_expect_equal(rectangle_payload.get("rectangle", {}).get("percent"), 900, "random rectangle percent")
	_expect_equal(
		rectangle_payload.get("rectangle", {}).get("battleRange"),
		[158, 163],
		"random rectangle updates authored battle high"
	)
	_expect_equal(
		interpreter.runtime_state.get_random_rectangle("land", 1, 17, {}).get("percent"),
		900,
		"random rectangle persists by map and index"
	)
	_expect_equal(
		bundle.get_random_rectangle("land", 1, 17),
		baseline,
		"random rectangle leaves bundle immutable"
	)

	interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_location("land", 0, 0, 0)
	interpreter.runtime_state.set_darkland("land", 0, 1)
	_expect(interpreter.begin_trigger("Data ED3:macro:163", 1), "begin CoB land-look action")
	var landlook_result: Dictionary = interpreter.run_until_yield()
	var landlook_payload: Dictionary = landlook_result.get("payload", {})
	_expect_equal(landlook_result.get("command"), "set_land_look", "land-look command")
	_expect_equal(landlook_payload.get("previousLandlook"), 0, "land-look uses random-level baseline")
	_expect_equal(landlook_payload.get("landlook"), 10, "land-look stores authored visual set")
	_expect_equal(landlook_payload.get("previousDarkness"), 1, "land-look reports previous darkness")
	_expect_equal(landlook_payload.get("darkness"), 0, "land-look stores authored darkness")
	_expect_equal(landlook_payload.get("redraw"), "center", "land context redraws center view")
	_expect_equal(interpreter.runtime_state.get_landlook("land", 0, -1), 10, "land-look persists by map")
	_expect_equal(interpreter.runtime_state.get_darkland("land", 0, -1), 0, "land-look persists darkness")
	var winter_text: Dictionary = interpreter.run_until_yield()
	_expect_equal(winter_text.get("payload", {}).get("messageId"), 867, "land-look continues to authored text")

	interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_location("dungeon", 0, 0, 0)
	interpreter.begin_trigger("Data ED3:macro:163", 1)
	_expect_equal(
		interpreter.run_until_yield().get("payload", {}).get("redraw"),
		"none",
		"dungeon context defers land redraw"
	)

	var synthetic_bundle = _random_level_mutation_test_bundle()
	interpreter = _interpreter(synthetic_bundle)
	_expect(interpreter.begin_trigger("random:dungeon"), "begin dungeon random rectangle action")
	var dungeon_result: Dictionary = interpreter.run_until_yield()
	var dungeon_payload: Dictionary = dungeon_result.get("payload", {})
	_expect_equal(dungeon_payload.get("levelType"), "dungeon", "negative opcode selects dungeon data")
	_expect_equal(dungeon_payload.get("rectangle", {}).get("percent"), 250, "dungeon rectangle percent")
	_expect_equal(
		dungeon_payload.get("rectangle", {}).get("battleRange"),
		[10, 20],
		"negative battle ids preserve existing range"
	)
	_expect_equal(interpreter.trace[0].get("code"), -23, "dungeon opcode remains signed in trace")
	_expect_equal(interpreter.run_until_yield().get("reason"), "keep-codes", "dungeon mutation continues")

	interpreter = _interpreter(synthetic_bundle)
	_expect(interpreter.begin_trigger("random:missing"), "begin unused random rectangle action")
	var missing_payload: Dictionary = interpreter.run_until_yield().get("payload", {})
	_expect_equal(missing_payload.get("rectIndex"), 18, "unused fixed rectangle index")
	_expect_equal(missing_payload.get("previousRectangle", {}).get("percent"), 0, "unused rectangle baseline percent")
	_expect_equal(missing_payload.get("rectangle", {}).get("battleRange"), [0, 0], "unused rectangle baseline range")


func _test_experience_award(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:1:30", 4), "begin CoB experience award")
	var experience_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(experience_result.get("command"), "give_experience", "experience command")
	_expect_equal(
		experience_result.get("payload", {}).get("experience"),
		1500,
		"experience command preserves the authored total"
	)
	var completed: Dictionary = interpreter.run_until_yield()
	_expect_equal(completed.get("status"), "completed", "experience sequence completes")
	_expect_equal(completed.get("reason"), "action-point-ended", "experience sequence falls through")
	var patched_target: Dictionary = interpreter.runtime_state.get_action_point_override("Data DD:1:31")
	_expect_equal(
		patched_target.get("actions", [])[0].get("id"),
		522,
		"experience sequence continues to its source-backed action-point patch"
	)
	_expect_equal(
		bundle.get_trigger("Data DD:1:31").get("actions", [])[0].get("code"),
		24,
		"experience sequence leaves the compiled target immutable"
	)


func _test_party_health_effect(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data ED3:macro:142"), "begin CoB party damage action")
	var damage_result: Dictionary = interpreter.run_until_yield()
	var payload: Dictionary = damage_result.get("payload", {})
	_expect_equal(damage_result.get("command"), "change_party_health", "party health command")
	_expect_equal(payload.get("multiplier"), -1, "party damage multiplier")
	_expect_equal(payload.get("rollRange"), [1, 1], "party damage roll range")
	_expect_equal(payload.get("soundId"), 699, "party damage sound")
	_expect_equal(payload.get("messageId"), 0, "party damage optional message")
	_expect_equal(payload.get("message"), {}, "zero party-health message id is a sentinel")
	_expect_equal(
		interpreter.run_until_yield().get("reason"),
		"action-point-ended",
		"party damage action point completes"
	)

	var adapter = GodotAdapterScript.new()
	var first_target := RogueTestCharacter.new()
	var second_target := RogueTestCharacter.new()
	var fixed_result: Dictionary = adapter.apply_party_health_effect(
		payload,
		[first_target, second_target]
	)
	_expect_equal(fixed_result.get("hits", []).size(), 2, "party damage affects every member")
	_expect_equal(first_target.current_hp, 29, "fixed party damage affects first member")
	_expect_equal(second_target.current_hp, 29, "fixed party damage affects second member")

	var variable_target := RogueTestCharacter.new()
	adapter.apply_party_health_effect(
		{"multiplier": -2, "rollRange": [1, 3]},
		[variable_target]
	)
	_expect(
		variable_target.current_hp >= 24 and variable_target.current_hp <= 28,
		"party damage uses an inclusive per-character roll"
	)
	var healing_target := RogueTestCharacter.new()
	healing_target.current_hp = 10
	adapter.apply_party_health_effect(
		{"multiplier": 2, "rollRange": [3, 3]},
		[healing_target]
	)
	_expect_equal(healing_target.current_hp, 16, "positive multiplier heals party members")


func _test_selected_character_pipeline(bundle) -> void:
	var pick_interpreter = _interpreter(bundle)
	_expect(
		pick_interpreter.begin_trigger("Data DD:7:54", 3),
		"begin CoB single-character pick"
	)
	var pick_result: Dictionary = pick_interpreter.run_until_yield()
	var pick_payload: Dictionary = pick_result.get("payload", {})
	_expect_equal(pick_result.get("command"), "pick_characters", "character-pick command")
	_expect_equal(pick_payload.get("count"), 1, "character-pick count")
	_expect_equal(pick_payload.get("allowDead"), false, "positive pick excludes dead characters")
	_expect_equal(pick_payload.get("invert"), false, "positive pick keeps chosen characters")
	_expect_equal(
		pick_interpreter.run_until_yield().get("payload", {}).get("messageId"),
		-506,
		"character pick continues to its source message"
	)

	var inverse_interpreter = _interpreter(bundle)
	_expect(
		inverse_interpreter.begin_trigger("Data DD:6:12", 5),
		"begin CoB inverse-character pick"
	)
	var inverse_result: Dictionary = inverse_interpreter.run_until_yield()
	var inverse_payload: Dictionary = inverse_result.get("payload", {})
	_expect_equal(inverse_result.get("command"), "pick_characters", "inverse-pick command")
	_expect_equal(inverse_payload.get("count"), 4, "inverse-pick count")
	_expect_equal(inverse_payload.get("allowDead"), true, "negative pick id allows dead characters")
	_expect_equal(inverse_payload.get("invert"), true, "negative opcode selects the complement")
	_expect_equal(
		inverse_interpreter.run_until_yield().get("payload", {}).get("messageId"),
		450,
		"inverse pick continues to the energy discharge"
	)
	var inverse_damage: Dictionary = inverse_interpreter.run_until_yield()
	var inverse_damage_payload: Dictionary = inverse_damage.get("payload", {})
	_expect_equal(
		inverse_damage.get("command"),
		"change_selected_health",
		"inverse-pick sequence damages its complement"
	)
	_expect_equal(inverse_damage_payload.get("multiplier"), -6, "inverse damage multiplier")
	_expect_equal(inverse_damage_payload.get("rollRange"), [1, 4], "inverse damage range")
	_expect_equal(inverse_damage_payload.get("soundId"), 659, "inverse damage sound")

	var check_interpreter = _interpreter(bundle)
	_expect(
		check_interpreter.begin_trigger("Data DD:7:45", 1),
		"begin CoB Acrobatics selection"
	)
	var check_result: Dictionary = check_interpreter.run_until_yield()
	var check_payload: Dictionary = check_result.get("payload", {})
	_expect_equal(
		check_result.get("command"),
		"filter_selected_characters",
		"character-check command"
	)
	_expect_equal(check_payload.get("checkType"), "special", "Acrobatics check type")
	_expect_equal(check_payload.get("checkIndex"), 5, "Acrobatics Classic index")
	_expect_equal(check_payload.get("modifier"), 30, "Acrobatics modifier")
	_expect_equal(check_payload.get("candidateMode"), "party", "Acrobatics checks party")
	_expect_equal(check_payload.get("selectOnFailure"), false, "positive check selects success")
	var checked_damage: Dictionary = check_interpreter.run_until_yield()
	_expect_equal(
		checked_damage.get("command"),
		"change_selected_health",
		"checked characters receive the following health effect"
	)
	_expect_equal(
		checked_damage.get("payload", {}).get("rollRange"),
		[1, 6],
		"checked damage range"
	)
	_expect_equal(
		check_interpreter.run_until_yield().get("payload", {}).get("messageId"),
		377,
		"checked damage continues to its source message"
	)

	var adapter = GodotAdapterScript.new()
	var first_target := RogueTestCharacter.new()
	first_target.name = "First"
	var second_target := RogueTestCharacter.new()
	second_target.name = "Second"
	var third_target := RogueTestCharacter.new()
	third_target.name = "Third"
	var party := [first_target, second_target, third_target]
	_expect_equal(
		adapter.select_characters_after_pick([first_target, second_target], party, false),
		[first_target, second_target],
		"normal pick keeps chosen party members"
	)
	_expect_equal(
		adapter.select_characters_after_pick([first_target, second_target], party, true),
		[third_target],
		"inverse pick keeps the unchosen party members"
	)

	first_target.stat_value = 100.0
	second_target.stat_value = -100.0
	var checked: Dictionary = adapter.filter_characters_by_check(
		check_payload,
		[first_target, second_target],
		[]
	)
	_expect_equal(checked.get("selected"), [first_target], "special check selects successes")
	var failure_payload := check_payload.duplicate()
	failure_payload["selectOnFailure"] = true
	var failed: Dictionary = adapter.filter_characters_by_check(
		failure_payload,
		[first_target, second_target],
		[]
	)
	_expect_equal(failed.get("selected"), [second_target], "negative check selects failures")
	var attribute_payload := {
		"checkType": "attribute",
		"checkIndex": 1,
		"modifier": 0,
		"candidateMode": "party",
		"selectOnFailure": false,
	}
	var attribute_result: Dictionary = adapter.filter_characters_by_check(
		attribute_payload,
		[first_target, second_target],
		[]
	)
	_expect_equal(
		attribute_result.get("selected"),
		[first_target],
		"attribute check uses the Remake stat mapping"
	)

	var selected_damage: Dictionary = adapter.apply_selected_health_effect(
		{"multiplier": -2, "rollRange": [3, 3]},
		[first_target]
	)
	_expect_equal(selected_damage.get("hits", []).size(), 1, "selected damage has one target")
	_expect_equal(first_target.current_hp, 24, "selected damage changes picked character HP")
	_expect_equal(second_target.current_hp, 30, "selected damage leaves unpicked character alone")
	_expect_equal(
		adapter.apply_selected_health_effect(
			{"multiplier": -1, "rollRange": [1, 1]},
			[]
		).get("hits", []).size(),
		0,
		"empty selected set is a valid no-op"
	)


func _test_misc_character_selection(bundle) -> void:
	var movement_interpreter = _interpreter(bundle)
	_expect(
		movement_interpreter.begin_trigger("Data ED3:macro:67"),
		"begin CoB movement-based rockfall"
	)
	_expect_equal(
		movement_interpreter.run_until_yield().get("payload", {}).get("messageId"),
		-508,
		"movement rockfall starts with its source warning"
	)
	var movement_result: Dictionary = movement_interpreter.run_until_yield()
	var movement_payload: Dictionary = movement_result.get("payload", {})
	_expect_equal(
		movement_result.get("command"),
		"select_characters_by_misc",
		"movement selector command"
	)
	_expect_equal(movement_payload.get("selector"), "movement_below", "movement selector type")
	_expect_equal(movement_payload.get("value"), 10, "movement selector threshold")
	_expect_equal(movement_payload.get("candidateMode"), "party", "movement selector checks party")
	_expect_equal(
		movement_interpreter.run_until_yield().get("command"),
		"change_selected_health",
		"movement-selected characters receive rockfall damage"
	)

	var attribute_interpreter = _interpreter(bundle)
	_expect(
		attribute_interpreter.begin_trigger("Data DD:2:12"),
		"begin CoB attribute-save rockfall"
	)
	_expect_equal(
		attribute_interpreter.run_until_yield().get("payload", {}).get("messageId"),
		560,
		"attribute rockfall starts with its source warning"
	)
	var attribute_result: Dictionary = attribute_interpreter.run_until_yield()
	var attribute_payload: Dictionary = attribute_result.get("payload", {})
	_expect_equal(
		attribute_result.get("command"),
		"select_characters_by_misc",
		"attribute-save selector command"
	)
	_expect_equal(
		attribute_payload.get("selector"),
		"attribute_save_failure",
		"attribute-save selector type"
	)
	_expect_equal(attribute_payload.get("value"), 5, "CoB rockfall preserves selector 5")
	_expect_equal(
		attribute_interpreter.run_until_yield().get("payload", {}).get("rollRange"),
		[2, 8],
		"attribute-save rockfall preserves damage range"
	)

	var first_target := RogueTestCharacter.new()
	first_target.name = "Slow"
	first_target.stat_values = {
		"MaxMovement": 8,
		"Dexterity": 0,
		"MultiplierMental": 1.0,
		"ResistanceMental": 0,
	}
	first_target.inventory = [{"name": "Dagger", "equipped": 0}]
	var second_target := RogueTestCharacter.new()
	second_target.name = "Fast"
	second_target.stat_values = {
		"MaxMovement": 12,
		"Dexterity": 100,
		"MultiplierMental": 0.0,
		"ResistanceMental": 0,
	}
	second_target.inventory = [{"name": "Dagger", "equipped": 1}]
	var third_target := RogueTestCharacter.new()
	third_target.name = "Dead"
	third_target.current_hp = 0
	var party := [first_target, second_target, third_target]
	var adapter = GodotAdapterScript.new()

	var movement_selected: Dictionary = adapter.select_characters_by_misc(
		{"selector": "movement_below", "value": 10, "candidateMode": "party"},
		party,
		[],
		null
	)
	_expect_equal(
		movement_selected.get("selected"),
		[first_target],
		"movement selector picks characters below the authored maximum"
	)
	var attribute_failed: Dictionary = adapter.select_characters_by_misc(
		{"selector": "attribute_save_failure", "value": 5, "candidateMode": "party"},
		[first_target, second_target],
		[],
		null
	)
	_expect_equal(
		attribute_failed.get("selected"),
		[first_target],
		"misc attribute selector picks failed saves"
	)
	var spell_failed: Dictionary = adapter.select_characters_by_misc(
		{"selector": "spell_save_failure", "value": 5, "candidateMode": "party"},
		[first_target, second_target],
		[],
		null
	)
	_expect_equal(
		spell_failed.get("selected"),
		[first_target],
		"misc spell selector picks failed saves"
	)
	var selected_only: Dictionary = adapter.select_characters_by_misc(
		{"selector": "percent", "value": 100, "candidateMode": "selected"},
		party,
		[second_target],
		null
	)
	_expect_equal(
		selected_only.get("selected"),
		[second_target],
		"misc selector can filter the previous selection"
	)
	var alive_only: Dictionary = adapter.select_characters_by_misc(
		{"selector": "percent", "value": 100, "candidateMode": "alive"},
		party,
		[],
		null
	)
	_expect_equal(
		alive_only.get("selected"),
		[first_target, second_target],
		"misc selector can restrict candidates to living characters"
	)
	_expect_equal(
		adapter.select_characters_by_misc(
			{"selector": "position_before", "value": 3, "candidateMode": "party"},
			party,
			[],
			null
		).get("selected"),
		[first_target, second_target],
		"position selector uses Classic's one-based before threshold"
	)
	_expect_equal(
		adapter.select_characters_by_misc(
			{"selector": "exact_position", "value": 3, "candidateMode": "party"},
			party,
			[],
			null
		).get("selected"),
		[third_target],
		"exact-position extension selects one-based party slot"
	)
	_expect_equal(
		adapter.select_characters_by_misc(
			{"selector": "focused_character", "value": 0, "candidateMode": "party"},
			party,
			[],
			second_target
		).get("selected"),
		[second_target],
		"focused-character extension uses the native HUD selection"
	)
	var item_payload := {
		"selector": "has_item",
		"value": 1,
		"candidateMode": "party",
		"itemNames": ["Dagger"],
	}
	_expect_equal(
		adapter.select_characters_by_misc(item_payload, party, [], null).get("selected"),
		[first_target, second_target],
		"item selector matches carried and worn items"
	)
	item_payload["selector"] = "wearing_item"
	_expect_equal(
		adapter.select_characters_by_misc(item_payload, party, [], null).get("selected"),
		[second_target],
		"worn-item extension requires equipped state"
	)


func _test_spell_effect_actions(bundle) -> void:
	var party_interpreter = _interpreter(bundle)
	_expect(
		party_interpreter.begin_trigger("Data DD:8:89"),
		"begin CoB party spell action"
	)
	_expect_equal(
		party_interpreter.run_until_yield().get("payload", {}).get("messageId"),
		698,
		"party spell starts with its source warning"
	)
	var party_result: Dictionary = party_interpreter.run_until_yield()
	var party_payload: Dictionary = party_result.get("payload", {})
	_expect_equal(party_result.get("command"), "cast_classic_spell", "party spell command")
	_expect_equal(party_payload.get("spellId"), 1408, "party spell ID")
	_expect_equal(party_payload.get("power"), 3, "party spell power")
	_expect_equal(party_payload.get("saveAdjustment"), 0, "party spell save adjustment")
	_expect_equal(party_payload.get("forceAffect"), false, "party spell force flag")
	_expect_equal(party_payload.get("targetMode"), "party", "party spell target mode")
	_expect_equal(
		party_interpreter.run_until_yield().get("reason"),
		"keep-codes",
		"party spell keeps its source action point"
	)

	var selected_interpreter = _interpreter(bundle)
	_expect(
		selected_interpreter.begin_trigger("Data ED3:macro:108"),
		"begin CoB selected-character spell"
	)
	_expect_equal(
		selected_interpreter.run_until_yield().get("payload", {}).get("soundId"),
		-692,
		"selected spell preserves its first source sound"
	)
	_expect_equal(
		selected_interpreter.run_until_yield().get("payload", {}).get("soundId"),
		699,
		"selected spell preserves its second source sound"
	)
	var selected_result: Dictionary = selected_interpreter.run_until_yield()
	var selected_payload: Dictionary = selected_result.get("payload", {})
	_expect_equal(
		selected_result.get("command"),
		"cast_classic_spell",
		"selected-character spell command"
	)
	_expect_equal(selected_payload.get("spellId"), 2301, "selected spell ID")
	_expect_equal(selected_payload.get("power"), 1, "selected spell power")
	_expect_equal(selected_payload.get("targetMode"), "selected", "selected spell target mode")

	var adjusted_interpreter = _interpreter(bundle)
	_expect(
		adjusted_interpreter.begin_trigger("Data ED3:macro:128"),
		"begin CoB adjusted selected-character spell"
	)
	var adjusted_payload: Dictionary = \
		adjusted_interpreter.run_until_yield().get("payload", {})
	_expect_equal(adjusted_payload.get("spellId"), 4606, "adjusted spell ID")
	_expect_equal(adjusted_payload.get("power"), 3, "adjusted spell power")
	_expect_equal(adjusted_payload.get("saveAdjustment"), 30, "adjusted spell save modifier")
	_expect_equal(adjusted_payload.get("forceAffect"), false, "adjusted spell force flag")

	var adapter = GodotAdapterScript.new()
	var first_target := RogueTestCharacter.new()
	var second_target := RogueTestCharacter.new()
	_expect_equal(
		adapter.spell_effect_targets("party", [first_target, second_target], [second_target]),
		[first_target, second_target],
		"party spell selects every party member"
	)
	_expect_equal(
		adapter.spell_effect_targets("selected", [first_target, second_target], [second_target]),
		[second_target],
		"selected spell retains the transient picked set"
	)
	_expect_equal(
		adapter.classic_spell_mapping_key(1408),
		"10037",
		"Power Drain ID resolves to Remake's spell-table key"
	)
	_expect_equal(
		adapter.classic_spell_mapping_key(2301),
		"20020",
		"Confuse ID resolves to Remake's spell-table key"
	)
	_expect_equal(
		adapter.classic_spell_mapping_key(4606),
		"40055",
		"Fire Flare ID resolves to Remake's spell-table key"
	)


func _test_item_actions() -> void:
	var bundle = _item_action_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:possession"), "begin item possession branch")
	var item_check: Dictionary = interpreter.run_until_yield()
	_expect_equal(item_check.get("command"), "check_party_item", "opcode 21 checks party inventory")
	_expect_equal(item_check.get("payload", {}).get("itemId"), 100, "item check preserves item ID")
	_expect_equal(
		item_check.get("payload", {}).get("itemTexts", [])[0].get("identifiedName"),
		"Test Key",
		"item check supplies scenario item text"
	)
	var possessed: Dictionary = interpreter.resume_item_check(true)
	_expect_equal(possessed.get("payload", {}).get("messageId"), 900, "possessed item takes success branch")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:possession"), "begin missing item continuation")
	interpreter.run_until_yield()
	var missing_continues: Dictionary = interpreter.resume_item_check(false)
	_expect_equal(
		missing_continues.get("payload", {}).get("messageId"),
		910,
		"missing item can continue the current action point"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:missing-branch"), "begin missing item branch")
	interpreter.run_until_yield()
	var missing_branch: Dictionary = interpreter.resume_item_check(false)
	_expect_equal(
		missing_branch.get("payload", {}).get("messageId"),
		901,
		"missing item can take its alternate branch"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:missing-text"), "begin missing item message")
	interpreter.run_until_yield()
	var missing_text: Dictionary = interpreter.resume_item_check(false)
	_expect_equal(missing_text.get("payload", {}).get("messageId"), 902, "missing item can exit with text")
	_expect_equal(
		interpreter.run_until_yield().get("reason"),
		"action-point-ended",
		"missing-item text exits instead of falling through"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:gosub"), "begin GOSUB item branch")
	interpreter.run_until_yield()
	var subroutine: Dictionary = interpreter.resume_item_check(true)
	_expect_equal(subroutine.get("payload", {}).get("messageId"), 911, "item branch enters GOSUB target")
	var returned: Dictionary = interpreter.run_until_yield()
	_expect_equal(returned.get("payload", {}).get("messageId"), 913, "item branch returns to caller")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:simple"), "begin item encounter branch")
	interpreter.run_until_yield()
	var item_encounter: Dictionary = interpreter.resume_item_check(true)
	_expect_equal(item_encounter.get("command"), "start_encounter", "item branch can start an encounter")
	_expect_equal(item_encounter.get("payload", {}).get("encounterId"), 2, "item branch selects encounter")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:result-present"), "begin present-item result branch")
	interpreter.run_until_yield()
	var present_result: Dictionary = interpreter.resume_item_check(true)
	_expect_equal(present_result.get("payload", {}).get("messageId"), 921, "opcode 38 branches on possession")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:result-present"), "begin failed result item test")
	interpreter.run_until_yield()
	var present_fallthrough: Dictionary = interpreter.resume_item_check(false)
	_expect_equal(
		present_fallthrough.get("payload", {}).get("messageId"),
		920,
		"opcode 38 falls through when its test fails"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:result-absent"), "begin absent-item result branch")
	interpreter.run_until_yield()
	var absent_result: Dictionary = interpreter.resume_item_check(false)
	_expect_equal(absent_result.get("payload", {}).get("messageId"), 922, "opcode 38 branches on absence")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:result-force"), "begin forced item result branch")
	var forced_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(forced_result.get("payload", {}).get("messageId"), 923, "opcode 38 preserves forced branch mode")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:mutation"), "begin item mutation action")
	var mutation: Dictionary = interpreter.run_until_yield()
	_expect_equal(mutation.get("command"), "alter_party_items", "opcode 22 yields typed mutation")
	_expect_equal(mutation.get("payload", {}).get("maxMatches"), 2, "item mutation preserves match limit")
	_expect_equal(mutation.get("payload", {}).get("operation"), 3, "item mutation preserves operation")
	_expect_equal(mutation.get("payload", {}).get("chargeDelta"), -4, "item mutation preserves charge delta")
	_expect_equal(
		mutation.get("payload", {}).get("replacementItemId"),
		101,
		"item mutation preserves replacement ID"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:capture"), "begin equipment capture action")
	_expect(bool(interpreter.run_until_yield().get("payload", {}).get("capture")), "nonzero opcode 36 captures")
	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("item:restore"), "begin equipment restore action")
	_expect(not bool(interpreter.run_until_yield().get("payload", {}).get("capture")), "zero opcode 36 restores")
	var adapter = GodotAdapterScript.new()
	var unresolved_item: Dictionary = adapter._check_party_item({
		"itemId": 990,
		"itemTexts": [],
	})
	_expect_equal(
		unresolved_item.get("status"),
		"error",
		"native item check stops when a scenario item has no exported identity"
	)
	var host = HostScript.new()
	get_root().add_child(host)
	var host_adapter = GuardHouseAdapter.new()
	host.configure(host_adapter)
	host.runtime.bundle = bundle
	host.runtime.runtime_state = StateScript.new()
	host.runtime.runtime_state.configure_from_bundle(bundle)
	host.runtime.interpreter.configure(bundle, host.runtime.runtime_state)
	var host_completions: Array = []
	host.playthrough_completed.connect(
		func(result: Dictionary) -> void: host_completions.append(result)
	)
	_expect(host.start_trigger("item:possession"), "runtime host starts item possession branch")
	_expect_equal(host_adapter.commands[0].get("command"), "check_party_item", "host dispatches item check")
	_expect_equal(host_adapter.commands[1].get("payload", {}).get("messageId"), 900, "host resumes item branch")
	_expect_equal(host_completions.size(), 1, "host completes item possession branch")
	host.queue_free()


func _test_item_mutation_rules() -> void:
	var equipped_character = InventoryTestCharacter.new()
	equipped_character.inventory = [_test_item("Test Key", 1, 5)]
	var carried_character = InventoryTestCharacter.new()
	carried_character.inventory = [_test_item("Spare Key")]
	_expect(
		InventoryRulesScript.party_has_named_item(
			[equipped_character, carried_character],
			["test key"]
		),
		"item possession includes equipped items"
	)

	var drop_result: Dictionary = InventoryRulesScript.alter_named_items(
		[equipped_character, carried_character],
		["Test Key", "Spare Key"],
		1,
		1,
		0
	)
	_expect_equal(drop_result.get("changed"), 1, "item removal honors its match limit")
	_expect(equipped_character.inventory.is_empty(), "item removal drops the first party match")
	_expect_equal(carried_character.inventory.size(), 1, "item removal leaves later matches alone")

	var charged_character = InventoryTestCharacter.new()
	charged_character.inventory = [_test_item("Charged Wand", 1, 5)]
	var charge_result: Dictionary = InventoryRulesScript.alter_named_items(
		[charged_character],
		["Charged Wand"],
		1,
		2,
		-2
	)
	_expect_equal(charge_result.get("changed"), 1, "item charge mutation finds its target")
	_expect_equal(charged_character.inventory[0].get("charges"), 3, "item charge mutation is signed")
	_expect_equal(charged_character.unequip_count, 0, "charge mutation does not unequip the item")
	_expect_equal(charged_character.inventory[0].get("equipped"), 1, "charged item remains equipped")

	var replaced_character = InventoryTestCharacter.new()
	replaced_character.inventory = [_test_item("Old Wand", 1, 2)]
	var replacement := _test_item("New Wand", 0, 7)
	var replace_result: Dictionary = InventoryRulesScript.alter_named_items(
		[replaced_character],
		["Old Wand"],
		1,
		3,
		0,
		replacement
	)
	_expect_equal(replace_result.get("changed"), 1, "item replacement finds its target")
	_expect_equal(replaced_character.inventory[0].get("name"), "New Wand", "item replacement uses new template")
	_expect_equal(replaced_character.inventory[0].get("charges"), 7, "item replacement resets charges")
	_expect_equal(replaced_character.inventory[0].get("is_identified"), 0, "item replacement resets identification")
	_expect_equal(replaced_character.inventory[0].get("equipped"), 1, "replacement retries prior equipment state")


func _test_equipment_storage_rules() -> void:
	var first_character = InventoryTestCharacter.new()
	first_character.inventory = [_test_item("Sword", 1)]
	first_character.money = [10, 1, 0]
	var second_character = InventoryTestCharacter.new()
	second_character.inventory = [_test_item("Ring")]
	second_character.money = [0, 0, 1]
	var pooled_money := [5, 2, 1]
	var captured: Dictionary = InventoryRulesScript.capture_party_equipment(
		[first_character, second_character],
		pooled_money
	)
	_expect(bool(captured.get("active")), "equipment capture creates active storage")
	_expect_equal(captured.get("wealth"), [15, 3, 2], "equipment capture pools all wealth")
	_expect(first_character.inventory.is_empty(), "equipment capture clears first inventory")
	_expect(second_character.inventory.is_empty(), "equipment capture clears second inventory")
	first_character.inventory.append(_test_item("Interim Loot"))
	var restored: Dictionary = InventoryRulesScript.restore_party_equipment(
		[first_character, second_character],
		pooled_money,
		captured
	)
	_expect(bool(restored.get("restored")), "equipment restore consumes active storage")
	_expect_equal(first_character.inventory[0].get("name"), "Sword", "equipment restore returns original item")
	_expect_equal(first_character.inventory[0].get("equipped"), 1, "equipment restore reapplies worn state")
	_expect_equal(second_character.inventory[0].get("name"), "Ring", "equipment restore returns party inventory")
	_expect_equal(restored.get("extraItems", [])[0].get("name"), "Interim Loot", "interim items become loot")
	for currency: int in 3:
		_expect_equal(
			int(first_character.money[currency]) + int(second_character.money[currency]) \
				+ int(pooled_money[currency]),
			int(captured.get("wealth", [])[currency]),
			"equipment restore preserves wealth type %d" % currency
		)
	var limited_character = InventoryTestCharacter.new()
	limited_character.weight_limit = 10
	var limited_pool := [0, 0, 0]
	InventoryRulesScript.restore_party_equipment(
		[limited_character],
		limited_pool,
		{"active": true, "inventories": [[]], "wealth": [0, 0, 1]}
	)
	_expect_equal(
		limited_character.money[2],
		1,
		"equipment restore preserves Classic's pre-award jewel weight check"
	)
	var loaded_character = InventoryTestCharacter.new()
	loaded_character.weight_limit = 2
	loaded_character.inventory = [_test_item("Interim Weight")]
	loaded_character.inventory[0]["weight"] = 2
	var loaded_pool := [0, 0, 0]
	InventoryRulesScript.restore_party_equipment(
		[loaded_character],
		loaded_pool,
		{"active": true, "inventories": [[]], "wealth": [1, 0, 0]}
	)
	_expect_equal(
		loaded_pool[0],
		1,
		"equipment restore shares wealth before replacing interim items"
	)


func _test_evidence_backed_dispatcher_noop(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data ED3:macro:73", 2), "begin CoB dispatcher no-op slot")
	var result: Dictionary = interpreter.run_until_yield()
	_expect_equal(result.get("status"), "completed", "evidence-listed dispatcher no-op is skipped")
	_expect_equal(interpreter.trace[0].get("code"), 200, "dispatcher no-op remains visible in trace")


func _test_quest_state_and_branch(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:80", 5), "begin CoB quest setter at slot 5")
	var set_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(set_result.get("status"), "completed", "quest setter completes")
	_expect(interpreter.runtime_state.is_quest_set(33), "opcode 47 sets quest 33")
	_expect_equal(bundle.get_trigger("Data DD:0:80").get("id"), "Data DD:0:80", "execution does not mutate bundle records")
	interpreter.runtime_state.set_quest_flag(-33)
	_expect(not interpreter.runtime_state.is_quest_set(33), "negative quest id clears quest 33")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:78"), "begin CoB quest branch")
	var false_branch: Dictionary = interpreter.run_until_yield()
	_expect_equal(false_branch.get("status"), "completed", "unset quest follows ED3 branch")
	_expect_equal(false_branch.get("reason"), "keep-codes", "ED3 target executes opcode 24")
	_expect_equal(interpreter.trace.size(), 2, "branch trace contains source and target")
	_expect_equal(interpreter.trace[1].get("triggerId"), "Data ED3:macro:100", "branch target is CoB ED3 record 100")

	interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_quest_flag(20)
	_expect(interpreter.begin_trigger("Data DD:0:78"), "restart CoB quest branch")
	var true_branch: Dictionary = interpreter.run_until_yield()
	_expect_equal(true_branch.get("command"), "show_text", "set quest continues within current AP")
	_expect_equal(true_branch.get("payload", {}).get("messageId"), 620, "continued AP reaches CoB message 620")


func _test_classic_stack_semantics() -> void:
	var bundle = _stack_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("stack:sticky"), "begin sticky GOSUB stack fixture")
	var nested_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(nested_result.get("payload", {}).get("messageId"), 902, "nested positive branch inherits GOSUB mode")
	_expect_equal(interpreter.call_stack.size(), 2, "sticky GOSUB pushes nested positive branch")
	_expect(interpreter.gosub_active, "GOSUB mode remains active while nested")
	var middle_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(middle_result.get("payload", {}).get("messageId"), 901, "first return resumes middle AP")
	_expect_equal(interpreter.call_stack.size(), 1, "first return pops one frame")
	var root_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(root_result.get("payload", {}).get("messageId"), 900, "second return resumes root AP")
	_expect_equal(interpreter.call_stack.size(), 0, "second return empties stack")
	_expect(not interpreter.gosub_active, "positive root action clears GOSUB mode on empty stack")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("stack:pop"), "begin POP stack fixture")
	var pop_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(pop_result.get("payload", {}).get("messageId"), 910, "POP discards middle frame before return")
	_expect_equal(interpreter.call_stack.size(), 0, "POP and return consume both frames")
	_expect(
		not _trace_has_action(interpreter.trace, "Data ED3:macro:200", 1),
		"discarded frame does not resume"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("stack:empty-pop"), "begin empty POP stack fixture")
	var empty_pop_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(empty_pop_result.get("payload", {}).get("messageId"), 912, "POP on an empty stack is a no-op")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("stack:extend"), "begin Extend Door Codes fixture")
	var extend_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(extend_result.get("payload", {}).get("messageId"), 931, "Extend Door Codes enters its target AP")
	_expect_equal(interpreter.call_stack.size(), 0, "negative Extend Door Codes does not push a frame")
	var extend_end: Dictionary = interpreter.run_until_yield()
	_expect_equal(extend_end.get("reason"), "return-with-empty-stack", "Extend Door Codes target cannot return to its source")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("stack:no-implicit-return"), "begin explicit-return fixture")
	var leaf_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(leaf_result.get("payload", {}).get("messageId"), 921, "GOSUB leaf executes")
	var ended_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(ended_result.get("reason"), "action-point-ended", "AP end does not implicitly return")
	_expect_equal(interpreter.call_stack.size(), 0, "unfinished frames are discarded when execution ends")
	_expect(
		not _trace_has_action(interpreter.trace, "stack:no-implicit-return", 1),
		"root AP remains suspended without opcode 111"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("stack:overflow"), "begin stack depth fixture")
	var overflow_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(overflow_result.get("status"), "error", "twenty-first GOSUB frame stops safely")
	_expect_equal(interpreter.call_stack.size(), 20, "GOSUB stack matches Classic's twenty-frame capacity")
	_expect(
		str(overflow_result.get("message", "")).contains("exceeded 20 frames"),
		"stack overflow reports Classic frame limit"
	)


func _test_shipped_gosub_chain() -> void:
	var bundle = BundleScript.new()
	_expect(
		bundle.load_from_directory(WAR_IN_THE_SWORD_LANDS_GOSUB_FIXTURE),
		"War in the Sword Lands GOSUB fixture loads: %s" % bundle.last_error
	)
	if not bundle.last_error.is_empty():
		return

	var interpreter = _interpreter(bundle)
	# EDCD rows 1508 and 1824 require set flags; row 1510 requires quest 2 to remain unset.
	interpreter.runtime_state.set_quest_flag(29)
	interpreter.runtime_state.set_quest_flag(64)
	_expect(
		interpreter.begin_trigger("Data DD:9:48", 3),
		"begin shipped War in the Sword Lands GOSUB chain"
	)

	var random_text: Dictionary = interpreter.run_until_yield()
	var random_message_id := int(random_text.get("payload", {}).get("messageId", -1))
	_expect_equal(random_text.get("command"), "show_text", "shipped chain displays random text")
	_expect(
		random_message_id >= 1107 and random_message_id <= 1109,
		"random text stays within source EDCD message range"
	)
	_expect_equal(
		random_text.get("payload", {}).get("message", {}).get("id"),
		random_message_id,
		"random text resolves the selected source message"
	)
	_expect_equal(interpreter.call_stack.size(), 1, "first shipped GOSUB pushes the map AP")

	var first_nested_text: Dictionary = interpreter.run_until_yield()
	_expect_equal(
		first_nested_text.get("payload", {}).get("messageId"),
		1110,
		"first nested XAP displays source message 1110"
	)
	_expect_equal(interpreter.call_stack.size(), 2, "second shipped GOSUB pushes its XAP")

	var second_nested_text: Dictionary = interpreter.run_until_yield()
	_expect_equal(
		second_nested_text.get("payload", {}).get("messageId"),
		1246,
		"second nested XAP displays source message 1246"
	)
	_expect_equal(interpreter.call_stack.size(), 3, "third shipped GOSUB pushes its XAP")

	var completed: Dictionary = interpreter.run_until_yield()
	_expect_equal(completed.get("reason"), "keep-codes", "three opcode 111 returns resume the map AP")
	_expect_equal(interpreter.call_stack.size(), 0, "shipped GOSUB chain unwinds every frame")
	_expect_equal(interpreter.trace, [
		{"triggerId": "Data DD:9:48", "slot": 3, "code": 46},
		{"triggerId": "Data ED3:macro:1026", "slot": 0, "code": 19},
		{"triggerId": "Data ED3:macro:1026", "slot": 1, "code": 46},
		{"triggerId": "Data ED3:macro:1027", "slot": 0, "code": 1},
		{"triggerId": "Data ED3:macro:1027", "slot": 1, "code": 46},
		{"triggerId": "Data ED3:macro:1196", "slot": 0, "code": 1},
		{"triggerId": "Data ED3:macro:1196", "slot": 1, "code": 111},
		{"triggerId": "Data ED3:macro:1027", "slot": 2, "code": 111},
		{"triggerId": "Data ED3:macro:1026", "slot": 2, "code": 111},
		{"triggerId": "Data DD:9:48", "slot": 7, "code": 24},
	], "shipped GOSUB trace matches Classic return order")


func _test_shipped_opcode_25_mutation() -> void:
	var bundle = BundleScript.new()
	_expect(
		bundle.load_from_directory(TWIN_SANDS_OPCODE_25_FIXTURE),
		"Twin Sands opcode 25 fixture loads: %s" % bundle.last_error
	)
	if not bundle.last_error.is_empty():
		return

	var state = StateScript.new()
	state.configure_from_bundle(bundle)
	state.level_type = "dungeon"
	state.set_position(0, 43, 81)
	var interpreter = InterpreterScript.new()
	interpreter.configure(bundle, state)
	_expect(
		interpreter.begin_trigger("Data DDD:0:32", 7),
		"begin shipped Twin Sands opcode 25"
	)
	var completed: Dictionary = interpreter.run_until_yield()
	_expect_equal(completed.get("reason"), "action-point-ended", "opcode 25 finishes the AP")
	_expect_equal(state.x, 77, "opcode 25 exit reaches the source door destination x")
	_expect_equal(state.y, 16, "opcode 25 exit reaches the source door destination y")
	_expect_equal(
		state.get_trigger_percent("dungeon", 0, 32, 100),
		-1,
		"opcode 25 consumes the source door"
	)
	var replacement := state.get_action_point_override("Data DDD:0:32")
	_expect_equal(replacement.get("targetX"), 43, "replacement door points back to activation x")
	_expect_equal(replacement.get("targetY"), 81, "replacement door points back to activation y")
	_expect_equal(replacement.get("coordinate"), {"x": 43, "y": 81}, "replacement keeps its door coordinate")
	_expect_equal(replacement.get("actions", []).size(), 3, "replacement keeps the active AP actions")
	_expect_equal(
		bundle.get_trigger("Data DDD:0:32").get("targetX"),
		77,
		"opcode 25 leaves imported bundle records immutable"
	)

	var restored = StateScript.new()
	restored.restore(state.snapshot())
	var restored_replacement := restored.get_action_point_override("Data DDD:0:32")
	_expect_equal(restored_replacement.get("targetX"), 43, "replacement door survives snapshot")
	_expect_equal(
		restored.get_trigger_percent("dungeon", 0, 32, 100),
		-1,
		"replacement percent survives snapshot"
	)

	var runtime = RuntimeScript.new()
	_expect(runtime.load_campaign(TWIN_SANDS_OPCODE_25_FIXTURE), "runtime loads opcode 25 fixture")
	runtime.restore(state.snapshot())
	var triggers := runtime.triggers_at("dungeon", 0, 43, 81)
	_expect_equal(triggers.size(), 1, "runtime lookup exposes the persisted door record")
	_expect_equal(triggers[0].get("targetX"), 43, "runtime lookup applies the persisted target")


func _test_opcode_25_xap_copy() -> void:
	var bundle = _opcode_25_test_bundle()
	var state = StateScript.new()
	state.configure_from_bundle(bundle)
	state.set_position(0, 2, 3)
	var interpreter = InterpreterScript.new()
	interpreter.configure(bundle, state)
	_expect(interpreter.begin_trigger("Data DD:0:7"), "begin opcode 25 XAP copy fixture")

	var first_text: Dictionary = interpreter.run_until_yield()
	_expect_equal(first_text.get("payload", {}).get("messageId"), 900, "GOSUB enters replacement XAP")
	_expect_equal(interpreter.call_stack.size(), 1, "XAP starts with a saved caller frame")
	var second_text: Dictionary = interpreter.run_until_yield()
	_expect_equal(second_text.get("payload", {}).get("messageId"), 901, "execution continues after opcode 25")
	_expect_equal(interpreter.call_stack.size(), 0, "opcode 25 clears the GOSUB stack immediately")
	_expect_equal(interpreter.trace[3].get("code"), 111, "cleared-stack return is a no-op after opcode 25")
	var completed: Dictionary = interpreter.run_until_yield()
	_expect_equal(completed.get("status"), "completed", "replacement XAP completes")
	_expect_equal(completed.get("reason"), "keep-codes", "replacement XAP honors Keep Codes")

	var replacement := state.get_action_point_override("Data DD:0:7")
	_expect_equal(replacement.get("targetX"), 2, "XAP replacement captures activation x")
	_expect_equal(replacement.get("targetY"), 3, "XAP replacement captures activation y")
	_expect_equal(replacement.get("actions", []).size(), 5, "XAP actions replace the map AP actions")
	_expect_equal(replacement.get("actions", [])[1].get("code"), 25, "replacement contains opcode 25")
	_expect_equal(
		state.get_trigger_percent("land", 0, 7, 100),
		100,
		"Keep Codes preserves the replacement trigger percent"
	)
	_expect_equal(
		bundle.get_trigger("Data DD:0:7").get("actions", []).size(),
		1,
		"XAP replacement does not edit the bundle map AP"
	)

	var replay = InterpreterScript.new()
	replay.configure(bundle, state)
	_expect(replay.begin_trigger("Data DD:0:7"), "restart persisted XAP replacement")
	var replay_text: Dictionary = replay.run_until_yield()
	_expect_equal(replay_text.get("payload", {}).get("messageId"), 900, "persisted XAP actions run on reactivation")
	_expect_equal(replay.trace[0].get("code"), 1, "reactivation starts with the copied action list")
	_expect_equal(replay.call_stack.size(), 0, "reactivation no longer enters the original GOSUB")


func _test_modal_picture_actions() -> void:
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	bundle.pictures_by_id[32128] = {
		"resourceId": 32128,
		"resourceType": "PICT",
		"relativePath": "Splash Images/32128.png",
	}
	bundle.messages_by_id[900] = {"id": 900, "text": "After the click."}
	bundle.messages_by_id[901] = {"id": 901, "text": "After the picture."}
	_add_stack_trigger(bundle, "modal:click", -1, [
		_classic_action(0, 26, 0),
		_classic_action(1, 1, 900),
	])
	_add_stack_trigger(bundle, "modal:picture", -1, [
		_classic_action(0, 27, 32128),
		_classic_action(1, 1, 901),
	])
	_add_stack_trigger(bundle, "modal:redraw", -1, [_classic_action(0, 28, 0)])

	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("modal:click"), "begin click acknowledgement fixture")
	var click_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(click_result.get("command"), "wait_for_click", "get-click command")
	_expect_equal(click_result.get("payload", {}).get("prompt"), "Click Mouse", "get-click prompt")
	_expect_equal(click_result.get("payload", {}).get("soundId"), 30005, "get-click sound")
	_expect_equal(interpreter.run_until_yield().get("command"), "show_text", "click resumes action list")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("modal:picture"), "begin picture fixture")
	var picture_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(picture_result.get("command"), "show_picture", "show-picture command")
	_expect_equal(picture_result.get("payload", {}).get("pictureId"), 32128, "show-picture ID")
	_expect_equal(
		picture_result.get("payload", {}).get("picture", {}).get("resourceType"),
		"PICT",
		"show-picture catalog record"
	)
	_expect_equal(interpreter.run_until_yield().get("command"), "show_text", "picture resumes action list")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("modal:redraw"), "begin map redraw fixture")
	_expect_equal(interpreter.run_until_yield().get("command"), "redraw_map", "map redraw command")

	var adapter = GodotAdapterScript.new()
	_expect_equal(
		adapter.picture_file_candidates({
			"pictureId": 32128,
			"picture": {
				"fileName": "../outside.png",
				"relativePath": "Splash Images/32128.png",
				"path": "C:/outside.png",
				"name": "portraits/mayor.png",
			},
		}),
		["32128.png", "portraits/mayor.png"],
		"picture candidates stay inside the campaign splash directory"
	)


func _test_party_state_actions() -> void:
	var bundle = _party_state_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:condition"), "begin party-condition fixture")
	var condition_check: Dictionary = interpreter.run_until_yield()
	_expect_equal(condition_check.get("command"), "check_party_condition", "condition yields typed check")
	_expect_equal(condition_check.get("payload", {}).get("conditionIndex"), 1, "condition preserves Waterworld index")
	_expect(bool(condition_check.get("payload", {}).get("requiredActive")), "condition requests active state")
	var condition_branch: Dictionary = interpreter.resume_party_condition_check(true)
	_expect_equal(condition_branch.get("command"), "start_encounter", "active condition follows its branch")
	_expect_equal(condition_branch.get("payload", {}).get("encounterKind"), "complex", "condition selects complex encounter")
	_expect_equal(condition_branch.get("payload", {}).get("encounterId"), 8, "condition preserves encounter ID")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:condition"), "restart party-condition fixture")
	interpreter.run_until_yield()
	var condition_fallthrough: Dictionary = interpreter.resume_party_condition_check(false)
	_expect_equal(condition_fallthrough.get("payload", {}).get("messageId"), 901, "inactive condition falls through")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:ally"), "begin ally-check fixture")
	var ally_check: Dictionary = interpreter.run_until_yield()
	_expect_equal(ally_check.get("command"), "check_party_ally", "ally action yields typed check")
	_expect_equal(ally_check.get("payload", {}).get("monsterId"), 71, "ally check preserves monster ID")
	_expect_equal(
		ally_check.get("payload", {}).get("monster", {}).get("displayName"),
		"Vodalian",
		"ally check resolves compiled monster"
	)
	var ally_branch: Dictionary = interpreter.resume_ally_check(true)
	_expect_equal(ally_branch.get("payload", {}).get("messageId"), 910, "present ally follows XAP branch")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:ally"), "restart ally-check fixture")
	interpreter.run_until_yield()
	var ally_fallthrough: Dictionary = interpreter.resume_ally_check(false)
	_expect_equal(ally_fallthrough.get("payload", {}).get("messageId"), 902, "absent ally continues when requested")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:ally-message"), "begin absent-ally message fixture")
	interpreter.run_until_yield()
	var ally_message: Dictionary = interpreter.resume_ally_check(false)
	_expect_equal(ally_message.get("payload", {}).get("messageId"), 903, "absent ally can show text and exit")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:add-ally"), "begin add-ally fixture")
	var add_ally: Dictionary = interpreter.run_until_yield()
	_expect_equal(add_ally.get("command"), "add_party_ally", "add ally yields typed mutation")
	_expect_equal(add_ally.get("payload", {}).get("monsterId"), 71, "add ally preserves monster ID")
	_expect_equal(add_ally.get("payload", {}).get("monster", {}).get("displayName"), "Vodalian", "add ally resolves monster")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:registration"), "begin registration fixture")
	var registration_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(registration_result.get("payload", {}).get("messageId"), 904, "registration gate is a no-op")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:random-xap"), "begin random XAP fixture")
	var random_presentation: Dictionary = interpreter.run_until_yield()
	_expect_equal(random_presentation.get("command"), "present_random_branch", "random branch presents message and sound")
	_expect_equal(random_presentation.get("payload", {}).get("targetId"), 500, "fixed random range selects its target")
	_expect_equal(random_presentation.get("payload", {}).get("soundId"), 10105, "random branch preserves sound")
	_expect_equal(random_presentation.get("payload", {}).get("messageId"), 905, "random branch preserves message")
	var random_xap: Dictionary = interpreter.resume_random_branch()
	_expect_equal(random_xap.get("payload", {}).get("messageId"), 910, "random branch resumes into XAP")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:random-gosub"), "begin random GOSUB fixture")
	var random_gosub: Dictionary = interpreter.run_until_yield()
	_expect_equal(random_gosub.get("payload", {}).get("messageId"), 912, "random GOSUB enters its XAP")
	_expect_equal(interpreter.call_stack.size(), 1, "random GOSUB retains its return frame")
	var random_return: Dictionary = interpreter.run_until_yield()
	_expect_equal(random_return.get("payload", {}).get("messageId"), 911, "random GOSUB returns to its next action")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:random-simple"), "begin random simple fixture")
	var random_simple: Dictionary = interpreter.run_until_yield()
	_expect_equal(random_simple.get("payload", {}).get("encounterKind"), "simple", "random branch starts simple encounter")
	_expect_equal(random_simple.get("payload", {}).get("encounterId"), 3, "random simple target is inclusive")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:random-complex"), "begin random complex fixture")
	var random_complex: Dictionary = interpreter.run_until_yield()
	_expect_equal(random_complex.get("payload", {}).get("encounterKind"), "complex", "random branch starts complex encounter")
	_expect_equal(random_complex.get("payload", {}).get("encounterId"), 8, "random complex target is inclusive")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("party:random-missing"), "begin malformed random fixture")
	var random_missing: Dictionary = interpreter.run_until_yield()
	_expect_equal(random_missing.get("status"), "error", "missing random Extra Code is explicit")
	_expect("-1700" in str(random_missing.get("message", "")), "missing random row retains signed ID")

	var adapter = GodotAdapterScript.new()
	_expect_equal(
		adapter.party_condition_status(1, {"WaterBreath": {"Duration": 10}}, 0),
		{"supported": true, "active": true},
		"Waterworld maps to active WaterBreath"
	)
	_expect_equal(
		adapter.party_condition_status(1, {"WaterBreath": {"Duration": 0}}, 0),
		{"supported": true, "active": false},
		"expired WaterBreath is inactive"
	)
	_expect_equal(
		adapter.party_condition_status(0, {}, 5),
		{"supported": true, "active": true},
		"torch condition uses remaining light time"
	)
	_expect_equal(
		adapter.party_condition_status(5, {}, 0),
		{"supported": false, "active": false},
		"Search remains an explicit unmapped condition"
	)
	var ally = AllyTestCharacter.new()
	_expect(
		adapter.party_has_classic_ally({"monsterId": 71, "monster": {"displayName": "Vodalian"}}, [ally]),
		"native ally name can satisfy a Classic check"
	)
	ally.name = "Renamed Ally"
	ally.set_meta("classic_monster_id", 71)
	_expect(
		adapter.party_has_classic_ally({"monsterId": 71, "monster": {"displayName": "Vodalian"}}, [ally]),
		"imported Classic monster ID survives ally renaming"
	)
	_expect_equal(
		adapter.resolve_classic_ally_bestiary_name(
			71,
			{"displayName": "Vodalian"},
			{"Vodalian": {"data": {"name": "Vodalian"}}}
		),
		"Vodalian",
		"ally resource resolves by exact display name"
	)
	_expect_equal(
		adapter.resolve_classic_ally_bestiary_name(
			71,
			{"displayName": "Vodalian"},
			{
				"Vodalian": {"data": {"name": "Vodalian"}},
				"Imported ally": {"data": {"name": "Other", "classicMonsterId": 71}},
			}
		),
		"Imported ally",
		"ally resource prefers explicit Classic monster ID"
	)


func _test_priest_turning_actions() -> void:
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	bundle.extra_codes_by_id[1] = {"id": 1, "values": [5, 0, 0, 0, 0]}
	bundle.battles_by_id[5] = {"id": 5}
	_add_stack_trigger(bundle, "priest:disable", -1, [
		_classic_action(0, 82, 0),
		_classic_action(1, 2, 1),
	])
	_add_stack_trigger(bundle, "priest:enable", -1, [
		_classic_action(0, 83, 0),
		_classic_action(1, 2, 1),
	])

	var interpreter = _interpreter(bundle)
	_expect(interpreter.runtime_state.priest_turning_enabled, "priest turning starts enabled")
	_expect(interpreter.begin_trigger("priest:disable"), "begin priest-turning disable fixture")
	var disabled: Dictionary = interpreter.run_until_yield()
	_expect_equal(disabled.get("command"), "set_priest_turning", "disable yields typed state command")
	_expect(not bool(disabled.get("payload", {}).get("enabled")), "opcode 82 disables priest turning")
	_expect_equal(disabled.get("payload", {}).get("soundId"), 10105, "disable preserves Classic sound")
	_expect_equal(
		disabled.get("payload", {}).get("message", {}).get("text"),
		"You may not use your ability to turn undead or nether spawn.",
		"disable preserves Classic feedback"
	)
	_expect(not interpreter.runtime_state.priest_turning_enabled, "disabled state is authoritative")
	var disabled_battle: Dictionary = interpreter.run_until_yield()
	_expect_equal(disabled_battle.get("command"), "start_battle", "disable action continues to battle")
	_expect(
		not bool(disabled_battle.get("payload", {}).get("priestTurningEnabled")),
		"battle request carries disabled turning state"
	)

	var restored = StateScript.new()
	restored.restore(interpreter.runtime_state.snapshot())
	_expect(not restored.priest_turning_enabled, "priest-turning gate survives snapshot")
	interpreter = InterpreterScript.new()
	interpreter.configure(bundle, restored)
	_expect(interpreter.begin_trigger("priest:enable"), "begin priest-turning enable fixture")
	var enabled: Dictionary = interpreter.run_until_yield()
	_expect(bool(enabled.get("payload", {}).get("enabled")), "opcode 83 enables priest turning")
	_expect_equal(enabled.get("payload", {}).get("soundId"), 20004, "enable preserves Classic sound")
	_expect_equal(
		enabled.get("payload", {}).get("message", {}).get("text"),
		"You regain your ability to turn undead and nether spawn.",
		"enable preserves Classic feedback"
	)
	_expect(restored.priest_turning_enabled, "enabled state is authoritative")
	var enabled_battle: Dictionary = interpreter.run_until_yield()
	_expect(
		bool(enabled_battle.get("payload", {}).get("priestTurningEnabled")),
		"battle request carries enabled turning state"
	)

	var legacy_state = StateScript.new()
	legacy_state.restore({})
	_expect(legacy_state.priest_turning_enabled, "older snapshots default priest turning to enabled")


func _test_combat_monster_presence_action() -> void:
	var bundle = _combat_monster_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("combat:present"), "begin combat-monster check fixture")
	var check: Dictionary = interpreter.run_until_yield()
	_expect_equal(check.get("command"), "check_combat_monster", "opcode 127 yields typed check")
	_expect_equal(check.get("payload", {}).get("monsterId"), 134, "combat check preserves monster ID")
	_expect_equal(
		check.get("payload", {}).get("monster", {}).get("displayName"),
		"Rat Demi-Lord",
		"combat check carries compiled monster identity"
	)
	var continued: Dictionary = interpreter.resume_combat_monster_check(true)
	_expect_equal(continued.get("command"), "show_text", "present monster continues combat macro")
	_expect_equal(continued.get("payload", {}).get("messageId"), 920, "present monster reaches next action")

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("combat:present")
	interpreter.run_until_yield()
	var stopped: Dictionary = interpreter.resume_combat_monster_check(false)
	_expect_equal(stopped.get("status"), "completed", "absent monster stops combat macro")
	_expect_equal(
		stopped.get("reason"),
		"required-combat-monster-absent",
		"absent-monster completion is explicit"
	)

	var adapter = GodotAdapterScript.new()
	var metadata_creature := CombatTestCreature.new("Imported enemy", 12)
	metadata_creature.set_meta("classic_monster_id", 134)
	var named_creature := CombatTestCreature.new("Rat Demi-Lord 134", 12)
	var dead_creature := CombatTestCreature.new("Rat Demi-Lord 134", 0)
	_expect(
		adapter.combat_has_classic_monster(
			{"monsterId": 134},
			[CombatTestButton.new(metadata_creature)]
		),
		"combat roster resolves explicit Classic metadata"
	)
	_expect(
		adapter.combat_has_classic_monster(
			{"monsterId": 134},
			[CombatTestButton.new(named_creature)]
		),
		"combat roster resolves current CoB bestiary suffixes"
	)
	_expect(
		not adapter.combat_has_classic_monster(
			{"monsterId": 134},
			[CombatTestButton.new(dead_creature)]
		),
		"combat roster ignores defeated matching monsters"
	)
	_expect(
		adapter.combat_has_classic_monster(
			{"monsterId": 134},
			[{"creature": {"classicMonsterId": 134, "curHP": 1}}]
		),
		"combat roster accepts converted dictionary metadata"
	)


func _test_combat_monster_destruction_action() -> void:
	var bundle = _combat_monster_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("combat:destroy"), "begin combat-monster destruction fixture")
	var command: Dictionary = interpreter.run_until_yield()
	_expect_equal(command.get("command"), "destroy_combat_monsters", "opcode 125 yields typed mutation")
	_expect_equal(command.get("payload", {}).get("monsterId"), 134, "destruction preserves monster ID")
	_expect_equal(command.get("payload", {}).get("maxMatches"), 100, "zero destruction limit becomes 100")
	_expect(
		not bool(command.get("payload", {}).get("includeAllFactions")),
		"default destruction targets hostile monsters"
	)
	_expect_equal(
		interpreter.run_until_yield().get("payload", {}).get("messageId"),
		921,
		"destruction command continues to the next combat action"
	)

	var adapter = GodotAdapterScript.new()
	var enemy_one := CombatTestButton.new(CombatTestCreature.new("Rat Demi-Lord 134", 10))
	var enemy_two := CombatTestButton.new(CombatTestCreature.new("Rat Demi-Lord 134", 10))
	var ally := CombatTestButton.new(CombatTestCreature.new("Rat Demi-Lord 134", 10, 0))
	var other := CombatTestButton.new(CombatTestCreature.new("Podling 42", 10))
	var defeated := CombatTestButton.new(CombatTestCreature.new("Rat Demi-Lord 134", 0))
	var roster := [enemy_one, enemy_two, ally, other, defeated]
	var limited: Array = adapter.select_classic_combatants(
		{"monsterId": 134, "maxMatches": 1, "includeAllFactions": false},
		roster
	)
	_expect_equal(limited, [enemy_one], "destruction honors its match limit")
	var hostile_only: Array = adapter.select_classic_combatants(
		{"monsterId": 134, "maxMatches": 100, "includeAllFactions": false},
		roster
	)
	_expect_equal(hostile_only, [enemy_one, enemy_two], "destruction defaults to hostile matches")
	var all_factions: Array = adapter.select_classic_combatants(
		{"monsterId": 134, "maxMatches": 100, "includeAllFactions": true},
		roster
	)
	_expect_equal(all_factions, [enemy_one, enemy_two, ally], "destruction can include allied matches")
	var combat_state := CombatTestState.new(roster)
	_expect_equal(
		adapter.remove_classic_combatants(combat_state, all_factions),
		3,
		"combat adapter removes every selected match"
	)
	_expect_equal(combat_state.all_battle_creatures_btns.size(), 2, "removed matches leave the live roster")
	_expect_equal(combat_state.battle_creatures_yet_to_act_btns.size(), 2, "removed matches leave initiative")
	_expect_equal(combat_state.battle_dead_enemies.size(), 2, "only hostile removals enter battle rewards")


func _test_lower_undead_deanimation_action() -> void:
	var bundle = _combat_monster_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("combat:deanimate"), "begin lower-undead deanimation fixture")
	var command: Dictionary = interpreter.run_until_yield()
	_expect_equal(command.get("command"), "deanimate_lower_undead", "opcode 121 yields typed mutation")
	_expect_equal(command.get("payload", {}).get("extraCodeId"), 0, "deanimation preserves Extra Code ID")
	_expect_equal(command.get("payload", {}).get("monsterIds"), [17, 78], "deanimation selects lower undead IDs")
	_expect_equal(
		interpreter.run_until_yield().get("payload", {}).get("messageId"),
		922,
		"deanimation command continues to the next combat action"
	)

	var adapter = GodotAdapterScript.new()
	var lower_enemy := CombatTestButton.new(CombatTestCreature.new("Skeletal Beast 17", 10))
	var lower_ally := CombatTestButton.new(CombatTestCreature.new("Zombie 78", 10, 0))
	var higher_undead := CombatTestButton.new(CombatTestCreature.new("Skeletal Giant 19", 10))
	var living_creature := CombatTestButton.new(CombatTestCreature.new("Podling 42", 10))
	var defeated_lower := CombatTestButton.new(CombatTestCreature.new("Skeletal Beast 17", 0))
	var roster := [lower_enemy, lower_ally, higher_undead, living_creature, defeated_lower]
	var selected: Array = adapter.select_classic_combatants_by_ids([17, 78], roster)
	_expect_equal(selected, [lower_enemy, lower_ally], "deanimation ignores higher and defeated undead")
	var combat_state := CombatTestState.new(roster)
	_expect_equal(
		adapter.remove_classic_combatants(combat_state, selected),
		2,
		"deanimation removes lower undead from every faction"
	)
	_expect_equal(combat_state.battle_dead_enemies, [lower_enemy.creature], "only hostile undead enter rewards")


func _test_combat_monster_rout_action() -> void:
	var bundle = _combat_monster_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("combat:rout"), "begin combat-monster rout fixture")
	var command: Dictionary = interpreter.run_until_yield()
	_expect_equal(command.get("command"), "rout_combat_monsters", "opcode 123 yields typed mutation")
	_expect_equal(command.get("payload", {}).get("extraCodeId"), 2, "rout preserves Extra Code ID")
	_expect_equal(command.get("payload", {}).get("monsterIds"), [134, 42], "rout preserves monster IDs")
	_expect(bool(command.get("payload", {}).get("sameFactionAsActor")), "rout preserves faction rule")
	_expect(bool(command.get("payload", {}).get("permanent")), "rout preserves permanent duration")
	_expect_equal(command.get("payload", {}).get("surrenderPercent"), 50, "rout preserves surrender value")
	_expect_equal(
		interpreter.run_until_yield().get("payload", {}).get("messageId"),
		924,
		"rout command continues to the next combat action"
	)

	var adapter = GodotAdapterScript.new()
	var matching_enemy := CombatTestButton.new(CombatTestCreature.new("Rat Demi-Lord 134", 10, 1))
	var second_enemy := CombatTestButton.new(CombatTestCreature.new("Podling 42", 10, 1))
	var matching_ally := CombatTestButton.new(CombatTestCreature.new("Rat Demi-Lord 134", 10, 0))
	var defeated_enemy := CombatTestButton.new(CombatTestCreature.new("Podling 42", 0, 1))
	var other_enemy := CombatTestButton.new(CombatTestCreature.new("Skeletal Beast 17", 10, 1))
	var roster := [matching_enemy, second_enemy, matching_ally, defeated_enemy, other_enemy]
	var selected: Array = adapter.select_classic_combatants_by_ids_and_faction([134, 42], 1, roster)
	_expect_equal(selected, [matching_enemy, second_enemy], "rout selects living IDs on the actor faction")
	_expect_equal(
		adapter.PERMANENT_FLEEING_TRAIT_PATH,
		"res://shared_assets/traits/p_fleeing.gd",
		"rout maps to Remake's permanent fleeing trait"
	)
	_expect_equal(
		adapter.apply_classic_rout(selected, GodotAdapterScript),
		2,
		"rout applies native fleeing to every match"
	)
	for combatant: Variant in selected:
		_expect_equal(combatant.creature.applied_traits.size(), 1, "routed creature receives one trait")
		_expect_equal(
			str(combatant.creature.applied_traits[0]["script"].resource_path),
			"res://scripts/classic_runtime/classic_godot_command_adapter.gd",
			"rout applies the supplied trait script"
		)


func _test_battle_round_macro_action() -> void:
	var bundle = _combat_monster_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(
		interpreter.begin_trigger("combat:round", 0, {"combatRound": 3, "battleMacro": -118}),
		"begin exact-round battle macro fixture"
	)
	var activation: Dictionary = interpreter.run_until_yield()
	_expect_equal(
		activation.get("command"),
		"activate_battle_round_macro",
		"opcode 126 yields typed activation"
	)
	_expect_equal(activation.get("payload", {}).get("roundIndex"), 2, "battle macro uses elapsed rounds")
	_expect_equal(activation.get("payload", {}).get("targetMacroId"), 950, "battle macro selects target")
	_expect(bool(activation.get("payload", {}).get("disableSchedule")), "one-shot macro disables schedule")
	var target_result: Dictionary = interpreter.resume_battle_round_macro()
	_expect_equal(target_result.get("command"), "show_text", "battle macro enters its target action point")
	_expect_equal(target_result.get("payload", {}).get("messageId"), 925, "battle macro runs selected target")

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("combat:round", 0, {"combatRound": 2, "battleMacro": -118})
	var wrong_round: Dictionary = interpreter.run_until_yield()
	_expect_equal(wrong_round.get("status"), "completed", "exact-round macro skips other rounds")
	_expect_equal(wrong_round.get("reason"), "battle-round-macro-skipped", "round skip is explicit")

	interpreter = _interpreter(bundle)
	interpreter.set_percent_roll_provider(func() -> int: return 25)
	interpreter.begin_trigger("combat:chance", 0, {"combatRound": 4, "battleMacro": -119})
	var chance_activation: Dictionary = interpreter.run_until_yield()
	_expect_equal(chance_activation.get("payload", {}).get("chanceRoll"), 25, "chance macro uses inclusive roll")
	_expect(bool(chance_activation.get("payload", {}).get("repeat")), "repeating chance macro stays scheduled")
	_expect(
		not bool(chance_activation.get("payload", {}).get("disableSchedule")),
		"repeating macro preserves schedule"
	)
	_expect_equal(
		interpreter.resume_battle_round_macro().get("payload", {}).get("messageId"),
		926,
		"successful chance macro runs its target"
	)

	interpreter = _interpreter(bundle)
	interpreter.set_percent_roll_provider(func() -> int: return 26)
	interpreter.begin_trigger("combat:chance", 0, {"combatRound": 4, "battleMacro": -119})
	_expect_equal(
		interpreter.run_until_yield().get("reason"),
		"battle-round-macro-skipped",
		"chance macro skips rolls above its threshold"
	)

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("combat:random", 0, {"combatRound": 2, "battleMacro": -120})
	var random_activation: Dictionary = interpreter.run_until_yield()
	_expect(bool(random_activation.get("payload", {}).get("randomTarget")), "mode two selects a random macro")
	_expect_equal(random_activation.get("payload", {}).get("targetMacroId"), 952, "singleton range is stable")
	_expect_equal(
		interpreter.resume_battle_round_macro().get("payload", {}).get("messageId"),
		927,
		"random battle macro runs its selected target"
	)

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("combat:round", 0, {"combatRound": 3, "battleMacro": 118})
	_expect_equal(
		interpreter.run_until_yield().get("reason"),
		"legacy-battle-macro-disabled",
		"positive legacy battle macro is ignored"
	)
	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("combat:round")
	_expect_equal(
		interpreter.run_until_yield().get("status"),
		"error",
		"battle macro stops without round context"
	)
	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("combat:round", 0, {"combatRound": 0})
	_expect_equal(
		interpreter.run_until_yield().get("status"),
		"error",
		"battle macro rejects a zero-based round context"
	)

	var adapter = GodotAdapterScript.new()
	var battle_data := {"battleMacro": -119}
	_expect(adapter.apply_battle_round_macro_schedule(battle_data, false), "repeat schedule is accepted")
	_expect_equal(battle_data.get("battleMacro"), -119, "repeat schedule remains active")
	_expect(adapter.apply_battle_round_macro_schedule(battle_data, true), "one-shot schedule is accepted")
	_expect_equal(battle_data.get("battleMacro"), 0, "one-shot schedule is disabled")


func _test_forced_battle_end_action() -> void:
	var bundle = _combat_monster_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("combat:end"), "begin forced battle-end fixture")
	var command: Dictionary = interpreter.run_until_yield()
	_expect_equal(command.get("command"), "end_classic_battle", "opcode 100 yields typed battle end")
	_expect_equal(command.get("payload", {}).get("outcome"), "won", "forced battle end reports victory")
	_expect_equal(command.get("payload", {}).get("lootMode"), 5, "forced battle end preserves loot mode")
	_expect_equal(
		command.get("payload", {}).get("rewardMode"),
		"experience_only",
		"forced battle end requests experience-only rewards"
	)
	_expect_equal(command.get("payload", {}).get("resumeSlot"), 8, "forced battle end preserves resume slot")
	var completed: Dictionary = interpreter.resume_forced_battle_end()
	_expect_equal(completed.get("status"), "completed", "forced battle end completes the combat macro")
	_expect_equal(completed.get("reason"), "battle-ended", "forced battle completion is explicit")

	var defeated := [
		{"experience": 40, "money": [3, 2, 1], "inventory": ["Test blade"]},
		{"experience": 15, "money": [4, 0, 0], "inventory": ["Test shield"]},
	]
	var normal_rewards: Dictionary = BattleRewardRulesScript.collect(defeated)
	_expect_equal(normal_rewards.get("experience"), 55, "normal battle rewards retain experience")
	_expect_equal(normal_rewards.get("money"), [7, 2, 1], "normal battle rewards retain money")
	_expect_equal(
		normal_rewards.get("treasure"),
		["Test blade", "Test shield"],
		"normal battle rewards retain inventory"
	)
	var experience_rewards: Dictionary = BattleRewardRulesScript.collect(defeated, true)
	_expect_equal(experience_rewards.get("experience"), 55, "experience-only rewards retain experience")
	_expect_equal(experience_rewards.get("money"), [0, 0, 0], "experience-only rewards omit money")
	_expect_equal(experience_rewards.get("treasure"), [], "experience-only rewards omit inventory")


func _test_action_point_copy_mutations(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:5"), "begin CoB same-door action")
	var copied_text: Dictionary = interpreter.run_until_yield()
	_expect_equal(copied_text.get("command"), "show_text", "same-door copy executes borrowed actions")
	_expect_equal(copied_text.get("payload", {}).get("messageId"), -69, "same-door copy reaches source-backed text")
	_expect_equal(interpreter.trace[0].get("code"), 8, "same-door trace records copy action")
	_expect_equal(interpreter.trace[1].get("triggerId"), "Data DD:0:5", "borrowed actions retain active AP identity")
	_expect_equal(interpreter.active_action_point_header.get("recordIndex"), 5, "same-door copy preserves active header")
	_expect_equal(interpreter.run_until_yield().get("reason"), "keep-codes", "borrowed AP reaches its keep action")
	_expect(
		interpreter.runtime_state.get_action_point_override("Data DD:0:5").is_empty(),
		"same-door copy remains transient"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:27", 5), "begin CoB action-data patch")
	var patched_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(patched_result.get("reason"), "keep-codes", "action-data patch continues in source AP")
	var patched: Dictionary = interpreter.runtime_state.get_action_point_override("Data DD:0:27")
	_expect_equal(patched.get("recordIndex"), 27, "action-data patch preserves target record")
	_expect_equal(patched.get("coordinate", {}).get("x"), 47, "action-data patch preserves target x")
	_expect_equal(patched.get("coordinate", {}).get("y"), 5, "action-data patch preserves target y")
	_expect_equal(patched.get("actions", []).size(), 3, "action-data patch copies all authored XAP actions")
	_expect_equal(patched.get("actions", [])[0].get("id"), 241, "action-data patch copies source-backed XAP text")
	_expect_equal(
		bundle.get_trigger("Data DD:0:27").get("actions", [])[0].get("id"),
		-238,
		"action-data patch leaves compiled AP immutable"
	)

	var restored = StateScript.new()
	restored.restore(interpreter.runtime_state.snapshot())
	var replay = InterpreterScript.new()
	replay.configure(bundle, restored)
	_expect(replay.begin_trigger("Data DD:0:27"), "restart patched CoB action point")
	_expect_equal(
		replay.run_until_yield().get("payload", {}).get("messageId"),
		241,
		"patched action point survives snapshot"
	)

	var borrowed_target: Dictionary = bundle.get_trigger("Data DD:0:4").duplicate(true)
	borrowed_target["actions"] = bundle.get_extra_action_point(18).get("actions", []).duplicate(true)
	restored.set_action_point_override("Data DD:0:4", borrowed_target)
	replay = InterpreterScript.new()
	replay.configure(bundle, restored)
	_expect(replay.begin_trigger("Data DD:0:5"), "restart same-door action with patched target")
	_expect_equal(
		replay.run_until_yield().get("payload", {}).get("messageId"),
		241,
		"same-door copy reads the target's persistent override"
	)

	var miss_state = StateScript.new()
	miss_state.configure_from_bundle(bundle)
	var percent_door: Dictionary = bundle.get_trigger("Data DD:0:5").duplicate(true)
	percent_door["percent"] = 50
	miss_state.set_action_point_override("Data DD:0:5", percent_door)
	var miss_interpreter = InterpreterScript.new()
	miss_interpreter.configure(bundle, miss_state)
	miss_interpreter.set_percent_roll_provider(func() -> int: return 100)
	_expect(miss_interpreter.begin_trigger("Data DD:0:5"), "begin same-door percentage recheck")
	var miss_result: Dictionary = miss_interpreter.run_until_yield()
	_expect_equal(miss_result.get("reason"), "same-door-percent-miss", "same-door copy rechecks active percentage")
	_expect_equal(miss_interpreter.trace.size(), 1, "failed same-door recheck skips borrowed actions")


func _test_action_data_patch_variants() -> void:
	var bundle = _action_data_patch_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("patch:dungeon"), "begin explicit dungeon action-data patch")
	_expect_equal(interpreter.run_until_yield().get("reason"), "keep-codes", "dungeon patch completes")
	var dungeon_patch: Dictionary = interpreter.runtime_state.get_action_point_override("Data DDD:2:4")
	_expect_equal(
		dungeon_patch.get("actions", [])[0].get("id"),
		902,
		"action-data level selector targets a dungeon AP"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("patch:simple"), "begin simple-result action-data patch")
	_expect_equal(interpreter.run_until_yield().get("command"), "start_encounter", "simple patch continues to encounter")
	var simple_result: Dictionary = interpreter.resume_encounter(3)
	_expect_equal(simple_result.get("payload", {}).get("messageId"), 900, "simple result uses copied XAP")
	_expect_equal(
		_action_id_at_slot(bundle.get_encounter("simple", 10).get("actions", []), 16),
		802,
		"simple patch leaves compiled encounter immutable"
	)
	var restored = StateScript.new()
	restored.restore(interpreter.runtime_state.snapshot())
	var restored_simple := restored.get_effective_simple_encounter(bundle.get_encounter("simple", 10))
	_expect_equal(_action_id_at_slot(restored_simple.get("actions", []), 16), 900, "simple result patch survives snapshot")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("patch:complex"), "begin complex-result action-data patch")
	_expect_equal(interpreter.run_until_yield().get("command"), "start_encounter", "complex patch continues to encounter")
	var complex_result: Dictionary = interpreter.resume_encounter(2)
	_expect_equal(complex_result.get("payload", {}).get("messageId"), 901, "complex result uses copied XAP")
	_expect_equal(
		_action_id_at_slot(bundle.get_encounter("complex", 11).get("actions", []), 8),
		811,
		"complex patch leaves compiled encounter immutable"
	)


func _test_battle_request(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:27", 2), "begin CoB battle action")
	var result: Dictionary = interpreter.run_until_yield()
	var payload: Dictionary = result.get("payload", {})
	_expect_equal(result.get("command"), "start_battle", "battle command")
	_expect_equal(payload.get("battleIdRange"), [38, 38], "battle range decoded from EDCD row 70")
	_expect_equal(payload.get("soundId"), 30000, "battle sound decoded from EDCD row 70")
	_expect_equal(payload.get("battle", {}).get("id"), 38, "battle record resolves")


func _test_choice_continuation(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:27", 1), "begin CoB inverted choice")
	var choice_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(choice_result.get("command"), "choice", "choice yields to Godot host")
	var declined_result: Dictionary = interpreter.resume_choice(false)
	_expect_equal(declined_result.get("status"), "completed", "declining inverted CoB choice exits AP")
	_expect_equal(declined_result.get("reason"), "choice-exit", "choice exit reason")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:27", 1), "restart CoB inverted choice")
	interpreter.run_until_yield()
	var accepted_result: Dictionary = interpreter.resume_choice(true)
	_expect_equal(accepted_result.get("command"), "start_battle", "accepting inverted CoB choice continues to battle")


func _test_sound_and_treasure(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:10", 3), "begin CoB sound action")
	var sound_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(sound_result.get("command"), "play_sound", "sound command")
	_expect_equal(sound_result.get("payload", {}).get("soundId"), 10105, "sound resource id")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:30", 5), "begin CoB treasure action")
	var treasure_result: Dictionary = interpreter.run_until_yield()
	var payload: Dictionary = treasure_result.get("payload", {})
	_expect_equal(treasure_result.get("command"), "give_treasure", "treasure command")
	_expect_equal(payload.get("treasureId"), 11, "treasure record id")
	_expect_equal(payload.get("treasure", {}).get("exp"), 1200, "treasure record resolves")
	_expect_equal(payload.get("lootMode"), 1, "fixed treasure uses Classic loot mode 1")


func _test_shop_actions() -> void:
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	var item_ids: Array = []
	var quantities: Array = []
	item_ids.resize(1000)
	quantities.resize(1000)
	item_ids.fill(0)
	quantities.fill(0)
	for stock: Array in [
		[0, 1, 3],
		[200, 209, 2],
		[400, 418, 1],
		[600, 675, 1],
		[800, 803, 4],
	]:
		item_ids[stock[0]] = stock[1]
		quantities[stock[0]] = stock[2]
	bundle.shops_by_id[2] = {
		"id": 2,
		"inflation": 95,
		"itemIds": item_ids,
		"quantities": quantities,
	}
	bundle.item_texts_by_id[675] = {
		"itemId": 675,
		"identifiedName": "Quiver of Protection +2",
	}
	bundle.item_texts_by_id[617] = {
		"itemId": 617,
		"identifiedName": "Yellow Luck Stone +3",
	}
	bundle.extra_codes_by_id[7] = {"values": [-2, 1, 10, 600, 700]}
	bundle.extra_codes_by_id[8] = {"values": [2, 1, 100, 0, 0]}
	_add_stack_trigger(bundle, "shop:available", -1, [
		_classic_action(0, 6, 2),
		_classic_action(7, 24, 0),
	])
	_add_stack_trigger(bundle, "shop:immediate", -1, [
		_classic_action(0, 6, -2),
		_classic_action(7, 24, 0),
	])
	_add_stack_trigger(bundle, "shop:missing", -1, [_classic_action(0, 6, 3)])
	_add_stack_trigger(bundle, "shop:restricted", -1, [
		_classic_action(0, 73, 7),
		_classic_action(7, 24, 0),
	])
	_add_stack_trigger(bundle, "shop:single-range", -1, [_classic_action(0, 73, 8)])
	_add_stack_trigger(bundle, "shop:missing-ranges", -1, [_classic_action(0, 73, 9)])

	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("shop:available"), "begin available-shop action")
	var available_result: Dictionary = interpreter.run_until_yield()
	var available_payload: Dictionary = available_result.get("payload", {})
	_expect_equal(available_result.get("command"), "load_shop", "shop yields typed command")
	_expect_equal(available_payload.get("shopId"), 2, "shop ID is absolute")
	_expect_equal(available_payload.get("openImmediately"), false, "positive shop stays available")
	_expect_equal(available_payload.get("acceptRanges"), [0, 0, 0, 0], "plain shop clears restrictions")
	_expect_equal(available_payload.get("itemTexts", []).size(), 1, "shop carries scenario item text")
	_expect_equal(interpreter.run_until_yield().get("reason"), "keep-codes", "shop command resumes")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("shop:immediate"), "begin immediate-shop action")
	var immediate_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(
		immediate_result.get("payload", {}).get("openImmediately"),
		true,
		"negative shop opens immediately"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("shop:missing"), "begin missing-shop action")
	_expect_equal(interpreter.run_until_yield().get("status"), "error", "missing shop stops safely")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("shop:restricted"), "begin restricted-shop action")
	var restricted_result: Dictionary = interpreter.run_until_yield()
	var restricted_payload: Dictionary = restricted_result.get("payload", {})
	_expect_equal(restricted_result.get("command"), "load_shop", "restricted shop uses shop command")
	_expect_equal(restricted_payload.get("shopId"), 2, "restricted shop resolves Extra Code shop ID")
	_expect_equal(restricted_payload.get("openImmediately"), true, "signed Extra Code shop ID opens")
	_expect_equal(
		restricted_payload.get("acceptRanges"),
		[1, 10, 600, 700],
		"restricted shop carries both inclusive ranges"
	)
	_expect_equal(
		restricted_payload.get("itemTexts", []).size(),
		2,
		"restricted shop carries scenario item identities beyond its stock"
	)

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("shop:single-range"), "begin single-range shop action")
	var single_range_payload: Dictionary = interpreter.run_until_yield().get("payload", {})

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("shop:missing-ranges"), "begin missing restricted-shop row")
	_expect_equal(
		interpreter.run_until_yield().get("status"),
		"error",
		"missing restricted-shop Extra Code stops safely"
	)

	var item_mapping := {
		1: "Dagger",
		209: "Leather Armor",
		418: "Leather Cap",
		803: "Quiver of Arrows",
	}
	var available_items := {
		"Dagger": {},
		"Leather Armor": {},
		"Leather Cap": {},
		"Yellow Luck Stone +3": {},
		"Quiver of Protection +2": {},
		"Quiver of Arrows": {},
	}
	var built: Dictionary = GodotAdapterScript.new().build_shop_inventory(
		available_payload,
		item_mapping,
		available_items
	)
	var native_shop: Dictionary = built.get("shop", {})
	_expect_equal(native_shop.get("sell_rate"), 0.95, "shop inflation sets purchase rate")
	_expect_equal(native_shop.get("buy_rate"), 0.95, "shop inflation sets resale rate")
	_expect_equal(native_shop.get("Weapons"), [["Dagger", 3, -1]], "weapon slots map to Weapons")
	_expect_equal(native_shop.get("Armor"), [["Leather Armor", 2, -1]], "body armor maps to Armor")
	_expect_equal(native_shop.get("Limbs"), [["Leather Cap", 1, -1]], "limb armor maps to Limbs")
	_expect_equal(
		native_shop.get("Magic"),
		[["Quiver of Protection +2", 1, -1]],
		"scenario item text can resolve magic stock"
	)
	_expect_equal(native_shop.get("Supplies"), [["Quiver of Arrows", 4, -1]], "supplies map by slot")
	_expect_equal(built.get("itemCount"), 11, "shop reports total stock quantity")

	var restricted_built: Dictionary = GodotAdapterScript.new().build_shop_inventory(
		restricted_payload,
		item_mapping,
		available_items
	)
	var restricted_shop: Dictionary = restricted_built.get("shop", {})
	_expect_equal(
		restricted_shop.get("classic_accept_ranges"),
		[1, 10, 600, 700],
		"native shop retains Classic range evidence"
	)
	var accepted_item_names: Array = restricted_shop.get("accepted_item_names", {}).keys()
	accepted_item_names.sort()
	_expect_equal(
		accepted_item_names,
		["Dagger", "Quiver of Protection +2", "Yellow Luck Stone +3"],
		"native shop resolves both accepted ranges to available item identities"
	)
	_expect(
		ShopRulesScript.accepts_item(
			"restricted",
			{"restricted": restricted_shop},
			{"name": "Dagger"}
		),
		"restricted shop accepts range-one item"
	)
	_expect(
		ShopRulesScript.accepts_item(
			"restricted",
			{"restricted": restricted_shop},
			{"name": "Yellow Luck Stone +3"}
		),
		"restricted shop accepts scenario item in range two"
	)
	_expect(
		not ShopRulesScript.accepts_item(
			"restricted",
			{"restricted": restricted_shop},
			{"name": "Leather Armor"}
		),
		"restricted shop rejects item outside both ranges"
	)
	var single_range_built: Dictionary = GodotAdapterScript.new().build_shop_inventory(
		single_range_payload,
		item_mapping,
		available_items
	)
	_expect(
		not single_range_built.get("shop", {}).has("accepted_item_names"),
		"one populated range preserves Classic's unrestricted transfer result"
	)
	_expect(
		ShopRulesScript.accepts_item(
			"single",
			{"single": single_range_built.get("shop", {})},
			{"name": "Leather Armor"}
		),
		"single-range Classic shop remains unrestricted"
	)
	var alias_items: Array = []
	var alias_quantities: Array = []
	alias_items.resize(612)
	alias_quantities.resize(612)
	alias_items.fill(0)
	alias_quantities.fill(0)
	alias_items[98] = 98
	alias_quantities[98] = 1
	alias_items[610] = 610
	alias_quantities[610] = 1
	alias_items[611] = 611
	alias_quantities[611] = 2
	var aliases: Dictionary = GodotAdapterScript.new().build_shop_inventory(
		{"shop": {"itemIds": alias_items, "quantities": alias_quantities}},
		{},
		{"Quarter Staff": {}, "Waterworld": {}, "Heal Small Wounds": {}}
	)
	_expect_equal(
		aliases.get("shop", {}).get("Weapons"),
		[["Quarter Staff", 1, -1]],
		"duplicate shared weapon ID resolves"
	)
	_expect_equal(
		aliases.get("shop", {}).get("Magic"),
		[["Waterworld", 1, -1], ["Heal Small Wounds", 2, -1]],
		"duplicate shared magic IDs resolve"
	)


func _test_service_actions() -> void:
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	_add_stack_trigger(bundle, "services", -1, [
		_classic_action(0, 49, 0),
		_classic_action(1, 32, 150),
		_classic_action(7, 24, 0),
	])
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("services"), "begin banking and temple actions")
	var bank_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(bank_result.get("command"), "enable_banking", "bank action yields typed command")
	_expect_equal(bank_result.get("payload", {}).get("soundId"), 128, "bank action preserves sound")
	_expect_equal(bank_result.get("payload", {}).get("warningId"), 106, "bank action preserves warning")
	var temple_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(temple_result.get("command"), "offer_temple", "temple action yields typed command")
	_expect_equal(temple_result.get("payload", {}).get("costPercent"), 150, "temple cost percentage")
	_expect_equal(temple_result.get("payload", {}).get("soundId"), 10105, "temple action preserves sound")
	_expect_equal(interpreter.run_until_yield().get("reason"), "keep-codes", "service actions resume")

	var adapter = GodotAdapterScript.new()
	var standard: Dictionary = adapter.build_temple_services(100)
	_expect_equal(
		standard.get("services", []).map(func(service: Array) -> int: return int(service[2])),
		[250, 350, 850, 200, 750, 200, 350, 550, 1500],
		"standard temple uses Classic base prices"
	)
	var expensive: Dictionary = adapter.build_temple_services(300)
	_expect_equal(expensive.get("services", [])[0][2], 750, "temple percentage scales prices")
	_expect_equal(
		adapter.build_temple_services(33).get("services", [])[0][2],
		82,
		"temple price scaling truncates fractional gold"
	)
	_expect_equal(
		adapter.build_temple_services(-1).get("status"),
		"error",
		"negative temple percentage stops safely"
	)
	_expect(
		TemplePaymentScript.can_afford_service(75, 100, 150),
		"temple combines character and pooled gold for affordability"
	)
	_expect_equal(
		TemplePaymentScript.balances_after_service(75, 100, 150),
		[25, 0],
		"temple spends pooled gold before character gold"
	)
	_expect(
		not TemplePaymentScript.can_afford_service(40, 50, 100),
		"temple rejects an unaffordable service"
	)


func _test_treasure_delivery(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:5:3"), "begin CoB treasure delivery path")
	interpreter.run_until_yield()
	interpreter.resume_encounter(2)
	var treasure_result: Dictionary = interpreter.run_until_yield()
	var payload: Dictionary = treasure_result.get("payload", {})
	_expect_equal(
		payload.get("itemTexts", []).map(
			func(item_text: Dictionary) -> int: return int(item_text.get("itemId", 0))
		),
		[600, 601, 617, 801, 806],
		"treasure payload carries exported item text records"
	)
	var delivery: Dictionary = GodotAdapterScript.new().build_treasure_delivery(
		payload,
		{
			600: "Invisible Skin",
			601: "Adrenalin",
			617: "Yellow Luck Stone +3",
		},
		{
			"Invisible Skin": {},
			"Adrenalin": {},
			"Yellow Luck Stone +3": {},
			"Priest Scroll Case": {},
			"Parchment": {},
		}
	)
	_expect_equal(
		delivery.get("itemNames"),
		[
			"Invisible Skin",
			"Adrenalin",
			"Yellow Luck Stone +3",
			"Priest Scroll Case",
			"Parchment",
		],
		"treasure IDs resolve through shared mappings and scenario item text"
	)
	_expect_equal(delivery.get("money"), [0, 5, 2], "treasure preserves classic money")
	_expect_equal(delivery.get("experience"), 600, "treasure preserves classic experience")


func _test_map_mutations(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:69"), "begin CoB tile mutation")
	var tile_result: Dictionary = interpreter.run_until_yield()
	var tile_payload: Dictionary = tile_result.get("payload", {})
	_expect_equal(tile_result.get("command"), "set_map_tile", "tile mutation command")
	_expect_equal(tile_payload.get("levelType"), "land", "tile mutation map kind")
	_expect_equal(tile_payload.get("x"), 3, "land tile x keeps EDCD axis order")
	_expect_equal(tile_payload.get("y"), 28, "land tile y keeps EDCD axis order")
	_expect_equal(tile_payload.get("tileValue"), 193, "tile mutation value")
	_expect_equal(interpreter.runtime_state.get_tile("land", 0, 3, 28, -1), 193, "tile override persists")

	interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:30", 6), "begin CoB trigger mutation")
	var trigger_result: Dictionary = interpreter.run_until_yield()
	var trigger_payload: Dictionary = trigger_result.get("payload", {})
	_expect_equal(trigger_result.get("command"), "set_trigger_percent", "trigger mutation command")
	_expect_equal(trigger_payload.get("triggerIds"), [17], "single trigger id decoded")
	_expect_equal(trigger_payload.get("percent"), 100, "trigger percent decoded")
	_expect_equal(
		interpreter.runtime_state.get_trigger_percent("land", 0, 17, -1),
		100,
		"trigger override persists"
	)


func _test_complex_encounter(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:19"), "begin CoB complex encounter")
	var encounter_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(encounter_result.get("command"), "start_encounter", "complex encounter command")
	_expect_equal(encounter_result.get("payload", {}).get("encounterKind"), "complex", "complex encounter kind")
	var outcome_result: Dictionary = interpreter.resume_encounter(1)
	_expect_equal(outcome_result.get("command"), "show_text", "complex outcome executes first result block")
	_expect_equal(outcome_result.get("payload", {}).get("messageId"), 183, "complex result slot resolves")


func _test_complex_action_choices(bundle) -> void:
	var adapter = GodotAdapterScript.new()
	var cave_in: Dictionary = adapter.build_complex_action_choices(
		bundle.get_encounter("complex", 2),
		true
	)
	_expect_equal(
		cave_in.get("choices"),
		["Dig", "Throw stones at mountain", "Attempt to climb slope", "Back out"],
		"complex action choices expose shipped labels"
	)
	_expect_equal(
		cave_in.get("tokens"),
		["action:1", "action:1", "action:1", "back"],
		"complex actions share the source-backed result block"
	)
	var library: Dictionary = adapter.build_complex_action_choices(
		{
			"texts": [
				"Examine some books.",
				"Study quietly at a table.",
				"", "", "", "", "", "",
				"waterford",
			],
			"actionResult": 2,
		},
		false
	)
	_expect_equal(
		library.get("choices"),
		["Examine some books.", "Study quietly at a table."],
		"complex action choices exclude the separate spoken-word field"
	)


func _test_complex_word_results() -> void:
	var adapter = GodotAdapterScript.new()
	var archive := {
		"texts": [
			"Examine some books.",
			"Study quietly at a table.",
			"", "", "", "", "", "",
			"waterford",
		],
		"wordResult": 1,
	}
	var choices: Array = []
	var tokens: Array = []
	adapter._append_complex_word_choice(archive, choices, tokens)
	_expect_equal(choices, ["Speak"], "complex word response exposes the speech control")
	_expect_equal(tokens, ["word"], "complex word response uses its own selection token")
	choices.clear()
	tokens.clear()
	adapter._append_complex_word_choice({"wordResult": 0}, choices, tokens)
	_expect_equal(choices, [], "encounters without a word result omit the speech control")
	_expect_equal(
		adapter.resolve_complex_word_result(archive, "waterford"),
		1,
		"exact spoken word selects its authored result"
	)
	_expect_equal(
		adapter.resolve_complex_word_result(archive, "WATERFORD"),
		1,
		"spoken-word matching is case-insensitive"
	)
	_expect_equal(
		adapter.resolve_complex_word_result(archive, "waterford cellar"),
		1,
		"Classic accepts entered text beyond the matching word prefix"
	)
	_expect_equal(
		adapter.resolve_complex_word_result(archive, "water"),
		4,
		"short spoken-word prefixes use Classic's result 4 fallback"
	)
	_expect_equal(
		adapter.resolve_complex_word_result(archive, ""),
		4,
		"empty text cannot resolve a spoken-word result"
	)
	_expect_equal(
		adapter.resolve_complex_word_result(
			{
				"texts": ["", "", "", "", "", "", "", "", "magic phrase"],
				"wordResult": 3,
			},
			"MAGIC lantern"
		),
		3,
		"Classic stops the stored response at its first space"
	)
	var forty_character_response: Dictionary = archive.duplicate(true)
	forty_character_response["texts"][8] = "a".repeat(40) + "x"
	forty_character_response["wordResult"] = 2
	_expect_equal(
		adapter.resolve_complex_word_result(
			forty_character_response,
			"A".repeat(40) + "y"
		),
		2,
		"Classic compares no more than forty characters"
	)


func _test_encounter_lifecycle() -> void:
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	bundle.triggers_by_id["lifecycle:test"] = {
		"id": "lifecycle:test",
		"source": "Data DD",
		"actions": [{"slot": 0, "rawCode": 5, "code": 5, "id": 1}],
	}
	bundle.complex_encounters_by_id[1] = {
		"id": 1,
		"actions": [
			{"slot": 16, "rawCode": 1, "id": 303},
			{"slot": 24, "rawCode": 1, "id": 404},
		],
		"maxTimes": 2,
		"prompt": 0,
	}
	bundle.messages_by_id[303] = {"id": 303, "text": "Timed out"}
	bundle.messages_by_id[404] = {"id": 404, "text": "Try again"}
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("lifecycle:test"), "begin encounter lifecycle fixture")
	var encounter_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(
		encounter_result.get("payload", {}).get("remainingAttempts"),
		2,
		"encounter starts with its authored attempt count"
	)
	var first_failure: Dictionary = interpreter.resume_encounter(4)
	_expect_equal(
		first_failure.get("payload", {}).get("messageId"),
		404,
		"result 4 is unchanged before the final attempt"
	)
	var repeated: Dictionary = interpreter.run_until_yield()
	_expect_equal(repeated.get("command"), "start_encounter", "fallthrough repeats encounter")
	_expect_equal(
		repeated.get("payload", {}).get("remainingAttempts"),
		1,
		"encounter repetition decrements remaining attempts"
	)
	var timeout: Dictionary = interpreter.resume_encounter(4)
	_expect_equal(
		timeout.get("payload", {}).get("messageId"),
		303,
		"final complex result 4 uses Classic's result 3 timeout block"
	)
	var completed: Dictionary = interpreter.run_until_yield()
	_expect_equal(completed.get("status"), "completed", "final encounter attempt completes")


func _test_simple_encounter_mutation() -> void:
	var bundle = BundleScript.new()
	_expect(bundle.load_from_directory(FIXTURE), "CoB simple-option fixture loads: %s" % bundle.last_error)
	if not bundle.last_error.is_empty():
		return
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:8"), "begin CoB tavern encounter")
	var tavern_text: Dictionary = interpreter.run_until_yield()
	_expect_equal(tavern_text.get("payload", {}).get("messageId"), 75, "tavern intro message")
	var tavern: Dictionary = interpreter.run_until_yield()
	_expect_equal(tavern.get("payload", {}).get("encounterId"), 3, "tavern simple encounter")
	var barmaid: Dictionary = interpreter.resume_encounter(4)
	_expect_equal(barmaid.get("payload", {}).get("messageId"), 86, "barmaid response begins")
	var reopened: Dictionary = interpreter.run_until_yield()
	_expect_equal(reopened.get("command"), "start_encounter", "opcode 35 reopens the encounter")
	_expect_equal(
		reopened.get("payload", {}).get("remainingAttempts"),
		99,
		"opcode 35 does not consume an encounter attempt"
	)
	var effective_tavern: Dictionary = interpreter.runtime_state.get_effective_simple_encounter(
		bundle.get_encounter("simple", 3)
	)
	_expect_equal(
		effective_tavern.get("choiceResults", []).map(
			func(value: Variant) -> int: return int(value)
		),
		[1, 2, 3, 0],
		"opcode 35 removes its source choice"
	)
	_expect_equal(
		bundle.get_encounter("simple", 3).get("choiceResults", []).map(
			func(value: Variant) -> int: return int(value)
		),
		[1, 2, 3, 4],
		"opcode 35 leaves the compiled encounter immutable"
	)
	var restored = StateScript.new()
	restored.restore(interpreter.runtime_state.snapshot())
	_expect_equal(
		restored.get_effective_simple_encounter(bundle.get_encounter("simple", 3))
			.get("choiceResults", []).map(
				func(value: Variant) -> int: return int(value)
			),
		[1, 2, 3, 0],
		"simple option removal survives snapshot restore"
	)
	var cancelled: Dictionary = interpreter.resume_encounter(0)
	_expect_equal(cancelled.get("reason"), "encounter-cancelled", "party can leave the reopened tavern")

	bundle.triggers_by_id["simple-option:remote"] = {
		"id": "simple-option:remote",
		"source": "Data DD",
		"actions": [{"slot": 0, "rawCode": 4, "code": 4, "id": 4}],
	}
	var remote_interpreter = _interpreter(bundle)
	_expect(remote_interpreter.begin_trigger("simple-option:remote"), "begin remote option fixture")
	remote_interpreter.run_until_yield()
	var guards: Dictionary = remote_interpreter.resume_encounter(2)
	_expect_equal(guards.get("payload", {}).get("messageId"), 94, "remote mutation result begins")
	var crypt_map: Dictionary = remote_interpreter.run_until_yield()
	_expect_equal(crypt_map.get("payload", {}).get("messageId"), 95, "remote mutation result continues")
	var completed: Dictionary = remote_interpreter.run_until_yield()
	_expect_equal(completed.get("reason"), "keep-codes", "remote mutation result completes")
	_expect_equal(
		remote_interpreter.runtime_state.get_effective_simple_encounter(
			bundle.get_encounter("simple", 3)
		).get("choiceResults", []).map(
			func(value: Variant) -> int: return int(value)
		),
		[1, 2, 0, 0],
		"opcode 41 removes both Extra Code-selected choices"
	)
	_expect_equal(
		bundle.get_encounter("simple", 3).get("choiceResults", []).map(
			func(value: Variant) -> int: return int(value)
		),
		[1, 2, 3, 4],
		"opcode 41 leaves the compiled target immutable"
	)


func _test_spoken_word_archive() -> void:
	var bundle = BundleScript.new()
	_expect(
		bundle.load_from_directory(COB_SPOKEN_WORD_FIXTURE),
		"CoB spoken-word fixture loads: %s" % bundle.last_error
	)
	if not bundle.last_error.is_empty():
		return
	_expect_equal(bundle.get_player_map(2).get("level"), 0, "Waterford player map index")
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:6:28"), "begin CoB town archive")
	var encounter_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(encounter_result.get("command"), "start_encounter", "archive starts encounter")
	var first_message: Dictionary = interpreter.resume_encounter(1)
	_expect_equal(first_message.get("payload", {}).get("messageId"), 139, "archive result begins")
	var second_message: Dictionary = interpreter.run_until_yield()
	_expect_equal(second_message.get("payload", {}).get("messageId"), 153, "archive result continues")
	var map_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(map_result.get("command"), "give_map", "archive grants the Waterford map")
	_expect_equal(map_result.get("payload", {}).get("mapId"), 2, "archive map ID")
	_expect(not bool(map_result.get("payload", {}).get("display")), "positive map ID does not display")
	_expect(interpreter.runtime_state.is_map_owned(2), "archive map ownership persists")
	var repeated: Dictionary = interpreter.run_until_yield()
	_expect_equal(repeated.get("command"), "start_encounter", "archive reopens after result fallthrough")
	_expect_equal(
		repeated.get("payload", {}).get("remainingAttempts"),
		124,
		"archive decrements its source attempt count"
	)
	var effective: Dictionary = interpreter.runtime_state.get_effective_complex_encounter(
		bundle.get_encounter("complex", 1)
	)
	var first_result_actions: Array = effective.get("actions", []).filter(
		func(action: Dictionary) -> bool: return int(action.get("slot", -1)) < 8
	)
	_expect_equal(first_result_actions.size(), 1, "opcode 44 replaces the first result row")
	_expect_equal(first_result_actions[0].get("rawCode"), 24, "mutated result exits the encounter")
	_expect(
		bundle.get_encounter("complex", 1).get("actions", []).any(
			func(action: Dictionary) -> bool: return int(action.get("rawCode", 0)) == 44
		),
		"complex result mutation leaves the compiled bundle immutable"
	)
	var restored = StateScript.new()
	restored.restore(interpreter.runtime_state.snapshot())
	_expect(restored.is_map_owned(2), "map ownership survives snapshot restore")
	_expect_equal(
		restored.get_effective_complex_encounter(bundle.get_encounter("complex", 1))
			.get("actions", []).filter(
				func(action: Dictionary) -> bool: return int(action.get("slot", -1)) < 8
			).size(),
		1,
		"complex result mutation survives snapshot restore"
	)
	var cancelled: Dictionary = interpreter.resume_encounter(0)
	_expect_equal(cancelled.get("reason"), "encounter-cancelled", "party can leave reopened archive")
	bundle.triggers_by_id["map:display"] = {
		"id": "map:display",
		"source": "Data DD",
		"actions": [{"slot": 0, "rawCode": 29, "code": 29, "id": -2}],
	}
	var display_interpreter = _interpreter(bundle)
	_expect(display_interpreter.begin_trigger("map:display"), "begin display-map fixture")
	var display_map: Dictionary = display_interpreter.run_until_yield()
	_expect(bool(display_map.get("payload", {}).get("display")), "negative map ID requests display")
	_expect(display_interpreter.runtime_state.is_map_owned(2), "displayed map is also acquired")


func _test_percent_branching() -> void:
	var archive_bundle = BundleScript.new()
	_expect(
		archive_bundle.load_from_directory(COB_SPOKEN_WORD_FIXTURE),
		"CoB percent-branch fixture loads: %s" % archive_bundle.last_error
	)
	if not archive_bundle.last_error.is_empty():
		return

	var miss_interpreter = _interpreter(archive_bundle)
	miss_interpreter.set_percent_roll_provider(func() -> int: return 100)
	_expect(miss_interpreter.begin_trigger("Data DD:6:28"), "begin archive chance miss")
	miss_interpreter.run_until_yield()
	var study_message: Dictionary = miss_interpreter.resume_encounter(2)
	_expect_equal(study_message.get("payload", {}).get("messageId"), 141, "chance path begins")
	var missed: Dictionary = miss_interpreter.run_until_yield()
	_expect_equal(missed.get("command"), "start_encounter", "failed chance falls through")
	_expect_equal(
		missed.get("payload", {}).get("remainingAttempts"),
		124,
		"failed chance uses the active encounter loop"
	)

	var hit_interpreter = _interpreter(archive_bundle)
	hit_interpreter.set_percent_roll_provider(func() -> int: return 1)
	_expect(hit_interpreter.begin_trigger("Data DD:6:28"), "begin archive chance hit")
	hit_interpreter.run_until_yield()
	hit_interpreter.resume_encounter(2)
	var redirected: Dictionary = hit_interpreter.run_until_yield()
	_expect_equal(
		redirected.get("command"),
		"start_encounter",
		"successful chance follows the selected empty result row"
	)
	_expect_equal(
		redirected.get("triggerId"),
		"complex encounter:1:outcome:3",
		"result redirection does not start another encounter"
	)

	var bundle = _percent_branch_test_bundle()
	var interpreter = _interpreter(bundle)
	interpreter.set_percent_roll_provider(func() -> int: return 1)
	_expect(interpreter.begin_trigger("chance:ed3"), "begin percent ED3 branch")
	var ed3_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(ed3_result.get("payload", {}).get("messageId"), 500, "chance branches to ED3")

	interpreter = _interpreter(bundle)
	interpreter.set_percent_roll_provider(func() -> int: return 1)
	_expect(interpreter.begin_trigger("Data DD:0:1"), "begin percent keep branch")
	var kept: Dictionary = interpreter.run_until_yield()
	_expect_equal(kept.get("reason"), "keep-codes", "chance keeps source action point")
	_expect_equal(
		interpreter.runtime_state.get_trigger_percent("land", 0, 1, 100),
		100,
		"kept chance branch remains active"
	)

	interpreter = _interpreter(bundle)
	interpreter.set_percent_roll_provider(func() -> int: return 1)
	_expect(interpreter.begin_trigger("Data DD:0:2"), "begin percent consume branch")
	var consumed: Dictionary = interpreter.run_until_yield()
	_expect_equal(consumed.get("reason"), "dropout-and-erase", "chance consumes source action point")
	_expect_equal(
		interpreter.runtime_state.get_trigger_percent("land", 0, 2, 100),
		-1,
		"consumed chance branch persists its disabled percent"
	)

	interpreter = _interpreter(bundle)
	interpreter.set_percent_roll_provider(func() -> int: return 1)
	_expect(interpreter.begin_trigger("chance:slot-seven"), "begin percent dropout branch")
	var slot_seven: Dictionary = interpreter.run_until_yield()
	_expect_equal(slot_seven.get("payload", {}).get("messageId"), 501, "dropout executes slot seven")

	interpreter = _interpreter(bundle)
	interpreter.set_percent_roll_provider(func() -> int: return 1)
	_expect(interpreter.begin_trigger("chance:simple"), "begin simple result redirect")
	interpreter.run_until_yield()
	var simple_redirect: Dictionary = interpreter.resume_encounter(1)
	_expect_equal(
		simple_redirect.get("payload", {}).get("messageId"),
		502,
		"chance selects the loaded simple result row"
	)

	interpreter = _interpreter(bundle)
	interpreter.set_percent_roll_provider(func() -> int: return 1)
	_expect(interpreter.begin_trigger("chance:nested"), "begin nested result redirect")
	interpreter.run_until_yield()
	var nested_complex: Dictionary = interpreter.resume_encounter(1)
	_expect_equal(nested_complex.get("payload", {}).get("encounterId"), 3, "simple result starts nested complex encounter")
	var enclosing_simple: Dictionary = interpreter.resume_encounter(1)
	_expect_equal(
		enclosing_simple.get("payload", {}).get("messageId"),
		503,
		"nested complex result can select its loaded simple row"
	)

	interpreter = _interpreter(bundle)
	interpreter.set_percent_roll_provider(func() -> int: return 1)
	_expect(interpreter.begin_trigger("Data DD:0:3"), "begin encounter chance consume")
	interpreter.run_until_yield()
	var repeated: Dictionary = interpreter.resume_encounter(1)
	_expect_equal(repeated.get("command"), "start_encounter", "encounter chance dropout repeats")
	_expect_equal(
		interpreter.runtime_state.get_trigger_percent("land", 0, 3, 100),
		100,
		"encounter chance dropout does not consume the map action point"
	)


func _test_difficulty_branching() -> void:
	var bundle = _difficulty_branch_test_bundle()
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("difficulty:threshold"), "begin difficulty miss")
	var missed: Dictionary = interpreter.run_until_yield()
	_expect_equal(
		missed.get("payload", {}).get("messageId"),
		701,
		"difficulty below threshold continues the current action point"
	)

	interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_difficulty(1)
	_expect(interpreter.begin_trigger("difficulty:threshold"), "begin difficulty boundary hit")
	var matched: Dictionary = interpreter.run_until_yield()
	_expect_equal(
		matched.get("payload", {}).get("messageId"),
		700,
		"difficulty equal to threshold follows its ED3 branch"
	)

	interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_difficulty(2)
	_expect(interpreter.begin_trigger("difficulty:unused-mode"), "begin unused difficulty mode")
	var unused_mode: Dictionary = interpreter.run_until_yield()
	_expect_equal(
		unused_mode.get("payload", {}).get("messageId"),
		702,
		"unrecognized difficulty success mode continues like Classic"
	)

	interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_difficulty(2)
	_expect(interpreter.begin_trigger("Data DD:0:4"), "begin difficulty consume branch")
	var consumed: Dictionary = interpreter.run_until_yield()
	_expect_equal(consumed.get("reason"), "dropout-and-erase", "difficulty branch consumes source")
	_expect_equal(
		interpreter.runtime_state.get_trigger_percent("land", 0, 4, 100),
		-1,
		"difficulty consume persists the disabled action point"
	)

	interpreter = _interpreter(bundle)
	interpreter.runtime_state.set_difficulty(1)
	_expect(interpreter.begin_trigger("Data DD:0:5"), "begin difficulty keep branch")
	var kept: Dictionary = interpreter.run_until_yield()
	_expect_equal(kept.get("reason"), "keep-codes", "difficulty branch keeps source")
	_expect_equal(
		interpreter.runtime_state.get_trigger_percent("land", 0, 5, 100),
		100,
		"difficulty keep leaves the action point active"
	)


func _test_complex_spell_results(bundle) -> void:
	var adapter = GodotAdapterScript.new()
	var spell_mapping: Dictionary = SpellIdsScript.new().mappings
	var cave_in: Dictionary = bundle.get_encounter("complex", 2)
	_expect_equal(
		adapter.classic_spell_mapping_key(1201),
		"10010",
		"packed Dig Hole ID resolves to Remake's spell-table key"
	)
	_expect_equal(
		adapter.resolve_complex_spell_result(cave_in, "Dig Hole", 0, spell_mapping),
		1,
		"exact complex spell selects its shipped result"
	)
	_expect_equal(
		adapter.resolve_complex_spell_result(cave_in, "Flesh", 0, spell_mapping),
		2,
		"duplicate caster-school spell names share their authored result"
	)
	_expect_equal(
		adapter.resolve_complex_spell_result(cave_in, "Hands to Clay", 0, spell_mapping),
		4,
		"explicit spell can select Classic's failure result"
	)
	_expect_equal(
		adapter.resolve_complex_spell_result(cave_in, "Magic Darts", 0, spell_mapping),
		4,
		"unmatched complex spell defaults to result 4"
	)
	_expect_equal(
		adapter.resolve_complex_spell_result(
			{"spellIds": [1], "spellResults": [3]},
			"Flame Hands",
			1,
			spell_mapping
		),
		3,
		"explicit Classic spell-class metadata selects a class shortcut"
	)
	_expect_equal(
		adapter.resolve_complex_spell_result(
			{"spellIds": [1101], "spellResults": [1]},
			"Discover Magic",
			0,
			spell_mapping
		),
		1,
		"Remake's Discover Magic name matches the legacy Sorcerer alias"
	)


func _test_complex_item_results(bundle) -> void:
	var adapter = GodotAdapterScript.new()
	var item_mapping: Dictionary = ItemIdsScript.new().mapping
	var trapped_chest: Dictionary = bundle.get_encounter("complex", 3)
	var locked_door: Dictionary = bundle.get_encounter("complex", 4)
	_expect_equal(
		adapter.resolve_complex_item_result(
			trapped_chest,
			"Iron Key",
			item_mapping,
			[]
		),
		2,
		"exact complex item selects its shipped result"
	)
	_expect_equal(
		adapter.resolve_complex_item_result(
			trapped_chest,
			"Necklace of Keys",
			item_mapping,
			[]
		),
		2,
		"second authored item can share an encounter result"
	)
	_expect_equal(
		adapter.resolve_complex_item_result(
			locked_door,
			"Iron Key",
			item_mapping,
			[]
		),
		4,
		"unmatched complex item defaults to result 4"
	)
	_expect_equal(
		adapter.resolve_complex_item_result(
			{"itemIds": [900], "itemResults": [3]},
			"Scenario Seal",
			{},
			[{
				"itemId": 900,
				"identifiedName": "Scenario Seal",
				"unidentifiedName": "Wax Seal",
			}]
		),
		3,
		"scenario item text can identify a complex response item"
	)


func _test_shipped_lock_encounter(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:5:12"), "begin shipped CoB lock encounter")
	var encounter_result: Dictionary = interpreter.run_until_yield()
	var payload: Dictionary = encounter_result.get("payload", {})
	_expect_equal(encounter_result.get("command"), "start_encounter", "lock starts complex encounter")
	_expect_equal(payload.get("encounterId"), 4, "lock resolves Data ED2 record 4")
	_expect_equal(payload.get("thiefEncounter", {}).get("id"), 4, "lock resolves Data TD2 record 4")

	var resolver = RogueResolverScript.new()
	_expect(
		resolver.configure(payload.get("encounter", {}), payload.get("thiefEncounter", {})),
		"configure shipped rogue encounter"
	)
	_expect_equal(
		resolver.available_actions().map(func(action: Dictionary) -> int: return int(action["index"])),
		[1, 4, 6],
		"shipped lock exposes Detect Trap, Force Lock, and Pick Lock"
	)
	_expect_equal(resolver.success_percent(6, 35.0), 45, "Pick Lock applies Data TD2 modifier")
	var choice_model: Dictionary = GodotAdapterScript.new().build_rogue_encounter_choices(
		resolver,
		RogueTestCharacter.new(),
		true
	)
	_expect_equal(
		choice_model.get("tokens"),
		["rogue:1", "rogue:4", "rogue:6", "back"],
		"Godot adapter exposes shipped rogue actions and back-out"
	)
	var failed_pick: Dictionary = resolver.resolve_action(6, false)
	_expect_equal(failed_pick.get("outcome"), 0, "failed lockpick remains in complex encounter")
	_expect_equal(failed_pick.get("messageId"), 3, "failed lockpick resolves shipped text")
	_expect_equal(failed_pick.get("soundId"), 696, "failed lockpick resolves shipped sound")
	_expect(
		not bool(failed_pick.get("thiefEncounter", {}).get("typeFlags", [])[6]),
		"failed lockpick consumes the Pick Lock action"
	)
	var cancelled: Dictionary = interpreter.resume_encounter(0, failed_pick)
	_expect_equal(cancelled.get("reason"), "encounter-cancelled", "party can leave failed lock encounter")
	_expect(
		bool(bundle.get_thief_encounter(4).get("typeFlags", [])[6]),
		"rogue encounter mutation leaves bundle immutable"
	)
	_expect(
		not bool(interpreter.runtime_state.get_effective_thief_encounter(
			bundle.get_thief_encounter(4)
		).get("typeFlags", [])[6]),
		"failed lockpick persists in runtime state"
	)

	var restored = StateScript.new()
	restored.configure_from_bundle(bundle)
	restored.restore(interpreter.runtime_state.snapshot())
	_expect(
		not bool(restored.get_effective_thief_encounter(
			bundle.get_thief_encounter(4)
		).get("typeFlags", [])[6]),
		"failed lockpick survives snapshot restore"
	)

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("Data DD:5:12")
	payload = interpreter.run_until_yield().get("payload", {})
	resolver = RogueResolverScript.new()
	resolver.configure(payload.get("encounter", {}), payload.get("thiefEncounter", {}))
	var successful_pick: Dictionary = resolver.resolve_action(6, true)
	_expect_equal(successful_pick.get("outcome"), 1, "successful lockpick selects result 1")
	var sound_result: Dictionary = interpreter.resume_encounter(1, successful_pick)
	_expect_equal(sound_result.get("command"), "play_sound", "lock result begins with shipped sound")
	_expect_equal(sound_result.get("payload", {}).get("soundId"), 141, "lock result sound id")
	var text_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(text_result.get("command"), "show_text", "lock result continues to shipped text")
	_expect_equal(text_result.get("payload", {}).get("messageId"), 4, "successful lock text id")


func _test_shipped_trap_encounter(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:5:3"), "begin shipped CoB trapped chest")
	var encounter_result: Dictionary = interpreter.run_until_yield()
	var payload: Dictionary = encounter_result.get("payload", {})
	_expect_equal(payload.get("encounterId"), 3, "trapped chest resolves Data ED2 record 3")
	_expect_equal(payload.get("thiefEncounter", {}).get("id"), 1, "trapped chest resolves Data TD2 record 1")
	_expect_equal(
		payload.get("thiefMessages", []).map(func(message: Dictionary) -> int: return int(message["id"])),
		[7, 5, 4, 1, 6, 3],
		"rogue payload excludes trap parameters from text messages"
	)

	var resolver = RogueResolverScript.new()
	_expect(
		resolver.configure(payload.get("encounter", {}), payload.get("thiefEncounter", {})),
		"configure shipped trapped chest"
	)
	_expect_equal(
		resolver.available_actions().map(func(action: Dictionary) -> int: return int(action["index"])),
		[1, 6],
		"armed chest exposes Detect Trap and Pick Lock"
	)
	var detected: Dictionary = resolver.resolve_action(1, true)
	_expect_equal(detected.get("messageId"), 7, "Detect Trap uses shipped success text")
	_expect(
		bool(detected.get("thiefEncounter", {}).get("typeFlags", [])[2]),
		"Detect Trap enables Disarm Trap"
	)
	_expect(
		bool(detected.get("thiefEncounter", {}).get("typeFlags", [])[9]),
		"Detect Trap leaves the trap armed"
	)
	var disarmed: Dictionary = resolver.resolve_action(2, true)
	_expect_equal(disarmed.get("messageId"), 5, "Disarm Trap uses shipped success text")
	_expect(
		not bool(disarmed.get("thiefEncounter", {}).get("typeFlags", [])[9]),
		"successful Disarm Trap clears armed state"
	)

	resolver = RogueResolverScript.new()
	resolver.configure(payload.get("encounter", {}), payload.get("thiefEncounter", {}))
	var sprung_trap: Dictionary = resolver.resolve_action(6, true)
	_expect_equal(sprung_trap.get("status"), "trap", "armed chest springs before lock roll")
	_expect_equal(sprung_trap.get("trap", {}).get("damageLow"), 4, "shipped trap minimum damage")
	_expect_equal(sprung_trap.get("trap", {}).get("damageHigh"), 12, "shipped trap maximum damage")
	_expect_equal(sprung_trap.get("trap", {}).get("soundId"), 692, "shipped trap sound id")
	_expect(bool(sprung_trap.get("trap", {}).get("rogueOnly")), "shipped trap targets selected rogue")
	var sprung_flags: Array = sprung_trap.get("thiefEncounter", {}).get("typeFlags", [])
	_expect(not bool(sprung_flags[9]), "sprung trap clears armed state")
	_expect(not bool(sprung_flags[1]), "sprung trap consumes Detect Trap")
	_expect(bool(sprung_flags[6]), "sprung trap leaves Pick Lock available")

	var rogue := RogueTestCharacter.new()
	var damage_result: Dictionary = GodotAdapterScript.new().apply_rogue_trap_damage(
		sprung_trap.get("trap", {}),
		rogue,
		[rogue]
	)
	_expect_equal(damage_result.get("hits", []).size(), 1, "trap damages only selected rogue")
	_expect(rogue.current_hp >= 18 and rogue.current_hp <= 26, "trap applies shipped 4-12 damage range")

	var cancelled: Dictionary = interpreter.resume_encounter(0, sprung_trap)
	_expect_equal(cancelled.get("reason"), "encounter-cancelled", "party can regroup after sprung trap")
	var persisted: Dictionary = interpreter.runtime_state.get_effective_thief_encounter(
		bundle.get_thief_encounter(1)
	)
	_expect(not bool(persisted.get("typeFlags", [])[9]), "sprung trap state persists")
	_expect(bool(bundle.get_thief_encounter(1).get("typeFlags", [])[9]), "trap leaves bundle record immutable")

	_expect(interpreter.begin_trigger("Data DD:5:3"), "restart sprung CoB chest")
	payload = interpreter.run_until_yield().get("payload", {})
	resolver = RogueResolverScript.new()
	resolver.configure(payload.get("encounter", {}), payload.get("thiefEncounter", {}))
	var successful_pick: Dictionary = resolver.resolve_action(6, true)
	_expect_equal(successful_pick.get("outcome"), 2, "sprung chest lock selects result 2")
	var text_result: Dictionary = interpreter.resume_encounter(2, successful_pick)
	_expect_equal(text_result.get("command"), "show_text", "sprung chest result starts with source text")
	_expect_equal(text_result.get("payload", {}).get("messageId"), 210, "sprung chest result text id")
	var treasure_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(treasure_result.get("command"), "give_treasure", "sprung chest result gives treasure")
	_expect_equal(treasure_result.get("payload", {}).get("treasureId"), 8, "sprung chest treasure id")
	var completed: Dictionary = interpreter.run_until_yield()
	_expect_equal(completed.get("status"), "completed", "sprung chest result completes")
	_expect_equal(
		interpreter.runtime_state.get_trigger_percent("land", 5, 3, 100),
		-1,
		"sprung chest action point is consumed"
	)


func _test_battle_outcome(bundle) -> void:
	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:4:44", 4), "begin CoB battle-outcome action")
	var battle_result: Dictionary = interpreter.run_until_yield()
	var payload: Dictionary = battle_result.get("payload", {})
	_expect_equal(battle_result.get("command"), "start_battle", "battle-outcome command")
	_expect_equal(payload.get("battleIdRange"), [250, 250], "battle-outcome range")
	_expect_equal(payload.get("cowardMacroId"), -1, "coward penalty sentinel")
	_expect_equal(payload.get("battle", {}).get("id"), 250, "battle-outcome battle resolves")
	var blocked_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(blocked_result.get("status"), "error", "battle outcome requires explicit resume")
	var coward_result: Dictionary = interpreter.resume_battle(true)
	_expect_equal(coward_result.get("command"), "apply_coward_penalty", "coward sentinel command")
	_expect_equal(coward_result.get("payload", {}).get("experiencePerLevel"), 2000, "Classic coward penalty")

	interpreter = _interpreter(bundle)
	interpreter.begin_trigger("Data DD:4:44", 4)
	interpreter.run_until_yield()
	var victory_result: Dictionary = interpreter.resume_battle(false)
	_expect_equal(victory_result.get("command"), "give_battle_loot", "victory resumes through battle loot")


func _test_state_snapshot(bundle) -> void:
	var state = StateScript.new()
	state.configure_from_bundle(bundle)
	state.set_quest_flag(20)
	state.set_location("dungeon", 5, 6, 83)
	state.set_dungeon_view(4, false)
	state.set_compass_enabled(false)
	state.view_type = StateScript.VIEW_MAP
	state.set_darkland("land", 4, 1)
	state.set_darkland("dungeon", 0, -1)
	state.set_landlook("land", 4, 10)
	state.set_random_rectangle("land", 4, 2, {
		"rectIndex": 2,
		"percent": 900,
		"battleRange": [1, 2],
	})
	state.set_tile("land", 0, 3, 28, 193)
	state.set_trigger_percent("land", 0, 17, 100)
	state.set_difficulty(1)
	state.set_priest_turning_enabled(false)
	var restored = StateScript.new()
	restored.restore(state.snapshot())
	_expect(restored.is_quest_set(20), "quest flag survives snapshot")
	_expect_equal(restored.level_type, "dungeon", "map family survives snapshot")
	_expect_equal(restored.level_index, 5, "position survives snapshot")
	_expect_equal(restored.x, 6, "snapshot x")
	_expect_equal(restored.y, 83, "snapshot y")
	_expect_equal(restored.heading, 4, "dungeon heading survives snapshot")
	_expect_equal(restored.multi_view, false, "dungeon multiview survives snapshot")
	_expect_equal(restored.view_type, StateScript.VIEW_MAP, "signed dungeon view type survives snapshot")
	_expect_equal(restored.compass_enabled, false, "compass state survives snapshot")
	_expect_equal(restored.get_darkland("land", 4, 0), 1, "land darkness survives snapshot")
	_expect_equal(restored.get_darkland("dungeon", 0, 0), -1, "dungeon darkness is map-specific")
	_expect_equal(restored.get_landlook("land", 4, 0), 10, "land-look survives snapshot")
	_expect_equal(
		restored.get_random_rectangle("land", 4, 2, {}).get("battleRange"),
		[1, 2],
		"random rectangle survives snapshot"
	)
	_expect_equal(restored.get_tile("land", 0, 3, 28, -1), 193, "tile override survives snapshot")
	_expect_equal(restored.get_trigger_percent("land", 0, 17, -1), 100, "trigger override survives snapshot")
	_expect_equal(restored.difficulty, 1, "difficulty survives snapshot")
	_expect_equal(restored.priest_turning_enabled, false, "priest-turning gate survives snapshot")
	restored.set_difficulty(10)
	_expect_equal(restored.difficulty, 2, "difficulty is capped at Classic's hardest setting")
	restored.set_difficulty(-10)
	_expect_equal(restored.difficulty, -2, "difficulty is capped at Classic's easiest setting")


func _test_full_bundle(path: String) -> void:
	var bundle = BundleScript.new()
	_expect(bundle.load_from_directory(path), "full CoB bundle loads: %s" % bundle.last_error)
	if not bundle.last_error.is_empty():
		return
	_expect_equal(bundle.triggers_by_id.size(), 1341, "full CoB trigger index")
	_expect_equal(bundle.extra_action_points_by_id.size(), 241, "full CoB ED3 AP index")
	_expect_equal(bundle.extra_codes_by_id.size(), 5282, "full CoB Extra Code index")
	_expect_equal(bundle.messages_by_id.size(), 881, "full CoB message index")
	_expect_equal(bundle.battles_by_id.size(), 257, "full CoB battle index")
	_expect_equal(bundle.treasures_by_id.size(), 76, "full CoB treasure index")
	_expect_equal(bundle.shops_by_id.size(), 16, "full CoB shop index")
	_expect_equal(bundle.monsters_by_id.size(), 155, "full CoB monster index")
	_expect_equal(bundle.get_monster(71).get("displayName"), "Vodalian", "full CoB ally monster index")
	_expect_equal(bundle.simple_encounters_by_id.size(), 20, "full CoB simple encounter index")
	_expect_equal(bundle.complex_encounters_by_id.size(), 14, "full CoB complex encounter index")
	_expect_equal(bundle.thief_encounters_by_id.size(), 8, "full CoB rogue encounter index")
	_expect_equal(bundle.maps_by_id.size(), 11, "full CoB map index")
	_expect_equal(bundle.player_maps_by_id.size(), 20, "full CoB player map index")
	_expect_equal(bundle.random_levels_by_id.size(), 11, "full CoB random-level index")
	_expect_equal(bundle.pictures_by_id.size(), 1, "full CoB picture index")
	_expect_equal(bundle.get_picture(32128).get("resourceType"), "PICT", "full CoB picture metadata")
	_expect_equal(bundle.dispatcher_noop_keys.size(), 470, "full CoB dispatcher no-op evidence index")
	var coordinate_trigger_count := 0
	for coordinate: Variant in bundle.triggers_by_coordinate:
		coordinate_trigger_count += bundle.triggers_by_coordinate[coordinate].size()
	_expect_equal(coordinate_trigger_count, 658, "full CoB active coordinate trigger index")
	var handled_codes := [
		-14, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
		22, 23, 24, 25, 26, 27, 28, 29, 30, 32, 35, 36, 37, 38,
		39, 40, 41, 42, 44, 45, 46, 47, 49, 52, 56, 57, 58, 73, 82, 83, 85, 87, 89,
		93, 94, 95, 96, 97, 98, 100, 106, 111, 112,
		121, 123, 125, 126, 127,
	]
	var active_slots := 0
	var handled_slots := 0
	for trigger_value: Variant in bundle.triggers_by_id.values():
		if not bool(trigger_value.get("active", false)):
			continue
		for action_value: Variant in trigger_value.get("actions", []):
			active_slots += 1
			if handled_codes.has(int(action_value.get("code", 0))):
				handled_slots += 1
	_expect_equal(active_slots, 2734, "full CoB active action slots")
	_expect_equal(handled_slots, 2245, "full CoB directly handled action slots")
	_expect_equal(handled_slots + bundle.dispatcher_noop_keys.size(), 2715, "full CoB defined-behavior slots")

	var battle_end_interpreter = _interpreter(bundle)
	_expect(
		battle_end_interpreter.begin_trigger("Data ED3:macro:153", 5),
		"begin shipped CoB forced battle end"
	)
	var battle_end: Dictionary = battle_end_interpreter.run_until_yield()
	_expect_equal(battle_end.get("command"), "end_classic_battle", "shipped opcode 100 yields battle end")
	_expect_equal(battle_end.get("payload", {}).get("lootMode"), 5, "shipped battle end keeps loot mode")
	_expect_equal(
		battle_end.get("payload", {}).get("rewardMode"),
		"experience_only",
		"shipped battle end requests experience-only rewards"
	)

	for shipped_rout: Array in [
		["Data ED3:macro:109", 2, 387, [92, 129, 130, 116]],
		["Data ED3:macro:133", 1, 437, [49]],
		["Data ED3:macro:135", 2, 440, [92, 93, 129, 130]],
	]:
		var rout_interpreter = _interpreter(bundle)
		_expect(
			rout_interpreter.begin_trigger(shipped_rout[0], shipped_rout[1]),
			"begin shipped CoB combat rout %s" % shipped_rout[0]
		)
		var rout: Dictionary = rout_interpreter.run_until_yield()
		_expect_equal(rout.get("command"), "rout_combat_monsters", "shipped opcode 123 yields rout")
		_expect_equal(
			rout.get("payload", {}).get("extraCodeId"),
			shipped_rout[2],
			"shipped rout preserves Extra Code ID"
		)
		_expect_equal(
			rout.get("payload", {}).get("monsterIds"),
			shipped_rout[3],
			"shipped rout preserves monster IDs"
		)

	for shipped_round_macro: Array in [
		["Data ED3:macro:117", 1, 415, 3, 118, false],
		["Data ED3:macro:119", 0, 421, 2, 120, true],
		["Data ED3:macro:121", 1, 430, 2, 122, true],
		["Data ED3:macro:123", 0, 431, 2, 124, true],
		["Data ED3:macro:126", 0, 426, 2, 127, true],
		["Data ED3:macro:131", 1, 434, 2, 132, true],
		["Data ED3:macro:134", 0, 438, 2, 130, false],
	]:
		var round_interpreter = _interpreter(bundle)
		round_interpreter.set_percent_roll_provider(func() -> int: return 1)
		_expect(
			round_interpreter.begin_trigger(
				shipped_round_macro[0],
				shipped_round_macro[1],
				{"combatRound": shipped_round_macro[3], "battleMacro": -1}
			),
			"begin shipped CoB battle-round macro %s" % shipped_round_macro[0]
		)
		var round_activation: Dictionary = round_interpreter.run_until_yield()
		_expect_equal(
			round_activation.get("command"),
			"activate_battle_round_macro",
			"shipped opcode 126 yields typed activation"
		)
		_expect_equal(
			round_activation.get("payload", {}).get("extraCodeId"),
			shipped_round_macro[2],
			"shipped round macro preserves Extra Code ID"
		)
		_expect_equal(
			round_activation.get("payload", {}).get("targetMacroId"),
			shipped_round_macro[4],
			"shipped round macro preserves target"
		)
		_expect_equal(
			round_activation.get("payload", {}).get("repeat"),
			shipped_round_macro[5],
			"shipped round macro preserves repeat mode"
		)

	var deanimate_interpreter = _interpreter(bundle)
	_expect(
		deanimate_interpreter.begin_trigger("Data ED3:macro:107", 2),
		"begin shipped CoB lower-undead deanimation"
	)
	var deanimate: Dictionary = deanimate_interpreter.run_until_yield()
	_expect_equal(deanimate.get("command"), "deanimate_lower_undead", "shipped opcode 121 yields typed mutation")
	var lower_undead_ids: Array = deanimate.get("payload", {}).get("monsterIds", [])
	for lower_undead_id: int in [17, 65, 70, 75, 78, 84, 85, 86]:
		_expect(lower_undead_ids.has(lower_undead_id), "shipped deanimation includes lower undead %d" % lower_undead_id)
	for higher_undead_id: int in [19, 100, 135]:
		_expect(not lower_undead_ids.has(higher_undead_id), "shipped deanimation protects higher undead %d" % higher_undead_id)

	for shipped_destruction: Array in [
		["Data ED3:macro:110", 2, 389, 37, 8],
		["Data ED3:macro:112", 2, 399, 42, 100],
		["Data ED3:macro:125", 4, 423, 4, 100],
		["Data ED3:macro:161", 2, 656, 44, 100],
	]:
		var destruction_interpreter = _interpreter(bundle)
		_expect(
			destruction_interpreter.begin_trigger(shipped_destruction[0], shipped_destruction[1]),
			"begin shipped CoB combat destruction %s" % shipped_destruction[0]
		)
		var destruction: Dictionary = destruction_interpreter.run_until_yield()
		_expect_equal(
			destruction.get("command"),
			"destroy_combat_monsters",
			"shipped opcode 125 yields typed mutation"
		)
		_expect_equal(
			destruction.get("payload", {}).get("extraCodeId"),
			shipped_destruction[2],
			"shipped destruction preserves Extra Code ID"
		)
		_expect_equal(
			destruction.get("payload", {}).get("monsterId"),
			shipped_destruction[3],
			"shipped destruction preserves monster ID"
		)
		_expect_equal(
			destruction.get("payload", {}).get("maxMatches"),
			shipped_destruction[4],
			"shipped destruction preserves match limit"
		)

	for shipped_monster_check: Array in [
		["Data ED3:macro:121", 441],
		["Data ED3:macro:131", 31],
		["Data ED3:macro:135", 439],
		["Data ED3:macro:138", 400],
		["Data ED3:macro:94", 134],
	]:
		var combat_interpreter = _interpreter(bundle)
		_expect(
			combat_interpreter.begin_trigger(shipped_monster_check[0]),
			"begin shipped CoB combat-monster check %s" % shipped_monster_check[0]
		)
		var combat_check: Dictionary = combat_interpreter.run_until_yield()
		_expect_equal(
			combat_check.get("command"),
			"check_combat_monster",
			"shipped opcode 127 yields typed check"
		)
		_expect_equal(
			combat_check.get("payload", {}).get("monsterId"),
			shipped_monster_check[1],
			"shipped combat check preserves monster ID"
		)

	for shipped_priest_turning: Array in [
		[
			"Data DD:6:9",
			0,
			true,
			20004,
			"You regain your ability to turn undead and nether spawn.",
		],
		[
			"Data DD:6:10",
			2,
			false,
			10105,
			"You may not use your ability to turn undead or nether spawn.",
		],
	]:
		var priest_interpreter = _interpreter(bundle)
		_expect(
			priest_interpreter.begin_trigger(shipped_priest_turning[0], shipped_priest_turning[1]),
			"begin shipped CoB priest-turning action %s" % shipped_priest_turning[0]
		)
		var priest_result: Dictionary = priest_interpreter.run_until_yield()
		_expect_equal(priest_result.get("command"), "set_priest_turning", "shipped turning yields typed command")
		_expect_equal(
			priest_result.get("payload", {}).get("enabled"),
			shipped_priest_turning[2],
			"shipped turning preserves enabled state"
		)
		_expect_equal(
			priest_result.get("payload", {}).get("soundId"),
			shipped_priest_turning[3],
			"shipped turning preserves sound"
		)
		_expect_equal(
			priest_result.get("payload", {}).get("message", {}).get("text"),
			shipped_priest_turning[4],
			"shipped turning preserves feedback"
		)
		_expect_equal(
			priest_interpreter.runtime_state.priest_turning_enabled,
			shipped_priest_turning[2],
			"shipped turning updates runtime state"
		)

	var condition_interpreter = _interpreter(bundle)
	_expect(
		condition_interpreter.begin_trigger("Data DD:3:15", 2),
		"begin shipped CoB Waterworld branch"
	)
	var condition_check: Dictionary = condition_interpreter.run_until_yield()
	_expect_equal(condition_check.get("command"), "check_party_condition", "shipped condition yields typed check")
	_expect_equal(condition_check.get("payload", {}).get("conditionIndex"), 1, "shipped condition checks Waterworld")
	var waterworld_branch: Dictionary = condition_interpreter.resume_party_condition_check(true)
	_expect_equal(waterworld_branch.get("command"), "start_encounter", "active Waterworld follows shipped branch")
	_expect_equal(waterworld_branch.get("payload", {}).get("encounterKind"), "complex", "Waterworld branch is complex")
	_expect_equal(waterworld_branch.get("payload", {}).get("encounterId"), 8, "Waterworld branch preserves encounter ID")
	condition_interpreter = _interpreter(bundle)
	condition_interpreter.begin_trigger("Data DD:3:15", 2)
	condition_interpreter.run_until_yield()
	_expect_equal(
		condition_interpreter.resume_party_condition_check(false).get("command"),
		"set_trigger_percent",
		"inactive Waterworld continues the shipped action point"
	)

	for shipped_ally_check: Array in [
		["Data DD:0:82", 2, 71],
		["Data ED3:macro:104", 7, 77],
	]:
		var ally_interpreter = _interpreter(bundle)
		_expect(
			ally_interpreter.begin_trigger(shipped_ally_check[0], shipped_ally_check[1]),
			"begin shipped CoB ally check %s" % shipped_ally_check[0]
		)
		var ally_check: Dictionary = ally_interpreter.run_until_yield()
		_expect_equal(ally_check.get("command"), "check_party_ally", "shipped ally yields typed check")
		_expect_equal(
			ally_check.get("payload", {}).get("monsterId"),
			shipped_ally_check[2],
			"shipped ally check preserves monster ID"
		)

	var add_ally_interpreter = _interpreter(bundle)
	_expect(
		add_ally_interpreter.begin_trigger("Data ED3:macro:103", 5),
		"begin shipped CoB add-ally action"
	)
	var add_ally: Dictionary = add_ally_interpreter.run_until_yield()
	_expect_equal(add_ally.get("command"), "add_party_ally", "shipped add ally yields typed mutation")
	_expect_equal(add_ally.get("payload", {}).get("monsterId"), 71, "shipped add ally preserves Vodalian ID")

	for shipped_registration: Array in [
		["Data DD:0:37", 1, "keep-codes"],
		["Data ED3:macro:106", 0, "action-point-ended"],
	]:
		var registration_interpreter = _interpreter(bundle)
		_expect(
			registration_interpreter.begin_trigger(shipped_registration[0], shipped_registration[1]),
			"begin shipped CoB registration action %s" % shipped_registration[0]
		)
		var registration_result: Dictionary = registration_interpreter.run_until_yield()
		_expect_equal(registration_result.get("status"), "completed", "registration action continues")
		_expect_equal(
			registration_result.get("reason"),
			shipped_registration[2],
			"registration action preserves surrounding flow"
		)

	var malformed_random_interpreter = _interpreter(bundle)
	_expect(
		malformed_random_interpreter.begin_trigger("Data ED3:macro:197", 7),
		"begin malformed shipped CoB random branch"
	)
	var malformed_random: Dictionary = malformed_random_interpreter.run_until_yield()
	_expect_equal(malformed_random.get("status"), "error", "malformed shipped random branch remains explicit")
	_expect("-1700" in str(malformed_random.get("message", "")), "malformed random branch retains signed row ID")

	for shipped_click: Array in [
		["Data DD:7:55", 6],
		["Data DD:8:55", 6],
		["Data DDD:1:55", 6],
	]:
		var click_interpreter = _interpreter(bundle)
		_expect(
			click_interpreter.begin_trigger(shipped_click[0], shipped_click[1]),
			"begin shipped CoB click acknowledgement %s" % shipped_click[0]
		)
		var click_result: Dictionary = click_interpreter.run_until_yield()
		_expect_equal(click_result.get("command"), "wait_for_click", "shipped click yields typed command")
		_expect_equal(click_result.get("payload", {}).get("soundId"), 30005, "shipped click preserves sound")

	for shipped_picture: Array in [
		["Data DD:0:76", 0],
		["Data ED3:macro:162", 0],
	]:
		var picture_interpreter = _interpreter(bundle)
		_expect(
			picture_interpreter.begin_trigger(shipped_picture[0], shipped_picture[1]),
			"begin shipped CoB picture %s" % shipped_picture[0]
		)
		var picture_result: Dictionary = picture_interpreter.run_until_yield()
		_expect_equal(picture_result.get("command"), "show_picture", "shipped picture yields typed command")
		_expect_equal(picture_result.get("payload", {}).get("pictureId"), 32128, "shipped picture preserves ID")
		_expect_equal(
			picture_result.get("payload", {}).get("picture", {}).get("resourceType"),
			"PICT",
			"shipped picture resolves catalog metadata"
		)

	var redraw_interpreter = _interpreter(bundle)
	_expect(
		redraw_interpreter.begin_trigger("Data ED3:macro:73", 1),
		"begin shipped CoB map redraw"
	)
	_expect_equal(
		redraw_interpreter.run_until_yield().get("command"),
		"redraw_map",
		"shipped map redraw yields typed command"
	)

	for shipped_item_check: Array in [
		["Data DD:0:1", 1, 21, 990],
		["Data DD:0:2", 3, 38, 991],
		["Data ED3:macro:32", 1, 38, 808],
	]:
		var check_interpreter = _interpreter(bundle)
		_expect(
			check_interpreter.begin_trigger(shipped_item_check[0], shipped_item_check[1]),
			"begin shipped CoB item check %s" % shipped_item_check[0]
		)
		var check_result: Dictionary = check_interpreter.run_until_yield()
		_expect_equal(check_result.get("command"), "check_party_item", "shipped item check yields typed command")
		_expect_equal(
			check_result.get("payload", {}).get("itemId"),
			shipped_item_check[3],
			"shipped opcode %d preserves item ID" % shipped_item_check[2]
		)

	for shipped_item_mutation: Array in [
		["Data ED3:macro:33", 2, 808],
		["Data ED3:macro:39", 3, 807],
	]:
		var mutation_interpreter = _interpreter(bundle)
		_expect(
			mutation_interpreter.begin_trigger(shipped_item_mutation[0], shipped_item_mutation[1]),
			"begin shipped CoB item mutation %s" % shipped_item_mutation[0]
		)
		var mutation_result: Dictionary = mutation_interpreter.run_until_yield()
		_expect_equal(mutation_result.get("command"), "alter_party_items", "shipped item mutation yields typed command")
		_expect_equal(
			mutation_result.get("payload", {}).get("itemId"),
			shipped_item_mutation[2],
			"shipped item mutation preserves item ID"
		)

	for shipped_equipment_restore: Array in [
		["Data DD:1:19", 5],
		["Data DD:2:3", 4],
		["Data DD:8:49", 3],
		["Data DDD:1:49", 3],
	]:
		var restore_interpreter = _interpreter(bundle)
		_expect(
			restore_interpreter.begin_trigger(
				shipped_equipment_restore[0],
				shipped_equipment_restore[1]
			),
			"begin shipped CoB equipment restore %s" % shipped_equipment_restore[0]
		)
		var restore_result: Dictionary = restore_interpreter.run_until_yield()
		_expect_equal(restore_result.get("command"), "store_party_equipment", "shipped equipment restore yields typed command")
		_expect(not bool(restore_result.get("payload", {}).get("capture")), "shipped opcode 36 restores stored equipment")

	for shipped_shop: Array in [
		["Data DD:0:9", 2, 1],
		["Data DD:0:29", 2, 4],
		["Data DD:0:94", 1, 10],
		["Data DD:5:91", 1, 3],
		["Data ED3:macro:8", 1, 2],
	]:
		var shop_interpreter = _interpreter(bundle)
		_expect(
			shop_interpreter.begin_trigger(shipped_shop[0], shipped_shop[1]),
			"begin shipped CoB shop action %s" % shipped_shop[0]
		)
		var shop_result: Dictionary = shop_interpreter.run_until_yield()
		_expect_equal(shop_result.get("command"), "load_shop", "shipped shop yields typed command")
		_expect_equal(
			shop_result.get("payload", {}).get("shopId"),
			shipped_shop[2],
			"shipped shop record resolves"
		)
	var restricted_shop_interpreter = _interpreter(bundle)
	_expect(
		restricted_shop_interpreter.begin_trigger("Data ED3:macro:174", 5),
		"begin shipped CoB restricted-shop data row"
	)
	var restricted_shop_result: Dictionary = restricted_shop_interpreter.run_until_yield()
	_expect_equal(
		restricted_shop_result.get("command"),
		"load_shop",
		"shipped restricted-shop row yields typed command"
	)
	_expect_equal(
		restricted_shop_result.get("payload", {}).get("shopId"),
		1,
		"restricted shop resolves shop ID through Extra Code"
	)
	_expect_equal(
		restricted_shop_result.get("payload", {}).get("acceptRanges"),
		[1, 100, 0, 0],
		"restricted shop preserves shipped acceptance ranges"
	)
	var malformed_shop_interpreter = _interpreter(bundle)
	_expect(
		malformed_shop_interpreter.begin_trigger("Data ED3:macro:174", 3),
		"begin unresolved CoB restricted-shop row"
	)
	_expect_equal(
		malformed_shop_interpreter.run_until_yield().get("status"),
		"error",
		"missing restricted-shop Extra Code remains an explicit data error"
	)
	var shop_bank_interpreter = _interpreter(bundle)
	_expect(
		shop_bank_interpreter.begin_trigger("Data DD:0:9", 1),
		"begin shipped shop banking action"
	)
	_expect_equal(
		shop_bank_interpreter.run_until_yield().get("command"),
		"enable_banking",
		"shop banking action yields typed command"
	)
	var temple_interpreter = _interpreter(bundle)
	_expect(
		temple_interpreter.begin_trigger("Data DD:0:10", 1),
		"begin shipped temple service actions"
	)
	_expect_equal(
		temple_interpreter.run_until_yield().get("command"),
		"enable_banking",
		"temple entry enables banking first"
	)
	var standard_temple: Dictionary = temple_interpreter.run_until_yield()
	_expect_equal(standard_temple.get("command"), "offer_temple", "temple entry yields typed command")
	_expect_equal(
		standard_temple.get("payload", {}).get("costPercent"),
		100,
		"shipped temple uses standard prices"
	)
	var expensive_temple_interpreter = _interpreter(bundle)
	_expect(
		expensive_temple_interpreter.begin_trigger("Data ED3:macro:85", 1),
		"begin shipped expensive temple action"
	)
	_expect_equal(
		expensive_temple_interpreter.run_until_yield().get("payload", {}).get("costPercent"),
		300,
		"shipped expensive temple preserves its percentage"
	)
	var first_shop: Dictionary = bundle.get_shop(1)
	_expect_equal(
		first_shop.get("quantities", [])[0],
		3,
		"shipped Dagger stock quantity resolves"
	)
	var available_items_value: Variant = JSON.parse_string(
		FileAccess.get_file_as_string("res://shared_assets/items/stuff_book.json")
	)
	var available_items: Dictionary = available_items_value \
		if available_items_value is Dictionary else {}
	var shop_adapter = GodotAdapterScript.new()
	var built_shop_count := 0
	var resource_gap_count := 0
	for shop_value: Variant in bundle.shops_by_id.values():
		if not (shop_value is Dictionary):
			continue
		var built_shop: Dictionary = shop_adapter.build_shop_inventory(
			{
				"shop": shop_value,
				"itemTexts": bundle.item_texts_by_id.values(),
			},
			ItemIdsScript.new().mapping,
			available_items
		)
		var shop_id := int(shop_value.get("id", -1))
		if str(built_shop.get("status", "")).is_empty():
			built_shop_count += 1
		else:
			resource_gap_count += 1
			_expect(
				str(built_shop.get("message", "")).begins_with("Classic shop item "),
				"full CoB shop %d stops explicitly for unavailable item resources" % shop_id
			)
	_expect(built_shop_count >= 11, "all empty full CoB shops build for the native UI")
	_expect_equal(
		built_shop_count + resource_gap_count,
		16,
		"every full CoB shop either builds or reports its resource gap"
	)

	var interpreter = _interpreter(bundle)
	_expect(interpreter.begin_trigger("Data DD:0:58", 1), "begin CoB branching battle outcome")
	var branch_battle: Dictionary = interpreter.run_until_yield()
	_expect_equal(branch_battle.get("payload", {}).get("cowardMacroId"), 144, "coward ED3 branch id")
	var coward_branch: Dictionary = interpreter.resume_battle(true)
	_expect_equal(coward_branch.get("command"), "teleport", "coward outcome executes ED3 branch")
	_expect_equal(coward_branch.get("payload", {}).get("extraCodeId"), 641, "coward branch reaches CoB teleport")


func _test_godot_runtime_facade() -> void:
	var runtime = RuntimeScript.new()
	var commands: Array = []
	var stops: Array = []
	var completions: Array = []
	runtime.command_requested.connect(
		func(command: String, payload: Dictionary) -> void:
			commands.append({"command": command, "payload": payload})
	)
	runtime.runtime_stopped.connect(func(result: Dictionary) -> void: stops.append(result))
	runtime.trigger_completed.connect(func(result: Dictionary) -> void: completions.append(result))
	_expect(runtime.load_campaign(FIXTURE), "Godot runtime facade loads CoB fixture")
	runtime.set_difficulty(10)
	_expect_equal(runtime.runtime_state.difficulty, 2, "facade sets Classic difficulty")
	_expect_equal(runtime.triggers_at("land", 0, 9, 17).size(), 1, "facade exposes map trigger lookup")
	_expect(runtime.activate_trigger("Data DD:0:0"), "facade activates CoB trigger")
	_expect_equal(commands.size(), 1, "facade emits native command signal")
	_expect_equal(commands[0].get("command"), "show_text", "facade emits text command")
	runtime.continue_after_command()
	_expect_equal(commands.size(), 2, "facade emits encounter request")
	_expect_equal(commands[1].get("command"), "start_encounter", "facade emits encounter command")
	runtime.finish_encounter(4)
	_expect_equal(commands.size(), 3, "facade emits encounter outcome command")
	_expect_equal(commands[2].get("command"), "show_text", "facade executes encounter result")
	runtime.continue_after_command()
	_expect_equal(completions.size(), 1, "facade completes encounter result")
	_expect_equal(stops.size(), 0, "facade stays within implemented slice")


func _test_runtime_host() -> void:
	var host = HostScript.new()
	get_root().add_child(host)
	var adapter = GuardHouseAdapter.new()
	var completions: Array = []
	var stops: Array = []
	host.playthrough_completed.connect(func(result: Dictionary) -> void: completions.append(result))
	host.playthrough_stopped.connect(func(result: Dictionary) -> void: stops.append(result))
	host.configure(adapter)
	_expect(host.load_campaign(FIXTURE), "runtime host loads CoB fixture")
	_expect(
		host.start_trigger("Data DD:0:0", 0, {"actorFaction": 2}),
		"runtime host starts guard-house trigger"
	)
	_expect_equal(adapter.commands.size(), 3, "runtime host drives complete guard-house command flow")
	_expect_equal(adapter.commands[0].get("command"), "show_text", "host starts with guard-house text")
	_expect_equal(
		adapter.commands[0].get("payload", {}).get("actorFaction"),
		2,
		"host forwards macro actor context to commands"
	)
	_expect_equal(adapter.commands[1].get("command"), "start_encounter", "host requests simple encounter")
	_expect_equal(adapter.commands[2].get("payload", {}).get("messageId"), 61, "host runs selected outcome")
	_expect_equal(completions.size(), 1, "runtime host publishes completion")
	_expect_equal(completions[0].get("reason"), "keep-codes", "runtime host completion reason")
	_expect_equal(stops.size(), 0, "runtime host guard-house flow has no stop")
	_expect(host.start_trigger("Data DD:0:83"), "runtime host starts dungeon move")
	_expect_equal(adapter.commands[-1].get("command"), "teleport", "host dispatches dungeon move")
	_expect_equal(
		host.runtime.runtime_state.level_type,
		"dungeon",
		"host retains dungeon destination state"
	)
	_expect_equal(completions.size(), 2, "host completes dungeon move after adapter response")
	_expect_equal(completions[-1].get("reason"), "action-point-ended", "host does not resume moved AP")
	_expect(host.start_trigger("Data DDD:1:75"), "runtime host starts look direction")
	_expect_equal(adapter.commands[-2].get("command"), "set_view_direction", "host updates view direction")
	_expect_equal(adapter.commands[-1].get("command"), "teleport", "host continues after view update")
	_expect_equal(host.runtime.runtime_state.heading, 1, "host retains updated heading")
	_expect_equal(completions.size(), 3, "host completes look-direction action point")
	_expect(host.start_trigger("Data DD:7:85"), "runtime host starts allow-map action")
	_expect_equal(adapter.commands[-1].get("command"), "set_view_mode", "host dispatches view-mode change")
	_expect_equal(host.runtime.runtime_state.multi_view, true, "host retains updated map mode")
	_expect_equal(completions.size(), 4, "host completes view-mode action point")
	host.runtime.runtime_state.set_location("land", 4, 87, 28)
	_expect(host.start_trigger("Data DD:4:46", 2), "runtime host starts darkland action")
	_expect_equal(adapter.commands[-2].get("command"), "set_map_darkness", "host dispatches map darkness")
	_expect_equal(adapter.commands[-1].get("payload", {}).get("messageId"), 849, "host continues after darkness change")
	_expect_equal(host.runtime.runtime_state.get_darkland("land", 4, 0), 1, "host retains darkness override")
	_expect_equal(completions.size(), 5, "host completes darkland action point")
	host.runtime.runtime_state.set_location("land", 0, 0, 0)
	_expect(host.start_trigger("Data ED3:macro:163", 1), "runtime host starts land-look action")
	_expect_equal(adapter.commands[-2].get("command"), "set_land_look", "host dispatches land-look change")
	_expect_equal(adapter.commands[-1].get("payload", {}).get("messageId"), 867, "host continues after land-look change")
	_expect_equal(host.runtime.runtime_state.get_landlook("land", 0, 0), 10, "host retains land-look override")
	_expect_equal(completions.size(), 6, "host completes land-look action point")
	_expect(host.start_trigger("Data DD:1:30", 4), "runtime host starts experience award")
	_expect_equal(adapter.commands[-1].get("command"), "give_experience", "host dispatches experience award")
	_expect_equal(adapter.commands[-1].get("payload", {}).get("experience"), 1500, "host preserves experience total")
	_expect_equal(completions.size(), 7, "host completes experience action point")
	_expect_equal(
		host.runtime.runtime_state.get_action_point_override("Data DD:1:31").get("actions", [])[0].get("id"),
		522,
		"host continues through the following action-point patch"
	)
	_expect(host.start_trigger("Data ED3:macro:142"), "runtime host starts party damage action")
	_expect_equal(adapter.commands[-1].get("command"), "change_party_health", "host dispatches party health change")
	_expect_equal(adapter.commands[-1].get("payload", {}).get("rollRange"), [1, 1], "host preserves party damage range")
	_expect_equal(completions.size(), 8, "host completes party damage action point")
	_expect(host.start_trigger("Data DD:7:45", 1), "runtime host starts checked-character damage")
	_expect_equal(adapter.commands[-3].get("command"), "filter_selected_characters", "host dispatches character check")
	_expect_equal(adapter.commands[-2].get("command"), "change_selected_health", "host dispatches selected damage")
	_expect_equal(adapter.commands[-1].get("payload", {}).get("messageId"), 377, "host continues after selected damage")
	_expect_equal(completions.size(), 9, "host completes checked-character damage")
	_expect(host.start_trigger("Data ED3:macro:67"), "runtime host starts movement-based selection")
	_expect_equal(adapter.commands[-2].get("command"), "select_characters_by_misc", "host dispatches misc selector")
	_expect_equal(adapter.commands[-1].get("command"), "change_selected_health", "host continues to selected damage")
	_expect_equal(completions.size(), 10, "host completes movement-selected damage")
	_expect(host.start_trigger("Data DD:8:89", 1), "runtime host starts party spell action")
	_expect_equal(adapter.commands[-1].get("command"), "cast_classic_spell", "host dispatches party spell")
	_expect_equal(adapter.commands[-1].get("payload", {}).get("spellId"), 1408, "host preserves party spell ID")
	_expect_equal(completions.size(), 11, "host completes party spell action point")
	var godot_adapter = GodotAdapterScript.new()
	_expect(godot_adapter.has_method("execute_command"), "Godot command adapter loads")
	var encounter_choices: Dictionary = godot_adapter.build_simple_encounter_choices(
		host.runtime.bundle.get_encounter("simple", 0)
	)
	_expect_equal(encounter_choices.get("choices", []).size(), 5, "Godot adapter exposes simple back-out")
	_expect_equal(
		encounter_choices.get("outcomes"),
		["1", "2", "3", "4", "0"],
		"Godot adapter preserves Classic outcomes and back-out"
	)
	host.queue_free()

	var rejecting_host = HostScript.new()
	get_root().add_child(rejecting_host)
	var rejected: Array = []
	rejecting_host.playthrough_stopped.connect(func(result: Dictionary) -> void: rejected.append(result))
	rejecting_host.configure(RejectingAdapter.new())
	rejecting_host.load_campaign(FIXTURE)
	rejecting_host.start_trigger("Data DD:0:0")
	_expect_equal(rejected.size(), 1, "runtime host publishes adapter failure")
	_expect_equal(rejected[0].get("command"), "show_text", "runtime host identifies failed command")
	rejecting_host.queue_free()


func _interpreter(bundle):
	var state = StateScript.new()
	state.configure_from_bundle(bundle)
	var interpreter = InterpreterScript.new()
	interpreter.configure(bundle, state)
	return interpreter


func _party_state_test_bundle():
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	bundle.monsters_by_id[71] = {"id": 71, "displayName": "Vodalian"}
	_add_stack_trigger(bundle, "party:condition", -1, [
		_classic_action(0, 40, 1),
		_classic_action(1, 1, 901),
	])
	_add_stack_trigger(bundle, "party:ally", -1, [
		_classic_action(0, 87, 2),
		_classic_action(1, 1, 902),
	])
	_add_stack_trigger(bundle, "party:ally-message", -1, [_classic_action(0, 87, 6)])
	_add_stack_trigger(bundle, "party:add-ally", -1, [_classic_action(0, 89, 71)])
	_add_stack_trigger(bundle, "party:registration", -1, [
		_classic_action(0, 98, 0),
		_classic_action(1, 1, 904),
	])
	_add_stack_trigger(bundle, "party:random-xap", -1, [_classic_action(0, 85, 3)])
	_add_stack_trigger(bundle, "party:random-gosub", -1, [
		_classic_action(0, -85, 7),
		_classic_action(1, 1, 911),
	])
	_add_stack_trigger(bundle, "party:random-simple", -1, [_classic_action(0, 85, 4)])
	_add_stack_trigger(bundle, "party:random-complex", -1, [_classic_action(0, 85, 5)])
	_add_stack_trigger(bundle, "party:random-missing", -1, [_classic_action(0, 85, -1700)])
	_add_stack_trigger(bundle, "Data ED3:macro:500", 500, [_classic_action(0, 1, 910)])
	_add_stack_trigger(bundle, "Data ED3:macro:501", 501, [
		_classic_action(0, 1, 912),
		_classic_action(1, 111, 0),
	])
	bundle.extra_codes_by_id[1] = {"id": 1, "values": [1, 3, 8, 1, 0]}
	bundle.extra_codes_by_id[2] = {"id": 2, "values": [71, 0, 1, 500, 0]}
	bundle.extra_codes_by_id[3] = {"id": 3, "values": [0, 500, 500, 10105, 905]}
	bundle.extra_codes_by_id[4] = {"id": 4, "values": [1, 3, 3, 0, 0]}
	bundle.extra_codes_by_id[5] = {"id": 5, "values": [2, 8, 8, 0, 0]}
	bundle.extra_codes_by_id[6] = {"id": 6, "values": [71, 0, 2, 500, 903]}
	bundle.extra_codes_by_id[7] = {"id": 7, "values": [0, 501, 501, 0, 0]}
	bundle.simple_encounters_by_id[3] = {
		"id": 3,
		"actions": [],
		"choiceResults": [1, 0, 0, 0],
		"maxTimes": 1,
		"prompt": 0,
	}
	bundle.complex_encounters_by_id[8] = {
		"id": 8,
		"actions": [],
		"choiceResults": [1, 0, 0, 0],
		"maxTimes": 1,
		"prompt": 0,
	}
	for message_id: int in [901, 902, 903, 904, 905, 910, 911, 912]:
		bundle.messages_by_id[message_id] = {"id": message_id, "text": "Message %d" % message_id}
	return bundle


func _combat_monster_test_bundle():
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	bundle.monsters_by_id[17] = {
		"id": 17,
		"displayName": "Skeletal Beast",
		"typeFlags": [0, 1, 0, 0, 0, 0, 0, 0],
	}
	bundle.monsters_by_id[19] = {
		"id": 19,
		"displayName": "Skeletal Giant",
		"typeFlags": [0, 1, 0, 0, 0, 1, 0, 0],
	}
	bundle.monsters_by_id[42] = {
		"id": 42,
		"displayName": "Podling",
		"typeFlags": [0, 0, 0, 0, 0, 0, 0, 0],
	}
	bundle.monsters_by_id[78] = {
		"id": 78,
		"displayName": "Zombie",
		"typeFlags": [0, 1, 0, 0, 0, 0, 0, 0],
	}
	bundle.monsters_by_id[134] = {
		"id": 134,
		"displayName": "Rat Demi-Lord",
		"typeFlags": [0, 0, 0, 0, 0, 0, 0, 0],
	}
	bundle.messages_by_id[920] = {"id": 920, "text": "The fight continues."}
	bundle.messages_by_id[921] = {"id": 921, "text": "The remaining enemies recoil."}
	bundle.messages_by_id[922] = {"id": 922, "text": "The lower undead collapse."}
	bundle.messages_by_id[923] = {"id": 923, "text": "This action must not run after battle."}
	bundle.messages_by_id[924] = {"id": 924, "text": "The routed creatures scatter."}
	bundle.messages_by_id[925] = {"id": 925, "text": "The scheduled event begins."}
	bundle.messages_by_id[926] = {"id": 926, "text": "The repeating event begins."}
	bundle.messages_by_id[927] = {"id": 927, "text": "The random event begins."}
	bundle.extra_codes_by_id[1] = {"id": 1, "values": [134, 0, 0, 0, 0]}
	bundle.extra_codes_by_id[2] = {"id": 2, "values": [134, 42, 0, 0, 0]}
	bundle.extra_codes_by_id[3] = {"id": 3, "values": [0, 2, 0, 950, 0]}
	bundle.extra_codes_by_id[4] = {"id": 4, "values": [1, 25, 1, 951, 0]}
	bundle.extra_codes_by_id[5] = {"id": 5, "values": [2, 0, 2, 952, 952]}
	_add_stack_trigger(bundle, "combat:present", -1, [
		_classic_action(0, 127, 134),
		_classic_action(1, 1, 920),
	])
	_add_stack_trigger(bundle, "combat:destroy", -1, [
		_classic_action(0, 125, 1),
		_classic_action(1, 1, 921),
	])
	_add_stack_trigger(bundle, "combat:deanimate", -1, [
		_classic_action(0, 121, 0),
		_classic_action(1, 1, 922),
	])
	_add_stack_trigger(bundle, "combat:rout", -1, [
		_classic_action(0, 123, 2),
		_classic_action(1, 1, 924),
	])
	_add_stack_trigger(bundle, "combat:round", -1, [_classic_action(0, 126, 3)])
	_add_stack_trigger(bundle, "combat:chance", -1, [_classic_action(0, 126, 4)])
	_add_stack_trigger(bundle, "combat:random", -1, [_classic_action(0, 126, 5)])
	_add_stack_trigger(bundle, "Data ED3:macro:950", 950, [_classic_action(0, 1, 925)])
	_add_stack_trigger(bundle, "Data ED3:macro:951", 951, [_classic_action(0, 1, 926)])
	_add_stack_trigger(bundle, "Data ED3:macro:952", 952, [_classic_action(0, 1, 927)])
	_add_stack_trigger(bundle, "combat:end", -1, [
		_classic_action(0, 100, 0),
		_classic_action(1, 1, 923),
	])
	return bundle


func _random_level_mutation_test_bundle():
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	_add_stack_trigger(bundle, "random:dungeon", -1, [
		_classic_action(0, -23, 1),
		_classic_action(7, 24, 0),
	])
	_add_stack_trigger(bundle, "random:missing", -1, [
		_classic_action(0, 23, 2),
		_classic_action(7, 24, 0),
	])
	bundle.extra_codes_by_id[1] = {"id": 1, "values": [0, 2, 250, -1, -1]}
	bundle.extra_codes_by_id[2] = {"id": 2, "values": [7, 18, 0, 0, 0]}
	bundle.random_levels_by_id["dungeon:0:randlevel"] = {
		"id": "dungeon:0:randlevel",
		"levelType": "dungeon",
		"levelIndex": 0,
		"rects": [{"rectIndex": 2, "percent": 100, "battleRange": [10, 20]}],
	}
	# Classic stores 20 fixed rectangle slots even when the compiler omits empty rows.
	bundle.random_levels_by_id["land:7:randlevel"] = {
		"id": "land:7:randlevel",
		"levelType": "land",
		"levelIndex": 7,
		"rects": [],
	}
	return bundle


func _percent_branch_test_bundle():
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	_add_stack_trigger(bundle, "chance:ed3", -1, [_classic_action(0, 42, 1)])
	_add_stack_trigger(bundle, "Data ED3:macro:50", 50, [_classic_action(0, 1, 500)])
	_add_stack_trigger(bundle, "chance:slot-seven", -1, [
		_classic_action(0, 42, 4),
		_classic_action(7, 1, 501),
	])
	_add_stack_trigger(bundle, "chance:simple", -1, [_classic_action(0, 4, 1)])
	_add_stack_trigger(bundle, "chance:nested", -1, [_classic_action(0, 4, 2)])
	_add_branch_map_trigger(bundle, 1, [_classic_action(0, 42, 2)])
	_add_branch_map_trigger(bundle, 2, [_classic_action(0, 42, 3)])
	_add_branch_map_trigger(bundle, 3, [_classic_action(0, 5, 2)])
	bundle.extra_codes_by_id[1] = {"id": 1, "values": [100, 1, 0, 50, 0]}
	bundle.extra_codes_by_id[2] = {"id": 2, "values": [100, 2, 0, 0, 0]}
	bundle.extra_codes_by_id[3] = {"id": 3, "values": [100, -2, 0, 0, 0]}
	bundle.extra_codes_by_id[4] = {"id": 4, "values": [100, 1, -1, 0, 0]}
	bundle.extra_codes_by_id[5] = {"id": 5, "values": [100, 1, 1, 1, 0]}
	bundle.extra_codes_by_id[6] = {"id": 6, "values": [100, -2, 0, 0, 0]}
	bundle.extra_codes_by_id[7] = {"id": 7, "values": [100, 1, 1, 1, 0]}
	bundle.simple_encounters_by_id[1] = {
		"id": 1,
		"actions": [
			_classic_action(0, 42, 5),
			_classic_action(8, 1, 502),
		],
		"choiceResults": [1, 0, 0, 0],
		"maxTimes": 1,
		"prompt": 0,
	}
	bundle.simple_encounters_by_id[2] = {
		"id": 2,
		"actions": [
			_classic_action(0, 5, 3),
			_classic_action(8, 1, 503),
		],
		"choiceResults": [1, 0, 0, 0],
		"maxTimes": 1,
		"prompt": 0,
	}
	bundle.complex_encounters_by_id[2] = {
		"id": 2,
		"actions": [_classic_action(0, 42, 6)],
		"choiceResults": [1, 0, 0, 0],
		"maxTimes": 2,
		"prompt": 0,
	}
	bundle.complex_encounters_by_id[3] = {
		"id": 3,
		"actions": [_classic_action(0, 42, 7)],
		"choiceResults": [1, 0, 0, 0],
		"maxTimes": 1,
		"prompt": 0,
	}
	bundle.messages_by_id[500] = {"id": 500, "text": "ED3 branch"}
	bundle.messages_by_id[501] = {"id": 501, "text": "Slot seven"}
	bundle.messages_by_id[502] = {"id": 502, "text": "Simple result two"}
	bundle.messages_by_id[503] = {"id": 503, "text": "Enclosing simple result"}
	return bundle


func _difficulty_branch_test_bundle():
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	_add_stack_trigger(bundle, "difficulty:threshold", -1, [
		_classic_action(0, 58, 10),
		_classic_action(1, 1, 701),
	])
	_add_stack_trigger(bundle, "difficulty:unused-mode", -1, [
		_classic_action(0, 58, 13),
		_classic_action(1, 1, 702),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:60", 60, [_classic_action(0, 1, 700)])
	_add_branch_map_trigger(bundle, 4, [_classic_action(0, 58, 11)])
	_add_branch_map_trigger(bundle, 5, [_classic_action(0, 58, 12)])
	bundle.extra_codes_by_id[10] = {"id": 10, "values": [1, 1, 0, 60, 0]}
	bundle.extra_codes_by_id[11] = {"id": 11, "values": [2, -2, 0, 0, 0]}
	bundle.extra_codes_by_id[12] = {"id": 12, "values": [1, 2, 0, 0, 0]}
	# Tutorial contains difficulty rows with other success-mode values; Classic
	# simply continues when one of those rows meets its threshold.
	bundle.extra_codes_by_id[13] = {"id": 13, "values": [2, 3, 2, 25, 0]}
	bundle.messages_by_id[700] = {"id": 700, "text": "Hard route"}
	bundle.messages_by_id[701] = {"id": 701, "text": "Normal route"}
	bundle.messages_by_id[702] = {"id": 702, "text": "Unused mode continues"}
	return bundle


func _add_branch_map_trigger(bundle, record_index: int, actions: Array) -> void:
	var trigger := {
		"id": "Data DD:0:%d" % record_index,
		"source": "Data DD",
		"levelType": "land",
		"levelIndex": 0,
		"recordIndex": record_index,
		"active": true,
		"percent": 100,
		"actions": actions,
	}
	bundle.triggers_by_id[trigger["id"]] = trigger


func _opcode_25_test_bundle():
	# This pairs the source-backed XAP header-preservation and opcode 25 rules in
	# one small record so the copied action list is observable without a battle.
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 2, "y": 3}}
	var root := {
		"id": "Data DD:0:7",
		"source": "Data DD",
		"levelType": "land",
		"levelIndex": 0,
		"recordIndex": 7,
		"active": true,
		"doorid": 302,
		"landid": 0,
		"targetX": 8,
		"targetY": 9,
		"percent": 100,
		"coordinate": {"x": 2, "y": 3},
		"actions": [_classic_action(0, -46, 700)],
	}
	bundle.triggers_by_id[root["id"]] = root
	_add_stack_trigger(bundle, "Data ED3:macro:700", 700, [
		_classic_action(0, 1, 900),
		_classic_action(1, 25, 0),
		_classic_action(2, 111, 0),
		_classic_action(3, 1, 901),
		_classic_action(7, 24, 0),
	])
	_add_stack_branch(bundle, 700, 700)
	bundle.messages_by_id[900] = {"id": 900, "text": "Before removal"}
	bundle.messages_by_id[901] = {"id": 901, "text": "After removal"}
	return bundle


func _action_data_patch_test_bundle():
	# CoB uses opcode 7 only for map APs. These small records exercise the two
	# encounter-result destinations dispatched by the same source case.
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	_add_stack_trigger(bundle, "patch:simple", -1, [
		_classic_action(0, 7, 1),
		_classic_action(1, 4, 10),
	])
	_add_stack_trigger(bundle, "patch:complex", -1, [
		_classic_action(0, 7, 2),
		_classic_action(1, 5, 11),
	])
	_add_stack_trigger(bundle, "patch:dungeon", -1, [
		_classic_action(0, 7, 3),
		_classic_action(7, 24, 0),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:20", 20, [
		_classic_action(0, 1, 900),
		_classic_action(7, 24, 0),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:21", 21, [
		_classic_action(0, 1, 901),
		_classic_action(7, 24, 0),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:22", 22, [
		_classic_action(0, 1, 902),
		_classic_action(7, 24, 0),
	])
	bundle.extra_codes_by_id[1] = {"id": 1, "values": [-1, 10, 20, 0, 2]}
	bundle.extra_codes_by_id[2] = {"id": 2, "values": [-2, 11, 21, 0, 1]}
	bundle.extra_codes_by_id[3] = {"id": 3, "values": [2, 4, 22, 2, 0]}
	var dungeon_target := {
		"id": "Data DDD:2:4",
		"source": "Data DDD",
		"levelType": "dungeon",
		"levelIndex": 2,
		"recordIndex": 4,
		"active": true,
		"percent": 100,
		"actions": [_classic_action(0, 1, 820)],
	}
	bundle.triggers_by_id[dungeon_target["id"]] = dungeon_target
	bundle.simple_encounters_by_id[10] = {
		"id": 10,
		"actions": [
			_classic_action(0, 1, 800),
			_classic_action(7, 24, 0),
			_classic_action(8, 1, 801),
			_classic_action(15, 24, 0),
			_classic_action(16, 1, 802),
			_classic_action(23, 24, 0),
			_classic_action(24, 1, 803),
			_classic_action(31, 24, 0),
		],
		"choiceResults": [1, 2, 3, 4],
		"maxTimes": 1,
		"prompt": 0,
	}
	bundle.complex_encounters_by_id[11] = {
		"id": 11,
		"actions": [
			_classic_action(0, 1, 810),
			_classic_action(7, 24, 0),
			_classic_action(8, 1, 811),
			_classic_action(15, 24, 0),
			_classic_action(16, 1, 812),
			_classic_action(23, 24, 0),
			_classic_action(24, 1, 813),
			_classic_action(31, 24, 0),
		],
		"choiceResults": [1, 2, 3, 4],
		"maxTimes": 1,
		"prompt": 0,
	}
	for message_id: int in [800, 801, 802, 803, 810, 811, 812, 813, 820, 900, 901, 902]:
		bundle.messages_by_id[message_id] = {"id": message_id, "text": "Message %d" % message_id}
	return bundle


func _item_action_test_bundle():
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}
	_add_stack_trigger(bundle, "item:possession", -1, [
		_classic_action(0, 21, 1),
		_classic_action(1, 1, 910),
	])
	_add_stack_trigger(bundle, "item:missing-branch", -1, [_classic_action(0, 21, 2)])
	_add_stack_trigger(bundle, "item:missing-text", -1, [
		_classic_action(0, 21, 3),
		_classic_action(1, 1, 910),
	])
	_add_stack_trigger(bundle, "item:gosub", -1, [
		_classic_action(0, -21, 4),
		_classic_action(1, 1, 913),
		_classic_action(7, 24, 0),
	])
	_add_stack_trigger(bundle, "item:simple", -1, [_classic_action(0, 21, 8)])
	_add_stack_trigger(bundle, "item:result-present", -1, [
		_classic_action(0, 38, 5),
		_classic_action(1, 1, 920),
	])
	_add_stack_trigger(bundle, "item:result-absent", -1, [_classic_action(0, 38, 6)])
	_add_stack_trigger(bundle, "item:result-force", -1, [_classic_action(0, 38, 7)])
	_add_stack_trigger(bundle, "item:mutation", -1, [_classic_action(0, 22, 9)])
	_add_stack_trigger(bundle, "item:capture", -1, [_classic_action(0, 36, 44)])
	_add_stack_trigger(bundle, "item:restore", -1, [_classic_action(0, 36, 0)])
	_add_stack_trigger(bundle, "Data ED3:macro:10", 10, [_classic_action(0, 1, 900)])
	_add_stack_trigger(bundle, "Data ED3:macro:11", 11, [_classic_action(0, 1, 901)])
	_add_stack_trigger(bundle, "Data ED3:macro:12", 12, [
		_classic_action(0, 1, 911),
		_classic_action(1, 111, 0),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:13", 13, [_classic_action(0, 1, 921)])
	_add_stack_trigger(bundle, "Data ED3:macro:14", 14, [_classic_action(0, 1, 922)])
	_add_stack_trigger(bundle, "Data ED3:macro:15", 15, [_classic_action(0, 1, 923)])
	bundle.extra_codes_by_id[1] = {"id": 1, "values": [100, 0, 1, 10, 0]}
	bundle.extra_codes_by_id[2] = {"id": 2, "values": [100, 0, 0, 10, 11]}
	bundle.extra_codes_by_id[3] = {"id": 3, "values": [100, 0, 2, 10, 902]}
	bundle.extra_codes_by_id[4] = {"id": 4, "values": [100, 0, 1, 12, 0]}
	bundle.extra_codes_by_id[5] = {"id": 5, "values": [100, 1, 0, 13, 0]}
	bundle.extra_codes_by_id[6] = {"id": 6, "values": [100, 0, 0, 14, 0]}
	bundle.extra_codes_by_id[7] = {"id": 7, "values": [100, 2, 0, 15, 0]}
	bundle.extra_codes_by_id[8] = {"id": 8, "values": [100, 1, 1, 2, 0]}
	bundle.extra_codes_by_id[9] = {"id": 9, "values": [100, 2, 3, -4, 101]}
	bundle.item_texts_by_id[100] = {
		"itemId": 100,
		"identifiedName": "Test Key",
		"unidentifiedName": "Unknown Key",
	}
	bundle.item_texts_by_id[101] = {
		"itemId": 101,
		"identifiedName": "Replacement Key",
		"unidentifiedName": "Unknown Key",
	}
	for message_id: int in [900, 901, 902, 910, 911, 913, 920, 921, 922, 923]:
		bundle.messages_by_id[message_id] = {
			"id": message_id,
			"text": "Message %d" % message_id,
		}
	bundle.simple_encounters_by_id[2] = {
		"id": 2,
		"prompt": 0,
		"maxTimes": 1,
		"choiceResults": [1, 2, 3, 4],
		"actions": [],
	}
	return bundle


func _test_item(item_name: String, equipped := 0, charges := 0) -> Dictionary:
	return {
		"name": item_name,
		"equipped": equipped,
		"charges": charges,
		"weight": 1,
		"charges_weight": 0,
		"is_identified": 1,
	}


func _stack_test_bundle():
	# CoB does not contain GOSUB opcodes, so these synthetic APs isolate the
	# source-backed stack rules without presenting them as scenario fixtures.
	var bundle = BundleScript.new()
	bundle.manifest = {"start": {"levelType": "land", "levelIndex": 0, "x": 0, "y": 0}}

	_add_stack_trigger(bundle, "stack:sticky", -1, [
		_classic_action(0, -46, 1),
		_classic_action(1, 1, 900),
		_classic_action(2, 24, 0),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:100", 100, [
		_classic_action(0, 46, 2),
		_classic_action(1, 1, 901),
		_classic_action(2, 111, 0),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:101", 101, [
		_classic_action(0, 1, 902),
		_classic_action(1, 111, 0),
	])
	_add_stack_branch(bundle, 1, 100)
	_add_stack_branch(bundle, 2, 101)

	_add_stack_trigger(bundle, "stack:pop", -1, [
		_classic_action(0, -46, 3),
		_classic_action(1, 1, 910),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:200", 200, [
		_classic_action(0, 46, 4),
		_classic_action(1, 1, 911),
		_classic_action(2, 111, 0),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:201", 201, [
		_classic_action(0, 112, 0),
		_classic_action(1, 111, 0),
	])
	_add_stack_branch(bundle, 3, 200)
	_add_stack_branch(bundle, 4, 201)

	_add_stack_trigger(bundle, "stack:empty-pop", -1, [
		_classic_action(0, 112, 0),
		_classic_action(1, 1, 912),
	])

	_add_stack_trigger(bundle, "stack:extend", -1, [
		_classic_action(0, -39, 600),
		_classic_action(1, 1, 930),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:600", 600, [
		_classic_action(0, 1, 931),
		_classic_action(1, 111, 0),
	])

	_add_stack_trigger(bundle, "stack:no-implicit-return", -1, [
		_classic_action(0, -46, 5),
		_classic_action(1, 1, 920),
	])
	_add_stack_trigger(bundle, "Data ED3:macro:300", 300, [
		_classic_action(0, 1, 921),
	])
	_add_stack_branch(bundle, 5, 300)

	_add_stack_trigger(bundle, "stack:overflow", -1, [
		_classic_action(0, -46, 1000),
	])
	for index: int in range(21):
		var record_id := 400 + index
		var actions: Array = []
		if index < 20:
			actions.append(_classic_action(0, 46, 1001 + index))
		else:
			actions.append(_classic_action(0, 111, 0))
		_add_stack_trigger(bundle, "Data ED3:macro:%d" % record_id, record_id, actions)
	_add_stack_branch(bundle, 1000, 400)
	for index: int in range(20):
		_add_stack_branch(bundle, 1001 + index, 401 + index)

	return bundle


func _add_stack_trigger(
	bundle,
	trigger_id: String,
	record_id: int,
	actions: Array
) -> void:
	var trigger := {
		"id": trigger_id,
		"source": "Data ED3" if record_id >= 0 else "Stack test",
		"recordIndex": record_id,
		"active": true,
		"actions": actions,
	}
	bundle.triggers_by_id[trigger_id] = trigger
	if record_id >= 0:
		bundle.extra_action_points_by_id[record_id] = trigger


func _add_stack_branch(bundle, extra_code_id: int, target_record_id: int) -> void:
	bundle.extra_codes_by_id[extra_code_id] = {
		"id": extra_code_id,
		"values": [0, 2, 0, target_record_id, 0],
	}


func _classic_action(slot: int, raw_code: int, record_id: int) -> Dictionary:
	var starts_gosub := raw_code < 0 and raw_code not in [-14, -23]
	return {
		"slot": slot,
		"rawCode": raw_code,
		"code": abs(raw_code) if starts_gosub else raw_code,
		"id": record_id,
		"gosub": starts_gosub,
	}


func _trace_has_action(entries: Array, trigger_id: String, slot: int) -> bool:
	for entry: Variant in entries:
		if entry is Dictionary and entry.get("triggerId") == trigger_id and int(entry.get("slot", -1)) == slot:
			return true
	return false


func _action_id_at_slot(actions: Array, slot: int) -> int:
	for action: Variant in actions:
		if action is Dictionary and int(action.get("slot", -1)) == slot:
			return int(action.get("id", 0))
	return 0


func _expect(condition: bool, label: String) -> void:
	if condition:
		print("PASS: ", label)
		return
	failures += 1
	push_error("FAIL: %s" % label)


func _expect_equal(actual: Variant, expected: Variant, label: String) -> void:
	_expect(actual == expected, "%s (expected %s, got %s)" % [label, expected, actual])


func _finish() -> void:
	if failures == 0:
		print("Classic runtime tests passed.")
		quit(0)
		return
	push_error("Classic runtime tests failed: %d" % failures)
	quit(1)
