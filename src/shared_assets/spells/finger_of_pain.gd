extends Spell


func _init() -> void:
	name = "Finger of Pain"
	elements = [GameGlobal.ELEMENTS.MAGICAL]
	tags = ["Magical"]
	schools = ["Enchanter"]
	classic_spell_class = 8
	classic_spell_ids = [3506]
	classic_spell_save_index = -1
	classic_spell_save_mode = "none"
	targettile = TARGET_TILE.CREATURE
	school_levels = {"Sorcerer": 0, "Priest": 0, "Enchanter": 5}
	selection_costs = {"Sorcerer": 0, "Priest": 0, "Enchanter": 15}
	in_combat = true
	description = "Finger of Pain: Deals 20 plus 5 magical damage per power."
	resist = RESIST_TYPE.IGNORE_DODGE
	proj_tex = GFX.SPHERE
	proj_hit = GFX.SPHERE
	sounds = ["jump.wav", "door slam.wav"]


func get_range(_power: int, _caster) -> int:
	return 8


func get_min_damage(power: int, _caster) -> int:
	return 20 + power * 5


func get_max_damage(power: int, _caster) -> int:
	return 20 + power * 5


func get_damage_roll(power: int, _caster) -> int:
	return 20 + power * 5


func get_sp_cost(power: int, _caster) -> int:
	return power * 35
