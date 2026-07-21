extends Spell


func _init() -> void:
	name = "Acid Rain"
	elements = [GameGlobal.ELEMENTS.CHEMICAL]
	tags = ["Magical", "Chemical"]
	schools = ["Enchanter"]
	classic_spell_class = 4
	classic_spell_ids = [3401]
	classic_spell_save_index = 4
	classic_spell_save_mode = "half_damage"
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 0, "Priest": 0, "Enchanter": 4}
	selection_costs = {"Sorcerer": 0, "Priest": 0, "Enchanter": 10}
	in_combat = true
	description = "Acid Rain: Deals 3-16 chemical damage in an area that grows with power."
	resist = RESIST_TYPE.IGNORE_DODGE
	proj_tex = GFX.MIASMA
	proj_hit = GFX.SLIME
	sounds = ["big splat.wav", "slimed.wav"]


func get_range(_power: int, _caster) -> int:
	return 8


func get_min_damage(_power: int, _caster) -> int:
	return 3


func get_max_damage(_power: int, _caster) -> int:
	return 16


func get_damage_roll(_power: int, _caster) -> int:
	return randi_range(3, 16)


func get_sp_cost(power: int, _caster) -> int:
	return power * 12


func get_aoe(power: int, _caster) -> Array[Vector2i]:
	return AoE_b_SCALING[clampi(power, 1, 7)]
