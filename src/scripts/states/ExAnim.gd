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
	GameGlobal.currentTemple = []
	GameGlobal.allow_money_change(false)
	GameGlobal.allow_banking(false)
	GameGlobal.allow_honest_storage(false)
	GameGlobal.allow_temple(false)

	
	
	var walk_inputs : Array = []
	if _msg.has("walk_inputs") :
		walk_inputs += _msg["walk_inputs"]
	while not walk_inputs.is_empty() :
		var input = walk_inputs.pop_front()
		if GameGlobal.camping and input != Vector2i.ZERO :
			await UI.ow_hud._on_CampButton_pressed(true)
		if GameGlobal.fatigue >= GameGlobal.fatigue_limit() and input != Vector2i.ZERO :
			SfxPlayer.stream = GameGlobal.cmp_resources.sounds_book["effort 1.wav"]
			SfxPlayer.play()
		#input = Vector2i.ZERO
	
		var mapfocuschar = GameGlobal.map.focuscharacter
		var playerposx : int = mapfocuschar.tile_position_x
		var playerposy : int = mapfocuschar.tile_position_y
		var attemptedpos : Vector2 = Vector2(playerposx+input.x, playerposy+input.y)
		var attempted_tile := Vector2i(attemptedpos)
		var map_width: int = GameGlobal.map.mapdata.size()
		var map_height: int = GameGlobal.map.mapdata[0].size() if map_width > 0 else 0
		if (
			attempted_tile.x < 0
			or attempted_tile.y < 0
			or attempted_tile.x >= map_width
			or attempted_tile.y >= map_height
		):
			var edge_movement := GameGlobal.resolve_classic_map_movement(
				Vector2i(playerposx, playerposy),
				attempted_tile
			)
			if str(edge_movement.get("status", "")) == "error":
				push_error(str(edge_movement.get(
					"message",
					"Classic land edge transition failed"
				)))
			if bool(edge_movement.get("handled", false)):
				continue
			# Native campaigns do not define cross-map adjacency here.
			continue
		var tilestack : Array = GameGlobal.map.mapdata[attempted_tile.x][attempted_tile.y]
#		print(tilestack)
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
			var dungeon_reveal := GameGlobal.reveal_classic_dungeon_overhead(attempted_tile)
			if str(dungeon_reveal.get("status", "")) == "error":
				push_error(str(dungeon_reveal.get(
					"message",
					"Classic dungeon overhead could not be revealed"
				)))
			await StateMachine.check_map_script(
				attemptedpos,
				{"entryMovement": Vector2i(input)}
			)
			GameGlobal.pass_time(canmoveandtime[1])
			GameGlobal.map.explore_tiles_from_tilepos(Vector2i(attemptedpos))
			
			if GameGlobal.must_cancel_movement :
				mapfocuschar.move(-input)
				GameGlobal.must_cancel_movement = false
				
			
			var new_pos = Vector2i(mapfocuschar.tile_position_x, mapfocuschar.tile_position_y )
			if GameGlobal.map.mapboats.has(new_pos) :
				GameGlobal.map.on_step_on_boat(new_pos)
	
	#print(get_stack())
	if StateMachine.state.name == "ExMenus" :
		print("ExAnim exit, current state is ", StateMachine.state.name)
	else :
		StateMachine.transition_to("Exploration")
