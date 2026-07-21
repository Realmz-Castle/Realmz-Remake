extends Spell


func _init() -> void:
	name = "Soul Bind"
	elements = [GameGlobal.ELEMENTS.MAGICAL, GameGlobal.ELEMENTS.MENTAL]
	tags = ["Magical", "Mental"]
	schools = ["Priest"]
	classic_spell_class = 5
	classic_spell_ids = [2111]
	classic_spell_save_index = 5
	classic_spell_save_mode = "negate"
	targettile = TARGET_TILE.CREATURE
	school_levels = {"Sorcerer": 0, "Priest": 1, "Enchanter": 0}
	selection_costs = {"Sorcerer": 0, "Priest": 1, "Enchanter": 0}
	in_combat = true
	description = "Soul Bind: Renders the target helpless for two to four rounds."
	resist = RESIST_TYPE.IGNORE_NOTHING
	los = false
	proj_tex = GFX.WHIRL
	proj_hit = GFX.SPINNY
	sounds = ["hit effect 2.wav", "hit effect 4.wav"]


func get_range(_power: int, _caster) -> int:
	return 8


func get_min_duration(_power: int, _caster) -> int:
	return 2


func get_duration_roll(_power: int, _caster) -> int:
	return randi_range(2, 4)


func get_max_duration(_power: int, _caster) -> int:
	return 4


func get_sp_cost(power: int, _caster) -> int:
	return power * 15


func add_traits_to_creature(caster, target, power: int) -> void:
	var trait_script = load("res://shared_assets/traits/t_helpless.gd")
	target.add_trait(trait_script, [get_duration_roll(power, caster)])
