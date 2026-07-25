extends "res://scripts/classic_runtime/classic_breath_spell.gd"


func _init() -> void:
	name = "Flame Breath"
	classic_spell_class = 4
	classic_spell_ids = [4206, 4701]
	description = "Flame Breath: Deals 1-2 fire damage per power along a range-6 ray."
	attributes = ["Magical"]
	elements = [GameGlobal.ELEMENTS.FIRE]
	tags = ["Magical", "Fire"]
	schools = ["Special"]
	targettile = TARGET_TILE.NOWALL
	in_field = true
	in_combat = true
	resist = RESIST_TYPE.IGNORE_MRES_DODGE
	los = true
	ray = true
	proj_tex = GFX.FIRE
	proj_hit = GFX.FIRE
	sounds = ["wind.wav", "spell launch 2.wav"]
