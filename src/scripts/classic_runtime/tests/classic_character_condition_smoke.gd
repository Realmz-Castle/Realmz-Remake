extends Node

const ConditionRules = preload(
	"res://scripts/classic_runtime/classic_character_condition_rules.gd"
)

var failures: Array[String] = []
var original_time := 0
var original_time_scale := 1.0


class ConditionCharacter:
	extends Creature

	var classic_conditions: Array[int] = []
	var classic_conditions_initialized := false

	func _init() -> void:
		name = "Condition smoke target"
		is_player_controlled = true
		stats["curHP"] = 20
		stats["maxHP"] = 20

	func set_classic_conditions(values: Variant) -> void:
		classic_conditions.clear()
		if values is Array:
			for index: int in range(mini(40, values.size())):
				classic_conditions.append(int(values[index]))
		classic_conditions_initialized = classic_conditions.size() == 40

	func has_classic_conditions() -> bool:
		return classic_conditions_initialized

	func set_classic_condition(condition_index: int, value: int) -> void:
		classic_conditions[condition_index] = value

	func get_classic_condition(condition_index: int) -> int:
		return classic_conditions[condition_index]


func _ready() -> void:
	call_deferred("_run_smoke")


func _run_smoke() -> void:
	await get_tree().process_frame
	original_time = GameGlobal.time
	original_time_scale = GameGlobal.time_scale
	GameGlobal.time_scale = 1.0

	_expect_equal(
		ConditionRules.CONDITION_NAMES.size(),
		40,
		"the compatibility table owns all forty character slots"
	)
	for condition_index: int in range(40):
		_expect(
			ConditionRules.supports_condition(condition_index),
			"condition %d has an executable owner" % condition_index
		)

	var character := ConditionCharacter.new()
	var conditions: Array[int] = []
	conditions.resize(40)
	conditions.fill(0)
	character.set_classic_conditions(conditions)
	for definition: Array in [
		[3, 2, "t_classic_cursed.gd"],
		[6, 2, "t_classic_slow.gd"],
		[11, 2, "t_classic_prot_fire.gd"],
	]:
		var result: Dictionary = ConditionRules.set_condition_value(
			character,
			int(definition[0]),
			int(definition[1])
		)
		_expect_equal(
			result.get("status"),
			"ok",
			"condition %d installs through the shared rules"
			% int(definition[0])
		)
		_expect(
			_trait(character, str(definition[2])) != null,
			"condition %d uses %s"
			% [int(definition[0]), str(definition[2])]
		)

	var fire_trait: Variant = _trait(character, "t_classic_prot_fire.gd")
	_expect_equal(
		fire_trait._on_get_stat("MultiplierFire", 10),
		5.0,
		"temporary Classic fire protection halves matching damage"
	)
	GameGlobal.time = 3599
	for trait_instance: Variant in character.traits.duplicate():
		trait_instance._on_time_pass(character, 3599)
	_expect_equal(
		ConditionRules.snapshot(character).slice(3, 12),
		[2, 0, 0, 2, 0, 0, 0, 0, 2],
		"temporary conditions do not decay inside a Classic field hour"
	)
	GameGlobal.time = 3600
	for trait_instance: Variant in character.traits.duplicate():
		trait_instance._on_time_pass(character, 1)
	_expect_equal(
		[
			ConditionRules.condition_value(character, 3),
			ConditionRules.condition_value(character, 6),
			ConditionRules.condition_value(character, 11),
		],
		[1, 1, 1],
		"one crossed game-hour boundary removes one condition point"
	)
	for trait_instance: Variant in character.traits.duplicate():
		trait_instance._on_new_round(character)
	_expect_equal(
		[
			ConditionRules.condition_value(character, 3),
			ConditionRules.condition_value(character, 6),
			ConditionRules.condition_value(character, 11),
		],
		[0, 0, 0],
		"the next combat round expires each final condition point"
	)
	_expect_equal(
		ConditionRules.snapshot(character)[3],
		0,
		"the save snapshot cannot resurrect an expired condition"
	)

	ConditionRules.set_condition_value(character, 28, -3)
	var disease_trait: Variant = _trait(character, "t_classic_disease.gd")
	disease_trait._on_new_round(character)
	_expect_equal(
		[
			character.get_stat("curHP"),
			ConditionRules.condition_value(character, 28),
		],
		[17, -3],
		"permanent disease deals signed damage without decaying"
	)
	GameGlobal.time = 7200
	disease_trait._on_time_pass(character, 3600)
	_expect_equal(
		[character.get_stat("curHP"), ConditionRules.snapshot(character)[28]],
		[14, -3],
		"permanent disease survives field time and the save snapshot"
	)

	ConditionRules.set_condition_value(character, 28, 3)
	disease_trait = _trait(character, "t_classic_disease.gd")
	disease_trait._on_new_round(character)
	_expect_equal(
		[character.get_stat("curHP"), ConditionRules.snapshot(character)[28]],
		[11, 2],
		"temporary disease damages first and saves its reduced value"
	)

	_finish()


func _trait(character: ConditionCharacter, trait_name: String) -> Variant:
	for trait_instance: Variant in character.traits:
		if str(trait_instance.get("name")) == trait_name:
			return trait_instance
	return null


func _expect(value: bool, description: String) -> void:
	if value:
		print("PASS: %s" % description)
		return
	failures.append(description)
	push_error("FAIL: %s" % description)


func _expect_equal(actual: Variant, expected: Variant, description: String) -> void:
	if actual == expected:
		print("PASS: %s" % description)
		return
	var failure := "%s (expected %s, got %s)" % [
		description,
		expected,
		actual,
	]
	failures.append(failure)
	push_error("FAIL: %s" % failure)


func _finish() -> void:
	GameGlobal.time = original_time
	GameGlobal.time_scale = original_time_scale
	if failures.is_empty():
		print("Classic character-condition smoke passed.")
		get_tree().quit(0)
		return
	printerr(
		"Classic character-condition smoke failed: %s"
		% "; ".join(failures)
	)
	get_tree().quit(1)
