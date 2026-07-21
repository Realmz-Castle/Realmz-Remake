extends Spell


func _init() -> void:
	name = "Fireball"
	elements = [GameGlobal.ELEMENTS.FIRE]
	tags = ["Magical", "Fire"]
	schools = ["Sorcerer"]
	classic_spell_class = 1
	classic_spell_ids = [1306]
	classic_spell_save_index = 1
	classic_spell_save_mode = "half_damage"
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 3, "Priest": 0, "Enchanter": 0}
	selection_costs = {"Sorcerer": 6, "Priest": 0, "Enchanter": 0}
	in_combat = true
	description = "Fireball: Deals 1-16 fire damage in an area that grows with power."
	resist = RESIST_TYPE.IGNORE_DODGE
	proj_tex = GFX.FIRE
	proj_hit = GFX.FIRE
	sounds = ["spell launch 2.wav", "big explode.wav"]


func get_range(_power: int, _caster) -> int:
	return 15


func get_min_damage(_power: int, _caster) -> int:
	return 1


func get_max_damage(_power: int, _caster) -> int:
	return 16


func get_damage_roll(_power: int, _caster) -> int:
	return randi_range(1, 16)


func get_sp_cost(power: int, _caster) -> int:
	return power * 9


func get_aoe(power: int, _caster) -> Array[Vector2i]:
	return AoE_b_SCALING[clampi(power, 1, 7)]
