extends "res://scripts/classic_runtime/classic_breath_spell.gd"


func _init() -> void:
	name = "Acid Breath"
	classic_spell_class = 4
	classic_spell_ids = [4208, 4703]
	description = "Acid Breath: Deals 1-2 chemical damage per power along a range-6 ray."
	attributes = ["Magical"]
	elements = [GameGlobal.ELEMENTS.CHEMICAL]
	tags = ["Magical", "Chemical"]
	schools = ["Special"]
	targettile = TARGET_TILE.NOWALL
	in_field = true
	in_combat = true
	resist = RESIST_TYPE.IGNORE_MRES_DODGE
	los = true
	ray = true
	proj_tex = GFX.MIASMA
	proj_hit = GFX.SLIME
	sounds = ["wind.wav", "big splat.wav"]
