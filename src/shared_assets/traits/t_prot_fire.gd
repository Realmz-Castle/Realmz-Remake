const ConditionLog = preload(
	"res://scripts/classic_runtime/classic_condition_log.gd"
)
const name : String = 't_prot_fire.gd'
const menuname : String = 'Fire Protection (T)'
const stacks : bool = true
const trait_types : Array = []
var chara
var duration : int #in seconds, 1 round = 5s


func _init(args : Array):
	#[chara, duration]
	chara = args[0]
	duration = 5*args[1]
	ConditionLog.write(chara, " gets Fire Protection !")

func stack(args : Array) :
	duration += 5*args[0]

func unstack(args : Array) :
	duration -= 5*args[0]
	_remove_if_expired()

func get_saved_variables() :
	return [ceil(duration/5)]

func _on_new_round(_character : Creature) :
	duration -= 5
	_remove_if_expired()

func _on_get_stat(statname : String, stat : int) :
	if statname == "MultiplierFire" :
		return stat*0.5  #1  stat = 1% chance
	else :
		return stat

func _on_time_pass(_character, seconds) :
	duration -= seconds
	_remove_if_expired()

func _remove_if_expired() -> void:
	if duration <= 0:
		chara.remove_trait(self)
	
func get_info_as_text() -> String :
	return 'Fire Protection for '+str(ceil(duration/5))+' rounds'
