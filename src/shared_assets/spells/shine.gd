extends Spell


func _init() -> void:
	name = "Shine"
	elements = [GameGlobal.ELEMENTS.MAGICAL]
	tags = ["Magical", "Light"]
	schools = ["Sorcerer", "Priest"]
	classic_spell_class = 8
	classic_spell_ids = [1110, 2110]
	classic_spell_save_index = -1
	classic_spell_save_mode = "none"
	targettile = TARGET_TILE.ANY
	school_levels = {"Sorcerer": 1, "Priest": 1, "Enchanter": 0}
	selection_costs = {"Sorcerer": 1, "Priest": 1, "Enchanter": 0}
	in_field = true
	skip_targeting = true
	autotarget_type = AUTOTARGET_TYPE.SELF
	description = "Shine:  Will cause a magical flame to illuminate dark areas."
	proj_tex = GFX.WHIRL
	proj_hit = GFX.TARGET
	sounds = ["spell launch 2.wav", "spell launch 2.wav"]


func get_targets(_power: int, _caster) -> int:
	return 0


func get_min_duration(power: int, _caster) -> int:
	return 1200 * power


func get_duration_roll(power: int, _caster) -> int:
	return 1200 * power


func get_max_duration(power: int, _caster) -> int:
	return 1200 * power


func get_sp_cost(power: int, _caster) -> int:
	return power * 3


func get_target_number(_power: int, _caster) -> int:
	return 0


func special_effect(
	_caster,
	_spell,
	power: int,
	_main_targeted_tile,
	_effected_tiles,
	_effected_creatures,
	_add_terrain
) -> bool:
	if GameGlobal.is_classic_campaign(GameGlobal.currentcampaign):
		GameGlobal.add_classic_light_effect(power)
	else:
		GameGlobal.add_light_effect(power, 1200 * power)
	return true
