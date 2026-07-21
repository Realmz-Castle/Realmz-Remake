extends Spell


func _init() -> void:
	name = "Flame Spikes"
	elements = [GameGlobal.ELEMENTS.MAGICAL, GameGlobal.ELEMENTS.FIRE]
	tags = ["Magical", "Fire"]
	schools = ["Sorcerer"]
	classic_spell_class = 1
	classic_spell_ids = [1203]
	classic_spell_save_index = 1
	classic_spell_save_mode = "half_damage"
	classic_save_bonus = 10
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 2, "Priest": 0, "Enchanter": 0}
	selection_costs = {"Sorcerer": 3, "Priest": 0, "Enchanter": 0}
	in_combat = true
	description = "Flame Spikes: Deals 1-4 fire damage per power to every enemy."
	resist = RESIST_TYPE.IGNORE_DODGE
	los = false
	skip_targeting = true
	autotarget_type = AUTOTARGET_TYPE.ALL_ENEMIES
	proj_tex = GFX.FIRE
	proj_hit = GFX.FIRE
	sounds = ["spell launch 1.wav", "spell hit object.wav"]


func get_min_damage(power: int, _caster) -> int:
	return power


func get_max_damage(power: int, _caster) -> int:
	return power * 4


func get_damage_roll(power: int, _caster) -> int:
	var damage := 0
	for _roll in range(power):
		damage += randi_range(1, 4)
	return damage


func get_sp_cost(power: int, _caster) -> int:
	return power * 25
