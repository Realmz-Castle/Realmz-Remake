extends Spell


func _init() -> void:
	name = "Flame Hands"
	elements = [GameGlobal.ELEMENTS.FIRE]
	tags = ["Magical", "Fire", "Melee"]
	schools = ["Sorcerer"]
	classic_spell_class = 1
	classic_spell_ids = [1104]
	classic_spell_save_index = 1
	classic_spell_save_mode = "half_damage"
	targettile = TARGET_TILE.CREATURE
	school_levels = {"Sorcerer": 1, "Priest": 0, "Enchanter": 0}
	selection_costs = {"Sorcerer": 1, "Priest": 0, "Enchanter": 0}
	in_combat = true
	description = "Flame Hands: Deals 1-3 fire damage per power to a creature at touch range."
	resist = RESIST_TYPE.IGNORE_DODGE
	proj_tex = GFX.FIRE
	proj_hit = GFX.FIRE
	sounds = ["spell launch 7.wav", "small explode.wav"]


func get_range(_power: int, _caster) -> int:
	return 1


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
	return power * 2
