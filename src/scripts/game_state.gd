extends Node
class_name GameStateMachine

@export var initial_state : NodePath = NodePath()
@onready var state:State = get_node(initial_state) : set = set_state#, get = _get_state
@onready var _state_name : String = state.name

@onready var resource_node : Node = NodeAccess.__Resources()

@export var exploration_state : ExplorationState
@export var combat_state : CombatState
@export var ex_menu_state : ExMenusState
@export var cb_menu_state : CbMenusState
@export var cb_decide_state : CbDecideState
@export var cb_anim_state : CbAnimationState
#@export var cb_target_state : CbTargetingState

var time_since_last_dir_input : float = 0
#var last_dir_input : Vector2i = Vector2i.ZERO
#var last_nonnull_dir_input : Vector2i = Vector2i.ZERO

func _init() -> void :
	add_to_group("state_machine")

#func _unhandled_input(event : InputEvent) -> void :
#	state.unhandled_input(event)




func transition_to(target_state_path : String, msg : Dictionary = {} ) -> void :
#	print("STATEMACHINE transtioon from ",state.name," to "+target_state_path)
	if not has_node(target_state_path) :
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


func is_combat_state() :
	return ["CbDecideAction","CbAnimation", "CbMenus"].has(_state_name)

func is_exploration_state() :
	return ["ExWalking","ExMenus"].has(_state_name)



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



func get_dir_input_from_mouse(delta, offset : Vector2)->Vector2 :
	var dir = Vector2.ZERO
	var mousepos : Vector2 = GameGlobal.map.get_local_mouse_position()
#	var mouseposrelative : Vector2 = mousepos - map.charactersnode.position - map.focuscharacter.get_pixel_position() - Vector2(16,16)
	var mouseposrelative : Vector2 = mousepos - GameGlobal.map.charactersnode.position - offset - Vector2(16,16)
	
	if (abs(mouseposrelative.x) <=16 and abs(mouseposrelative.y) <=16) :
		time_since_last_dir_input = GameGlobal.gamespeed
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
		return dir



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_since_last_dir_input += delta

	

	if StateMachine.time_since_last_dir_input > GameGlobal.gamespeed :
		var maybe_input : Vector2i = Vector2i.ZERO
		if GameGlobal.map.mouseinside :
			#if Input.is_action_pressed("RightClick") :
				#send_dir_input(Vector2i.ZERO, false)
			var targoffset : Vector2 = GameGlobal.map.focuscharacter.get_pixel_position() 
			if is_combat_state() :
				pass
				var selecetdcharcb : CombatCreaButton = combat_state.get_selected_character_combatbutton()
				if is_instance_valid(selecetdcharcb) :
					targoffset = selecetdcharcb.position# + map.focuscharacter.position
				else :
					targoffset = GameGlobal.map.focuscharacter.get_pixel_position() 
			#else :
				#targoffset = GameGlobal.map.focuscharacter.get_pixel_position()
			if GameGlobal.map.pressed :
				maybe_input = StateMachine.get_dir_input_from_mouse(delta, targoffset)
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
			if not cb_decide_state.current_active_creabutton.creature.is_crea_player_controlled() :
				return
		state._on_dir_input_received(input,is_keyboard )



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

			

func check_map_script(position) ->bool :
	var canwalk = true
#	print("GameState check_map_scripts : ")
	
	var scriptstocall : Dictionary = {}
	
	for s in GameGlobal.map.mapscriptareas :
#		print(map.mapscriptareas[s])
		var sr = GameGlobal.map.mapscriptareas[s]
		var l = sr["scriptRectangle"][0][0]
		var u = sr["scriptRectangle"][0][1]
		var r = sr["scriptRectangle"][1][0]
		var d = sr["scriptRectangle"][1][1]
		if l<=position.x and position.x<=r :
			if u<=position.y and position.y<=d :
				print("StateMachine check_map_script Script rectangle : ", s , ", script : ", sr["scriptToLoad"])
				scriptstocall[sr["scriptToLoad"]] = ''
	#check map secrets :
	for x in [-1,0,1] :
		for y in [-1,0,1] :
			var vpos : Vector2i = Vector2i(int(position.x+x),int(position.y+y))
			if GameGlobal.map.mapsecrets.has( vpos ) :
				var  randomfloat : float = randf()
				var randomfail : bool = GameGlobal.map.get_secret_fail_chance(vpos) < randomfloat
				print("StateMachine randomfail : ", randomfail,' ',GameGlobal.map.get_secret_fail_chance(vpos), '<',randomfloat)
				if randomfail : #(x==!0 or y!=0) and 
					continue
			
				if GameGlobal.map.mapsecrets[vpos][0]==0 :
					print("StateMachine check_map_script : map.mapsecrets[vpos] ",GameGlobal.map.mapsecrets[vpos])
					scriptstocall[GameGlobal.map.mapsecrets[vpos][1]] = ''
					GameGlobal.map.set_secret_seen(vpos)

	for s in scriptstocall :
		#find the script
#				print (" map.mapscriptareas : ",map.mapscriptareas)
		var mapscriptareas_still_has_s : bool = false
		for sa in GameGlobal.map.mapscriptareas :
#					print(sa)
			if GameGlobal.map.mapscriptareas[sa]["scriptToLoad"] == s:
				mapscriptareas_still_has_s = true
				break
		for secretpos in GameGlobal.map.mapsecrets.keys() :
			if GameGlobal.map.mapsecrets[secretpos][1]==s :
				mapscriptareas_still_has_s = true
				break
		
		if mapscriptareas_still_has_s :#map.mapscripts.has_method(s) :
			await GameGlobal.map.mapscripts.call (s)
			print("StateMashine DONE await GameGlobal.map.mapscripts.call_deferred (s)")
			GameGlobal.map.queue_redraw()
			GameGlobal.refresh_OW_HUD()
		else :
			print("StateMachine : mapscript doesnt have script "+s+", ok if it's mecause of a map change")

	print("STateMachine finished check_map_script")
	if state==ex_menu_state :
		print("StateMachine escape out of MenuState")
		exit_ex_menu_state()
		exit_cb_menu_state()

	return canwalk
	



func enter_ex_menu_state(msg_dict : Dictionary) :
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
