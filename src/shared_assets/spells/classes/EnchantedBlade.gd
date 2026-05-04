extends Spell

func _init() -> void :
	name = "Enchanted Blade"
	attributes = ["Magical", "Misc"]
	tags = ["Magical"]
	schools = ["Sorcerer", "Enchanter"]
	targettile = TargetTile.NOWALL
	school_levels = {"Sorcerer": 1, "Priest": 0, "Enchanter": 1}
	selection_costs = {"Sorcerer": 1, "Priest": 0, "Enchanter": 1}
	in_field = true
	in_combat = true
	description = "Enchanted Blade:  Will cause the target to cause more damage during combat.  The target does not need to possess a weapon.  It will cause even those that are using their bare hands to cause more damage."
	proj_tex = "Ball"
	proj_hit = "Target"
	sounds = ["spell launch 1.wav", "clash.wav"]


static func get_min_duration(_power : int, _caster) -> int :
	return 1 * _power

static func get_duration_roll(_power : int, _caster) -> int :
	return _power  # original: sum of randi_range(1,1) over _power iters

static func get_max_duration(_power : int, _caster) -> int :
	return 1 * _power

static func get_range(_power : int, _caster) -> int :
	return 5

static func get_sp_cost(_power : int, _caster) -> int :
	return _power * 2


static func add_traits_to_target(_caster : Creature, _targetcbbutton, _power : int) -> void :
	var traitscript = load("res://shared_assets/traits/t_phys_dmg_bonus.gd")
	var trait_array : Array = [_power]
	_targetcbbutton.creature.add_trait(traitscript, trait_array)
