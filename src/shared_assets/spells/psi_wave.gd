extends Spell


func _init() -> void:
	name = "Psi Wave"
	elements = [GameGlobal.ELEMENTS.MENTAL]
	tags = ["Magical", "Mental"]
	schools = ["Priest"]
	classic_spell_class = 5
	classic_spell_ids = [2605]
	classic_spell_save_index = 5
	classic_spell_save_mode = "half_damage"
	classic_opposed_level_check = true
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 0, "Priest": 6, "Enchanter": 0}
	selection_costs = {"Sorcerer": 0, "Priest": 21, "Enchanter": 0}
	in_combat = true
	description = "Psi Wave: Deals 5-10 mental damage per power to every enemy after an opposed target-versus-caster level check."
	resist = RESIST_TYPE.IGNORE_DODGE
	los = false
	skip_targeting = true
	autotarget_type = AUTOTARGET_TYPE.ALL_ENEMIES
	proj_tex = GFX.SPINNY
	proj_hit = GFX.SPHERE
	sounds = ["dididup.wav", "bubbles.wav"]


func get_min_damage(power: int, _caster) -> int:
	return power * 5


func get_max_damage(power: int, _caster) -> int:
	return power * 10


func get_damage_roll(power: int, _caster) -> int:
	var damage := 0
	for _roll in range(power):
		damage += randi_range(5, 10)
	return damage


func get_sp_cost(power: int, _caster) -> int:
	return power * 30
