const name : String = 't_charmed.gd'  #Name of the script file
const menuname : String = 'Charmed (T)' #The name displayed in game
const stacks : bool = true #whether the status efefct is  affected by re applying it
const trait_types : Array = []
var chara  #don't initialize it,  poinsts to afflicetd  character
var duration : int
var charmer_crea : Creature
#var chara_was_controlled : int  = 0  #bool, 0= fals 1=true

func _init(args : Array): 
	#arg 0 is chara
	#argument 1   is  the duration as a  int
	# argument 2 : if-1, init chara_was_controlled to  the character, esle bool 0 1
	chara = args[0]
	duration = 5*args[1]
	var actiondata : Dictionary = StateMachine.cb_anim_state.cur_action
	match actiondata["type"] :
		"MeleeAttack" :
			charmer_crea = actiondata["attacker"].creature
			chara.curFaction = charmer_crea.curFaction
		"Spell" :
			charmer_crea = actiondata["caster"].creature
			chara.curFaction = charmer_crea.curFaction
		_: 
			chara.curFaction = 2
	
	#var firstapply : int = args[2]
	#if firstapply == -1 :
	#	if chara.is_player_controlled :
	#		chara_was_controlled = 1
	#else :
	#	chara_was_controlled = firstapply==1
	#chara.is_player_controlled = false


func stack(args : Array) :
	duration += 5*args[0]

func unstack(args : Array) :

	duration -= 5*args[0]
	if duration==0 :
		chara.remove_trait(self)

func get_saved_variables() :
	return [ceil(duration/5)]


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
	return GameGlobal.cmp_resources.creascripts_book['test_crea_script.gd']
	
func get_info_as_text() -> String :
	if is_instance_valid(charmer_crea) :
		return 'Charmed for '+str(ceil(duration/5))+'rounds by '+ charmer_crea.name
	return 'Charmed for '+str(ceil(duration/5))+'rounds'
