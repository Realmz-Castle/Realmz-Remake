const name : String = 'parrying.gd'
const menuname : String = 'Parrying'
const trait_types : Array = ['Parry']
var power : int = 0
var chara

func _init(args : Array):
	#npower : float, nduration : int
	chara = args[0]
	power = chara.get_apr_left()
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' goes  in parrying stance', null,'')

func stack(args : Array) :
	pass

func unstack(args : Array) :
	pass

func get_saved_variables() :
	print('trait  parrying.gd  shouldnt be active out of combat, get_saved_variables should never happen')
	return [power]

func _on_new_round(chara) :
	chara.remove_trait(self)

func _on_battle_end(chara) :
	chara.remove_trait(self)

func _on_get_stat(statname : String, stat : int) :
	if ['EvasionMelee','EvasionRanged', 'EvasionMagic'].has(statname) :
		return stat + power *2
	else :
		return stat

func _on_evasion_check(crea, evasion_stats_used : Array, attacker, spellornull, power : int) -> Array :
	#return array : [ proceed_with_atatack_on_self : bool, added_actions_queue : Array]
	if is_instance_valid(spellornull) :
		return [true, []]
	if evasion_stats_used.has('EvasionMelee') or evasion_stats_used.has('EvasionRanged') or evasion_stats_used.has('EvasionMagic') :
		power = max(power-1, 0)
	if evasion_stats_used.has('EvasionMelee') and power>0 and is_instance_valid(attacker.combat_button) :
		var act_msg : Dictionary = {'type' : 'MeleeAttack', 'attacker' : chara.combat_button, 'defender' : attacker.combat_button, 'weapon': chara.current_melee_weapons[0] }  #uses 1 apr
		return [false,[act_msg]]
	return [true, []]
	
func get_info_as_text() -> String :
	return 'parrying'
