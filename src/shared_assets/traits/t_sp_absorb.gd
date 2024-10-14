const name : String = 't_sp_absorb.gd'
const menuname : String = 'SP Absorb (T)'
const stacks : bool = true
const trait_types : Array = []
var chara
var duration : int #in seconds, 1 round = 5s


func _init(args : Array):
	#[chara, duration]
	chara = args[0]
	duration = 5*args[1]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' gets SP Absorbtion !', null,'')

func stack(args : Array) :
	duration += 5*args[0]

func unstack(args : Array) :
	duration -= 5*args[0]

func get_saved_variables() :
	return [ceil(duration/5)]

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


			#var returned_array = t._on_spell_hit_chara(caster, spell, power, applied_damage)
			#has_effect = has_effect and returned_array[0]
			#applied_damage = returned_array[1]
			#added_to_action_queue.append(returned_array[2])
func _on_spell_hit_chara(caster : Creature, spell, powerlevel : int, damage : int) -> Array :
	var cost = caster.get_spell_resource_cost(spell, powerlevel)
	chara.change_cur_sp(cost)
	return [true, damage, []]

func get_info_as_text() -> String :
	return 'SP Absorbtion for '+str(ceil(duration/5))+' rounds'
