extends "res://scripts/classic_runtime/classic_breath_spell.gd"


func _init() -> void:
	name = "Classic Acid Breath 4703"
	classic_spell_class = 5
	classic_target_type = 6
	classic_spell_ids = [4703]
	classic_spell_save_index = 5
	classic_spell_save_mode = "half_damage"
	description = "Acid Breath: Deals 1-2 mental damage per power along a range-6 ray."
	attributes = ["Magical"]
	elements = [GameGlobal.ELEMENTS.MENTAL]
	tags = ["Magical", "Mental"]
	schools = ["Special"]
	targettile = TARGET_TILE.NOWALL
	in_field = true
	in_combat = true
	resist = RESIST_TYPE.IGNORE_DODGE
	los = true
	ray = true
	proj_tex = GFX.MIASMA
	proj_hit = GFX.SLIME
	sounds = ["wind.wav", "big splat.wav"]
