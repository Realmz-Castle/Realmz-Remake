extends SceneTree

const BundleScript = preload("res://scripts/classic_runtime/classic_campaign_bundle.gd")
const StateScript = preload("res://scripts/classic_runtime/classic_runtime_state.gd")
const InterpreterScript = preload("res://scripts/classic_runtime/classic_action_interpreter.gd")
const RogueResolverScript = preload("res://scripts/classic_runtime/classic_rogue_encounter_resolver.gd")
const RuntimeScript = preload("res://scripts/classic_runtime/classic_runtime.gd")
const HostScript = preload("res://scripts/classic_runtime/classic_runtime_host.gd")
const GodotAdapterScript = preload("res://scripts/classic_runtime/classic_godot_command_adapter.gd")
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
	var current_hp := 30

	func get_stat(stat_name: String) -> float:
		match stat_name:
			"curHP":
				return current_hp
			"maxHP":
				return 30.0
			_:
				return stat_value

	func change_cur_hp(change: int) -> void:
		current_hp += change


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
	_test_quest_state_and_branch(bundle)
	_test_classic_stack_semantics()
	_test_shipped_gosub_chain()
	_test_shipped_opcode_25_mutation()
	_test_opcode_25_xap_copy()
	_test_choice_continuation(bundle)
	_test_battle_request(bundle)
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
	_expect_equal(single_view.get("viewType"), true, "negative heading selects fixed view")

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
	state.set_tile("land", 0, 3, 28, 193)
	state.set_trigger_percent("land", 0, 17, 100)
	state.set_difficulty(1)
	var restored = StateScript.new()
	restored.restore(state.snapshot())
	_expect(restored.is_quest_set(20), "quest flag survives snapshot")
	_expect_equal(restored.level_type, "dungeon", "map family survives snapshot")
	_expect_equal(restored.level_index, 5, "position survives snapshot")
	_expect_equal(restored.x, 6, "snapshot x")
	_expect_equal(restored.y, 83, "snapshot y")
	_expect_equal(restored.heading, 4, "dungeon heading survives snapshot")
	_expect_equal(restored.multi_view, false, "dungeon multiview survives snapshot")
	_expect_equal(restored.view_type, true, "dungeon view type survives snapshot")
	_expect_equal(restored.get_tile("land", 0, 3, 28, -1), 193, "tile override survives snapshot")
	_expect_equal(restored.get_trigger_percent("land", 0, 17, -1), 100, "trigger override survives snapshot")
	_expect_equal(restored.difficulty, 1, "difficulty survives snapshot")
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
	_expect_equal(bundle.simple_encounters_by_id.size(), 20, "full CoB simple encounter index")
	_expect_equal(bundle.complex_encounters_by_id.size(), 14, "full CoB complex encounter index")
	_expect_equal(bundle.thief_encounters_by_id.size(), 8, "full CoB rogue encounter index")
	_expect_equal(bundle.maps_by_id.size(), 11, "full CoB map index")
	_expect_equal(bundle.player_maps_by_id.size(), 20, "full CoB player map index")
	_expect_equal(bundle.dispatcher_noop_keys.size(), 470, "full CoB dispatcher no-op evidence index")
	var coordinate_trigger_count := 0
	for coordinate: Variant in bundle.triggers_by_coordinate:
		coordinate_trigger_count += bundle.triggers_by_coordinate[coordinate].size()
	_expect_equal(coordinate_trigger_count, 658, "full CoB active coordinate trigger index")
	var handled_codes := [
		0, 1, 2, 3, 4, 5, 9, 10, 12, 13, 19, 20, 24, 25, 29, 35, 37, 39,
		41, 42, 44, 45, 46, 47, 56, 58, 95, 111, 112,
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
	_expect_equal(handled_slots, 2091, "full CoB directly handled action slots")
	_expect_equal(handled_slots + bundle.dispatcher_noop_keys.size(), 2561, "full CoB defined-behavior slots")

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
	_expect(host.start_trigger("Data DD:0:0"), "runtime host starts guard-house trigger")
	_expect_equal(adapter.commands.size(), 3, "runtime host drives complete guard-house command flow")
	_expect_equal(adapter.commands[0].get("command"), "show_text", "host starts with guard-house text")
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
