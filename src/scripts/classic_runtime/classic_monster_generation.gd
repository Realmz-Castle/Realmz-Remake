class_name ClassicMonsterGeneration
extends RefCounted

const SFX_IDS_SCRIPT = preload("res://scripts/sfx_id_divinity.gd")

const MODE_BATTLE := "battle"
const MODE_SPAWN := "spawn"
const MODE_SUMMON := "summon"
const MODE_TRANSFORMATION := "transformation"
const MODE_ALLY := "ally"
const MODES := [
	MODE_BATTLE,
	MODE_SPAWN,
	MODE_SUMMON,
	MODE_TRANSFORMATION,
	MODE_ALLY,
]
const SECONDS_PER_DAY := 86400
const MIN_DIFFICULTY := -2
const MAX_DIFFICULTY := 2
const EXPERIENCE_BY_HIT_DICE := [
	[15, 3],
	[30, 6],
	[45, 9],
	[65, 12],
	[80, 15],
	[100, 18],
	[140, 21],
	[200, 24],
	[300, 27],
	[450, 30],
	[700, 33],
	[1100, 36],
	[1800, 39],
	[2300, 42],
	[2800, 45],
	[3200, 50],
	[3700, 55],
	[4200, 60],
	[4700, 65],
	[5200, 70],
	[5700, 75],
]
static var _sound_names_by_id: Dictionary = {}


static func context_from_game_global(mode: String, game_global: Object) -> Dictionary:
	var context := {
		"mode": mode if MODES.has(mode) else MODE_SPAWN,
		"difficulty": 0,
		"scenarioDay": 0,
	}
	if game_global == null:
		return context
	context["scenarioDay"] = maxi(
		0,
		floori(float(game_global.get("time")) / float(SECONDS_PER_DAY))
	)
	var host: Variant = game_global.get("classic_runtime_host")
	if not is_instance_valid(host):
		return context
	var runtime: Variant = host.get("runtime")
	var runtime_state: Variant = runtime.get("runtime_state") \
		if runtime is Object else null
	if runtime_state is Object:
		context["difficulty"] = clampi(
			int(runtime_state.get("difficulty")),
			MIN_DIFFICULTY,
			MAX_DIFFICULTY
		)
	return context


static func generate(record: Dictionary, context := {}) -> Dictionary:
	var mode := str(context.get("mode", MODE_SPAWN))
	if not MODES.has(mode):
		mode = MODE_SPAWN
	var difficulty := clampi(
		int(context.get("difficulty", 0)),
		MIN_DIFFICULTY,
		MAX_DIFFICULTY
	)
	var scenario_day := maxi(0, int(context.get("scenarioDay", 0)))
	var hit_dice := maxi(0, int(record.get("hitDice", 0)))
	var stamina := int(record.get("staminaBonus", 0))
	var stamina_rolls: Variant = context.get("staminaRolls", [])
	for roll_index: int in range(hit_dice):
		stamina += _roll(
			stamina_rolls[roll_index]
				if stamina_rolls is Array and roll_index < stamina_rolls.size()
				else null,
			1,
			8
		)

	var armor := int(record.get("armor", 0))
	var agility := int(record.get("agility", 0))
	var spell_points := int(record.get("spellPoints", 0))
	if mode != MODE_ALLY:
		armor += _roll(context.get("armorAdjustment"), -1, 1)
		agility += _roll(context.get("agilityAdjustment"), -1, 1)
		if mode == MODE_TRANSFORMATION:
			agility += _roll(context.get("initialAgilityAdjustment"), -1, 1)
	if agility < 1:
		agility = 1

	if mode in [MODE_BATTLE, MODE_SPAWN, MODE_SUMMON]:
		var spell_variance := int(float(spell_points) / 10.0)
		if spell_variance > 0:
			spell_points += _roll(
				context.get("spellPointAdjustment"),
				-spell_variance,
				spell_variance
			)

	var magic_resistance := _scaled_magic_resistance(
		int(record.get("magicResistance", 0)),
		difficulty,
		mode
	)
	var save_step := 10 if mode == MODE_BATTLE else 7
	var spell_saves := _integer_array(record.get("saves", []), 6)
	for save_index: int in range(spell_saves.size()):
		spell_saves[save_index] += save_step * difficulty
	armor -= (3 if mode == MODE_BATTLE else 2) * difficulty
	agility += difficulty

	var scale := 1.0
	if mode == MODE_BATTLE:
		scale += float(difficulty) * 0.40
	elif mode != MODE_ALLY:
		scale += float(difficulty) * 0.33
	if mode != MODE_ALLY:
		spell_points = int(float(spell_points) * scale)
		stamina = int(float(stamina) * scale)
		stamina = maxi(1, stamina)
		stamina += int(float(scenario_day) / float(180 - 30 * difficulty))
	else:
		stamina = maxi(1, stamina)

	return {
		"mode": mode,
		"difficulty": difficulty,
		"scenarioDay": scenario_day,
		"stamina": stamina,
		"spellPoints": spell_points,
		"armor": armor,
		"agility": agility,
		"magicResistance": magic_resistance,
		"spellSaves": spell_saves,
		"experience": experience(record, stamina),
	}


static func experience(record: Dictionary, stamina: int) -> int:
	var hit_dice := clampi(
		int(record.get("hitDice", 0)),
		0,
		EXPERIENCE_BY_HIT_DICE.size()
	)
	var values: Array = EXPERIENCE_BY_HIT_DICE[hit_dice] \
		if hit_dice < EXPERIENCE_BY_HIT_DICE.size() else [6200, 80]
	return (
		int(values[0])
		+ int(record.get("exp", 0))
		+ stamina * int(values[1])
	)


static func roll_money(maximums: Variant, rolls := []) -> Array[int]:
	var result: Array[int] = [0, 0, 0]
	if not (maximums is Array):
		return result
	for money_index: int in mini(result.size(), maximums.size()):
		var maximum := maxi(0, int(maximums[money_index]))
		var roll: Variant = rolls[money_index] \
			if rolls is Array and money_index < rolls.size() else null
		result[money_index] = _roll(roll, 0, maximum)
	return result


static func scale_money(amounts: Variant, difficulty: int) -> Array[int]:
	var result: Array[int] = [0, 0, 0]
	if not (amounts is Array):
		return result
	var scale := 1.0 + float(clampi(
		difficulty,
		MIN_DIFFICULTY,
		MAX_DIFFICULTY
	)) * 0.33
	for money_index: int in mini(result.size(), amounts.size()):
		result[money_index] = int(float(amounts[money_index]) * scale)
	return result


static func unarmed_attack_sound_name(
	attack_row: Variant,
	first_attack_row: Variant = []
) -> String:
	var source_row: Variant = attack_row
	if (
		source_row is Array
		and not source_row.is_empty()
		and int(source_row[0]) == 0
		and first_attack_row is Array
		and first_attack_row.size() >= 3
	):
		source_row = first_attack_row
	if not (source_row is Array) or source_row.size() < 3:
		return ""
	var sound_id := 600 + int(source_row[2])
	if sound_id == 631:
		sound_id = 632
	return _sound_name(sound_id)


static func armed_attack_sound_name(
	weapon_definition: Variant,
	weapon: Variant,
	roll: Variant = null
) -> String:
	var classic_record: Dictionary = {}
	var weapon_kind := ""
	if weapon_definition is Object:
		if weapon_definition.has_method("classic_record"):
			var record_value: Variant = weapon_definition.call("classic_record")
			if record_value is Dictionary:
				classic_record = record_value
		if weapon_definition.has_method("extra_data_value"):
			weapon_kind = str(weapon_definition.call(
				"extra_data_value",
				"classicWeaponKind",
				""
			))
	if weapon is Dictionary:
		var extra_data: Variant = weapon.get("extra_data", {})
		if weapon_kind.is_empty() and extra_data is Dictionary:
			weapon_kind = str(extra_data.get("classicWeaponKind", ""))
	var sound_id := _roll(roll, 635, 637) \
		if int(classic_record.get("blunt", 0)) == -2 or weapon_kind == "sharp" \
		else 632 if _roll(roll, 1, 100) < 50 else 639
	return _sound_name(sound_id)


static func _scaled_magic_resistance(
	value: int,
	difficulty: int,
	mode: String
) -> int:
	var result := value
	if mode == MODE_SPAWN:
		if result < 99 and result > 9:
			result += 3 * difficulty
		if result < 99:
			result += 3 * difficulty
		return maxi(0, result)
	if mode in [MODE_BATTLE, MODE_SUMMON]:
		if result < 99 and result > 9:
			result += 3 * difficulty
		return result
	return result + 3 * difficulty


static func _sound_name(sound_id: int) -> String:
	if _sound_names_by_id.is_empty():
		var catalog: Node = SFX_IDS_SCRIPT.new()
		_sound_names_by_id = catalog.mapping.duplicate()
		catalog.free()
	return str(_sound_names_by_id.get(sound_id, ""))


static func _roll(value: Variant, minimum: int, maximum: int) -> int:
	if value is int or value is float:
		return clampi(int(value), minimum, maximum)
	return randi_range(minimum, maximum)


static func _integer_array(value: Variant, size: int) -> Array[int]:
	var result: Array[int] = []
	result.resize(size)
	result.fill(0)
	if value is Array:
		for index: int in mini(size, value.size()):
			result[index] = int(value[index])
	return result
