extends Spell


func _init() -> void:
	name = "Classic Enchanted Blade"
	elements = [GameGlobal.ELEMENTS.MAGICAL]
	tags = ["Magical", "Misc"]
	classic_spell_class = 8
	classic_spell_ids = [1102, 3104]
	classic_spell_save_index = -1
	classic_spell_save_mode = "none"
	targettile = TARGET_TILE.CREATURE
	in_field = true
	in_combat = true
	description = "Classic Enchanted Blade: Adds a decaying physical damage bonus."
	resist = RESIST_TYPE.IGNORE_MRES_DODGE
	proj_tex = GFX.BALL
	proj_hit = GFX.TARGET
	sounds = ["spell launch 1.wav", "clash.wav"]


func get_min_duration(power: int, _caster) -> int:
	return power


func get_duration_roll(power: int, _caster) -> int:
	return power


func get_max_duration(power: int, _caster) -> int:
	return power


func get_range(_power: int, _caster) -> int:
	return 5


func get_sp_cost(power: int, _caster) -> int:
	return power * 2


func add_traits_to_creature(_caster, target, power: int) -> void:
	var trait_script = load("res://shared_assets/traits/t_classic_attack_bonus.gd")
	target.add_trait(trait_script, [power])
