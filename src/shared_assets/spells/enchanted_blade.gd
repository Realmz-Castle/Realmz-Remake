extends Spell

func _init() -> void :
	name = "Enchanted Blade"
	elements = [GameGlobal.ELEMENTS.MAGICAL]
	tags = ["Magical", "Misc"]
	schools = ["Sorcerer", "Enchanter"]
	classic_spell_class = 8
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 1, "Priest": 0, "Enchanter": 1}
	selection_costs = {"Sorcerer": 1, "Priest": 0, "Enchanter": 1}
	in_field = true
	in_combat = true
	description = "Enchanted Blade:  Will cause the target to cause more damage during combat.  The target does not need to possess a weapon.  It will cause even those that are using their bare hands to cause more damage."
	proj_tex = GFX.BALL
	proj_hit = GFX.TARGET
	sounds = ["spell launch 1.wav", "clash.wav"]


func get_min_duration(_power : int, _caster) -> int :
	return 1 * _power

func get_duration_roll(_power : int, _caster) -> int :
	return _power  # original: sum of randi_range(1,1) over _power iters

func get_max_duration(_power : int, _caster) -> int :
	return 1 * _power

func get_range(_power : int, _caster) -> int :
	return 5

func get_sp_cost(_power : int, _caster) -> int :
	return _power * 2

func add_traits_to_creature(_caster : Creature, _target : Creature, _power : int) -> void :
	var traitscript = load("res://shared_assets/traits/t_phys_dmg_bonus.gd")
	var trait_array : Array = [_power]
	_target.add_trait(traitscript, trait_array)
