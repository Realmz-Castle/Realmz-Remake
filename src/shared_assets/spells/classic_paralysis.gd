extends Spell

const HelplessTrait = preload(
	"res://shared_assets/traits/t_classic_helpless.gd"
)


func _init() -> void:
	name = "Paralysis"
	classic_spell_class = 5
	classic_target_type = 6
	classic_spell_ids = [4210]
	classic_spell_save_index = 5
	classic_spell_save_mode = "negate"
	description = "Paralysis: Renders one target helpless for one round per power."
	attributes = ["Magical", "Mental"]
	elements = [GameGlobal.ELEMENTS.MENTAL]
	tags = ["Magical", "Mental", "Helpless"]
	schools = ["Special"]
	targettile = TARGET_TILE.ANY
	in_field = false
	in_combat = true
	resist = RESIST_TYPE.IGNORE_MRES_DODGE
	los = false
	ray = true
	proj_tex = GFX.SPHERE
	proj_hit = GFX.SPHERE
	sounds = ["dididup.wav", "hit effect 3.wav"]


func get_range(_power: int, _caster) -> int:
	return 7


func get_min_duration(power: int, _caster) -> int:
	return power


func get_max_duration(power: int, _caster) -> int:
	return power


func get_duration_roll(power: int, _caster) -> int:
	return power


func get_min_damage(_power: int, _caster) -> int:
	return 0


func get_max_damage(_power: int, _caster) -> int:
	return 0


func get_damage_roll(_power: int, _caster) -> int:
	return 0


func get_sp_cost(_power: int, _caster) -> int:
	return 0


func add_traits_to_target(_caster, target_button, power: int) -> void:
	var target: Variant = target_button.get("creature") \
		if target_button is Object else null
	if target is Object and target.has_method("add_trait"):
		target.add_trait(HelplessTrait, [power])
