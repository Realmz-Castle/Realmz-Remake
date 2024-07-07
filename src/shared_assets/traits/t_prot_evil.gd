const name : String = 't_pro_evil.gd'
const menuname : String = 'Protection from Evil (T)'
const stacks : bool = true
const trait_types : Array = []
var chara
var duration : int #in seconds, 1 round = 5s

func _init(args : Array):
	#[chara, duration]
	chara = args[0]
	duration = 5*args[1]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' is Protected from Evil !', null,'')

func stack(args : Array) :
	duration += 5*args[1]

func unstack(args : Array) :
	duration -= 5*args[1]

func get_saved_variables() :
	return [ceil(duration/5)]

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

func _on_new_round(_character : Creature) :
	if duration <= 0 :
		chara.remove_trait(self)
		return
	duration -= 5

func _on_time_pass(_character, seconds) :
	if duration <= 0 :
		chara.remove_trait(self)
		return
	duration -= seconds
	
func get_info_as_text() -> String :
	return 'Evil Protection for '+str(ceil(duration/5))+' rounds'
