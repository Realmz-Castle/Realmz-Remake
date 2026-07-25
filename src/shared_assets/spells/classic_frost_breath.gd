extends "res://scripts/classic_runtime/classic_breath_spell.gd"


func _init() -> void:
	name = "Frost Breath"
	description = "Frost Breath: Deals 2-15 ice damage per power along a range-7 ray."
	attributes = ["Magical"]
	elements = [GameGlobal.ELEMENTS.ICE]
	tags = ["Magical", "Ice"]
	schools = ["Special"]
	targettile = TARGET_TILE.ANY
	in_combat = true
	resist = RESIST_TYPE.IGNORE_MRES_DODGE
	los = false
	ray = true
	proj_tex = GFX.ICE
	proj_hit = GFX.ICE
	sounds = ["wind.wav", "electric energize.wav"]
	breath_range = 7
	damage_minimum = 2
	damage_maximum = 15
