extends "res://shared_assets/spells/magic_darts.gd"


func _init() -> void:
	super()
	name = "Classic Magic Darts Enchanter"
	classic_spell_ids = [3208]
	schools = []
	school_levels = {}
	selection_costs = {}
	description = "Classic Enchanter Magic Darts: Deals 1-4 magical damage to each target."


func get_max_damage(_power: int, _caster) -> int:
	return 4


func get_damage_roll(_power: int, _caster) -> int:
	return randi_range(1, 4)
