const name : String = 't_sp_leak.gd'
const menuname : String = 'SP Leak (T)'
const stacks : bool = true
const trait_types : Array = []
var chara
var power : int #in seconds, 1 round = 5s


func _init(args : Array):
	#[chara, power]
	chara = args[0]
	power = args[1]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' suffers SP Leak !', null,'')

func stack(args : Array) :
	power += args[0]

func unstack(args : Array) :
	power -= args[0]
	if power <= 0 :
		chara.remove_trait(self)

func get_saved_variables() :
	return [power]

func _on_new_round(_character : Creature) :
	var usedpower : int = floor(sqrt(power*2))
	if _character.used_resource=='SP' :
		chara.change_cur_sp(-usedpower)
	power -= 1
	if power <= 0 :
		chara.remove_trait(self)

func _on_time_pass(_character, seconds) :
	var s : int = seconds
	while s > 0 :
		if power <= 0 :
			chara.remove_trait(self)
			return
		if _character.used_resource=='SP' :
			chara.change_cur_sp(-power)
		power -= 1
		if power <= 0 :
			chara.remove_trait(self)
		s -= 5
	
func get_info_as_text() -> String :
	return 'SP Leak for '+str(power)+' total'
