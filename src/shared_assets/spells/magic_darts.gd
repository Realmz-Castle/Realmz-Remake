extends Spell

func _init() -> void :
	name = "Magic Darts"
	elements = [GameGlobal.ELEMENTS.MAGICAL]
	tags = ["Magical"]
	schools = ["Sorcerer", "Enchanter"]
	classic_spell_class = 6
	targettile = TARGET_TILE.NOWALL
	school_levels = {"Sorcerer": 1, "Priest": 0, "Enchanter": 2}
	selection_costs = {"Sorcerer": 1, "Priest": 0, "Enchanter": 3}
	in_combat = true
	description = "Magic Darts\n\n Damage: 1-5\n    Range: 15\n    Target: x Power Level\n      Sight: Yes\nDuration: NA"
	proj_tex = GFX.SPARK
	proj_hit = GFX.SPARK
	sounds = ["energy blast.wav", "boing.wav"]


func get_range(_power : int, _caster) -> int :
	return 15

func get_min_damage(_power : int, _caster) -> int :
	return 1

func get_max_damage(_power : int, _caster) -> int :
	return 5

func get_damage_roll(_power : int, _caster) -> int :
	return randi_range(1, 5)

func get_sp_cost(_power : int, _caster) -> int :
	return _power * 4

func get_target_number(_power : int, _caster) -> int :
	return _power
