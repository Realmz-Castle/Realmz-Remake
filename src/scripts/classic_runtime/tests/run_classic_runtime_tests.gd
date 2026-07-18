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
	_test_text_and_unsupported_boundary(bundle)
	_test_evidence_backed_dispatcher_noop(bundle)
	_test_teleport(bundle)
	_test_quest_state_and_branch(bundle)
	_test_choice_continuation(bundle)
	_test_battle_request(bundle)
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


func _test_text_and_unsupported_boundary(bundle) -> void:
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
	var unsupported_result: Dictionary = interpreter.run_until_yield()
	_expect_equal(unsupported_result.get("status"), "unsupported", "unimplemented opcode is explicit")
	_expect_equal(unsupported_result.get("opcode"), 4, "simple encounter remains outside first slice")


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


func _test_state_snapshot(bundle) -> void:
	var state = StateScript.new()
	state.configure_from_bundle(bundle)
	state.set_quest_flag(20)
	state.set_position(5, 6, 83)
	var restored = StateScript.new()
	restored.restore(state.snapshot())
	_expect(restored.is_quest_set(20), "quest flag survives snapshot")
	_expect_equal(restored.level_index, 5, "position survives snapshot")
	_expect_equal(restored.x, 6, "snapshot x")
	_expect_equal(restored.y, 83, "snapshot y")


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
	_expect_equal(bundle.maps_by_id.size(), 11, "full CoB map index")
	_expect_equal(bundle.dispatcher_noop_keys.size(), 470, "full CoB dispatcher no-op evidence index")
	var coordinate_trigger_count := 0
	for coordinate: Variant in bundle.triggers_by_coordinate:
		coordinate_trigger_count += bundle.triggers_by_coordinate[coordinate].size()
	_expect_equal(coordinate_trigger_count, 658, "full CoB active coordinate trigger index")


func _test_godot_runtime_facade() -> void:
	var runtime = RuntimeScript.new()
	var commands: Array = []
	var stops: Array = []
	runtime.command_requested.connect(
		func(command: String, payload: Dictionary) -> void:
			commands.append({"command": command, "payload": payload})
	)
	runtime.runtime_stopped.connect(func(result: Dictionary) -> void: stops.append(result))
	_expect(runtime.load_campaign(FIXTURE), "Godot runtime facade loads CoB fixture")
	_expect_equal(runtime.triggers_at("land", 0, 9, 17).size(), 1, "facade exposes map trigger lookup")
	_expect(runtime.activate_trigger("Data DD:0:0"), "facade activates CoB trigger")
	_expect_equal(commands.size(), 1, "facade emits native command signal")
	_expect_equal(commands[0].get("command"), "show_text", "facade emits text command")
	runtime.continue_after_command()
	_expect_equal(stops.size(), 1, "facade reports unsupported boundary")
	_expect_equal(stops[0].get("opcode"), 4, "facade preserves unsupported opcode")


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
