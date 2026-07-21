extends Spell


func _init() -> void:
	name = "Steel Rain"
	elements = [GameGlobal.ELEMENTS.MAGICAL]
	tags = ["Magical"]
	schools = ["Enchanter"]
	classic_spell_class = 7
	classic_spell_ids = [3211]
	classic_spell_save_index = 7
	classic_spell_save_mode = "half_damage"
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 0, "Priest": 0, "Enchanter": 2}
	selection_costs = {"Sorcerer": 0, "Priest": 0, "Enchanter": 3}
	in_combat = true
	description = "Steel Rain: Deals 2-8 damage in an area that grows with power."
	resist = RESIST_TYPE.IGNORE_DODGE
	proj_tex = GFX.TARGET
	proj_hit = GFX.TARGET
	sounds = ["lightning.wav", "sting.wav"]


func get_range(_power: int, _caster) -> int:
	return 15


func get_min_damage(_power: int, _caster) -> int:
	return 2


func get_max_damage(_power: int, _caster) -> int:
	return 8


func get_damage_roll(_power: int, _caster) -> int:
	return randi_range(2, 8)


func get_sp_cost(power: int, _caster) -> int:
	return power * 7


func get_aoe(power: int, _caster) -> Array[Vector2i]:
	return AoE_b_SCALING[clampi(power, 1, 7)]
