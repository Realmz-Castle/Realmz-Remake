extends "res://shared_assets/spells/discover_magic.gd"


func _init() -> void:
	super()
	name = "Classic Discover Magic Area"
	classic_spell_ids = [2102, 3102]
	schools = []
	school_levels = {}
	selection_costs = {}
	targettile = TARGET_TILE.NOWALL


func get_aoe(power: int, _caster) -> Array[Vector2i]:
	return AoE_b_SCALING[clampi(power, 1, 7)]
