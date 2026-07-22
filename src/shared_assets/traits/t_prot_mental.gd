const name : String = 't_prot_mental.gd'
const menuname : String = 'Mental Protection (T)'
const stacks : bool = true
const trait_types : Array = []
var chara
var duration : int #in seconds, 1 round = 5s


func _init(args : Array):
	#[chara, duration]
	chara = args[0]
	duration = 5*args[1]
	_log_condition(' gets Mental Protection !')

func _log_condition(message: String) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var ui: Node = tree.root.get_node_or_null("UI") if tree != null else null
	if ui != null and ui.get("ow_hud") != null:
		ui.get("ow_hud").creatureRect.logrect.log_other_text(chara, message, null, '')

func stack(args : Array) :
	duration += 5*args[0]

func unstack(args : Array) :
	duration -= 5*args[0]
	_remove_if_expired()

func get_saved_variables() :
	return [ceil(duration/5)]

func _on_new_round(_character) :
	duration -= 5
	_remove_if_expired()

func _on_get_stat(statname : String, stat : int) :
	if statname == "MultiplierMental" :
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
	return 'Mental Protection for '+str(ceil(duration/5))+' rounds'
