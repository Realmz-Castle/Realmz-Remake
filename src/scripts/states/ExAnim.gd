extends "res://scripts/State.gd"

var warned_empty_pool : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _state_process(_delta : float) :
	pass

func exit() :
	pass

func enter(_msg : Dictionary = {}) -> void:
	
	GameGlobal.allow_character_swap(GameGlobal.allow_character_swap_anywhere)
	GameGlobal.currentSpecialEncounterName = "default.gd"
	
	var is_pool_empty = GameGlobal.money_pool[0]+GameGlobal.money_pool[1]+GameGlobal.money_pool[2] ==0
	if !is_pool_empty and !warned_empty_pool :
		SfxPlayer.stream = GameGlobal.cmp_resources.sounds_book["Death.wav"]
		SfxPlayer.play()
		StateMachine.time_since_last_dir_input += 4
		warned_empty_pool = true
	else :
		GameGlobal.money_pool = [0,0,0]
		warned_empty_pool = false

	GameGlobal.currentShop = ''
	GameGlobal.allow_money_change(false)
	GameGlobal.allow_banking(false)
	GameGlobal.allow_honest_storage(false)

	
	
	var walk_inputs : Array = []
	if _msg.has("walk_inputs") :
		walk_inputs += _msg["walk_inputs"]
	while not walk_inputs.is_empty() :
		var input = walk_inputs.pop_front()
		if GameGlobal.camping and input != Vector2i.ZERO :
			UI.ow_hud._on_CampButton_pressed()
		if GameGlobal.fatigue >= GameGlobal.max_fatigue and input != Vector2i.ZERO :
			SfxPlayer.stream = GameGlobal.cmp_resources.sounds_book["effort 1.wav"]
			SfxPlayer.play()
		#input = Vector2i.ZERO
	
		var mapfocuschar = GameGlobal.map.focuscharacter
		var playerposx : int = mapfocuschar.tile_position_x
		var playerposy : int = mapfocuschar.tile_position_y
		var tilestack : Array = GameGlobal.map.mapdata[playerposx+input.x][playerposy+input.y]
#		print(tilestack)
		var attemptedpos : Vector2 = Vector2(playerposx+input.x, playerposy+input.y)
		var canmoveandtime : Array = await StateMachine.exploration_state.on_trying_to_move_to_tile_stack(null,tilestack, attemptedpos )
	
		if canmoveandtime[0] :
		#print("YESS")
			if GameGlobal.is_sailing_boat :  #check if moving to a dock :
				var _is_shore : bool = false
				var stacksize = tilestack.size()
				for i  in range(stacksize) :
					var idef = tilestack[stacksize-i-1] 
					if idef['dock'] != 0 : 
						GameGlobal.map.dock_boat_at(Vector2i(playerposx,playerposy))
				
			mapfocuschar.move(input)
			await StateMachine.check_map_script(attemptedpos)
			GameGlobal.pass_time(canmoveandtime[1])
			GameGlobal.map.explore_tiles_from_tilepos(Vector2i(attemptedpos))
			var new_pos = Vector2i(mapfocuschar.tile_position_x, mapfocuschar.tile_position_y )
			if GameGlobal.map.mapboats.has(new_pos) :
				GameGlobal.map.on_step_on_boat(new_pos)
	
	#print(get_stack())
	StateMachine.transition_to("Exploration")
