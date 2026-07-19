extends Spell

func _init() -> void :
	name = "Power Drain"
	elements = [GameGlobal.ELEMENTS.MAGICAL]
	tags = ["Magical"]
	schools = ["Sorcerer", "Enchanter"]
	classic_spell_class = 7
	classic_spell_ids = [1408, 3311]
	classic_spell_save_index = 7
	classic_spell_save_mode = "negate"
	targettile = TARGET_TILE.CREATURE
	school_levels = {"Sorcerer": 4, "Priest": 0, "Enchanter": 3}
	selection_costs = {"Sorcerer": 10, "Priest": 0, "Enchanter": 6}
	in_combat = true
	description = "Power Drain: Will drain spell points from the target."
	resist = RESIST_TYPE.IGNORE_NOTHING
	proj_tex = GFX.WHIRL
	proj_hit = GFX.SPHERE
	sounds = ["boing.wav", "electric energize.wav"]


func get_range(_power : int, _caster) -> int :
	return 1

func get_sp_cost(power : int, _caster) -> int :
	return power * 10

func get_min_spell_point_drain(power : int) -> int :
	return power * 5

func get_max_spell_point_drain(power : int) -> int :
	return power * 8

func get_spell_point_drain_roll(power : int) -> int :
	var drain := 0
	for _roll in range(power) :
		drain += randi_range(5, 8)
	return drain

func apply_power_drain(target, power : int) -> int :
	var available := maxi(0, int(target.get_stat("curSP")))
	var drained := mini(available, get_spell_point_drain_roll(power))
	target.change_cur_sp(-drained)
	return drained

func special_effect(
	_caster,
	_spell,
	power,
	_main_targeted_tile,
	_effected_tiles,
	effected_creatures,
	_add_terrain
) -> bool :
	for target in effected_creatures :
		apply_power_drain(target, power)
	return true
