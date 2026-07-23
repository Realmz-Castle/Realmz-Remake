extends Spell


func _init() -> void:
	name = "Fearful Thoughts"
	elements = [GameGlobal.ELEMENTS.MAGICAL, GameGlobal.ELEMENTS.MENTAL]
	tags = ["Magical", "Mental"]
	schools = ["Priest"]
	classic_spell_class = 5
	classic_spell_ids = [2103]
	classic_spell_save_index = 5
	classic_spell_save_mode = "negate"
	classic_opposed_level_check = true
	targettile = TARGET_TILE.CREATURE
	school_levels = {"Sorcerer": 0, "Priest": 1, "Enchanter": 0}
	selection_costs = {"Sorcerer": 0, "Priest": 1, "Enchanter": 0}
	in_combat = true
	description = "Fearful Thoughts: Forces the target to flee for one round per power."
	resist = RESIST_TYPE.IGNORE_NOTHING
	proj_tex = GFX.WEB
	proj_hit = GFX.WEB
	sounds = ["wind.wav", "bwabble.wav"]


func get_range(_power: int, _caster) -> int:
	return 8


func get_min_duration(power: int, _caster) -> int:
	return power


func get_duration_roll(power: int, _caster) -> int:
	return power


func get_max_duration(power: int, _caster) -> int:
	return power


func get_sp_cost(power: int, _caster) -> int:
	return power * 10


func add_traits_to_creature(caster, target, power: int) -> void:
	var trait_script = load(
		"res://shared_assets/traits/t_classic_fleeing.gd"
	)
	target.add_trait(trait_script, [get_duration_roll(power, caster)])
