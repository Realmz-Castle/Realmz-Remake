extends Spell


func _init() -> void:
	name = "Flame Tongue"
	elements = [GameGlobal.ELEMENTS.MAGICAL, GameGlobal.ELEMENTS.FIRE]
	tags = ["Magical", "Fire"]
	schools = ["Sorcerer"]
	classic_spell_class = 1
	classic_spell_ids = [1402]
	classic_spell_save_index = 1
	classic_spell_save_mode = "half_damage"
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 4, "Priest": 0, "Enchanter": 0}
	selection_costs = {"Sorcerer": 10, "Priest": 0, "Enchanter": 0}
	in_combat = true
	description = "Flame Tongue: Deals 8-16 fire damage along a ray with range 2 per power."
	resist = RESIST_TYPE.IGNORE_DODGE
	ray = true
	proj_tex = GFX.FIRE
	proj_hit = GFX.FIRE
	sounds = ["spell launch 2.wav", "small explode.wav"]


func get_range(power: int, _caster) -> int:
	return power * 2


func get_min_damage(_power: int, _caster) -> int:
	return 8


func get_max_damage(_power: int, _caster) -> int:
	return 16


func get_damage_roll(_power: int, _caster) -> int:
	return randi_range(8, 16)


func get_sp_cost(power: int, _caster) -> int:
	return power * 18
