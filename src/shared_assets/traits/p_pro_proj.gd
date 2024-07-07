const name : String = 'p_pro_proj.gd'
const menuname : String = 'Protection from Projectiles (P)'
const stacks : bool = false
const trait_types : Array = []
var chara
const permanent : int = 1
var trait_source : String = ''

func _init(args : Array):
	#[chara]
	chara = args[0]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' is Permanently Protected from Projectiles !', null,'')

func get_saved_variables() :
	return []

func _on_spell_hit_chara(caster : Creature, spell, damage : int ):
	#[has_effect, applied_damage, [{added_to_action_queue}] ]
	if spell.attributes.has('Projectile') :
		return [false, 0, [{}]]
	else :
		return[true, damage, [{}]]

func get_info_as_text() -> String :
	return 'Permanent Missile Protection'+' (source : '+trait_source+')'

func equals_args(traits_array : Array) :
	return true
