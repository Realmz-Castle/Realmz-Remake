extends Spell


func _init() -> void:
	name = "Sparkling Armor"
	elements = [GameGlobal.ELEMENTS.MAGICAL]
	tags = ["Magical", "Buff"]
	schools = ["Sorcerer"]
	classic_spell_class = 8
	classic_spell_ids = [1111]
	classic_spell_save_index = -1
	classic_spell_save_mode = "none"
	targettile = TARGET_TILE.ANY
	school_levels = {"Sorcerer": 1, "Priest": 0, "Enchanter": 0}
	selection_costs = {"Sorcerer": 1, "Priest": 0, "Enchanter": 0}
	in_field = true
	in_combat = true
	description = "Sparkling Armor: Grants a decaying shield against melee attacks for one round per power."
	resist = RESIST_TYPE.IGNORE_MRES_DODGE
	skip_targeting = true
	autotarget_type = AUTOTARGET_TYPE.SELF
	proj_tex = GFX.WHIRL
	proj_hit = GFX.TARGET
	sounds = ["dididup.wav", "hit effect 1.wav"]


func get_min_duration(power: int, _caster) -> int:
	return power


func get_duration_roll(power: int, _caster) -> int:
	return power


func get_max_duration(power: int, _caster) -> int:
	return power


func get_sp_cost(power: int, _caster) -> int:
	return power * 2


func add_traits_to_creature(_caster, target, power: int) -> void:
	var trait_script = load("res://shared_assets/traits/t_pro_hits.gd")
	target.add_trait(trait_script, [power])
