const name : String = 't_reflect_melee.gd'
const menuname : String = 'Melee Reflection (T)'
const stacks : bool = true
const trait_types : Array = []
var chara
var duration : int #in seconds, 1 round = 5s
var power : int

func _init(args : Array):
	#[chara, duration]
	chara = args[0]
	duration = 5*args[1]
	power = args[2]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' gets Melee Reflection !', null,'')

func stack(args : Array) :
	duration += 5*args[0]

func unstack(args : Array) :
	duration -= 5*args[0]
	if duration <= 0 :
		chara.remove_trait(self)

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

func _on_evasion_check(crea, evasion_stats_used : Array, attacker, spellornull, power : int) -> Array :
	#return array : [ proceed_with_atatack_on_self : bool, added_actions_queue : Array]
	print('Melee Reflection Trait : _on_evasion_check attacker = '+attacker.name+', crea = '+crea.name)
	if is_instance_valid(spellornull) :	#null if melee
		#print('   spellornull is instance valid so nothing happens')
		return [true, []]
	if (not is_instance_valid(attacker.combat_button)) or (not is_instance_valid(chara.combat_button)) :
		#print('    on e of the cmbat buton is nt instance_valid so nothing happens')
		return [true, []]
	
	if randf()<0.666 : return [true, []]
	
	var used_weapon : Dictionary = crea.current_melee_weapons[0]
	var action_msg : Dictionary = {'type' : 'MeleeAttack', 'attacker' : crea.combat_button, 'defender' : attacker.combat_button, 'weapon': used_weapon }
	return [false,[action_msg]]
	
func get_info_as_text() -> String :
	return 'Melee Reflection for '+str(ceil(duration/5))+' rounds'
