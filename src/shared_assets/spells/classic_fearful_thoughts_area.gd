extends "res://shared_assets/spells/fearful_thoughts.gd"


func _init() -> void:
	super()
	name = "Classic Fearful Thoughts Area"
	classic_spell_class = 5
	classic_spell_ids = [1603, 3505]
	classic_spell_save_index = 5
	classic_spell_save_mode = "negate"
	classic_opposed_level_check = false
	targettile = TARGET_TILE.NOWALL
	schools = []
	school_levels = {}
	selection_costs = {}
	in_combat = true
	description = (
		"Classic Fearful Thoughts: Forces creatures in a fixed large area "
		+ "to flee for 1-2 rounds per power."
	)


func get_range(_power: int, _caster) -> int:
	return 7


func get_min_duration(power: int, _caster) -> int:
	return power


func get_duration_roll(power: int, _caster) -> int:
	var duration := 0
	for _roll in range(power):
		duration += randi_range(1, 2)
	return duration


func get_max_duration(power: int, _caster) -> int:
	return power * 2


func get_sp_cost(power: int, _caster) -> int:
	return power * 35


func get_aoe(_power: int, _caster) -> Array[Vector2i]:
	return AoE_ROUND
