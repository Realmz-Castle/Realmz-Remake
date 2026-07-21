extends Spell


func _init() -> void:
	name = "Radiate"
	elements = [GameGlobal.ELEMENTS.MAGICAL]
	tags = ["Magical"]
	schools = ["Sorcerer"]
	classic_spell_class = 6
	classic_spell_ids = [1310]
	classic_spell_save_index = 6
	classic_spell_save_mode = "half_damage"
	classic_save_bonus = -10
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 3, "Priest": 0, "Enchanter": 0}
	selection_costs = {"Sorcerer": 6, "Priest": 0, "Enchanter": 0}
	in_combat = true
	description = "Radiate: Deals 2-15 magical damage per power to all adjacent creatures."
	resist = RESIST_TYPE.IGNORE_DODGE
	skip_targeting = true
	autotarget_type = AUTOTARGET_TYPE.SELF
	proj_tex = GFX.SPARK
	proj_hit = GFX.SPINNY
	sounds = ["resurrect death.wav", "swup.wav"]


func get_min_damage(power: int, _caster) -> int:
	return power * 2


func get_max_damage(power: int, _caster) -> int:
	return power * 15


func get_damage_roll(power: int, _caster) -> int:
	var damage := 0
	for _roll in range(power):
		damage += randi_range(2, 15)
	return damage


func get_sp_cost(power: int, _caster) -> int:
	return power * 25


func get_aoe(_power: int, _caster) -> Array[Vector2i]:
	return AoE_RADIANT
