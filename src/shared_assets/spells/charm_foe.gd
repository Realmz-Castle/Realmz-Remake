extends Spell


func _init() -> void:
	name = "Charm Foe"
	elements = [GameGlobal.ELEMENTS.MAGICAL, GameGlobal.ELEMENTS.MENTAL]
	tags = ["Magical", "Charm"]
	schools = ["Sorcerer", "Priest"]
	classic_spell_class = 0
	classic_spell_ids = [1501, 2201]
	classic_spell_response_ids = [1501, 2201, 3603]
	classic_spell_save_index = -1
	classic_spell_save_mode = "none"
	targettile = TARGET_TILE.CREATURE
	school_levels = {"Sorcerer": 5, "Priest": 2, "Enchanter": 0}
	selection_costs = {"Sorcerer": 15, "Priest": 3, "Enchanter": 0}
	in_combat = true
	description = "Charm Foe: Changes the target's allegiance to the caster for the battle."
	resist = RESIST_TYPE.IGNORE_NOTHING
	los = false
	proj_tex = GFX.BALL
	proj_hit = GFX.SPINNY
	sounds = ["spell launch 4.wav", "hit effect 4.wav"]


func get_range(_power: int, _caster) -> int:
	return 8


func get_sp_cost(power: int, _caster) -> int:
	return power * 15


func add_traits_to_creature(caster, target, _power: int) -> void:
	var trait_script = load("res://shared_assets/traits/t_classic_charmed.gd")
	target.add_trait(trait_script, [caster])
