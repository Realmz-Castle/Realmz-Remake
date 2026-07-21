extends Spell


func _init() -> void:
	name = "Flash"
	elements = [GameGlobal.ELEMENTS.MAGICAL]
	tags = ["Magical"]
	schools = ["Sorcerer"]
	classic_spell_class = 6
	classic_spell_ids = [1504]
	classic_spell_save_index = 6
	classic_spell_save_mode = "half_damage"
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 5, "Priest": 0, "Enchanter": 0}
	selection_costs = {"Sorcerer": 15, "Priest": 0, "Enchanter": 0}
	in_combat = true
	description = "Flash: Deals 2-15 magical damage per power along a range-10 ray."
	resist = RESIST_TYPE.IGNORE_DODGE
	ray = true
	proj_tex = GFX.SPINNY
	proj_hit = GFX.TARGET
	sounds = ["spell launch 1.wav", "dingy ray gun.wav"]


func get_range(_power: int, _caster) -> int:
	return 10


func get_min_damage(power: int, _caster) -> int:
	return power * 2


func get_max_damage(power: int, _caster) -> int:
	return power * 15


func get_damage_roll(power: int, _caster) -> int:
	var damage := 0
	for _roll in range(power):
		damage += randi_range(2, 15)
	return damage


func get_sp_cost(power: int, _caster) -> int:
	return power * 30
