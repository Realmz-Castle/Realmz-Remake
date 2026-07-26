extends Spell


func _init() -> void:
	name = "Acid Spit"
	classic_spell_class = 4
	classic_target_type = 6
	classic_spell_ids = [4607]
	classic_spell_save_index = 4
	classic_spell_save_mode = "half_damage"
	description = "Acid Spit: Deals 12-36 chemical damage to one target."
	attributes = ["Magical"]
	elements = [GameGlobal.ELEMENTS.CHEMICAL]
	tags = ["Magical", "Chemical"]
	schools = ["Special"]
	targettile = TARGET_TILE.ANY
	in_field = false
	in_combat = true
	resist = RESIST_TYPE.IGNORE_MRES_DODGE
	los = false
	ray = true
	proj_tex = GFX.MIASMA
	proj_hit = GFX.SLIME
	sounds = ["bubbles.wav"]


func get_range(_power: int, _caster) -> int:
	return 4


func get_min_damage(_power: int, _caster) -> int:
	return 12


func get_max_damage(_power: int, _caster) -> int:
	return 36


func get_damage_roll(_power: int, _caster) -> int:
	return randi_range(12, 36)


func get_sp_cost(_power: int, _caster) -> int:
	return 0
