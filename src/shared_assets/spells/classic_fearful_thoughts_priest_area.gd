extends "res://shared_assets/spells/fearful_thoughts.gd"


func _init() -> void:
	super()
	name = "Classic Fearful Thoughts Priest Area"
	classic_spell_class = 5
	classic_spell_ids = [2403]
	classic_spell_save_index = 5
	classic_spell_save_mode = "negate"
	targettile = TARGET_TILE.NOWALL
	schools = []
	school_levels = {}
	selection_costs = {}
	in_combat = true
	description = (
		"Classic Priest Fearful Thoughts: Forces creatures in a fixed large area "
		+ "to flee for one round per power after an opposed-level check."
	)


func get_range(_power: int, _caster) -> int:
	return 7


func get_sp_cost(power: int, _caster) -> int:
	return power * 15


func get_aoe(_power: int, _caster) -> Array[Vector2i]:
	return AoE_ROUND
