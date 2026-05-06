extends Spell

func _init() -> void :
	name = "Sparkling Armor"
	attributes = ["Magical", "Misc"]
	tags = ["Magical"]
	schools = ["Sorcerer"]
	targettile = TargetTile.NOWALL
	school_levels = {"Sorcerer": 1, "Priest": 0, "Enchanter": 0}
	selection_costs = {"Sorcerer": 1, "Priest": 0, "Enchanter": 0}
	in_field = true
	in_combat = true
	description = "Sparkling Armor:  Protection against physical attacks."
	proj_tex = "Whirl"
	proj_hit = "Target"
	sounds = ["dididup.wav", "hit effect 1.wav"]


static func get_min_duration(_power : int, _caster) -> int :
	return 1 * _power

static func get_duration_roll(_power : int, _caster) -> int :
	return _power  # original: sum of randi_range(1,1) over _power iters

static func get_max_duration(_power : int, _caster) -> int :
	return 1 * _power

static func get_sp_cost(_power : int, _caster) -> int :
	return _power * 2


static func add_traits_to_target(_caster : Creature, _targetcbbutton, _power : int) -> void :
	var traitscript = load("res://shared_assets/traits/t_pro_hits.gd")
	var trait_array : Array = [_power]
	_targetcbbutton.creature.add_trait(traitscript, trait_array)
