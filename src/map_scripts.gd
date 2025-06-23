#City of Bywater Map 0  (overworld)

static func _on_map_load(_map) :  #Necessary even if unused, replace body with "pass" if so.
	print("mapscript _on_map_load() !!! ")
	if not GameGlobal.stuff_done.has("met_vodalian") :
		_map.add_extra_image("Vodada", "CREA_Vodalian",Vector2(13,10))


static func scenario_start() :  #===== LAND AP level=0 id=76 x=2 y=2 [LAP0/76]
	if GameGlobal.stuff_done.has("scenario_start_seen") :
		return
	ScriptHelperFuncsClass.display_picture_file('Scenario_Start.png')
	
	var textRect = UI.ow_hud.textRect
	
	await ScriptHelperFuncsClass.display_text_wait_noise('Welcome to "The City of Bywater", a scenario for use with the Realmz Scenario Driver.  If you enjoy playing Realmz and would like to see more scenarios developed, please support us by sending in your registration fee.', 'heal.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Once you have registered this copy of Realmz, you will be able to play the entire scenario.  This scenario is very loose.  It does not have a strong plot line.  You can adventure where you want for as long as you want', 'heal.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise("Once you have registered this copy of Realmz, you will also be able to play test other scenarios BEFORE having to register them.  The fee for each additional scenario are $13 each.  For information on how to register, see chapter 3 of the Realmz Manual.", 'hallelujah.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise("Other scenarios utilize the capabilities of the Realmz scenario driver to a greater extent.  These scenarios feature a definite plot line, new monsters, new magical items and more dangerous encounters.",'message nod.wav')
	ScriptHelperFuncsClass.hide_picture()
	GameGlobal.stuff_done["scenario_start_seen"] = 1


static func guard_house() : #LAND AP level=0 id=0 x=9 y=17 [LAP0/0]
	if GameGlobal.stuff_done.has("guardhouse_attacked") :
		return
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise("You enter the guard house outside the main gate to Castle Anthrax.  Several guards keep a wary eye on you as you approach the head Magistrate.  He is a stately looking man in fine robes.",'message nod.wav')
	
	# SIMPLE ENCOUNTER id=0
	ScriptHelperFuncsClass.play_sound('hit effect 3.wav', false)
	var toptext : String = "Judging by the man's large girth, robes are not all he fancies.  You approach his fine oak desk.  \"Present your invitation so I may validate it for passage to yon castle.\""
	textRect.display_multiple_choices([toptext, "Attempt to bribe your way into the castle.","Show him an invitation to the castle.", "Show him a forged invitation.","Kindly bid him farewell and leave the guardhouse."],["TEXT","bribe", "show","forged", "leave"])
	var answer = await textRect.choice_pressed
	if answer == "bribe" :
		toptext = "The lump of a man leans close so the guards do not hear.  \"For 300 Gold, I shall give you an invitation, but you must swear to use it but once.  To do so more than once will raise my ire.\""
		ScriptHelperFuncsClass.play_sound('hit effect 3.wav', false)
		textRect.display_multiple_choices([toptext,"Pay the gold.", "Refuse his offer."],["TEXT", "pay", "refuse"])
		var answer2 = await textRect.choice_pressed
		print("MAP  SCRIPT  map_0 : answer2 : ", answer2, " pay ? ", answer2=="pay")
		if answer2 == "pay" :
			# check if characters have 300g :
			var totalgold : int = 0
			for character in GameGlobal.player_characters :
				totalgold += character.money[0] #0 is gold
			print("MAP  SCRIPT  map_0 : total gold : ", totalgold)
			if totalgold>=300 :
				ScriptHelperFuncsClass.play_sound('message nod.wav', false)
				textRect.set_text("He hands you an invitation to the Castle Anthrax.", true)
				#pay 300g
				var gold_to_give : int = 300
				for character in GameGlobal.player_characters :
					var gold_given : int = min (gold_to_give, character.money[0])
					gold_to_give -= gold_given
					character.money[0] -= gold_given
				await textRect.interruption_over
				#give treasure 0
				var invtemplate = NodeAccess.__Resources().items_book["Invitation"]
				var treasureitems = [ invtemplate.duplicate(true)]
				StateMachine.enter_ex_menu_state({"menu_name" : "LootMenu", "treasure" : treasureitems ,"money" : [0,0,0] ,"exp" : 0 })
				await UI.ow_hud.treasureControl.done_looting
				
				await ScriptHelperFuncsClass.display_text_wait_noise("In a booming voice, he pronounces you valid petitioners and bids the guards to let you pass into Castle Anthrax.",'message nod.wav')
				
				return
			else :
				await ScriptHelperFuncsClass.display_text_wait_noise("Your party does not have enough gold.",'generation error.wav')
				textRect.set_text("He bids you farewell as you make your way from the gate house.", true)
				await textRect.interruption_over
				return
	if answer == "show" :
		if ScriptHelperFuncsClass.does_party_have_item_named("Invitation") :
			await ScriptHelperFuncsClass.display_text_wait_noise("In a booming voice, he pronounces you valid petitioners and bids the guards to let you pass into Castle Anthrax.",'message nod.wav')
			return
		else :
			await ScriptHelperFuncsClass.display_text_wait_noise("The Magistrate gazes at you and speaks \"Without an invitation you will not be allowed through the main gate.  Perhaps we can work something out.\"",'message nod.wav')
			#copypasted from above
			toptext = "The lump of a man leans close so the guards do not hear.  \"For 300 Gold, I shall give you an invitation, but you must swear to use it but once.  To do so more than once will raise my ire.\""
			ScriptHelperFuncsClass.play_sound('hit effect 3.wav', false)
			textRect.display_multiple_choices([toptext,"Pay the gold.", "Refuse his offer."],["TEXT", "pay", "refuse"])
			var answer2 = await textRect.choice_pressed
			if answer2 == "pay" :
				# check if characters have 300g :
				var totalgold : int = 0
				for character in GameGlobal.player_characters :
					totalgold += character.money[0] #0 is gold
				if totalgold>=300 :
					ScriptHelperFuncsClass.play_sound('message nod.wav', false)
					textRect.set_text("He hands you an invitation to the Castle Anthrax.", true)
					#pay 300g
					var gold_to_give : int = 300
					for character in GameGlobal.player_characters :
						var gold_given : int = min (gold_to_give, character.money[0])
						gold_to_give -= gold_given
						character.money[0] -= gold_given
					await textRect.interruption_over
					#give treasure 0
					var invtemplate = NodeAccess.__Resources().items_book["Invitation"]
					var treasureitems = [ invtemplate.duplicate(true)]
					StateMachine.enter_ex_menu_state({"menu_name" : "LootMenu", "treasure" : treasureitems ,"money" : [0,0,0] ,"exp" : 0 })
					await UI.ow_hud.treasureControl.done_looting
					
					await ScriptHelperFuncsClass.display_text_wait_noise("In a booming voice, he pronounces you valid petitioners and bids the guards to let you pass into Castle Anthrax.",'message nod.wav')
				
					return
				else :
					await ScriptHelperFuncsClass.display_text_wait_noise("Your party does not have enough gold.",'generation error.wav')
					textRect.set_text("He bids you farewell as you make your way from the gate house.", true)
					await textRect.interruption_over
					return
	if answer == "forged" :
		#SIMPLE ENCOUNTER id=1
		toptext = "He takes your clever forgery and looks it over carefully.  Ere he hands it back to you his eyes go wide and he summons the guards.\n\"Hold these fools, they attempt deception.\"\nGuards rush to apprehend you."
		ScriptHelperFuncsClass.play_sound('hit effect 3.wav', false)
		textRect.display_multiple_choices([toptext,"Attack the guards in an attempt to gain entry to the castle.", "Take the magistrate hostage.", "Flee from the gatehouse.", "Let them seize you and attempt to explain that there has been a mistake." ],["TEXT", "attack", "hostage", "flee", "explain"])
		var answer2 = await textRect.choice_pressed
		if answer2 == "attack" :
				await ScriptHelperFuncsClass.display_text_wait_noise("The sergeant of the guard grins in anticipation.  \"You shall swing from the gallows ere today's sun bids us farewell.\"  The battle is joined.",'message nod.wav')
				#change_rect              level=0, id=0, times_in_10k=150, new_battle_low=4, new_battle_high=8
				GameGlobal.stuff_done["guardhouse_attacked"] = 1
				#BATTLE
				GameGlobal.start_battle("Battle_1",false, true,true,true,[])
				var battle_outcome = await GameGlobal.battle_end
				return
		if answer2 == "hostage" :
			GameGlobal.stuff_done["guardhouse_attacked"] = 1
			await ScriptHelperFuncsClass.display_text_wait_noise("The Magistrate screeches in fear.  \"Hold men, for I fear they have foul intentions!\"  With your hostage you manage to beat a hasty retreat from the guardhouse and disappear.\nTwas a difficult task with such bulk in tow.",'message nod.wav')
			ScriptHelperFuncsClass.teleport_to_map_and_pos("map_0", Vector2(4,3), '')
			
			#SIMPLE ENCOUNTER id=2
			
			toptext ="With the reluctant aid of the Magistrate you find your way to a secluded alley.  From the shouts you here in the streets, it would seem the whole kingdom is in search of your whereabouts."
			ScriptHelperFuncsClass.play_sound('hit effect 3.wav', false)
			textRect.display_multiple_choices([toptext,"Set the magistrate free.", "Kill the magistrate so he cannot give you away and take his possessions.", "Search the magistrate,  take his possessions and set him free.", "State that you have panicked and beg forgiveness." ],["TEXT", "free", "kill", "mug", "apology"])
			var answer3 = await textRect.choice_pressed
			if answer3=="free" :
				await ScriptHelperFuncsClass.display_text_wait_noise("As he flees, he shouts to no one in particular.  \"Help, I am being waylaid.  Help....Help!\"  Unfortunately for you, the streets are filled with troops searching for you and they stream towards you.  They do not even ask you to throw down your arms.",'message nod.wav')
					#BATTLE
				GameGlobal.start_battle("Battle_2",false, true,true,true,[])
				var battle_outcome = await GameGlobal.battle_end
				return
			if answer3=="kill" :
				await ScriptHelperFuncsClass.display_text_wait_noise("You send him to the gods.  In his dying whispers he says a prayer to an unfamiliar god.  It would seem he has cursed you with his last gasp.  One might hope he was not held in high regard by his deity.\nYou search the body.",'message nod.wav')
				#result2> modify_ap                level=0, id=4, source_xap=3, level_type=same, result_code=0
				#result2> modify_ap                level=0, id=1, source_xap=3, level_type=same, result_code=0
				#result2> modify_ap                level=0, id=0, source_xap=3, level_type=same, result_code=0
				#result2> enable_ap                level=0, id=0, percent_chance=-100, low=0, high=0
				#result2> change_rect              level=0, id=0, times_in_10k=150, new_battle_low=4, new_battle_high=8
				
				#give treasure 1
				var itemsbook : Dictionary = NodeAccess.__Resources().items_book
				StateMachine.enter_ex_menu_state({"menu_name" : "LootMenu", "treasure" : [itemsbook["Robe of Protection +1"].duplicate(true),itemsbook["Dagger of Penetration +2"].duplicate(true)] ,"money" : [45,3,0] ,"exp" : 0 })
				await UI.ow_hud.treasureControl.done_looting
				return
			if answer3=="mug" :
				await ScriptHelperFuncsClass.display_text_wait_noise("You take all his possessions as you strip him down to his breeches.  \"You ruffians shall pay dearly for this!  The King will spare no expense at expunging you and your kind!\" he cries.",'message nod.wav')
				#give treasure 1
				var itemsbook : Dictionary = NodeAccess.__Resources().items_book
				StateMachine.enter_ex_menu_state({"menu_name" : "LootMenu", "treasure" : [itemsbook["Robe of Protection +1"].duplicate(true),itemsbook["Dagger of Penetration +2"].duplicate(true)] ,"money" : [45,3,0] ,"exp" : 0 })
				await UI.ow_hud.treasureControl.done_looting
				return
			if answer3=="apology":
				await ScriptHelperFuncsClass.display_text_wait_noise("\"Well, I should guess so.  I shall explain the error of your ways to the city guard.  It is fortunate for you that I am a patient man.  Now be gone, for I must return to my duties.\"",'message nod.wav')
				return
			
		if answer2=="flee" :
			await ScriptHelperFuncsClass.display_text_wait_noise("The guards begin to pursue when you here the Magistrate bellow with laughter as he calls them back.  \"Run foul vermin, for we are far too busy to chase the likes of you!\"  It would seem they did not take you as too serious a threat.",'message nod.wav')
			return
		if answer2=="explain" :
			await ScriptHelperFuncsClass.display_text_wait_noise("After you explain that you only want to gain entrance to the court on honest business, the Magistrate is so amused that he lets you enter.  \"Since you chose not to resist, I deem you to be honest folk, and this is an honest kingdom.  Enter as you will.\"",'message nod.wav')
			await ScriptHelperFuncsClass.display_text_wait_noise("He hands you an invitation to the Castle Anthrax.",'message nod.wav')
			#give treasure 0
			var invtemplate = NodeAccess.__Resources().items_book["Invitation"]
			var treasureitems = [ invtemplate.duplicate(true)]
			StateMachine.enter_ex_menu_state({"menu_name" : "LootMenu", "treasure" : treasureitems ,"money" : [0,0,0] ,"exp" : 0 })
			await UI.ow_hud.treasureControl.done_looting
			return
	if answer== "leave" :
		await ScriptHelperFuncsClass.display_text_wait_noise("He bids you farewell as you make your way from the gate house.",'message nod.wav')



static func castle_gate() :#===== LAND AP level=0 id=1 x=8 y=16 [LAP0/1]
	var textRect = UI.ow_hud.textRect
	#ScriptHelperFuncsClass.play_sound('message nod.wav', false)
	#textRect.set_text("You approach the main gate to Castle Anthrax.  As you near, the gate guard bars your path and asks to see your formal invitation.", true)
	#await textRect.interruption_over
	await ScriptHelperFuncsClass.display_text_wait_noise("You approach the main gate to Castle Anthrax.  As you near, the gate guard bars your path and asks to see your formal invitation.", 'message nod.wav')
	if ScriptHelperFuncsClass.does_party_have_item_named("Invitation") :
		#===== XAP id=1 [XAP1]
		#ScriptHelperFuncsClass.play_sound('message nod.wav', false)
		#textRect.set_text("The gate guards check your invitation and wave you through.", true)
		#await textRect.interruption_over
		await ScriptHelperFuncsClass.display_text_wait_noise("The gate guards check your invitation and wave you through.", 'message nod.wav')
	else :
		#===== XAP id=2 [XAP2]
		#ScriptHelperFuncsClass.play_sound('message nod.wav', false)
		#textRect.set_text("\"Sorry citizen, without a formal invitation, the only way into the castle is in chains.  See the magistrate in yon building, he can explain all.  Now be off.\"", true)
		#await textRect.interruption_over
		ScriptHelperFuncsClass.teleport_to_map_and_pos("map_0", Vector2(9,16), '')
		await ScriptHelperFuncsClass.display_text_wait_noise("\"Sorry citizen, without a formal invitation, the only way into the castle is in chains.  See the magistrate in yon building, he can explain all.  Now be off.\"",'message nod.wav')
	return

static func guard_barracks() : #===== LAND AP level=0 id=2 x=6 y=16 [LAP0/2]
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('message nod.wav', false)
	textRect.set_text("You enter the barracks of the town guard.", true)
	await textRect.interruption_over
	ScriptHelperFuncsClass.play_sound('message nod.wav', false)
	textRect.set_text("As you enter, you hear sharp words being exchanged from two high-ranking men.  It would seem the guardsmen are split into two factions.  One faction appears to be headed by a man by the name of Haikur, the other by a man named Thurfur.", true)
	await textRect.interruption_over



static func cookhouse() : #===== LAND AP level=0 id=14 x=25 y=6 [LAP0/14]
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('message nod.wav', false)
	var text : String = "You come upon an inn and cookhouse.  The smell of hot meals and the sounds of good conversation waft to you from inside.   Do you step inside?"
	textRect.set_text(text)
	textRect.display_multiple_choices([text, "YESNO"],["TEXT","YESNO"])
	var answer = await textRect.choice_pressed
	if answer == "YES" :
		GameGlobal.currentSpecialEncounterName = "cookhouse.gd"
		UI.ow_hud._on_EncounterButton_pressed()
		#TODO  CONTINUE, was  actually  not a complex encounter...
		

static func caved_in_cavern() :  #===== LAND AP level=0 id=19 x=2 y=48 [LAP0/19]
	if GameGlobal.stuff_done.has("caved_in_cavern_solved") :
		if GameGlobal.stuff_done["caved_in_cavern_solved"] == 1 :
			return
		if GameGlobal.stuff_done["caved_in_cavern_solved"] == 2 :
			ScriptHelperFuncsClass.play_sound("effort 1.wav", false)
			ScriptHelperFuncsClass.set_walk_back_once(true)
			return
	ScriptHelperFuncsClass.play_sound('hit effect 3.wav', false)
	var textRect = UI.ow_hud.textRect
	var text : String = "This appears to be the site of a rather large cavern that has recently caved in."
	textRect.set_text(text)
	GameGlobal.currentSpecialEncounterName = "caved_in_cavern.gd"
	UI.ow_hud.show_special_encounter()


static func frost_viper_lady() : #===== XAP id=6 [XAP6]
	if GameGlobal.stuff_done.has("met_osswell") :
		return
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('message nod.wav', false)
	var text : String = "You come upon a shocking scene.  You spy a small group of town bullies attacking an old woman.  It would seem they are after a dagger she is clutching to her chest.  Do you wish to intervene on her behalf?"
	textRect.set_text(text)
	textRect.display_multiple_choices([text, "Rescue the woman", "Back away"],["TEXT","rescue", "leave"])
	var answer = await textRect.choice_pressed
	if answer == "leave" :
		GameGlobal.stuff_done["met_osswell"] = 2 #abandonned her
		return
	text = "The bullies do not have the stomach to fight and flee at your approach.  The old hag scowls at you, \"Stay away!  You can't have it!\"  The dagger she is clutching is rather ornate and seems very likely to be magical in nature.  What do you do?"
	ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
	textRect.display_multiple_choices([text, "Take the dagger", "Bid her goodday"],["TEXT","steal", "bye"])
	answer = await textRect.choice_pressed
	if answer == "steal" :
		text = "\"You young whelps!  You shall rot in hell for your evil ways!\"  Having lost the dagger she shuffles away."
		await ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
		#TSR3  #"Frozen Viper +2"
		
		var invtemplate = NodeAccess.__Resources().items_book["Frozen Viper +2"]
		var treasureitems = [ invtemplate.duplicate(true)]
		StateMachine.enter_ex_menu_state({"menu_name" : "LootMenu", "treasure" : treasureitems ,"money" : [0,0,0] ,"exp" : 0 })
		await UI.ow_hud.treasureControl.done_looting
		
		
		GameGlobal.stuff_done["met_osswell"] = 3 #stole frost viper
		return
	if answer == "bye" :
		text = "As you walk away, she yells, \"Come and see me at my shop.  I will give you a special price!\"  She quickly disappears around a corner before you realize that you do not even know where her shop is."
		ScriptHelperFuncsClass.display_text_wait_noise(text,'message nod.wav')
		GameGlobal.stuff_done["met_osswell"] = 1  #honest to osswell
		


static func graveyard_random_battle() :  #LRR0/3, not a  real AP
	#  from  the radom  rectangle  data
	var t : String = "You spot a group of undead stumbling about. Do you wish to attack them?"
	#  from  the battle data  of battles  of id in b
	var bt : String = "The stench of death assaults you as you are attacked by zombies."
	await ScriptHelperFuncsClass.randomrect_battle([24,31], 33, "growl 2.wav", t, bt)

static func enter_brothel() :  #===== LAND AP level=0 id=16 x=7 y=6 to_level=6 to_x=8 to_y=1 [LAP0/16]
	await ScriptHelperFuncsClass.display_text_wait_noise("You have come to the town brothel.  Perfume fills the air and covers any original odor that may come from this former boarding house.  A sign outside the building gives prices for various races and sexes.",'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise("It appears to be well-managed and doing a lot of business.  There is a steady stream of customers going in the front door and another coming out the back.",'message nod.wav')
	# add this because AP  description has a to_level  to_x  to_y
	ScriptHelperFuncsClass.teleport_to_map_and_pos("map_6", Vector2(8,1), '')

static func general_store() : #===== LAND AP level=0 id=9 x=7 y=11 [LAP0/9]
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('message nod.wav', false)
	var text : String = "You enter a pleasant little shop that seems well stocked.  The shopkeeper smiles and asks you to look around at his fine wares.   (To enter shops, click the button labeled SHOP at the bottom right of the game screen.)"
	textRect.set_text(text, false)
	
	GameGlobal.currentShop = 'shop_1'
	GameGlobal.allow_money_change(true)
	GameGlobal.allow_banking(true)

static func sestuona_temple() :
	# ===== XAP id=85 [XAP85]
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('heal.wav', false)
	var text : String = "You arrive at a temple dedicated to Sestuona, goddess of nature.  You will be permitted entry only if you are willing to pay an outrageous price for the temple's services.  Your presence here is opposed by a powerful enemy within the sect."
	textRect.set_text(text, false)
	GameGlobal.cu
	GameGlobal.allow_temple(true)

static func meet_vodalian() : #===== XAP id=103 [XAP103]
	#RANDOM RECTANGLE REFERENCE land_level=0 rect_num=8 start_coord=0,0 end_coord=41,13 [LRR0/8]
	if GameGlobal.stuff_done.has("met_vodalian") :
		return
	GameGlobal.stuff_done["met_vodalian"] = 1
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('talk 1.wav', false)
	await SfxPlayer.finished
	ScriptHelperFuncsClass.play_sound('talk 2.wav', false)
	var text : String = "You greet a passing wizard who smiles warmly at you.  You strike up a wonderful conversation and become friends.  He asks about your travels and would like to know if he may accompany you on your exploits?"
	textRect.set_text(text, false)
	textRect.display_multiple_choices([text, "YESNO"],["TEXT","YESNO"])
	var answer = await textRect.choice_pressed
	if answer == "NO" :
		return
	await ScriptHelperFuncsClass.display_text_wait_noise("You return to his small shack to gather his things before you set off with your new found friend.  His name is Vodalian and he states that he simply loves adventure.",'message nod.wav')
	var vodalian : Creature = Creature.new()
	vodalian.initialize_from_bestiary_dict(NodeAccess.__Resources().crea_book["Vodalian"])
	GameGlobal.add_npc_ally(vodalian)

static func guard_give_map() :
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('message nod.wav', false)
	var text : String = "The town patrol waves you through as they hand you a map showing where you can buy provisions."
	textRect.set_text(text, false)
	GameGlobal.minimaps[0][6]=1



static func GlyphScript_Two() :
	if false  :
		var hud = UI.ow_hud
		hud.request_pc_pick(3)
		var picked = await hud.pc_picked
		print(picked)
		var pickednames = "picked characters : "
		for c in picked :
			pickednames = pickednames + c.name + ' '
		pickednames = pickednames + ", in this order."
		var textbox = UI.ow_hud.textRect
		textbox.set_text(pickednames, false)
		print("mapscript over and  out")
		return

	print("GlyphScript_TwoGlyphScript_TwoGlyphScript_Two")
	var textRect = UI.ow_hud.textRect
	textRect.set_text("MULTIPLE CHOICE !", false)
	textRect.display_multiple_choices(["Exposition text_a\nwith\nextra lines","A wordy choice.", "YESNO","STOP"],["TEXT","answer_words", "YESNO","STOP"])
	var answer = await textRect.choice_pressed
	print("choice_pressed : ", answer)
	if answer == "answer_words" :
		print("You give a long, verbose answer.")
		pass #do stuff
	if answer == "YES" :
		print("You categorically answer YES.")
	if answer == "NO" :
		print("You firmly refuse")
	if answer == "STOP" :
		print("Nothing stops you from just walking away. You do just that.")
	

static func Allow_Char_Swap() :
	print("Allow_Char_Swap")
	SfxPlayer.stream = NodeAccess.__Resources().sounds_book["generation good.wav"]
	SfxPlayer.play()
	var textRect = UI.ow_hud.textRect
	textRect.set_text("You may swap characters here. And exchange currencies. And shop at 'SimpleShop'.", false)
	GameGlobal.allow_character_swap(true)
	GameGlobal.allow_honest_storage(true)
	GameGlobal.currentShop = 'shop_1'
	MusicStreamPlayer.play_music_type("Dungeon")
	GameGlobal.currentSpecialEncounterName = "otherencounter.gd"
	#MusicStreamPlayer.play_music_specific("camp.mod")
	GameGlobal.allow_money_change(true)
	GameGlobal.allow_banking(true)

static func Find_Treasure() :
	var textRect = UI.ow_hud.textRect
	textRect.set_text("You find some delicious loot !", true)
	await textRect.interruption_over
	#var treasureControl = UI.ow_hud.treasureControl
	var healpottemplate = NodeAccess.__Resources().items_book["Health Potion"]
	var treasureitems = []
	for i in range(200) :
		var healpotion = healpottemplate.duplicate(true)
		treasureitems.append(healpotion)
	await StateMachine.enter_ex_menu_state({"menu_name" : "LootMenu", "treasure" : treasureitems ,"money" : [10,5,3] ,"exp" : 2000 })
	#await GameGlobal.show_loot_menu(treasureitems,[10,5,3],2000)
	#yield(textRect, "interruption_over")

static func Take_Stairs_D() :
	var textRect = UI.ow_hud.textRect
	textRect.set_text("You take the stairs down to rug_dungeon_floor !", true)
	GameGlobal.change_map("rug_dungeon_floor",3,3)

static func Test_Battle() :
	print("Map Script func Test_Battle() ")
	#start_battle(battlename : String, is_ambush : bool, allow_loss : bool, allow_escape : bool, summons_allowed : bool, pc_participating : Array)
	GameGlobal.start_battle("Test_Battle",false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	print("mapScript battle_outcome : ", battle_outcome)
	if battle_outcome == "won" :
		print("BATTLE WON")
		UI.ow_hud.textRect.set_text("You won this battle, but did you use the Debug buttons ?", true)
	if battle_outcome == "fled" :
		print("BATTLE ESCAPED")
		UI.ow_hud.textRect.set_text("You escaped this battle, but HOW ? This is not implemented yet !", true)
	if battle_outcome == "lost" :
		for pc in GameGlobal.player_characters :
			pc.stats["curHP"] = 1
			pc.life_status = 0
		print("BATTLE LOST")
		UI.ow_hud.textRect.set_text("You lost this battle, but live to fight another day.", true)

static func example_script() :
	return
	var map = NodeAccess.__Map()
	map.modulate = Color(0.5, 0, 1, 1)
	var resources = NodeAccess.__Resources()
	print(resources.tiles_book["ForestDay.json"][181])
	map.mapdata[5][5][0]= resources.tiles_book["ForestDay.json"][181]
	return
	if GameGlobal.stuff_done.has("helped_boy") :
		if GameGlobal.stuff_done["helped_boy"] :
			UI.ow_hud.modulate = Color(0, 0, 1, 0.5)

			return
	var textRect = UI.ow_hud.textRect
	textRect.set_text("A boy  asks you to recue his dog.", false)
	textRect.display_multiple_choices(["Do you help the dog ?","Ask for details", "YESNO","STOP"],["TEXT","ask_details", "YESNO","STOP"])
	var answer = await textRect.choice_pressed
	if answer == "ask_details" :
		textRect.set_text("The boy explains the dog fell in a well and can't get out", false)
		textRect.display_multiple_choices(["Do you help the dog ?", "YESNO","STOP"],["TEXT", "YESNO","STOP"])
		answer = await textRect.choice_pressed
	if answer == "YES" :
		textRect.set_text("You help the  dog,  but get hurt.", false)
		UI.ow_hud.show_spell_effect_on_char_menu(GameGlobal.player_characters[0], "Slime")
		GameGlobal.player_characters[0].stats["curHP"] -=5
		UI.ow_hud.updateCharPanelDisplay()
		GameGlobal.stuff_done["helped_boy"] = 1
	if answer == "NO" :
		textRect.set_text("The boy walks away crying", false)

static func Secret_AP() :
	GameGlobal.play_sfx("generation good.wav")
	UI.ow_hud.textRect.set_text("You find a secret path in the mountain.", false)
