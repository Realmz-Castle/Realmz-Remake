extends Node
class_name ScriptHelperFuncsClass

static func get_random_creature_of_size(needed_size : Vector2i, pickstrongest : bool, picks_to_compare : int) -> String :
	var bestiary : Dictionary = GameGlobal.cmp_resources.crea_book
	var right_size_crea_namesandlvl : Array = []
	for crea_name : String in bestiary.keys() :
		var crea_data : Dictionary = bestiary[crea_name]
		var crea_size : Vector2i = Vector2i(crea_data["data"]["size"][0], crea_data["data"]["size"][1])
		var crea_summonable : bool = crea_data["data"][ "summonable"]>0
		if crea_size == needed_size and crea_summonable :
			right_size_crea_namesandlvl.append([ crea_name, crea_data["data"]["level"] ])
	if right_size_crea_namesandlvl.is_empty() :
		print("ERROR ScriptHelperFuncs get_random_creature_of_size :  couldnt find creature of size "+str(needed_size))
		return("returned ScriptHelperFuncs get_random_creature_of_size :  couldnt find creature of size "+str(needed_size))
	else:
		return pick_random_crea_from_array(right_size_crea_namesandlvl, pickstrongest, picks_to_compare)

static func pick_random_crea_from_array(arr : Array, pickstrong : bool, picks : int) -> String :
	var picked_arr : Array = []
	for i in range(picks) :
		picked_arr.append(arr.pick_random())
	var picked_name : String = "ERROR ScriptHelperFuncs  pick_random_crea_from_array"
	if pickstrong :
		var highest_lvl : int = 0
		for ca in picked_arr :
			if ca[1]>=highest_lvl :
				picked_name = ca[0]
				highest_lvl = ca[1]
	else :
		var lowest_lvl : int = 999999999
		for ca in picked_arr :
			if ca[1]<=lowest_lvl :
				picked_name = ca[0]
				lowest_lvl = ca[1]
	return picked_name
