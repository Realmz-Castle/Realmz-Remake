extends Node
class_name GameStateMachine

@export var initial_state : NodePath = NodePath()
@onready var state:State = get_node(initial_state) : set = set_state#, get = _get_state
@onready var _state_name : String = state.name

const EXPLORATION_STATE_PATH := "res://scripts/states/ExplorationState.gd"
const EX_MENU_STATE_PATH := "res://scripts/states/ExMenusState.gd"
const EX_ANIMATION_STATE_PATH := "res://scripts/states/ExAnim.gd"
const COMBAT_STATE_PATH := "res://scripts/states/CombatState.gd"
const CB_DECIDE_STATE_PATH := "res://scripts/states/CbDecideActionState.gd"
const CB_ANIMATION_STATE_PATH := "res://scripts/states/CbAnimationState.gd"
const CB_MENU_STATE_PATH := "res://scripts/states/CbMenusState.gd"

var exploration_state: Node
var combat_state: Node
var ex_menu_state: Node
var cb_menu_state: Node
var cb_decide_state: Node
var cb_anim_state: Node
#@export var cb_target_state : CbTargetingState

var time_since_last_dir_input : float = 0
#var last_dir_input : Vector2i = Vector2i.ZERO
#var last_nonnull_dir_input : Vector2i = Vector2i.ZERO

const MOVE_ACTIONS : Array[StringName] = [
	&"move_up", &"move_down", &"move_left", &"move_right",
	&"move_upleft", &"move_upright", &"move_downleft", &"move_downright",
]

func _init() -> void :
	add_to_group("state_machine")

# Edge-triggered movement: fires one move on the just-pressed edge of any
# movement action. Polling in _process still handles continuous walking when a
# real keyboard key stays held. is_action_pressed(action) excludes echo events,
# so keyboard auto-repeat doesn't double-fire here.
func _input(event : InputEvent) -> void :
	for action in MOVE_ACTIONS :
		if event.is_action_pressed(action) :
			var arr : Array = get_dir_input_from_kb()
			if arr[1] :
				send_dir_input(arr[0], true)
			return




func transition_to(target_state_path : String, msg : Dictionary = {} ) -> void :
#	print("STATEMACHINE transtioon from ",state.name," to "+target_state_path)
	if not has_node(target_state_path) and target_state_path != "Inactive":
		if not ensure_gameplay_states_loaded():
			return
	if not has_node(target_state_path) :
		push_error("GameStateMachine does not have this state path : "+target_state_path)
		return
	var target_state :=get_node(target_state_path)
	state.exit()
	self.state = target_state  #the self is important here for some reason
	#print("transition to msg :", msg)
	state.enter(msg)
#	print("STATEMACHINE transtion : state is now ", self.state)


func set_state(value : State) ->void :
	state = value
	_state_name = state.name


# Called when the node enters the scene tree for the first time.
func _ready():
#	yield(owner, "ready")
	#await owner.ready
	state.enter( )


func ensure_gameplay_states_loaded() -> bool:
	if is_instance_valid(exploration_state) and is_instance_valid(combat_state):
		return true

	exploration_state = _instantiate_state(EXPLORATION_STATE_PATH, "Exploration")
	ex_menu_state = _instantiate_state(EX_MENU_STATE_PATH, "ExMenus")
	var ex_animation_state := _instantiate_state(EX_ANIMATION_STATE_PATH, "ExAnim")
	combat_state = _instantiate_state(COMBAT_STATE_PATH, "Combat")
	cb_decide_state = _instantiate_state(CB_DECIDE_STATE_PATH, "CbDecideAction")
	cb_anim_state = _instantiate_state(CB_ANIMATION_STATE_PATH, "CbAnimation")
	cb_menu_state = _instantiate_state(CB_MENU_STATE_PATH, "CbMenus")
	for gameplay_state: Node in [
		exploration_state,
		ex_menu_state,
		ex_animation_state,
		combat_state,
		cb_decide_state,
		cb_anim_state,
		cb_menu_state,
	]:
		if gameplay_state == null:
			push_error("GameStateMachine could not create the gameplay state graph.")
			return false

	add_child(exploration_state)
	exploration_state.add_child(ex_menu_state)
	exploration_state.add_child(ex_animation_state)
	add_child(combat_state)
	combat_state.add_child(cb_decide_state)
	combat_state.add_child(cb_anim_state)
	combat_state.add_child(cb_menu_state)
	combat_state.set("cbanimstate", cb_anim_state)
	cb_decide_state.set("combat_state", combat_state)
	return true


func _instantiate_state(script_path: String, state_name: String) -> Node:
	var script := load(script_path) as GDScript
	if script == null:
		push_error("GameStateMachine could not load %s." % script_path)
		return null
	var gameplay_state := script.new() as Node
	if gameplay_state != null:
		gameplay_state.name = state_name
	return gameplay_state


func is_combat_state() :
	return ["CbDecideAction","CbAnimation", "CbMenus"].has(_state_name)

func is_exploration_state() :
	#printerr("GameStateMachine.is_combat_state() needs to be updated. ExWalking is not a valid state name anymore.")
	return ["Exploration","ExAnim","ExMenus"].has(_state_name)



func get_dir_input_from_kb()-> Array :
	var dir = Vector2.ZERO
	var key_pressed : bool = false
	if (Input.is_action_pressed("move_up")):
		dir += Vector2.UP
		key_pressed = true
	if (Input.is_action_pressed("move_down")):
		dir += Vector2.DOWN
		key_pressed = true
	if (Input.is_action_pressed("move_left")):
		dir += Vector2.LEFT
		key_pressed = true
	if (Input.is_action_pressed("move_right")):
		dir += Vector2.RIGHT
		key_pressed = true
	if (Input.is_action_pressed("move_upleft")):
		dir = Vector2.UP+Vector2.LEFT
		key_pressed = true
	if (Input.is_action_pressed("move_upright")):
		dir = Vector2.UP+Vector2.RIGHT
		key_pressed = true
	if (Input.is_action_pressed("move_downleft")):
		dir = Vector2.DOWN+Vector2.LEFT
		key_pressed = true
	if (Input.is_action_pressed("move_downright")):
		dir = Vector2.DOWN+Vector2.RIGHT
		key_pressed = true
	return [dir, key_pressed]



func get_dir_input_from_mouse(_delta, offset : Vector2)->Vector2 :
	#print("gamestate get_dir_input_from_mouse,  offset : ", offset)
	var dir = Vector2.ZERO
	var mousepos : Vector2 = GameGlobal.map.get_local_mouse_position()
#	var mouseposrelative : Vector2 = mousepos - map.charactersnode.position - map.focuscharacter.get_pixel_position() - Vector2(16,16)
	var mouseposrelative : Vector2 = mousepos - GameGlobal.map.charactersnode.position - offset - Vector2(8,8)
	
	if (abs(mouseposrelative.x) <=16 and abs(mouseposrelative.y) <=16) :
		#time_since_last_dir_input = GameGlobal.gamespeed
		#print("l102 gameèstate dir time_since_last_dir_input maxed, : ", dir)
		return dir
	else :
		var angle = mouseposrelative.angle()
		if abs(angle)<=PI/8 :
			dir = Vector2.RIGHT
		if abs(angle - PI/4 )<=PI/8 :
			dir =  Vector2.RIGHT + Vector2.DOWN
		if abs(angle - PI/2 )<=PI/8 :
			dir = Vector2.DOWN
		if abs(angle - 3*PI/4 )<=PI/8 :
			dir = Vector2.LEFT + Vector2.DOWN
		if abs(angle)>7*PI/8 :
			dir = Vector2.LEFT
		if abs(angle + PI/4 )<=PI/8 :
			dir =  Vector2.RIGHT + Vector2.UP
		if abs(angle + PI/2 )<=PI/8 :
			dir =  Vector2.UP
		if abs(angle + 3*PI/4 )<=PI/8 :
			dir =  Vector2.LEFT + Vector2.UP
		#print("l122 gameèstate dir : ", dir)
		return dir



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_since_last_dir_input += delta

	#print("game_state process :  state_name : ", state.name)
	#if StateMachine.state == StateMachine.ex_menu_state :
		#return

	if StateMachine.time_since_last_dir_input > GameGlobal.gamespeed :
		

		
		var maybe_input : Vector2i = Vector2i.ZERO
		var current_map: Map = GameGlobal.map
		if is_instance_valid(current_map) and current_map.mouseinside :
			#if Input.is_action_pressed("RightClick") :
				#send_dir_input(Vector2i.ZERO, false)
			var targoffset : Vector2 = current_map.focuscharacter.get_pixel_position()
			if is_combat_state() :
				pass
				var selecetdcharcb : CombatCreaButton = combat_state.get_selected_character_combatbutton()
				if is_instance_valid(selecetdcharcb) :
					targoffset = selecetdcharcb.position# + map.focuscharacter.position
				else :
					targoffset = current_map.focuscharacter.get_pixel_position()
			#else :
				#targoffset = GameGlobal.map.focuscharacter.get_pixel_position()
			if current_map.pressed :
				maybe_input = StateMachine.get_dir_input_from_mouse(delta, targoffset)
				#print("gamestate l150 send_dir_input ", maybe_input, " w offset ", targoffset)
				send_dir_input(maybe_input, false)
			#print("maybe_input ", maybe_input)
		if maybe_input == Vector2i.ZERO :
			var maybe_input_array : Array = StateMachine.get_dir_input_from_kb()
			if maybe_input_array[1] :
				send_dir_input(maybe_input_array[0], true)
	#print("gamestate state_process")
	state._state_process(delta)

func send_dir_input(input : Vector2, is_keyboard : bool) :
	StateMachine.time_since_last_dir_input = 0
	if ["Exploration","CbDecideAction","Combat/CbTargeting"].has(_state_name) :
		if is_combat_state() :
			if not is_instance_valid(cb_decide_state.current_active_creabutton) :
				print("ERROR in GameStateMachine.send_dir_input, cb_decide_state.current_active_creabutton NOT VALID")
				return
			if not cb_decide_state.current_active_creabutton.creature.is_crea_player_controlled() :
				return
		state._on_dir_input_received(input,is_keyboard )

func set_arrow_mouse_cursor(_delta : float) :
	# When a full-screen overlay panel (bestiary/char-stats, inventory, etc.) is
	# up, the directional arrow cursor isn't meaningful — we're not navigating
	# the map. Use the default sword cursor over the panel instead.
	if _is_overlay_panel_visible() :
		Input.set_custom_mouse_cursor(UI.cursor_sword)
		return
	var mousepos : Vector2 = UI.ow_hud.get_local_mouse_position()
	var wsize : Vector2 = ScreenUtils.get_logical_window_size(self)
	if mousepos.x+320<wsize.x and mousepos.y+200<wsize.y :
		var targoffset : Vector2 = GameGlobal.map.focuscharacter.get_pixel_position()
		#print("gamestate set_cursor get_dir_input_from_mouse, offset : ", targoffset)
		var cursordir = StateMachine.get_dir_input_from_mouse(_delta, targoffset)
		Input.set_custom_mouse_cursor(UI.cursor_map_dict[cursordir])
	else :
		Input.set_custom_mouse_cursor((UI.cursor_sword))


func _is_overlay_panel_visible() -> bool :
	var hud = UI.ow_hud
	if hud == null :
		return false
	for n in [hud.bestiaryRect, hud.characterStatRect, hud.inventoryRect, hud.minimapRect, hud.abilitesmngtMenu] :
		if n != null and n.visible :
			return true
	return false

#
#func on_trying_to_move_to_tile_stack(crea : Creature, stack : Array, position : Vector2) : #exporation mode
	#var canwalk : bool = true
	#var soundplayed : bool = false
##	stack["light"] = true
##	for tile in stack["items"] :
##		##TODO  run script checked  trytowalk with tile
##		if tiles_book[tile]['wall'] != '0' :
##			canwalk = false
	#var stacksize = stack.size()
##	print("gamestate trying to move : stack : ", stack)
	#var timetowalk : int = 0
	#for i  in range(stack.size()) :
##		print(stack["items"][stacksize-i-1])
		#var idef = stack[stacksize-i-1]
##		print (idef)
		#timetowalk += idef["time"]
		#if !is_combat_state() and ((not GameGlobal.is_sailing_boat) and idef['water'] != 0) :
			#if not GameGlobal.map.mapboats.has(Vector2i(position)) :
				#canwalk = false
				#timetowalk -= idef["time"]
				#timetowalk += 5
		#if GameGlobal.is_sailing_boat :
			#if idef['water'] == 0 and idef['dock'] == 0 :
				#canwalk = false
		#if is_instance_valid(crea) :
			#print("gamastate on trying to move : "+crea.name, crea.size, not ( idef['wall'] != 0 or (idef['swall'] != 0 and crea.size==Vector2.ONE) )   )
			#canwalk = not ( idef['wall'] != 0 or (idef['swall'] != 0 and crea.size==Vector2.ONE) )
		#else :
			#canwalk = not ( idef['wall'] != 0 or idef['swall'] != 0 )
		#if not soundplayed and idef['sound'] != [] :
			#soundplayed = true
			#var soundslist : Array = idef['sound']
##			print("GameState soundlist : ",soundslist)
			#soundslist.shuffle()
			#
			#SfxPlayer.stream = GameGlobal.cmp_resources.sounds_book[soundslist[0]]
##			print("GameState sbok has sound "+soundslist[0]+"? ", sounds_book.has(soundslist[0]))
			#SfxPlayer.play()
			#
	## check for scripts checked the map :
	#var canwalk_path : bool = GameGlobal.map.mapsecretpaths.has(Vector2i(position))
	#var canwalk_secret : bool = false
	#if GameGlobal.map.mapsecrets.has(Vector2i(position)) :
		#if GameGlobal.map.mapsecrets[Vector2i(position)][0]== 1 :
			#canwalk_secret  = true
	#
	#canwalk = (canwalk or canwalk_path or canwalk_secret) 
	#if canwalk :
		#
		#if canwalk_path :
			#GameGlobal.map.set_secretpath_seen( Vector2i(position) )
		#if canwalk_secret :
			#GameGlobal.map.set_secret_seen( Vector2i(position) )
#
	#if is_combat_state() :
		#timetowalk =  crea.get_mp_cost_for_tile_stack(stack)
	#
	#return [canwalk, timetowalk ]

			

func check_map_script(position, context := {}) ->bool :
	var canwalk = true
#	print("GameState check_map_scripts : ")
	GameGlobal.apply_classic_search_time_cost()
	if await GameGlobal.check_classic_random_rectangles(
		Vector2i(position),
		context
	):
		return false
	
	var scriptstocall : Dictionary = {}
	
	for s in GameGlobal.map.mapscriptareas :
#		print(map.mapscriptareas[s])
		var sr = GameGlobal.map.mapscriptareas[s]
		if (
			GameGlobal.is_classic_runtime_active()
			and not GameGlobal.ClassicRandomRectangleScript.identity(
				str(s),
				sr
			).is_empty()
		):
			continue
		var l = sr["scriptRectangle"][0][0]
		var u = sr["scriptRectangle"][0][1]
		var r = sr["scriptRectangle"][1][0]
		var d = sr["scriptRectangle"][1][1]
		



		if l<=position.x and position.x<=r :
			if u<=position.y and position.y<=d :
				var scriptname : String = ''
				
				
				var chance : float = 1.0
				if sr.has("chance") :
					chance = sr["chance"]
				printerr("StateMachine chance", ' ', chance, ' ', sr["scriptToLoad"])
				pass
				if randf() > chance :	#skip this
					continue
				

				if sr.has("RR_Battle") and GameGlobal.random_battles_allowed():
					printerr("StateMachine sr has RR_Battle")
					var do_rr_fight : bool = false
					var num_of_poss_outcomes : int = 1
					if sr["scriptToLoad"] is Array :
						num_of_poss_outcomes += floor(sr["scriptToLoad"].size()/2)
					else : 
						num_of_poss_outcomes +=1
					do_rr_fight = randi()%num_of_poss_outcomes==0
					if do_rr_fight :
						var _battle_result = await ScriptHelperFuncsClass.do_RR_battle(sr["RR_Battle"])
						if state==ex_menu_state :
							print("StateMachine escape out of MenuState")
							exit_ex_menu_state()
							exit_cb_menu_state()
						return false


				
				if sr["scriptToLoad"] is Array :
					printerr('STateMachine sr["scriptToLoad"] is array , ', range(0,sr["scriptToLoad"].size(),2))
					for i in range(0,sr["scriptToLoad"].size(),2) :
						if randf() <= sr["scriptToLoad"][i+1]/100 :
							scriptname = sr["scriptToLoad"][i]
							break
				else : scriptname = sr["scriptToLoad"]
				

				
				
				if not scriptname.is_empty() : scriptstocall[scriptname] = '' #just a set, value doesnt matter
	
	printerr("SStateMachine l282 scriptstocall : ", scriptstocall)
	# Scenario maps keep Classic secret state in their preserved tile fields.
	var classic_secret_result := GameGlobal.discover_classic_map_secrets(Vector2i(position))
	if str(classic_secret_result.get("status", "")) == "error":
		push_error(str(classic_secret_result.get(
			"message",
			"Classic secret discovery failed"
		)))
	if not bool(classic_secret_result.get("handled", false)):
		for x in [-1,0,1] :
			for y in [-1,0,1] :
				var vpos : Vector2i = Vector2i(int(position.x+x),int(position.y+y))
				if GameGlobal.map.mapsecrets.has( vpos ) :
					var randomfloat : float = randf()
					var detected := GameGlobal.map_secret_detection_succeeds(vpos, randomfloat)
					if not detected:
						continue

					if GameGlobal.map.mapsecrets[vpos][0]==0 :
						print("StateMachine check_map_script : map.mapsecrets[vpos] ",GameGlobal.map.mapsecrets[vpos])
						scriptstocall[GameGlobal.map.mapsecrets[vpos][1]] = ''
						GameGlobal.map.set_secret_seen(vpos)

	for s in scriptstocall:
		#find the script
		#print (" map.mapscriptareas : ",GameGlobal.map.mapscriptareas)
		var mapscriptareas_still_has_s : bool = false
		for sa in GameGlobal.map.mapscriptareas:
			var mapstlentry = GameGlobal.map.mapscriptareas[sa]["scriptToLoad"]
			if mapstlentry is Array:
				if mapstlentry.has(s):
					mapscriptareas_still_has_s = true
					break
			else:
				if mapstlentry == s:
					mapscriptareas_still_has_s = true
					break
		
		for secretpos in GameGlobal.map.mapsecrets.keys():
			if GameGlobal.map.mapsecrets[secretpos][1] == s:
				mapscriptareas_still_has_s = true
				break
		
		if mapscriptareas_still_has_s:
			GameGlobal.current_map_script_name = s
			var classic_context: Dictionary = context.duplicate(true) \
				if context is Dictionary else {}
			classic_context["mapPosition"] = Vector2i(position)
			var classic_dispatch: Dictionary = await GameGlobal.dispatch_classic_map_script(
				s,
				classic_context
			)
			if bool(classic_dispatch.get("handled", false)):
				var classic_result: Variant = classic_dispatch.get("result", {})
				if (
					classic_result is Dictionary
					and str(classic_result.get("status", "")) not in ["completed", ""]
				):
					printerr(
						"Classic map action point stopped: ",
						classic_result.get("message", classic_result)
					)
				GameGlobal.current_map_script_name = ''
				continue
			push_error(
				"Scenario map trigger '%s' is not registered with the scenario VM" % s
			)
			GameGlobal.current_map_script_name = ''
		else:
			print("StateMachine : mapscript doesnt have script "+s+", ok if it's because of a map change")
	#print("StateMachine DONE await GameGlobal.map.mapscripts.call_deferred (s)")
	GameGlobal.map.queue_redraw()
	GameGlobal.refresh_OW_HUD()
	#print("STateMachine finished check_map_script")
	if state==ex_menu_state :
		print("StateMachine escape out of MenuState")
		exit_ex_menu_state()
		exit_cb_menu_state()

	return canwalk
	



func run_complex_encounter_branch(branch: Dictionary) -> void:
	await ScriptHelperFuncsClass.start_complex_encounter(str(branch["encounter"]))


func enter_ex_menu_state(msg_dict : Dictionary) :
	#if _state_name!="ExMenus" :
		msg_dict["prev_state"] = _state_name
		transition_to("Exploration/ExMenus", msg_dict)

func enter_cb_menu_state(msg_dict : Dictionary) :
	msg_dict["prev_state"] = _state_name
	transition_to("Combat/CbMenus", msg_dict)

func exit_ex_menu_state( _extra_msg : Dictionary = {}) :
	if _state_name=="ExMenus" :
		print("StateMachine exit_menu_state to "+ex_menu_state.prev_state_path)
		transition_to(ex_menu_state.prev_state_path, _extra_msg)

func exit_cb_menu_state( _extra_msg : Dictionary = {}) :
	print("game_state exit_cb_menu_tate : cur state is "+_state_name+", prev was "+cb_menu_state.prev_state_path)
	if _state_name=="CbMenus" :
		print("StateMachine exit_menu_state to "+cb_menu_state.prev_state_path)
		transition_to(cb_menu_state.prev_state_path, _extra_msg)
