const name : String = 't_hindered_def.gd'
const menuname : String = 'Hindered Evasion (T)'
const stacks : bool = true
const trait_types : Array = []
var chara
var duration : float #in seconds, 1 round = 5s

func _init(args : Array):
	#npower : float, nduration : int
	chara = args[0]
	duration = 5*args[0]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, 's evasion is Hindered !', null,'')

func stack(args : Array) :
	duration += 5*args[0]

func unstack(args : Array) :
	duration -= 5*args[1]
	if duration <= 0 :
		chara.remove_trait(self)

func get_saved_variables() :
	return [ceil(duration/5)]

func _on_new_round(_character : Creature) :
	if duration <= 0 :
		chara.remove_trait(self)
		return
	duration -= 1


#func _on_battle_end(chara) :
	#chara.remove_trait(self)

func _on_get_stat(statname : String, stat : int) :
	if ['EvasionMelee','EvasionRanged'].has(statname) :
		return stat-ceil(duration/2)
	else :
		return stat

func _on_time_pass(_character, seconds) :
	if duration <= 0 :
		chara.remove_trait(self)
		return
	duration -= seconds
	
func get_info_as_text() -> String :
	return 'Hindered Evasion for '+str(duration)+' rounds'
