const name : String = 'pro_proj.gd'
const menuname : String = 'Protection from Projectiles'
const stacks : bool = false
const trait_types : Array = []
var chara
var level : int = 0
const permanent : int = 1
var trait_source : String = ''

func _init(args : Array):
	#[chara,level]
	chara = args[0]
	level = args[1]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' is Permanently Immune Lv.<='+str(level)+' !', null,'')

func get_saved_variables() :
	return [level]

func _on_spell_hit_chara(caster : Creature, spell, damage : int ):
	#[has_effect, applied_damage, [{added_to_action_queue}] ]
	if spell.attributes.has('Magical') and spell.level <= level:
		return [false, 0, [{}]]
	else :
		return[true, damage, [{}]]

func get_info_as_text() -> String :
	return 'Permanent Spell Protection Lv.'+str(level)+' (source : '+trait_source+')'

func equals_args(traits_array : Array) :
	return traits_array[0]==level
