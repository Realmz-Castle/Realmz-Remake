extends "res://shared_assets/spells/power_drain.gd"


func _init() -> void:
	super()
	name = "Classic Power Drain Priest"
	classic_spell_class = 7
	classic_spell_ids = [2708]
	classic_spell_save_index = 7
	classic_spell_save_mode = "half_damage"
	classic_save_adjust = -10
	classic_resist_adjust = -10
	schools = []
	school_levels = {}
	selection_costs = {}
	in_combat = true
	description = (
		"Classic Priest Power Drain: Drains 30-40 spell points per power "
		+ "with the Classic save and resistance penalties."
	)


func get_sp_cost(power: int, _caster) -> int:
	return power * 35


func get_min_spell_point_drain(power: int) -> int:
	return power * 30


func get_max_spell_point_drain(power: int) -> int:
	return power * 40


func get_spell_point_drain_roll(power: int) -> int:
	var drain := 0
	for _roll in range(power):
		drain += randi_range(30, 40)
	return drain
