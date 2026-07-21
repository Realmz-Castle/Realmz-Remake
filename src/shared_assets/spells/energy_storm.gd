extends Spell


func _init() -> void:
	name = "Energy Storm"
	elements = [GameGlobal.ELEMENTS.MAGICAL, GameGlobal.ELEMENTS.ELECTRIC]
	tags = ["Magical", "Electric"]
	schools = ["Sorcerer"]
	classic_spell_class = 6
	classic_spell_ids = [1103]
	classic_spell_save_index = 6
	classic_spell_save_mode = "half_damage"
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 1, "Priest": 0, "Enchanter": 0}
	selection_costs = {"Sorcerer": 1, "Priest": 0, "Enchanter": 0}
	in_combat = true
	description = "Energy Storm: Deals 1-3 electrical damage per power over a fixed large area."
	resist = RESIST_TYPE.IGNORE_DODGE
	proj_tex = GFX.SPARK
	proj_hit = GFX.SPARK
	sounds = ["spell launch 1.wav", "electric energize.wav"]


func get_range(_power: int, _caster) -> int:
	return 7


func get_min_damage(power: int, _caster) -> int:
	return power


func get_max_damage(power: int, _caster) -> int:
	return power * 3


func get_damage_roll(power: int, _caster) -> int:
	var damage := 0
	for _roll in range(power):
		damage += randi_range(1, 3)
	return damage


func get_sp_cost(power: int, _caster) -> int:
	return power * 10


func get_aoe(_power: int, _caster) -> Array[Vector2i]:
	return AoE_ROUND
