extends Node


static func get_range_between_creas(crea : Creature, othercrea : Creature) ->int :
	#print("test crea script get_range_between_creas "+crea.name+'-'+othercrea.name)
	var min_range : int = 9999
	for cx in range(0,crea.size.x) :
		for cy in range(0,crea.size.y) :
			for tx in range(0,othercrea.size.x) :
				for ty in range(0,othercrea.size.y) :
					var r : int = GameGlobal.calculate_range_v(crea.position + Vector2(cx,cy)-othercrea.position - Vector2(tx,ty))
					#print(cx,' ',cy,' , ',tx,' ',ty,' ',r)
					min_range = min(min_range, r)
	print("test crea script get_range_between_creas returns", min_range)
	return min_range


static func get_closest_creas_not_of_side(crea : Creature, notside : int) -> Array :
	var found_creas : Array = []
	var found_range : int = 9999
	for cb in StateMachine.combat_state.all_battle_creatures_btns :
		if cb.creature.curFaction != notside :
			var r : int = AiFunctions.get_range_between_creas(crea, cb.creature)
			if r < found_range :
				found_creas.clear()
				found_range = r
			if r == found_range :
				found_creas.append(cb.creature)
	found_creas.shuffle()
	return found_creas
