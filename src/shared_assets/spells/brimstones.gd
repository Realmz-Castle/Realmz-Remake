extends Spell


func _init() -> void:
	name = "Brimstones"
	elements = [GameGlobal.ELEMENTS.FIRE]
	tags = ["Magical", "Fire"]
	schools = ["Priest"]
	classic_spell_class = 1
	classic_spell_ids = [2101]
	classic_spell_save_index = 1
	classic_spell_save_mode = "half_damage"
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 0, "Priest": 1, "Enchanter": 0}
	selection_costs = {"Sorcerer": 0, "Priest": 1, "Enchanter": 0}
	in_combat = true
	description = "Brimstones: Deals 1-4 fire damage in an area that grows with power."
	resist = RESIST_TYPE.IGNORE_DODGE
	proj_tex = GFX.FIRE
	proj_hit = GFX.FIRE
	sounds = ["spell launch 2.wav", "small explode.wav"]


func get_range(_power: int, _caster) -> int:
	return 10


func get_min_damage(_power: int, _caster) -> int:
	return 1


func get_max_damage(_power: int, _caster) -> int:
	return 4


func get_damage_roll(_power: int, _caster) -> int:
	return randi_range(1, 4)


func get_sp_cost(power: int, _caster) -> int:
	return power * 3


func get_aoe(power: int, _caster) -> Array[Vector2i]:
	return AoE_b_SCALING[clampi(power, 1, 7)]
