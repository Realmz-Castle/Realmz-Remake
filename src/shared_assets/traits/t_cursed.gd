const name : String = 't_cursed.gd'
const menuname : String = 'Cursed (T)'
const stacks : bool = true
const trait_types : Array = []
var chara
var duration : int #in seconds, 1 round = 5s

func _init(args : Array):
	#[chara, duration]
	chara = args[0]
	duration = 5*args[1]
	log_status(chara, ' gets Cursed !')

func stack(args : Array) :
	duration += 5*args[0]

func unstack(args : Array) :
	duration -= 5*args[0]
	if duration <= 0 :
		chara.remove_trait(self)

func get_saved_variables() :
	return [ceil(duration/5)]

func _on_new_round(_character : Creature) :
	duration -= 5
	if duration <= 0 :
		chara.remove_trait(self)
		return
	

func _on_get_stat(statname : String, stat : int) :
	if ['EvasionMelee','EvasionRanged','AccuracyMelee','AccuracyRanged'].has(statname) :
		return stat-1  # 1 native point = Classic's 5 percentage points.
	else :
		return stat

static func log_status(character, message: String) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	var ui: Node = tree.root.get_node_or_null("UI")
	if ui == null:
		return
	var hud: Variant = ui.get("ow_hud")
	var creature_rect: Variant = hud.get("creatureRect") if hud is Object else null
	var log_rect: Variant = creature_rect.get("logrect") \
		if creature_rect is Object else null
	if log_rect is Object and log_rect.has_method("log_other_text"):
		log_rect.call("log_other_text", character, message, null, '')

func _on_time_pass(_character, seconds) :
	duration -= seconds
	if duration <= 0 :
		chara.remove_trait(self)
		return

func get_info_as_text() -> String :
	return 'Cursed for '+str(ceil(duration/5))+' rounds'
