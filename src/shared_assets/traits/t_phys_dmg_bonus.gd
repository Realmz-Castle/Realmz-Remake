const name : String = 't_phys_dmg_bonus.gd'
const menuname : String = 'Physical Damage Bonus (T)'
const stacks = true  #one instance per applied effect, removed instance chosen if equals_args
var chara
var power : float = 0
const trait_types : Array = []

func _init(args : Array):
	#npower : float
	chara = args[0]
	power = args[1]

func get_saved_variables() :
	return [power]

func _on_get_stat(statname : String, stat : int) :
	if statname == "Bonus_Physical_dmg" :
		var usedpower : int = ceil( sqrt(power*2) )
		return usedpower  #1  stat = 1% chance
	else :
		return stat

func stack(args : Array) :
	power += args[1]

func unstack(args : Array) :
	power -= args[1]
	if power <= 0 :
		chara.remove_trait(self)

func _on_new_round(_character : Creature) :
	var usedpower : int = floor(sqrt(power*2))
	power -= usedpower
	if power <= 0 :
		chara.remove_trait(self)

func _on_time_pass(_character, seconds) :
	if power <= 0 :
		chara.remove_trait(self)
		return
	var usedpower : int = ceil( sqrt(power*2) * max(5,seconds/5) )
	power -= usedpower
	if power <= 0 :
		chara.remove_trait(self)


func equals_args(args : Array) ->bool :
	return  (power == args[1])

func get_info_as_text() -> String :
	var usedpower : int = floor(sqrt(power*2))
	return 'Temporary Phys. Dmg. Bonus + '+str(usedpower)
