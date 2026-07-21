extends Spell


func _init() -> void:
	name = "Mind Melt"
	elements = [GameGlobal.ELEMENTS.MENTAL]
	tags = ["Magical", "Mental"]
	schools = ["Priest"]
	classic_spell_class = 5
	classic_spell_ids = [2706]
	classic_spell_save_index = 5
	classic_spell_save_mode = "half_damage"
	classic_opposed_level_check = true
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 0, "Priest": 7, "Enchanter": 0}
	selection_costs = {"Sorcerer": 0, "Priest": 28, "Enchanter": 0}
	in_combat = true
	description = "Mind Melt: Deals 25-35 mental damage along a ray with range 3 per power after an opposed target-versus-caster level check."
	resist = RESIST_TYPE.IGNORE_DODGE
	los = false
	ray = true
	proj_tex = GFX.SPINNY
	proj_hit = GFX.SPHERE
	sounds = ["bwee.wav", "prout.wav"]


func get_range(power: int, _caster) -> int:
	return power * 3


func get_min_damage(_power: int, _caster) -> int:
	return 25


func get_max_damage(_power: int, _caster) -> int:
	return 35


func get_damage_roll(_power: int, _caster) -> int:
	return randi_range(25, 35)


func get_sp_cost(power: int, _caster) -> int:
	return power * 40
