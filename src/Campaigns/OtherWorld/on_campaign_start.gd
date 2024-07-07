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
	GameGlobal.currentmap_name = "test_map"	# set starting map
	#GameGlobal.allow_character_swap_anywhere = true
