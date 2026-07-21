extends Spell


func _init() -> void:
	name = "Magic Grip"
	elements = [GameGlobal.ELEMENTS.MAGICAL]
	tags = ["Magical", "Melee"]
	schools = ["Sorcerer"]
	classic_spell_class = 6
	classic_spell_ids = [1209]
	classic_spell_save_index = -1
	classic_spell_save_mode = "none"
	targettile = TARGET_TILE.CREATURE
	school_levels = {"Sorcerer": 2, "Priest": 0, "Enchanter": 0}
	selection_costs = {"Sorcerer": 3, "Priest": 0, "Enchanter": 0}
	in_combat = true
	description = "Magic Grip: Deals 2-6 magical damage per power at touch range."
	resist = RESIST_TYPE.IGNORE_DODGE
	proj_tex = GFX.SPINNY
	proj_hit = GFX.SPHERE
	sounds = ["bwabble.wav", "door slam.wav"]


func get_range(_power: int, _caster) -> int:
	return 1


func get_min_damage(power: int, _caster) -> int:
	return power * 2


func get_max_damage(power: int, _caster) -> int:
	return power * 6


func get_damage_roll(power: int, _caster) -> int:
	var damage := 0
	for _roll in range(power):
		damage += randi_range(2, 6)
	return damage


func get_sp_cost(power: int, _caster) -> int:
	return power * 4
