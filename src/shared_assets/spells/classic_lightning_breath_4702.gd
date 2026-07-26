extends "res://scripts/classic_runtime/classic_breath_spell.gd"


func _init() -> void:
	name = "Classic Lightning Breath 4702"
	classic_spell_class = 3
	classic_target_type = 6
	classic_spell_ids = [4702]
	classic_spell_save_index = 3
	classic_spell_save_mode = "half_damage"
	description = "Lightning Breath: Deals 1-2 electric damage per power along a range-6 ray."
	attributes = ["Magical"]
	elements = [GameGlobal.ELEMENTS.ELECTRIC]
	tags = ["Magical", "Electric"]
	schools = ["Special"]
	targettile = TARGET_TILE.NOWALL
	in_field = true
	in_combat = true
	resist = RESIST_TYPE.IGNORE_DODGE
	los = true
	ray = true
	proj_tex = GFX.SPARK
	proj_hit = GFX.SPARK
	sounds = ["wind.wav", "hit effect 3.wav"]
