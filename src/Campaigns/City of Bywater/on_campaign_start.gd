# only ran when starting a  new  campaign, use globalscript for other needs.

static func before_loading_ressources() :
	print("City of bywater before_loading_ressources() ")
	var owchar = NodeAccess.__Map().owcharacter
	owchar .position = Vector2(3,3) * Utils.GRID_SIZE
	owchar.tile_position_x = 2
	owchar.tile_position_y = 1
	pass

static func after_loading_ressources() :
	GameGlobal.time = 86401	#set starting dime  (day 1, 1s)
	GameGlobal.currentmap_name = "map_0"	# set starting map
	#GameGlobal.currentmap_name = "new_map_tutorial"
	#GameGlobal.allow_character_swap_anywhere = true
	set_boats_in_gameglobal()
	set_minimaps_in_gameglobal()

#sets boat data in GameGlobal.map_boats_dict
static func set_boats_in_gameglobal() :
	pass
	#GameGlobal.map_boats_dict = {"test_map" : {  "67,50" :  "Funny2" } }
	
static func set_minimaps_in_gameglobal() :
	#
	GameGlobal.minimaps = [
		#"MinimapName, MapItRepresents, splashimagename, descroiption, topleftcoordinates, pixels/tile, owned
		["City of Bywater NW", "map_0", "CityMiniMap.png","A copy of the posting on the city gate showing directions to a general store.", [5,5], 16, 1],
		["Anthrax Castle", "map_0", [20,20], "CastleMiniMap.png", "This map shows the location of a secret cavern that leads into the courtyard of the castle Anthrax.", 1, 0],
		["Waterford Cave", "map_0", [20,20], "CastleMiniMap.png", "This map shows the location of the cave that leads to the sunken city of Waterford.", 1, 0],
		["Blacksmith's Son", "map_0", [20,20], "BlacksmithMiniMap.png", "The location where they found the son of the blacksmith's body.", 1, 0],
		["Krise Caverns Entrance", "map_0", [20,20], "KriseEntranceMiniMap.png.png", "Secret entrace to the krise controled caverns.", 1, 0],
		["Scary Place", "map_0", [20,20], "ScaryMiniMap.png", 'The map given to you by the seedy looking Orc.  In one corner is scribbled, "Scary Place"', 1, 0],
		["Ranthog's Treasure", "map_0", [20,20], "RanthogMiniMap.png", "Map showing location of hidden treasure as told you by Ranthog the Hill Giant.", 1, 0],
		["Crypt Secrets", "map_5", [20,20], "CryptMiniMap.png", "Map showing two secret locations.  One is a secret wall and the other is a secret passage in the crypt under the graveyard.", 1, 0],
		["Beastmen Corral", "map_0", [20,20], "BeastmenMiniMap.png", "This map shows the location of a corral of beastmen.  You have agreed to eliminate the corral for the sum of 400 gold pieces.", 1, 0],
		["Slave Shed", "map_0", [20,20], "SlaveShedMiniMap.png", "Map showing the location of the slave shed.  Your to deliver 3 Proto-Hyenas in return for a reward of gold coins.", 1, 0],
		["King's Gardens", "map_0", [20,20], "GardenMiniMap.png", "A map showing the loation of the King's gardens.  You are to destroy a rabid beast that dwells within.", 1, 0],
		["ScrollingText", "map_0", [20,20], "CastleMiniMap.png", "text id=-200", 1, 0],
		["ScrollingText", "map_0", [20,20], "CastleMiniMap.png", "text id=-201", 1, 0],
		["ScrollingText", "map_0", [20,20], "CastleMiniMap.png", "text id=-202", 1, 0],
		["Waterford Cave", "map_1", [20,20], "GnollsMiniMap.png", "A map showing a treasure that the gnolls can't reach because of their size.", 1, 0],
		["Waterford Cave", "map_0", [20,20], "CastleMiniMap.png", 'On the bottom of the map is a note:\n"After several weeks of sneaking about after the inn has closed for the night, I think I have found the source of the dissapearing townsfolk.\n     Corporal Sanchez.  Kings Investigative Agent 4th class."', 1, 0]
	]
