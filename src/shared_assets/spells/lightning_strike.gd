extends Spell


func _init() -> void:
	name = "Lightning Strike"
	elements = [GameGlobal.ELEMENTS.ELECTRIC]
	tags = ["Magical", "Electric"]
	schools = ["Enchanter"]
	classic_spell_class = 3
	classic_spell_ids = [3105]
	classic_spell_save_index = 3
	classic_spell_save_mode = "half_damage"
	targettile = TARGET_TILE.CREATURE
	school_levels = {"Sorcerer": 0, "Priest": 0, "Enchanter": 1}
	selection_costs = {"Sorcerer": 0, "Priest": 0, "Enchanter": 1}
	in_combat = true
	description = "Lightning Strike: Deals 1-6 electrical damage per power without requiring line of sight."
	resist = RESIST_TYPE.IGNORE_DODGE
	los = false
	proj_tex = GFX.SPARK
	proj_hit = GFX.SPARK
	sounds = ["spell launch 9.wav", "lightning.wav"]


func get_range(_power: int, _caster) -> int:
	return 20


func get_min_damage(power: int, _caster) -> int:
	return power


func get_max_damage(power: int, _caster) -> int:
	return power * 6


func get_damage_roll(power: int, _caster) -> int:
	var damage := 0
	for _roll in range(power):
		damage += randi_range(1, 6)
	return damage


func get_sp_cost(power: int, _caster) -> int:
	return power * 5
