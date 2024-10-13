const name : String = 't_confused.gd'  #Name of the script file
const menuname : String = 'Confused (T)' #The name displayed in game
const stacks : bool = true #whether the status efefct is  affected by re applying it
const trait_types : Array = []
var chara  #don't initialize it,  poinsts to afflicetd  character
var duration : int
#var chara_was_controlled : int  = 0  #bool, 0= fals 1=true

func _init(args : Array): 
	#arg 0 is chara
	#argument 1   is  the duration as a  int
	# argument 2 : if-1, init chara_was_controlled to  the character, esle bool 0 1
	chara = args[0]
	duration = 5*args[1]
	#var firstapply : int = args[2]
	#if firstapply == -1 :
	#	if chara.is_player_controlled :
	#		chara_was_controlled = 1
	#else :
	#	chara_was_controlled = firstapply==1
	#chara.is_player_controlled = false


func stack(args : Array) :
	duration += 5*args[1]

func unstack(args : Array) :

	duration -= 5*args[1]
	if duration==0 :
		chara.remove_trait(self)

func get_saved_variables() :
	return [ceil(duration/5)]

func _on_get_stat(statname : String, stat : int) :
	if ['AccuracyMelee','AccuracyRanged'].has(statname) :
		return stat-10 
	else :
		return stat

func _on_remove_trait(character : Creature, traitscript) :
	if traitscript == self :
		character.curFaction = character.baseFaction


func _on_time_pass(character, s : int) :
	if duration >=0 :
		duration -= s
		if duration <= 0 :
			character.remove_trait(self)

func _on_get_player_controlled() :
	return false

func _on_get_creature_script() :
	#print(GameGlobal.cmp_resources.creascripts_book)
	chara.curFaction = [0,0,1,2].pick_random()
	var runing_script = GameGlobal.cmp_resources.creascripts_book['runningaway.gd']
	var dumb_script = GameGlobal.cmp_resources.creascripts_book['dumb_melee.gd']
	return [runing_script,dumb_script].pick_random()
	
func get_info_as_text() -> String :
	return 'Confused for '+str(ceil(duration/5))+'rounds'
