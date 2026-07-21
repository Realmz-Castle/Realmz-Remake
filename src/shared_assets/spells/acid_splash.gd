extends Spell


func _init() -> void:
	name = "Acid Splash"
	elements = [GameGlobal.ELEMENTS.CHEMICAL]
	tags = ["Magical", "Chemical"]
	schools = ["Enchanter"]
	classic_spell_class = 4
	classic_spell_ids = [3301]
	classic_spell_save_index = 4
	classic_spell_save_mode = "half_damage"
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 0, "Priest": 0, "Enchanter": 3}
	selection_costs = {"Sorcerer": 0, "Priest": 0, "Enchanter": 6}
	in_combat = true
	description = "Acid Splash: Deals 2-6 chemical damage per power along a ray with range 3 per power."
	resist = RESIST_TYPE.IGNORE_DODGE
	ray = true
	proj_tex = GFX.MIASMA
	proj_hit = GFX.SLIME
	sounds = ["big splat.wav", "slimed.wav"]


func get_range(power: int, _caster) -> int:
	return power * 3


func get_min_damage(power: int, _caster) -> int:
	return power * 2


func get_max_damage(power: int, _caster) -> int:
	return power * 6


func get_damage_roll(power: int, _caster) -> int:
	var damage := 0
	for _roll in range(power):
		damage += randi_range(2, 6)
	return damage


func get_sp_cost(power: int, _caster) -> int:
	return power * 10
