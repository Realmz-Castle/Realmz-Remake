extends Spell


func _init() -> void:
	name = "Vapor Trail"
	elements = [GameGlobal.ELEMENTS.CHEMICAL]
	tags = ["Magical", "Chemical"]
	schools = ["Enchanter"]
	classic_spell_class = 4
	classic_spell_ids = [3712]
	classic_spell_save_index = 4
	classic_spell_save_mode = "half_damage"
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 0, "Priest": 0, "Enchanter": 7}
	selection_costs = {"Sorcerer": 0, "Priest": 0, "Enchanter": 28}
	in_combat = true
	description = "Vapor Trail: Deals 40-65 chemical damage along a ray with range 2 per power without requiring line of sight."
	resist = RESIST_TYPE.IGNORE_DODGE
	los = false
	ray = true
	proj_tex = GFX.MIASMA
	proj_hit = GFX.MIASMA
	sounds = ["wind.wav", "big splat.wav"]


func get_range(power: int, _caster) -> int:
	return power * 2


func get_min_damage(_power: int, _caster) -> int:
	return 40


func get_max_damage(_power: int, _caster) -> int:
	return 65


func get_damage_roll(_power: int, _caster) -> int:
	return randi_range(40, 65)


func get_sp_cost(power: int, _caster) -> int:
	return power * 45
