extends Object
class_name running_crea_script

#const target_pos : Vector2i = Vector2i(51,87)

# returns : depends of  fint int in array :
#  [0]==0 means  walk in  the direction Vector2i  at  [1]
#  [1, selectedSpell, selectedplvl, spell_target_pos].......aoe_shape : Array, picked_targets : Dictionary, picked_tiles:Dictionary, chain_start : bool, must_add_terrain : bool)
static func decide_action(crea : Creature) -> Array :
	print("running_crea_script decide_action : "+crea.name)
	#find barycenter of all enemy  positions
	var barycenter : Vector2 = Vector2.ZERO
	var enemies_number : int = 0
	for cb : CombatCreaButton in StateMachine.combat_state.all_battle_creatures_btns :
		if cb.creature.curFaction != crea.curFaction :
			barycenter += cb.creature.position
			enemies_number +=1
	barycenter *= (1/enemies_number)
	#find direction away from barycenter
	var safe_direction : Vector2 = ((crea.position-barycenter).normalized())
	safe_direction = safe_direction.round()
	#check if that position is walkable for crea
	var canwalkandtime : Array = StateMachine.combat_state.on_trying_to_move_to_position(crea,crea.position+safe_direction , true)
	if canwalkandtime[0] and canwalkandtime[1]<=crea.get_movement_left() :
		return [0,Vector2i(safe_direction)]
	else :
		#use  a ranged weapon ?
		if crea.current_range_weapon["name"] == "NO_RANGE_WEAPON" :
			return [0, Vector2i.ZERO]
		var ranged_spell_array : Array = crea.current_range_weapon["_on_combat_use_spell"]
		var ranged_spell = GameGlobal.cmp_resources.spells_book[ranged_spell_array[0]]["script"]
		var ranged_plvl : int = ranged_spell_array[1]
		var max_range : int = ranged_spell.get_range(ranged_plvl, crea)
		
		var target_crea : Creature
		var targ_range : int = 9999
		var closest_enemies : Array = get_closest_creas_not_of_side(crea, crea.curFaction)
		
		if not closest_enemies.is_empty():
			for c in closest_enemies :
				targ_range = get_range_between_creas(crea, c)
				var targ_los : bool = check_los_between_creas(crea,c,max_range)
				if targ_range<=max_range and targ_los :
					target_crea = c
					break
			if is_instance_valid(target_crea) :
				var tg : TargetingLayer = GameGlobal.map.targetingLayer
				var affected_tiles = tg.get_affected_tiles(ranged_spell, ranged_plvl, crea.combat_button, target_crea.position, [])
				var affected_creas = tg.get_cbs_touching_tiles(affected_tiles)
				if affected_creas.is_empty() :
					return [0, Vector2.ZERO]
				var aoe_name = ranged_spell.get_aoe(ranged_plvl, crea)
				var aoe_shape = GameGlobal.map.targetingLayer.get_aoe_from_name(aoe_name)
				return [1, ranged_spell, ranged_plvl, target_crea.position, aoe_shape, {},Vector2i(target_crea.position), affected_tiles, affected_creas]
			else :
				return [0, Vector2i.ZERO]
		else :
			return [0, Vector2i.ZERO]
			
	return [0, Vector2i.ZERO ]
				
#	if not crea.scripts_memory.has("prev_dir") :
#		crea.scripts_memory["prev_dir"] = [Vector2.UP, Vector2.RIGHT].pick_random()
#	crea.scripts_memory["prev_dir"] = - crea.scripts_memory["prev_dir"]
#	return [0, - crea.scripts_memory["prev_dir"] ]


	#if not crea.scripts_memory.has("target_pos") :
		#crea.scripts_memory["target_pos"] = target_pos
	##find_path(from : Vector2i, to : Vector2i, swimmer : bool, flying : bool, big : bool)
	#var path : Array = GameState.map.find_path(crea.position, target_pos, true, false, false)
	#
	#if path.size() < 1 :
##		print("test_crea_script : ", crea.position, ' path empty :c ')
		#return [0, Vector2.ZERO ]
	#else :
		#print("test_crea_script : ", crea.position, ' path: ', path[0])
		#print("TileDict : ", GameState.map.mapdata[path[0].x][path[0].y])
		#return [0,Vector2(path[1])-crea.position ]
	

# return true iff the other crea is "range"  or less tiles away.
static func is_other_in_range(crea :Creature, othercrea : Creature, mrange : int) ->bool :
	for cx in range(0,crea.size.x) :
		for cy in range(0,crea.size.y) :
			for tx in range(0,othercrea.size.x) :
				for ty in range(0,othercrea.size.y) :
					if GameGlobal.calculate_range_v(Vector2(cx,cy)-Vector2(tx,ty)) <= mrange :
						return true
	return false

#useful for bigger creatures !
# ignores terrain
static func get_range_between_creas(crea : Creature, othercrea : Creature) ->int :
	var min_range : int = 9999
	for cx in range(0,crea.size.x) :
		for cy in range(0,crea.size.y) :
			for tx in range(0,othercrea.size.x) :
				for ty in range(0,othercrea.size.y) :
					var r : int = GameGlobal.calculate_range_v(Vector2(cx,cy)-Vector2(tx,ty))
					min_range = min(min_range, r)
	return min_range

#ignores terrain
static func get_closest_creas_not_of_side(crea : Creature, notside : int) -> Array :
	var found_creas : Array = []
	var found_range : int = 9999
	for cb in StateMachine.combat_state.all_battle_creatures_btns :
		if cb.creature.curFaction != notside :
			var r : int = get_range_between_creas(crea, cb.creature)
			if r < found_range :
				found_creas.clear()
				found_range = r
			if r == found_range :
				found_creas.append(cb.creature)
	found_creas.shuffle()
	return found_creas

static func check_los_between_creas(crea_a : Creature, crea_b : Creature, max_range : int) -> bool :
	var tg : TargetingLayer = GameGlobal.map.targetingLayer
	var tiles_line_array = tg.bresenham_line(crea_a.position,crea_b.position, 0, max_range)
	for ts_pos in tiles_line_array :
		var tilestack : Array = GameGlobal.map.mapdata[ts_pos.x][ts_pos.y]
		for tiledict in tilestack :
#			print(tiledict)
			if tiledict["blkproj"]==1 :
				return false
	return true
