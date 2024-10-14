const name : String = 't_helpless.gd'
const menuname : String = 'Helpless (T)'
const stacks : bool = true
const trait_types : Array = ['crea_bg_blue']
var chara
var duration

func _init(args : Array):
	#npower : float, nduration : int
	chara = args[0]
	duration = args[1]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' is rendered Helpless !', null,'')

func stack(args : Array) :
	duration += args[0]

func unstack(args : Array) :
	duration -= args[0]
	if duration <= 0 :
		chara.remove_trait(self)

func get_saved_variables() :
	print('trait  helpless.gd  shouldnt be active out of combat, get_saved_variables should never happen')
	return [duration]

func _on_new_round(_character : Creature) :
	if duration <= 0 :
		chara.remove_trait(self)
		return
	chara.used_apr = chara.get_apr_left()
	chara.used_movepoints = chara.get_movement_left()
	duration -= 1

func _on_get_player_controlled() :
	return false

func _on_battle_end(chara) :
	chara.remove_trait(self)

func _on_get_stat(statname : String, stat : int) :
	if ['EvasionMelee','EvasionRanged'].has(statname) :
		return 0
	else :
		return stat

func get_info_as_text() -> String :
	return 'Helpless for '+str(duration)+' rounds'
