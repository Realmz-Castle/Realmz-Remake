# only ran when starting a  new  campaign, use globalscript for other needs.

static func before_loading_ressources() :
	print("City of bywater before_loading_ressources() ")
	var owchar = NodeAccess.__Map().owcharacter
	owchar .position = Vector2(3,3) * Utils.GRID_SIZE
	owchar.tile_position_x = 3
	owchar.tile_position_y = 3
	pass

static func after_loading_ressources() :
	GameGlobal.time = 86401	#set starting dime  (day 1, 1s)
	GameGlobal.currentmap_name = "map_1"	# set starting map
	#GameGlobal.currentmap_name = "new_map_tutorial"
	#GameGlobal.allow_character_swap_anywhere = true
	set_boats_in_gameglobal()
	set_minimaps_in_gameglobal()

#sets boat data in GameGlobal.map_boats_dict
static func set_boats_in_gameglobal() :
	pass
	#GameGlobal.map_boats_dict = {"test_map" : {  "67,50" :  "Funny2" } }
	
static func set_minimaps_in_gameglobal() :
	pass
	#GameGlobal.minimaps = [
	#	#"MinimapName, MapItRepresents, splashimagename, descroiption, topleftcoordinates, pixels/tile, owned
	#	["City of Bywater NW", "test_map", "CityMiniMap.png","A map of the City of Bywater. The General Store is marked.", [5,5], 16, 1],
	#	["Wilderness", "test_map", [20,20], "wilderness.png", "mostly forest and shit.", 1, 0]
	#]