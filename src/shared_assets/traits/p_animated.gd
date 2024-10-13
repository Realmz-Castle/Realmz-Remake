const name : String = 'p_animated.gd'  #Name of the script file
const menuname : String = 'Animated (P)' #The name displayed in game
const stacks : bool = false #whether the status efefct is  affected by re applying it
const trait_types : Array = ['no_exp']
var chara
const permanent : int = 1
var trait_source : String = ''


func _init(args : Array): 
	#arg 0 is chara
	#args1  if-1, init chara_was_controlled to  the character, esle bool 0 1
	chara = args[0]
	if chara.get_stat('curHP') <= 0 :
		chara.change_cur_hp(-chara.get_stat('curHP')+1)
		chara.life_status = 0

func _on_chara_dead(character : Creature) :
	character.remove_trait(self)

func get_saved_variables() :
	return []

func _on_get_stat(statname : String, stat : int) :
	if statname == 'MultiplierHealing' :
		return -signi(stat)*signi(stat)
	else :
		return stat

func _on_get_player_controlled() :
	return false

#func _on_battle_end(chara) :
	#chara.remove_trait(self)


func _on_get_creature_script() :
	#print(GameGlobal.cmp_resources.creascripts_book)
	return GameGlobal.cmp_resources.creascripts_book['dumb_melee.gd']
	
func get_info_as_text() -> String :
	return 'Permanently Animated'+' (source : '+trait_source+')'

func equals_args(traits_array : Array) :
	return true
