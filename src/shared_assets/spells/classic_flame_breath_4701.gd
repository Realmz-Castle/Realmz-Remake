extends "res://scripts/classic_runtime/classic_breath_spell.gd"


func _init() -> void:
	name = "Classic Flame Breath 4701"
	classic_spell_class = 1
	classic_target_type = 6
	classic_spell_ids = [4701]
	classic_spell_save_index = 1
	classic_spell_save_mode = "half_damage"
	description = "Flame Breath: Deals 1-2 fire damage per power along a range-6 ray."
	attributes = ["Magical"]
	elements = [GameGlobal.ELEMENTS.FIRE]
	tags = ["Magical", "Fire"]
	schools = ["Special"]
	targettile = TARGET_TILE.NOWALL
	in_field = true
	in_combat = true
	resist = RESIST_TYPE.IGNORE_DODGE
	los = true
	ray = true
	proj_tex = GFX.FIRE
	proj_hit = GFX.FIRE
	sounds = ["wind.wav", "spell launch 2.wav"]
