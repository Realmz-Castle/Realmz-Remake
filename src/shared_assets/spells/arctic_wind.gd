extends Spell


func _init() -> void:
	name = "Arctic Wind"
	elements = [GameGlobal.ELEMENTS.ICE]
	tags = ["Magical", "Ice"]
	schools = ["Sorcerer"]
	classic_spell_class = 2
	classic_spell_ids = [1701]
	classic_spell_save_index = 2
	classic_spell_save_mode = "half_damage"
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 7, "Priest": 0, "Enchanter": 0}
	selection_costs = {"Sorcerer": 28, "Priest": 0, "Enchanter": 0}
	in_combat = true
	description = "Arctic Wind: Deals 20-40 cold damage per power along a range-15 ray without requiring line of sight."
	resist = RESIST_TYPE.IGNORE_DODGE
	los = false
	ray = true
	proj_tex = GFX.ICE
	proj_hit = GFX.ICE
	sounds = ["wind.wav", "electric energize.wav"]


func get_range(_power: int, _caster) -> int:
	return 15


func get_min_damage(power: int, _caster) -> int:
	return power * 20


func get_max_damage(power: int, _caster) -> int:
	return power * 40


func get_damage_roll(power: int, _caster) -> int:
	var damage := 0
	for _roll in range(power):
		damage += randi_range(20, 40)
	return damage


func get_sp_cost(power: int, _caster) -> int:
	return power * 60
