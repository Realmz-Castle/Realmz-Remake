extends Spell


func _init() -> void:
	name = "Heat Ray"
	elements = [GameGlobal.ELEMENTS.FIRE]
	tags = ["Magical", "Fire"]
	schools = ["Enchanter"]
	classic_spell_class = 1
	classic_spell_ids = [3207]
	classic_spell_save_index = 1
	classic_spell_save_mode = "half_damage"
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 0, "Priest": 0, "Enchanter": 2}
	selection_costs = {"Sorcerer": 0, "Priest": 0, "Enchanter": 3}
	in_combat = true
	description = "Heat Ray: Deals 2-8 fire damage along a ray with range 2 per power."
	resist = RESIST_TYPE.IGNORE_DODGE
	ray = true
	proj_tex = GFX.FIRE
	proj_hit = GFX.FIRE
	sounds = ["spell launch 1.wav", "small explode.wav"]


func get_range(power: int, _caster) -> int:
	return power * 2


func get_min_damage(_power: int, _caster) -> int:
	return 2


func get_max_damage(_power: int, _caster) -> int:
	return 8


func get_damage_roll(_power: int, _caster) -> int:
	return randi_range(2, 8)


func get_sp_cost(power: int, _caster) -> int:
	return power * 10
