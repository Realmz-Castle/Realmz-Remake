extends Spell


func _init() -> void:
	name = "Shock Palm"
	elements = [GameGlobal.ELEMENTS.ELECTRIC]
	tags = ["Magical", "Electric", "Melee"]
	schools = ["Enchanter"]
	classic_spell_class = 3
	classic_spell_ids = [3409]
	classic_spell_save_index = 3
	classic_spell_save_mode = "half_damage"
	classic_save_adjust = -5
	classic_resist_adjust = -5
	targettile = TARGET_TILE.CREATURE
	school_levels = {"Sorcerer": 0, "Priest": 0, "Enchanter": 4}
	selection_costs = {"Sorcerer": 0, "Priest": 0, "Enchanter": 10}
	in_combat = true
	description = "Shock Palm: Deals 10 plus 2-4 electrical damage per power and penalizes saves and resistance by 5% per power."
	resist = RESIST_TYPE.IGNORE_DODGE
	proj_tex = GFX.SPARK
	proj_hit = GFX.SPARK
	sounds = ["spell launch 6.wav", "prout.wav"]


func get_range(_power: int, _caster) -> int:
	return 1


func get_min_damage(power: int, _caster) -> int:
	return 10 + power * 2


func get_max_damage(power: int, _caster) -> int:
	return 10 + power * 4


func get_damage_roll(power: int, _caster) -> int:
	var damage := 10
	for _roll in range(power):
		damage += randi_range(2, 4)
	return damage


func get_sp_cost(power: int, _caster) -> int:
	return power * 15
