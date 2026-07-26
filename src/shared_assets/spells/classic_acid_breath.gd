extends "res://scripts/classic_runtime/classic_breath_spell.gd"


func _init() -> void:
	name = "Acid Breath"
	classic_spell_class = 4
	classic_target_type = 6
	classic_spell_ids = [4208]
	classic_spell_save_index = 4
	classic_spell_save_mode = "half_damage"
	description = "Acid Breath: Deals 2-15 chemical damage per power along a range-7 ray."
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
	sounds = ["wind.wav", "big splat.wav"]
	breath_range = 7
	damage_minimum = 2
	damage_maximum = 15
