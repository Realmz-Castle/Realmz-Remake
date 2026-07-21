extends Spell


func _init() -> void:
	name = "Lightning Bolt"
	elements = [GameGlobal.ELEMENTS.ELECTRIC]
	tags = ["Magical", "Electric"]
	schools = ["Enchanter"]
	classic_spell_class = 3
	classic_spell_ids = [3308]
	classic_spell_save_index = 3
	classic_spell_save_mode = "half_damage"
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 0, "Priest": 0, "Enchanter": 3}
	selection_costs = {"Sorcerer": 0, "Priest": 0, "Enchanter": 6}
	in_combat = true
	description = "Lightning Bolt: Deals 3-18 electrical damage along a ray with range 2 per power."
	resist = RESIST_TYPE.IGNORE_DODGE
	ray = true
	proj_tex = GFX.BALL
	proj_hit = GFX.SPARK
	sounds = ["lightning.wav", "prout.wav"]


func get_range(power: int, _caster) -> int:
	return power * 2


func get_min_damage(_power: int, _caster) -> int:
	return 3


func get_max_damage(_power: int, _caster) -> int:
	return 18


func get_damage_roll(_power: int, _caster) -> int:
	return randi_range(3, 18)


func get_sp_cost(power: int, _caster) -> int:
	return power * 10
