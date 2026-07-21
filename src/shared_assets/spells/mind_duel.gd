extends Spell


func _init() -> void:
	name = "Mind Duel"
	elements = [GameGlobal.ELEMENTS.MENTAL]
	tags = ["Magical", "Mental"]
	schools = ["Priest"]
	classic_spell_class = 5
	classic_spell_ids = [2306]
	classic_spell_save_index = 5
	classic_spell_save_mode = "half_damage"
	classic_opposed_level_check = true
	targettile = TARGET_TILE.CREATURE
	school_levels = {"Sorcerer": 0, "Priest": 3, "Enchanter": 0}
	selection_costs = {"Sorcerer": 0, "Priest": 6, "Enchanter": 0}
	in_combat = true
	description = "Mind Duel: Deals 4-10 mental damage per power at range 12 after an opposed target-versus-caster level check."
	resist = RESIST_TYPE.IGNORE_DODGE
	los = false
	proj_tex = GFX.TARGET
	proj_hit = GFX.SPINNY
	sounds = ["pinball bumper.wav", "swup.wav"]


func get_range(_power: int, _caster) -> int:
	return 12


func get_min_damage(power: int, _caster) -> int:
	return power * 4


func get_max_damage(power: int, _caster) -> int:
	return power * 10


func get_damage_roll(power: int, _caster) -> int:
	var damage := 0
	for _roll in range(power):
		damage += randi_range(4, 10)
	return damage


func get_sp_cost(power: int, _caster) -> int:
	return power * 10
