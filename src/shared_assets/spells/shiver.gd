extends Spell


func _init() -> void:
	name = "Shiver"
	elements = [GameGlobal.ELEMENTS.ICE]
	tags = ["Magical", "Ice"]
	schools = ["Sorcerer"]
	classic_spell_class = 2
	classic_spell_ids = [1212]
	classic_spell_save_index = -1
	classic_spell_save_mode = "none"
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 2, "Priest": 0, "Enchanter": 0}
	selection_costs = {"Sorcerer": 3, "Priest": 0, "Enchanter": 0}
	in_combat = true
	description = "Shiver: Deals 1-2 cold damage per power to every enemy without a damage save."
	resist = RESIST_TYPE.IGNORE_DODGE
	los = false
	skip_targeting = true
	autotarget_type = AUTOTARGET_TYPE.ALL_ENEMIES
	proj_tex = GFX.ICE
	proj_hit = GFX.ICE
	sounds = ["wind.wav", "electric energize.wav"]


func get_min_damage(power: int, _caster) -> int:
	return power


func get_max_damage(power: int, _caster) -> int:
	return power * 2


func get_damage_roll(power: int, _caster) -> int:
	var damage := 0
	for _roll in range(power):
		damage += randi_range(1, 2)
	return damage


func get_sp_cost(power: int, _caster) -> int:
	return power * 20
