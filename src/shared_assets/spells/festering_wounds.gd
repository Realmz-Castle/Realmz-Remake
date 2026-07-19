extends Spell

func _init() -> void :
	name = "Festering Wounds"
	elements = [GameGlobal.ELEMENTS.MAGICAL, GameGlobal.ELEMENTS.CHEMICAL]
	tags = ["Magical", "Chemical"]
	schools = ["Priest"]
	classic_spell_class = 4
	classic_spell_ids = [2304]
	classic_spell_save_index = 4
	classic_spell_save_mode = "negate"
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 0, "Priest": 3, "Enchanter": 0}
	selection_costs = {"Sorcerer": 0, "Priest": 6, "Enchanter": 0}
	in_combat = true
	description = "Festering Wounds: Diseases every enemy for 1-3 rounds per power."
	resist = RESIST_TYPE.IGNORE_MRES_DODGE
	skip_targeting = true
	autotarget_type = AUTOTARGET_TYPE.ALL_ENEMIES
	proj_tex = GFX.CLOUD
	proj_hit = GFX.MIASMA
	sounds = ["big splat.wav", "slimed.wav"]


func get_min_duration(power : int, _caster) -> int :
	return power


func get_duration_roll(power : int, _caster) -> int :
	var duration := 0
	for _roll in range(power) :
		duration += randi_range(1, 3)
	return duration


func get_max_duration(power : int, _caster) -> int :
	return power * 3


func get_range(_power : int, _caster) -> int :
	return 0


func get_sp_cost(power : int, _caster) -> int :
	return power * 12


func add_traits_to_creature(caster, target, power : int) -> void :
	var trait_script = load("res://shared_assets/traits/t_disease.gd")
	target.add_trait(trait_script, [get_duration_roll(power, caster)])
