extends Spell


func _init() -> void:
	name = "Cosmic Blast"
	elements = [GameGlobal.ELEMENTS.MAGICAL]
	tags = ["Magical"]
	schools = ["Enchanter", "Sorcerer"]
	classic_spell_class = 6
	classic_spell_ids = [1401, 3303]
	classic_spell_save_index = 6
	classic_spell_save_mode = "half_damage"
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 4, "Priest": 0, "Enchanter": 3}
	selection_costs = {"Sorcerer": 10, "Priest": 0, "Enchanter": 6}
	in_combat = true
	description = "Cosmic Blast: Deals 2-4 magical damage per power to every enemy."
	resist = RESIST_TYPE.IGNORE_DODGE
	los = false
	skip_targeting = true
	autotarget_type = AUTOTARGET_TYPE.ALL_ENEMIES
	proj_tex = GFX.WHIRL
	proj_hit = GFX.SPHERE
	sounds = ["lightning.wav", "spell hit object.wav"]


func get_min_damage(power: int, _caster) -> int:
	return power * 2


func get_max_damage(power: int, _caster) -> int:
	return power * 4


func get_damage_roll(power: int, _caster) -> int:
	var damage := 0
	for _roll in range(power):
		damage += randi_range(2, 4)
	return damage


func get_sp_cost(power: int, _caster) -> int:
	return power * 30
