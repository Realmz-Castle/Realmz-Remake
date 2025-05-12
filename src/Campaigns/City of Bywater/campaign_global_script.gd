var has_on_time_pass : bool = false

func _on_time_pass(s : int) :
	print("campaign_global_script noticed "+ str(s)+" seconds passed")

func get_string_to_save() -> String :
	var dict_to_save : Dictionary = {}
	return  JSON.stringify(dict_to_save)


func give_treasure_with_id(treasure_id) :	##Necessary for ScriptHelperFuncs.give_treasure_with_id
	var items : Array= []
	var money : Array = [0,0,0]
	var exp : int = 0
	match treasure_id :
		0 :
			items.append( GameGlobal.generate_item("Health Potion") )
			money = [0,0,1]
			exp= 16
	return {"treasure" : items, "money" : money, "exp" : exp}
