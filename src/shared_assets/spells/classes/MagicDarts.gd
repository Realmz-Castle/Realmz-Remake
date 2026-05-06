extends Spell

func _init() -> void :
	name = "Magic Darts"
	attributes = ["Magical"]
	tags = ["Magical"]
	schools = ["Sorcerer", "Enchanter"]
	targettile = TargetTile.NOWALL
	school_levels = {"Sorcerer": 1, "Priest": 0, "Enchanter": 2}
	selection_costs = {"Sorcerer": 1, "Priest": 0, "Enchanter": 3}
	in_combat = true
	description = "Magic Darts\n\n Damage: 1-5\n    Range: 15\n    Target: x Power Level\n      Sight: Yes\nDuration: NA"
	proj_tex = "Spark"
	proj_hit = "Spark"
	sounds = ["energy blast.wav", "boink.wav"]


static func get_range(_power : int, _caster) -> int :
	return 15

static func get_min_damage(_power : int, _caster) -> int :
	return 1

static func get_max_damage(_power : int, _caster) -> int :
	return 5

static func get_damage_roll(_power : int, _caster) -> int :
	return randi_range(1, 5)

static func get_sp_cost(_power : int, _caster) -> int :
	return _power * 4
