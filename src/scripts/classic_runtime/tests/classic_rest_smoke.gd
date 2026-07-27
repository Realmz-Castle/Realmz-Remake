extends Node

const RestScript = preload("res://scripts/classic_runtime/classic_rest.gd")

var failures: Array[String] = []


class CharacterStub:
	extends RefCounted

	var level := 1
	var stats := {
		"curHP": 10,
		"maxHP": 20,
		"curSP": 0,
		"maxSP": 20,
	}
	var conditions: Array[int] = []

	func _init(character_level := 1) -> void:
		level = character_level
		conditions.resize(40)
		conditions.fill(0)

	func get_stat(stat_name: String) -> int:
		return int(stats[stat_name])

	func change_cur_hp(amount: int) -> void:
		stats["curHP"] = mini(int(stats["curHP"]) + amount, int(stats["maxHP"]))

	func change_cur_sp(amount: int) -> void:
		stats["curSP"] = mini(int(stats["curSP"]) + amount, int(stats["maxSP"]))

	func get_classic_condition(condition_index: int) -> int:
		return conditions[condition_index]


class RationPool:
	extends RefCounted

	var charges := 0

	func _init(initial_charges: int) -> void:
		charges = initial_charges

	func consume() -> bool:
		if charges <= 0:
			return false
		charges -= 1
		return true


func _ready() -> void:
	call_deferred("_run_smoke")


func _run_smoke() -> void:
	await get_tree().process_frame
	_test_timeclick_conversion()
	_test_boundary_and_fatigue_rules()
	_test_player_and_ally_recovery()
	_test_recovery_restrictions_and_rations()
	_test_classic_time_skips_generic_regeneration()
	_test_random_battle_area_eligibility()
	_finish()


func _test_timeclick_conversion() -> void:
	_expect_equal(
		RestScript.pass_time_units(RestScript.REST_TIMECLICKS, 0, 10.0),
		150,
		"outdoor Rest advances twenty-five game minutes"
	)
	_expect_equal(
		RestScript.pass_time_units(RestScript.REST_TIMECLICKS, 1, 10.0),
		30,
		"indoor Rest advances five game minutes"
	)
	_expect_equal(
		RestScript.pass_time_units(RestScript.CAMP_EXIT_TIMECLICKS, 0, 10.0),
		60,
		"leaving an outdoor camp advances ten game minutes"
	)
	_expect_equal(
		RestScript.pass_time_units(RestScript.CAMP_EXIT_TIMECLICKS, 1, 10.0),
		12,
		"leaving an indoor camp advances two game minutes"
	)
	_expect_equal(
		RestScript.pass_time_units(
			RestScript.OUTDOOR_CAMP_MOVEMENT_EXIT_TIMECLICKS,
			0,
			10.0
		),
		450,
		"moving from an outdoor camp advances seventy-five game minutes"
	)


func _test_boundary_and_fatigue_rules() -> void:
	_expect_equal(
		RestScript.elapsed_hour_boundaries(3599, 3600),
		1,
		"the source recovery cadence notices an hour boundary"
	)
	_expect_equal(
		RestScript.elapsed_half_day_boundaries(43199, 43200),
		1,
		"the source recovery cadence notices noon"
	)
	_expect_equal(
		RestScript.elapsed_half_day_boundaries(86399, 86400),
		1,
		"the source recovery cadence notices midnight"
	)
	_expect_equal(
		RestScript.fatigue_before_rest(80.0),
		78.0,
		"each Rest operation removes two Classic fatigue points"
	)
	_expect_equal(
		RestScript.fatigue_before_rest(4.0),
		4.0,
		"ordinary Rest cannot reduce fatigue below the native minimum"
	)
	_expect_equal(
		RestScript.fatigue_after_time(78.0, 3599, 3600),
		79.0,
		"crossing an hour adds one Classic fatigue point"
	)
	_expect_equal(
		RestScript.fatigue_after_time(1.0, 100, 200),
		1.0,
		"sub-hour time leaves a directly assigned Classic fatigue value unchanged"
	)


func _test_player_and_ally_recovery() -> void:
	var player := CharacterStub.new(6)
	var ally := CharacterStub.new(8)
	ally.set_meta("classic_hit_dice", 8)
	var hourly: Dictionary = RestScript.apply_party_recovery(
		[player],
		[ally],
		3599,
		3600
	)
	_expect_equal(player.stats["curSP"], 3, "a player restores half their level in spell points")
	_expect_equal(ally.stats["curSP"], 4, "an ally restores half their hit dice in spell points")
	_expect_equal(hourly["playerHitPoints"], 0, "ordinary hour boundaries do not restore player health")

	var rations := RationPool.new(1)
	var half_day: Dictionary = RestScript.apply_party_recovery(
		[player],
		[ally],
		43199,
		43200,
		Callable(rations, "consume")
	)
	_expect_equal(player.stats["curHP"], 12, "Iron Rations preserve the full level-based noon recovery")
	_expect_equal(ally.stats["curHP"], 13, "an ally restores one plus one quarter hit dice at noon")
	_expect_equal(rations.charges, 0, "noon recovery consumes one Iron Rations charge")
	_expect_equal(half_day["ironRationsConsumed"], 1, "the recovery report records consumed rations")


func _test_recovery_restrictions_and_rations() -> void:
	var first := CharacterStub.new(9)
	var second := CharacterStub.new(9)
	var rations := RationPool.new(1)
	RestScript.apply_party_recovery(
		[first, second],
		[],
		43199,
		43200,
		Callable(rations, "consume")
	)
	_expect_equal(first.stats["curHP"], 13, "the first injured character receives the ration-assisted recovery")
	_expect_equal(second.stats["curHP"], 11, "recovery is halved when no ration charge remains")

	var poisoned := CharacterStub.new(6)
	poisoned.conditions[RestScript.POISONED_CONDITION_INDEX] = 2
	var poison_rations := RationPool.new(1)
	RestScript.apply_party_recovery(
		[poisoned],
		[],
		43199,
		43200,
		Callable(poison_rations, "consume")
	)
	_expect_equal(poisoned.stats["curHP"], 14, "the noon heal preserves Classic's poison adjustment")

	var animated := CharacterStub.new(6)
	animated.conditions[RestScript.ANIMATED_CONDITION_INDEX] = 1
	RestScript.apply_party_recovery([animated], [], 3599, 3600)
	_expect_equal(animated.stats["curSP"], 0, "animated characters do not recover spell points")

	var petrified := CharacterStub.new(6)
	petrified.conditions[RestScript.TURNED_TO_STONE_CONDITION_INDEX] = -1
	var unused_rations := RationPool.new(1)
	RestScript.apply_party_recovery(
		[petrified],
		[],
		43199,
		43200,
		Callable(unused_rations, "consume")
	)
	_expect_equal(petrified.stats["curHP"], 10, "petrified characters do not receive the half-day heal")
	_expect_equal(
		unused_rations.charges,
		0,
		"the source consumes a ration before its heal rejects a petrified character"
	)


func _test_classic_time_skips_generic_regeneration() -> void:
	var creature := Creature.new()
	creature.level = 1
	creature.stats = {
		"curHP": 1,
		"maxHP": 10,
		"curSP": 0,
		"maxSP": 10,
		"HP_regen_base": 1,
		"HP_regen_mult": 1,
		"SP_regen_base": 1,
		"SP_regen_mult": 1,
	}
	creature._on_classic_time_pass(86400)
	_expect_equal(creature.stats["curHP"], 1, "Classic field time bypasses generic passive health regeneration")
	_expect_equal(creature.stats["curSP"], 0, "Classic field time bypasses generic passive spell regeneration")
	creature._on_time_pass(86400)
	_expect_equal(creature.stats["curHP"], 2, "non-Classic time retains generic passive health regeneration")
	_expect_equal(creature.stats["curSP"], 1, "non-Classic time retains generic passive spell regeneration")
	creature.free()


func _test_random_battle_area_eligibility() -> void:
	var area := {
		"scriptRectangle": [[4, 5], [8, 9]],
		"chance": 0.25,
		"RR_Battle": {"battle_range": [10, 12]},
	}
	_expect(
		RestScript.random_battle_area_eligible(area, Vector2i(4, 9), 0.25),
		"Rest checks include the edge of a Classic random rectangle"
	)
	_expect(
		not RestScript.random_battle_area_eligible(area, Vector2i(3, 9), 0.0),
		"Rest ignores random rectangles that do not contain the party"
	)
	_expect(
		not RestScript.random_battle_area_eligible(area, Vector2i(4, 9), 0.26),
		"Rest respects the random rectangle probability"
	)


func _expect(condition: bool, description: String) -> void:
	if condition:
		print("PASS: %s" % description)
		return
	failures.append(description)
	push_error("FAIL: %s" % description)


func _expect_equal(actual: Variant, expected: Variant, description: String) -> void:
	_expect(actual == expected, "%s (expected %s, got %s)" % [description, expected, actual])


func _finish() -> void:
	if failures.is_empty():
		print("CLASSIC REST SMOKE PASSED")
		get_tree().quit(0)
		return
	push_error("CLASSIC REST SMOKE FAILED: %s" % "; ".join(failures))
	get_tree().quit(1)
