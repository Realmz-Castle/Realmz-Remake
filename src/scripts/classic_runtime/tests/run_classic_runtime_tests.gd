extends SceneTree

const BundleScript = preload("res://scripts/classic_runtime/classic_campaign_bundle.gd")
const StateScript = preload("res://scripts/classic_runtime/classic_runtime_state.gd")
const InterpreterScript = preload("res://scripts/classic_runtime/classic_action_interpreter.gd")
const RuntimeScript = preload("res://scripts/classic_runtime/classic_runtime.gd")
const FIXTURE := "res://scripts/classic_runtime/tests/fixtures/cob_vertical_slice"

var failures := 0


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
	_test_quest_state_and_branch(bundle)
	_test_choice_continuation(bundle)
	_test_battle_request(bundle)
	_test_sound_and_treasure(bundle)
	_test_map_mutations(bundle)
	_test_complex_encounter(bundle)
	_test_battle_outcome(bundle)
	_test_state_snapshot(bundle)
	_test_godot_runtime_facade()
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
	_expect_equal(bundle.get_encounter("simple", 0).get("prompt"), 51, "simple encounter index")
	_expect_equal(bundle.get_encounter("complex", 2).get("prompt"), 180, "complex encounter index")


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
	state.set_position(5, 6, 83)
	state.set_tile("land", 0, 3, 28, 193)
	state.set_trigger_percent("land", 0, 17, 100)
	var restored = StateScript.new()
	restored.restore(state.snapshot())
	_expect(restored.is_quest_set(20), "quest flag survives snapshot")
	_expect_equal(restored.level_index, 5, "position survives snapshot")
	_expect_equal(restored.x, 6, "snapshot x")
	_expect_equal(restored.y, 83, "snapshot y")
	_expect_equal(restored.get_tile("land", 0, 3, 28, -1), 193, "tile override survives snapshot")
	_expect_equal(restored.get_trigger_percent("land", 0, 17, -1), 100, "trigger override survives snapshot")


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
	_expect_equal(bundle.simple_encounters_by_id.size(), 20, "full CoB simple encounter index")
	_expect_equal(bundle.complex_encounters_by_id.size(), 14, "full CoB complex encounter index")
	_expect_equal(bundle.maps_by_id.size(), 11, "full CoB map index")
	_expect_equal(bundle.dispatcher_noop_keys.size(), 470, "full CoB dispatcher no-op evidence index")
	var coordinate_trigger_count := 0
	for coordinate: Variant in bundle.triggers_by_coordinate:
		coordinate_trigger_count += bundle.triggers_by_coordinate[coordinate].size()
	_expect_equal(coordinate_trigger_count, 658, "full CoB active coordinate trigger index")
	var handled_codes := [0, 1, 2, 3, 4, 5, 9, 10, 12, 13, 20, 24, 39, 45, 46, 47, 56, 111]
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
	_expect_equal(handled_slots, 2013, "full CoB directly handled action slots")
	_expect_equal(handled_slots + bundle.dispatcher_noop_keys.size(), 2483, "full CoB defined-behavior slots")

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


func _interpreter(bundle):
	var state = StateScript.new()
	state.configure_from_bundle(bundle)
	var interpreter = InterpreterScript.new()
	interpreter.configure(bundle, state)
	return interpreter


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
