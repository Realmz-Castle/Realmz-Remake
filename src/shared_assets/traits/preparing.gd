const name : String = 'preparing.gd'
const menuname : String = 'Preparing'
const trait_types : Array = ['Prep.']
const prep_can_use_every_round  : bool = false
var power : int = 0 # only for display in the menu
# check creature.func move(dir : Vector2)->void :
var melee_crit_rate_bonus : float = 0
var ranged_crit_rate_bonus : float = 0
var melee_crit_mult_bonus : float = 0
var ranged_crit_mult_bonus : float = 0
var melee_acc_bonus : float = 0
var ranged_acc_bonus : float= 0
var magic_acc_bonus : float= 0
var apr_bonus : int = 0

var duration : int = 0

var chara

func _init(args : Array):
	duration = 2
	chara = args[0]
	var consumed_ap : int = chara.get_apr_left()
	power = 1 # only for display in the menu
	var chara_melee_acc : float = chara.get_stat('AccuracyMelee')
	var chara_ranged_acc : float = chara.get_stat('AccuracyRanged')
	var melee_weight : float = chara_melee_acc/(chara_melee_acc+chara_ranged_acc)
	var ap_for_mele : float = consumed_ap * melee_weight
	var ap_for_ranged : float = consumed_ap * (1.0-melee_weight)
	var chara_melee_cr : float = chara.get_stat('Melee_Crit_Rate')
	var chara_ranged_cr : float = chara.get_stat('Ranged_Crit_Rate')
	
	while chara_melee_cr+melee_crit_rate_bonus<1.0 :
		if ap_for_mele<=0 :
			break
		melee_crit_rate_bonus +=0.05
		melee_acc_bonus+2
		ap_for_mele -= 0.5
	while ap_for_mele>0 :
		if ap_for_mele<=0 :
			break
		melee_acc_bonus+2
		melee_crit_mult_bonus+0.1
		ap_for_mele -= 0.5
	
	while chara_ranged_cr+ranged_acc_bonus<1.0 :
		if ap_for_ranged<=0 :
			break
		ranged_crit_rate_bonus +=0.05
		ranged_acc_bonus+2
		ap_for_ranged -= 0.5
	while ap_for_ranged>0 :
		if ap_for_ranged<=0 :
			break
		ranged_acc_bonus+2
		ranged_crit_mult_bonus+0.1
		ap_for_ranged -= 0.5
	magic_acc_bonus = consumed_ap * 0.05 * chara.get_stat('Intellect')
	apr_bonus = ceil(consumed_ap/2)
	duration = 2
	
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, '  prepares themself for he next round.', null,'')

func stack(args : Array) :
	pass

func unstack(args : Array) :
	pass

func get_saved_variables() :
	print('trait preparing.gd shouldnt be active out of combat, get_saved_variables should never happen')
	return [duration]

func _on_new_round(chara) :
	duration -= 1
	if duration <= 0 :
		chara.remove_trait(self)
	

func _on_battle_end(chara) :
	chara.remove_trait(self)

func _on_get_stat(statname : String, stat : float) :
	match statname :
		'AccuracyMelee' :
			return stat + melee_acc_bonus
		'AccuracyRanged' :
			return stat + ranged_acc_bonus
		'AccuracyMagic' :
			return stat + magic_acc_bonus
		'Melee_Crit_Rate' :
			return stat + melee_crit_rate_bonus
		'Ranged_Crit_Rate' :
			return stat + ranged_crit_rate_bonus
		'Melee_Crit_Mult' :
			return stat + melee_crit_mult_bonus
		'Ranged_Crit_Mult' :
			return stat + ranged_crit_mult_bonus
		'MaxActions' :
			return stat + apr_bonus
	return stat


func get_info_as_text() -> String :
	return 'Preparing for the next turn !'
