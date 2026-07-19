extends Spell

func _init() -> void :
	name = "Fire Flare"
	elements = [GameGlobal.ELEMENTS.FIRE]
	tags = ["Magical", "Fire"]
	schools = ["Special/Misc"]
	classic_spell_class = 1
	classic_spell_ids = [4606]
	classic_spell_save_index = 1
	classic_spell_save_mode = "half_damage"
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 0, "Priest": 0, "Enchanter": 0}
	selection_costs = {"Sorcerer": 0, "Priest": 0, "Enchanter": 0}
	description = "Fire Flare: Deals fire damage over a fixed area."
	resist = RESIST_TYPE.IGNORE_DODGE
	proj_tex = GFX.FIRE
	proj_hit = GFX.FIRE
	sounds = ["spell launch 2.wav", "small explode.wav"]


func get_range(_power : int, _caster) -> int :
	return 6

func get_min_damage(_power : int, _caster) -> int :
	return 1

func get_max_damage(_power : int, _caster) -> int :
	return 10

func get_damage_roll(_power : int, _caster) -> int :
	return randi_range(1, 10)

func get_min_duration(power : int, _caster) -> int :
	return power

func get_duration_roll(power : int, _caster) -> int :
	return power

func get_max_duration(power : int, _caster) -> int :
	return power

func get_sp_cost(power : int, _caster) -> int :
	return power * 15

func get_aoe(_power : int, _caster) -> Array[Vector2i] :
	return AoE_b4
