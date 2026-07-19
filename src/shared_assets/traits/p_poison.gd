const name : String = 'p_poison.gd'
const menuname : String = 'Poison (P)'
const stacks : bool = false
const trait_types : Array = ['Poison']
var chara
var power : int 
var trait_source : String = ''

func _init(args : Array):
	#[chara, duration]
	chara = args[0]
	power = args[1]
	_log_condition(' is Permanently Poisoned !')


func _log_condition(message: String) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var ui: Node = tree.root.get_node_or_null("UI") if tree != null else null
	if ui != null and ui.get("ow_hud") != null:
		ui.get("ow_hud").creatureRect.logrect.log_other_text(chara, message, null, '')




func get_saved_variables() :
	return [power]

func _on_new_round(_character) :
	chara.change_cur_hp(-power)
	if power <= 0 :
		chara.remove_trait(self)


func _on_time_pass(_character, seconds) :
	var s : int = seconds
	while s > 0 :
		if power <= 0 :
			chara.remove_trait(self)
			return
		chara.change_cur_hp(-power)
		if power <= 0 :
			chara.remove_trait(self)
		s -= 5
	
func get_info_as_text() -> String :
	return 'Permanently Poisoned for '+str(power)+' per 5s'

