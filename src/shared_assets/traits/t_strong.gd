const name : String = 't_strong.gd'
const menuname : String = 'Strong (T)'
const stacks : bool = true
const trait_types : Array = []
var chara
var duration : int #in seconds, 1 round = 5s

func _init(args : Array):
	#[chara, duration]
	chara = args[0]
	duration = 5*args[1]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' becomes Strong !', null,'')


func get_saved_variables() :
	return [ceil(duration/5)]

func _on_new_round(_character : Creature) :
	if duration <= 0 :
		chara.remove_trait(self)
		return
	duration -= 5



func stack(args : Array) :
	duration += 5*args[1]

func unstack(args : Array) :
	duration -= 5*args[1]
	if duration <= 0 :
		chara.remove_trait(self)

func _on_get_stat(statname : String, stat : int) :
	if statname == 'Bonus_Physical_dmg' :
		return stat+3  #1  stat = 1% chance
	if statname == 'AccuracyMelee' :
		return stat+15
	else :
		return stat

func _on_time_pass(_character, seconds) :
	if duration <= 0 :
		chara.remove_trait(self)
		return
	duration -= seconds
	
func get_info_as_text() -> String :
	return 'Strong for '+str(ceil(duration/5))+' rounds'

