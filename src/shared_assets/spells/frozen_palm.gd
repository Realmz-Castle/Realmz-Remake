extends Spell


func _init() -> void:
	name = "Frozen Palm"
	elements = [GameGlobal.ELEMENTS.ICE]
	tags = ["Magical", "Ice", "Melee"]
	schools = ["Sorcerer"]
	classic_spell_class = 2
	classic_spell_ids = [1204]
	classic_spell_save_index = 2
	classic_spell_save_mode = "half_damage"
	targettile = TARGET_TILE.CREATURE
	school_levels = {"Sorcerer": 2, "Priest": 0, "Enchanter": 0}
	selection_costs = {"Sorcerer": 3, "Priest": 0, "Enchanter": 0}
	in_combat = true
	description = "Frozen Palm: Deals 2-4 cold damage per power to a creature at touch range."
	resist = RESIST_TYPE.IGNORE_DODGE
	proj_tex = GFX.ICE
	proj_hit = GFX.ICE
	sounds = ["spell launch 7.wav", "electric energize.wav"]


func get_range(_power: int, _caster) -> int:
	return 1


func get_min_damage(power: int, _caster) -> int:
	return power * 2


func get_max_damage(power: int, _caster) -> int:
	return power * 4


func get_damage_roll(power: int, _caster) -> int:
	var damage := 0
	for _roll in range(power):
		damage += randi_range(2, 4)
	return damage


func get_sp_cost(power: int, _caster) -> int:
	return power * 3
