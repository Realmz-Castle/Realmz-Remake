extends Spell


func _init() -> void:
	name = "Mind Rash"
	elements = [GameGlobal.ELEMENTS.MENTAL]
	tags = ["Magical", "Mental"]
	schools = ["Enchanter"]
	classic_spell_class = 5
	classic_spell_ids = [3704]
	classic_spell_save_index = 5
	classic_spell_save_mode = "half_damage"
	classic_save_adjust = -2
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 0, "Priest": 0, "Enchanter": 7}
	selection_costs = {"Sorcerer": 0, "Priest": 0, "Enchanter": 28}
	in_combat = true
	description = "Mind Rash: Deals 4-7 plus 4-7 mental damage per power to every enemy and penalizes saves by 2% per power."
	resist = RESIST_TYPE.IGNORE_DODGE
	los = false
	skip_targeting = true
	autotarget_type = AUTOTARGET_TYPE.ALL_ENEMIES
	proj_tex = GFX.MIASMA
	proj_hit = GFX.THORNS
	sounds = ["dididup.wav", "prout.wav"]


func get_min_damage(power: int, _caster) -> int:
	return 4 + power * 4


func get_max_damage(power: int, _caster) -> int:
	return 7 + power * 7


func get_damage_roll(power: int, _caster) -> int:
	var damage := randi_range(4, 7)
	for _roll in range(power):
		damage += randi_range(4, 7)
	return damage


func get_sp_cost(power: int, _caster) -> int:
	return power * 90
