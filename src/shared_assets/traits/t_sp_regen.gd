const name : String = 't_sp_regen.gd'
const menuname : String = 'SP Regeneration (T)'
const stacks : bool = true
const trait_types : Array = []
var chara
var power : int #in seconds, 1 round = 5s


func _init(args : Array):
	#[chara, duration, permanent]
	chara = args[0]
	power = args[1]
	UI.ow_hud.creatureRect.logrect.log_other_text(chara, ' gets SP Regeneration !', null,'')

func stack(args : Array) :
	power += args[1]

func unstack(args : Array) :
	power -= args[1]
	if power <= 0 :
		chara.remove_trait(self)

func get_saved_variables() :
	return [power]

func _on_new_round(_character : Creature) :
	var usedpower : int = floor(sqrt(power*2))
	if _character.used_resource=='SP' :
		chara.change_cur_sp(-usedpower)
	power -= usedpower
	if power <= 0 :
		chara.remove_trait(self)


func _on_time_pass(_character, seconds) :
	if power <= 0 :
		chara.remove_trait(self)
		return
	var usedpower : int = ceil( sqrt(power*2) * max(5,seconds/5) )
	if _character.used_resource=='SP' :
		chara.change_cur_sp(-usedpower)
	power -= usedpower
	if power <= 0 :
		chara.remove_trait(self)
	
func get_info_as_text() -> String :
	var usedpower : int = ceil(sqrt(power*2))
	return 'Regenerating SP '+str(power)+' total'

