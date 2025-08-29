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
	ScriptHelperFuncsClass.set_time_event_chance("Time_Enc_1", 0)

static func Time_Enc_2() : #xap_id=XAP0 NOT IN DUMP, invalid ?
	pass


func give_treasure_with_id(treasure_id) :    ##Necessary for ScriptHelperFuncs.give_treasure_with_id
	var items : Array= []
	var money : Array = [0,0,0]
	var exp : int = 0
	match treasure_id :
		0 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[990]) )
		1 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[204]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[5]) )
			money = [45,3,0]
		2 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[990]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[991]) )
			exp = 600
		3 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[9]) )
		4 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[656]) )
			exp = 600
		5 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[405]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[769]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[770]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[771]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[772]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			money = [250,3,0]
			exp = 700
		6 :
			money = [0,3,0]
		7 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[648]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[654]) )
			exp = 300
		8 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[600]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[601]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[617]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[801]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			money = [0,5,2]
			exp = 600
		9 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[654]) )
			exp = 100
		10 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[8]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[439]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[427]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[802]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[760]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[767]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[768]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[603]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[604]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[611]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[611]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[611]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			money = [2000,6,1]
			exp = 2000
		11 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[807]) )
			exp = 1200
		12 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[1]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[209]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[450]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[452]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[250]) )
			money = [250,5,0]
		13 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[765]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[766]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[611]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[608]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[719]) )
			exp = 400
		14 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[1]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[1]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[104]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[11]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[45]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[60]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[210]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[216]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[401]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[419]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[400]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[400]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[400]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[209]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[215]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[215]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[223]) )
			money = [250,5,0]
			exp = 1200
		15 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[808]) )
		16 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[90]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[146]) )
			exp = 1000
		17 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[802]) )
			exp = 200
		18 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[657]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[623]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[649]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[204]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[111]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[119]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[715]) )
			money = [0,0,5]
			exp = 1200
		19 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[210]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[434]) )
			exp = 800
		20 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[5]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[12]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[25]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[74]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[86]) )
			money = [1500,15,2]
			exp = 6000
		21 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[203]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[220]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[405]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[402]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[427]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[445]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[456]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[459]) )
			money = [1500,15,2]
			exp = 6000
		22 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[800]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[616]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[623]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[638]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[637]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[659]) )
			money = [1500,15,2]
			exp = 6000
		23 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[641]) )
			exp = 500
		24 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[242]) )
			exp = 2500
		25 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[877]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[877]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[877]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[877]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[877]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[877]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[877]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[877]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[877]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[877]) )
		26 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
		27 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[605]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[606]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[607]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[619]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[627]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[638]) )
			money = [550,5,1]
			exp = 1000
		28 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[800]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[606]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[609]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[607]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[415]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[611]) )
			money = [0,5,2]
			exp = 1000
		29 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[623]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[232]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[600]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[610]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[610]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[611]) )
			exp = 1000
		30 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[216]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[214]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[401]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[405]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[419]) )
			exp = 1000
		31 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[34]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[220]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[421]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[1]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[803]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[803]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[1]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[83]) )
			exp = 1000
		32 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[656]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[655]) )
			exp = 1500
		33 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[618]) )
			exp = 650
		34 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[614]) )
			exp = 300
		35 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[7]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[202]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[407]) )
			money = [1500,7,2]
			exp = 1000
		36 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[801]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[877]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[881]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[881]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[881]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			money = [1500,20,2]
			exp = 2000
		37 :
			exp = 600
		38 :
			money = [100,0,0]
			exp = 200
		39 :
			money = [200,0,0]
			exp = 400
		40 :
			money = [300,0,0]
			exp = 600
		41 :
			money = [400,0,0]
			exp = 800
		42 :
			money = [400,5,0]
			exp = 1000
		43 :
			money = [18000,0,0]
			exp = 6000
		44 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[8]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[614]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[715]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[800]) )
			money = [2300,15,3]
			exp = 3000
		45 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[662]) )
		46 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[3]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[1]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[1]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[1]) )
		47 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[624]) )
			exp = 500
		48 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[803]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[805]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[803]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[805]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[877]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[878]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[803]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[880]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[881]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[881]) )
		49 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[619]) )
			exp = 750
		50 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[18]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[23]) )
			exp = 10000
		51 :
			money = [500,0,0]
			exp = 6500
		52 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[405]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[1]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[11]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[219]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[418]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[436]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[455]) )
		53 :
			money = [500,0,0]
			exp = 6000
		54 :
			exp = 7000
		55 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[169]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[169]) )
		56 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[623]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[637]) )
			exp = 6000
		57 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[881]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[881]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[881]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[881]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[881]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[881]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[881]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[881]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[881]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[881]) )
		58 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[883]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[877]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[877]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[877]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[877]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[877]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[877]) )
		59 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[8]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[405]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[421]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[211]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[607]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[716]) )
			exp = 6000
		60 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[601]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[601]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[602]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[715]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[719]) )
		61 :
			money = [2200,0,0]
			exp = 1500
		62 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[22]) )
			money = [25,0,0]
			exp = 1500
		63 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[1]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[216]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[405]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[421]) )
			money = [45,5,0]
		64 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[761]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[763]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[764]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			money = [65,5,0]
			exp = 150
		65 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[602]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[604]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[607]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[715]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[718]) )
			money = [350,0,0]
			exp = 1200
		66 :
			money = [24000,0,13]
			exp = 10000
		67 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[672]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[703]) )
			exp = 15000
		68 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[162]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[162]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[406]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[800]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[715]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[717]) )
		69 :
			money = [4500,0,0]
			exp = 2000
		70 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[806]) )
		71 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[178]) )
		72 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[804]) )
			exp = 2000
		73 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[178]) )
		74 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[178]) )
		75 :
			items.append( GameGlobal.generate_item(ItemIdDivinity.mapping[465]) )
	return {"treasure" : items, "money" : money, "exp" : exp}
