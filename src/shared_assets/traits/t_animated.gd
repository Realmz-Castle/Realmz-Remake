const name : String = 't_animated.gd'  #Name of the script file
const menuname : String = 'Animated (T)' #The name displayed in game
const stacks : bool = true #whether the status efefct is  affected by re applying it
const trait_types : Array = ['no_exp']
var chara  #don't initialize it,  poinsts to afflicetd  character
var duration : int

func _init(args : Array): 
	#arg 0 is chara
	#argument 1   is  the duration as a  int
	chara = args[0]
	if chara.get_stat('curHP') <= 0 :
		chara.change_cur_hp(-chara.get_stat('curHP')+1)
		chara.life_status = 0
	duration = 5*args[1]

	chara.is_player_controlled = false

func _on_chara_dead(character : Creature) :
	character.remove_trait(self)

func stack(args : Array) :
	duration += 5*args[1]

func unstack(args : Array) :
	duration -= 5*args[1]
	if duration==0 :
		chara.remove_trait(self)

func get_saved_variables() :
	return [ceil(duration/5)]

func _on_get_stat(statname : String, stat : int) :
	if statname == 'MultiplierHealing' :
		return -signi(stat)*signi(stat)
	else :
		return stat

func _on_battle_end(chara) :
	chara.remove_trait(self)

func _on_get_player_controlled() :
	return false

func _on_time_pass(character, s : int) :
	if duration >=0 :
		duration -= s
		if duration <= 0 :
			character.remove_trait(self)

func _on_get_creature_script() :
	return GameGlobal.cmp_resources.creascripts_book['dumb_melee.gd']
	
func get_info_as_text() -> String :
	return 'Animated for '+str(ceil(duration/5))+'rounds'
	
