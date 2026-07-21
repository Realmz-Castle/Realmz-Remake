extends "res://shared_assets/spells/charm_foe.gd"


func _init() -> void:
	super()
	name = "Classic Charm Foe Enchanter"
	classic_spell_ids = [3603]
	schools = []
	school_levels = {}
	selection_costs = {}


func get_sp_cost(power: int, _caster) -> int:
	return power * 30
