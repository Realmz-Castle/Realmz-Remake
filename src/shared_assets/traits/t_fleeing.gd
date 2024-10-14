const name : String = 't_fleeing.gd'  #Name of the script file
const menuname : String = 'Fleeing (T)' #The name displayed in game
const stacks : bool = true #whether the status efefct is  affected by re applying it
const trait_types : Array = []
var chara  #don't initialize it,  poinsts to afflicetd  character
var duration : int

func _init(args : Array): 
	#arg 0 is chara
	#argument 1   is  the duration as a  int
	chara = args[0]
	duration = 5*args[1]

	chara.is_player_controlled = false

func stack(args : Array) :
	duration += 5*args[0]

func unstack(args : Array) :
	duration -= 5*args[0]
	if duration==0 :
		chara.remove_trait(self)

func get_saved_variables() :
	return [ceil(duration/5)]

func _on_get_stat(statname : String, stat : int) :
	if ['AccuracyMelee','AccuracyRanged'].has(statname) :
		return stat-25  
	else :
		return stat

func _on_battle_end(chara) :
	chara.remove_trait(self)

func _on_time_pass(character, s : int) :
	if duration >=0 :
		duration -= s
		if duration <= 0 :
			character.remove_trait(self)

func _on_get_player_controlled() :
	return false

func _on_get_creature_script() :
	return GameGlobal.cmp_resources.creascripts_book['runningaway.gd']
	
func get_info_as_text() -> String :
	return 'Fleeing for '+str(ceil(duration/5))+'rounds'
