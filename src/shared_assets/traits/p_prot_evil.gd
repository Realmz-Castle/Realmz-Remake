const name : String = 'pro_evil.gd'
const menuname : String = 'Protection from Evil'
const stacks : bool = false
const trait_types : Array = []
var chara
const permanent : int = 1
var trait_source : String = ''

func _init(args : Array):
	#[chara]
	chara = args[0]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' is Permanently Protected from Evil !', null,'')

func get_saved_variables() :
	return []

func _on_spell_hit_chara(caster : Creature, spell, damage : int ):
	#[has_effect, applied_damage, [{added_to_action_queue}] ]
	if caster.tags.has('Evil') :
		
		return [true, roundi(damage*0.9), [{}]]
	else :
		return[true, damage, [{}]]

func _on_before_melee_attack(character : Creature, returned_array : Array) :
	#[true, _attacker , combat_button, damage_detail, []] #last is for extra  queued actions
	if returned_array[1].tags.has('Evil') :
		returned_array[3]['total'] = roundi(returned_array[3]['total']*0.9)
	return returned_array
	
func get_info_as_text() -> String :
	return 'Permanent Evil Protection'+' (source : '+trait_source+')'

func equals_args(traits_array : Array) :
	return true
