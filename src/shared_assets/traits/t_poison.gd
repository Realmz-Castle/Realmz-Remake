const name : String = 't_poison.gd'
const menuname : String = 'Poison'
const stacks : bool = true
const trait_types : Array = ['Poison']
const ClassicAnimationScript = preload(
	"res://scripts/classic_runtime/classic_animation.gd"
)
var chara
var power : int #in seconds, 1 round = 5s


func _init(args : Array):
	#[chara, duration]
	chara = args[0]
	power = args[1]
	_log_condition(' is Poisoned !')


func _log_condition(message: String) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var ui: Node = tree.root.get_node_or_null("UI") if tree != null else null
	if ui != null and ui.get("ow_hud") != null:
		ui.get("ow_hud").creatureRect.logrect.log_other_text(chara, message, null, '')

func stack(args : Array) :
	power += args[0]

func unstack(args : Array) :
	power -= args[0]
	if power <= 0 :
		chara.remove_trait(self)

func get_saved_variables() :
	return [power]

func _on_new_round(_character) :
	if not ClassicAnimationScript.is_permanently_animated(chara) :
		chara.change_cur_hp(-power)
	power -= 1
	if power <= 0 :
		chara.remove_trait(self)


func _on_time_pass(_character, seconds) :
	var s : int = seconds
	while s > 0 :
		if power <= 0 :
			chara.remove_trait(self)
			return
		if not ClassicAnimationScript.is_permanently_animated(chara) :
			chara.change_cur_hp(-power)
		power -= 1
		if power <= 0 :
			chara.remove_trait(self)
		s -= 5
	
func get_info_as_text() -> String :
	var usedpower : int = ceil(sqrt(power*2))
	return 'Poisoned for '+str(power)+'rounds'
