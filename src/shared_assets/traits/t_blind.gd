const name : String = 't_blind.gd'
const menuname : String = 'Blind (T)'
const stacks : bool = true

const trait_types : Array = []
var chara
var duration : int #in seconds, 1 round = 5s

func _init(args : Array):
	#[chara, duration]
	chara = args[0]
	duration = 5*args[1]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' is Blinded !', null,'')

func stack(args : Array) :
	duration += 5*args[1]



func unstack(args : Array) :
	duration -= 5*args[1]
	if duration <= 0 :
		chara.remove_trait(self)

func get_saved_variables() :
	return [ceil(duration/5)]

func _on_new_round(_character : Creature) :
	if duration <= 0 :
		chara.remove_trait(self)

func _on_get_stat(statname : String, stat : int) :
	if ['AccuracyMelee','AccuracyRanged', 'AccuracyMagic'].has(statname) :
		return stat-15  #1  stat = 1% chance
	else :
		return stat

func _on_time_pass(_character, seconds) :
	if duration <= 0 :
		chara.remove_trait(self)
		return
	duration -= seconds
	
func get_info_as_text() -> String :
	return 'Blind for '+str(ceil(duration/5))+' rounds'
