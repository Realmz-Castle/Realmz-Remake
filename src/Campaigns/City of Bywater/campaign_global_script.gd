var has_on_time_pass : bool = true

func _on_time_pass(s : int) :
	pass
	#print("campaign_global_script noticed "+ str(s)+" seconds passed")
	#var time = GameGlobal.time
	#===== TIME ENCOUNTER id=0 day=-1 increment=0 percent_chance=0 xap_id=XAP83 required_level: id=0(land) [TEC0]
	#===== TIME ENCOUNTER id=1 day=3 increment=0 percent_chance=100 xap_id=XAP163 [TEC1]
	#===== TIME ENCOUNTER id=2 day=0 increment=0 percent_chance=0 xap_id=XAP0 required_level: id=0(dungeon) required_rect=0 required_pos=(0,0) required_item_id=0 required_quest=0 [TEC2]

func get_string_to_save() -> String :
	var dict_to_save : Dictionary = {}
	return  JSON.stringify(dict_to_save)


static func Time_Enc_0() : #xap_id=XAP83 
	await ScriptHelperFuncsClass.play_sound_divinity(10136)
	var text : String = "Frenzied shouting suddenly breaks out.  A patrol of men rapidly approach your position.  \"They're the ones!  They left Corporal Sampson to die like a wretched beast!  Seize them!\""
	await ScriptHelperFuncsClass.display_text_wait_noise(text, 'message nod.wav')
	await ScriptHelperFuncsClass.start_battle_in_range(207, 207, 0, '', 0)

static func Time_Enc_1() : #xap_id=XAP163
	await ScriptHelperFuncsClass.play_sound_divinity(699)
	var text : String = "You arrived in Bywater just in time as a winter storm has just covered the entire region in a thick blanket of snow."
	await ScriptHelperFuncsClass.display_text_wait_noise(text, 'message nod.wav')
	GameGlobal.stuff_done["is_winter"] = 1
	if GameGlobal.currentmap_name == "map_0" :
		ScriptHelperFuncsClass.change_tileset("ForestDay", "SnowDay")
	ScriptHelperFuncsClass.set_time_enc_chance("Time_Enc_1", 0)

static func Time_Enc_2() : #xap_id=XAP0 NOT IN DUMP, invalid ?
	pass


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
