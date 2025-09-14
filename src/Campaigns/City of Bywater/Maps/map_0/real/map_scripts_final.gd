#Map test Script generated from old AP format

static func _on_map_load(_map) :
	print("mapscript _on_map_load() !!! ")
	# Add any initialization code here

static func AP0x9y17() : #0 at 9,17
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter the guard house outside the main gate to Castle Anthrax.  Several guards keep a wary eye on you as you approach the head Magistrate.  He is a stately looking man in fine robes.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_simple_encounter_Divinity(0)
	return

static func AP1x8y16() : #1 at 8,16
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You approach the main gate to Castle Anthrax.  As you near, the gate guard bars your path and asks to see your formal invitation.', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.branch_item_possession_divinity(990, 0, 0, 1, 2)
	if not branch.is_empty(): return branch
	return

static func AP2x6y16() : #2 at 6,16
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter the barracks of the town guard.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('As you enter, you hear sharp words being exchanged from two high-ranking men.  It would seem the guardsmen are split into two factions.  One faction appears to be headed by a man by the name of Haikur, the other by a man named Thurfur.                    ', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.branch_item_possession_divinity(991, 1, 1, 4, 0)
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('Before you catch too much of the argument, the barracks falls silent as all heads turn to you.  Thurfur comes over and demands to know your business for being there.  Not satisfied with your answer, he orders you to leave.  Do you leave?', 'message nod.wav')
	branch = await ScriptHelperFuncsClass.yesno_branch(true, 1, 5, "", "")
	if not branch.is_empty(): return branch
	return

static func AP3x4y17() : #3 at 4,17
	var textRect = UI.ow_hud.textRect
	# This AP teleports to level 5 at 29,88
	# Needs rework: teleport parameters need to be converted to map_id (int), posx, posy, sfx_id (int)
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(5, 29, 88, 0)
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(5, 6, 83, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter Anthrax castle.  The herald announces your arrival to the king who is holding audience.  As your names are called, there are puzzled looks.  It is obvious that you are newcomers.  King Steven\'s motions you to approach.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('\"Hail, good people!  What brings you here this fine day?  You are obviously not from Bywater, for your manner of dress is most foreign.\"  You explain to the king that you are but simple travelers in search of adventure.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('\"Adventure!  Well, my good citizens.  This is the place!  Many strange happenings have been taking place of late.  Many, I\'m sure, the direct result of that accursed Spider Tower that has sprung up at the east end of town.\"', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('\"But this is a peaceful land, which claims hatred towards no one who does no direct harm.  As of yet, there has been no evil which can be proven to have originated from that foul spire.  Come, meet with me in my chambers.\"', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('With little fanfare, he calls an end to court and bids his patrons good day.  You retreat with the king to a chamber adjoining the main hall.  The door is closed, and you are surrounded by only the king and his closest advisors.  The king speaks.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('\"My good fellows.  Dark times have befallen this fair city.  Alas, politics prevent me from declaring so in public.  This foul spider cult is sapping the very strength of our bustling city.  I would see this vile cult rousted from my kingdom, ', 'message nod.wav')
	# XAP 22 content (recursively resolved):
	await ScriptHelperFuncsClass.display_text_wait_noise('but my own decrees of fairness prevent me from doing so. If you rid this town of this accursed tower, I could not reward you publicly.  In private, however, is another matter.  I charge you to rid Bywater of this foul cult!\"', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('\"What say you?  Will you accept my plea of help for this fair city?\"', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch(true, 1, 24, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('\"Good!  It\'s settled then.  There is another secret agent of mine that is striving toward a similar goal.  If you cross paths, I decree you to help rather than hinder each other\'s efforts.  Well!  We all have much to do.\"', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('The steward tells you of the armory and asks you to take your pick of equipment.  He also gives you an item. \"Use this magic crown to return to the front gate of our fair castle.  It will work but 3 times so use it only in time of great need.\"', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(0)
	await ScriptHelperFuncsClass.display_text_wait_noise('The steward informs the kings provisioner to allow you to have anything you want from the kings storeroom.  \"You will find the storeroom near the entrance.  Fair thee well.\"', 'message nod.wav')
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 3, 25, 0)
	return
	# end of XAP 22 (with nested expansions)

static func AP4x23y12() : #4 at 23,12
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The town patrol waves you through as they hand you a map showing where you can buy provisions.', 'message nod.wav')
	return

static func AP5x10y14() : #5 at 10,14
	var textRect = UI.ow_hud.textRect
	return ScriptHelperFuncs.get_ap_name_starting_with('AP'+str(2))

static func AP6x41y7() : #6 at 41,7
	var textRect = UI.ow_hud.textRect
	return ScriptHelperFuncs.get_ap_name_starting_with('AP'+str(2))

static func AP7x10y15() : #7 at 10,15
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The corporal of the watch shouts \"Be sure to check in with the Magistrate in the guard house before entering.\"', 'message nod.wav')
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func AP8x9y13() : #8 at 9,13
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You have entered a rather fine tavern filled with only the best citizens of Bywater.  Most of the tables are filled with patrons eating spiced potatoes and engaged in interesting discussions.  You find yourself a table near the back.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_simple_encounter(0)
	return

static func AP9x7y11() : #9 at 7,11
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter a pleasant little shop that seems well stocked.  The shopkeeper smiles and asks you to look around at his fine wares. ', 'message nod.wav')
	GameGlobal.allow_banking(true)
	GameGlobal.currentShop = 'shop_0'
	GameGlobal.allow_money_change(true)
	return

static func AP10x16y3() : #10 at 16,3
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('This is a temple dedicated to Sestuona, goddess of nature.  A portly-looking man wearing a green robe approaches and speaks.  \"Welcome travelers, to this most holy of temples.  If you like, you may partake of our healing skills.\"', 'message nod.wav')
	GameGlobal.allow_banking(true)
	GameGlobal.allow_temple(true)
	ScriptHelperFuncsClass.play_sound('heal.wav', false)
	return

static func AP11x4y13() : #11 at 4,13
	var textRect = UI.ow_hud.textRect
	pass
	return

static func AP12x27y5() : #12 at 27,5
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('This is an old abandoned well.  It looks to be a long ways down.  The bucket and crank are almost rotted out.  This well has not been in use for quite some time.', 'message nod.wav')
	return

static func AP13x26y7() : #13 at 26,7
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You hear the yip of a frightened dog followed by a howl and barking.  A dog appears to be in distress somewhere close by.  Hopefully, someone does not intend to dine on poor man\'s filet mignon tonight.                                          ', 'message nod.wav')
	return

static func AP14x25y6() : #14 at 25,6
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You come upon an inn and cookhouse.  The smell of hot meals and the sounds of good conversation waft to you from inside.   Do you step inside?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch(true, 1, 100, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_simple_encounter(0)
	return

static func AP15x24y9() : #15 at 24,9
	var textRect = UI.ow_hud.textRect
	# This AP teleports to level 6 at 80,42
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(6, 80, 42, 0)
	return

static func AP16x7y6() : #16 at 7,6
	var textRect = UI.ow_hud.textRect
	# This AP teleports to level 6 at 8,1
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(6, 8, 1, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('You have come to the town brothel.  Perfume fills the air and covers any original odor that may come from this former boarding house.  A sign outside the building gives prices for various races and sexes.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('It appears to be well-managed and doing a lot of business.  There is a steady stream of customers going in the front door and another coming out the back.', 'message nod.wav')
	return

static func AP17x10y6() : #17 at 10,6
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You have entered the blacksmith\'s shop.  The smith is hard at work on repairing the bellows.  His face is covered with soot except for a clean streak leading down each cheek.  It would appear he has been crying.                                           ', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('\"Hello.  Good people, what can I do for you today?\"  You ask him where his apprentice is that he must stoop to fixing the bellows.  \"My son was slain several days ago in the Barren mountains.  We found his body defiled by the evil sluk that live there.\"', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('\"I cannot get the King\'s men to rout out these foul vermin, and I do not have the gold to purchase retribution from mercenaries.  All I have is the sweat of my brow, and that buys little justice these days.  You would seem to be of hardy stock.\"', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('If you were to send these foul sluk to the pits that spawned them, I would be eternally grateful.\"  What do you do?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch(false, 1, 14, "Avenge his son", "Wish him luck")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('\"I bid you good day then, for I have much work to do and can ill afford to waste my time telling my problems to every wayward band.\"                                                                                                                     ', 'message nod.wav')
	return

static func AP18x6y43() : #18 at 6,43
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You see a small village in the distance.  It appears to be vacant.  Many of the straw huts have fallen into total decay.  Pieces of broken crockery and cooking utensils lie scattered about.  Whoever lived here seems to have beaten a hasty retreat.', 'message nod.wav')
	return

static func AP19x2y48() : #19 at 2,48
	var textRect = UI.ow_hud.textRect
	GameGlobal.currentSpecialEncounterName = "encounter_0.gd"
	UI.ow_hud.show_special_encounter()
	return

static func AP20x2y50() : #20 at 2,50
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You find the slain bodies of several goblins.  Their bodies have been scattered about the area.  You also see a small pile of what looks to be polished stones.  As you kick the pile around you notice a gem among them.  Do you wish to look for more?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch(false, 1, 15, "Stay", "Leave")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('You search the remains of the cavern and find nothing of interest.', 'message nod.wav')
	return

static func AP21x39y9() : #21 at 39,9
	var textRect = UI.ow_hud.textRect
	return ScriptHelperFuncs.get_ap_name_starting_with('AP'+str(2))

static func AP22x33y18() : #22 at 33,18
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The town patrol waves you through as they hand you a map showing where you can buy provisions.', 'message nod.wav')
	return

static func AP23x6y19() : #23 at 6,19
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('This is an ancient secret passage into the courtyard of castle Anthrax.', 'message nod.wav')
	return

static func AP24x22y14() : #24 at 22,14
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The gate stands unguarded.  A notice from the king is posted.  It reads, \"Stanchion burial lands are closed until further notice.  All those that enter do so of their own accord and at their own risk.\" ', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('The graveyard has fallen into a state of total disrepair.  Most of the graves and crypts have been looted.  The caretakers have not been busy for quite some time.', 'message nod.wav')
	return

static func AP25x16y17() : #25 at 16,17
	var textRect = UI.ow_hud.textRect
	# This AP teleports to level 5 at 21,5
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(5, 21, 5, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('The doors on this crypt are broken as are most in the graveyard.  As you peer in, you happen to see a small crack in the floor.  Your investigation reveals that it is a trap door that leads to a subterranean crypt.', 'message nod.wav')
	return

static func AP26x13y17() : #26 at 13,17
	var textRect = UI.ow_hud.textRect
	# This AP teleports to level 1 at 9,1
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(1, 9, 1, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('You come upon some fresh excavation.  It would seem that someone or something has burrowed up from below.  The tunnel is considerable in size and looks to be frequently used.  You venture inside.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('You descend approximately 60 feet below the surface by means of a well-trod slope.  It would take countless shuffling feet to compact the earth to such a flat and hard surface.  It is likely that you are not alone below the city of Bywater.', 'message nod.wav')
	return

static func AP27x47y5() : #27 at 47,5
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('This is the gate to enter the Spider Tower.  Herein dwells an evil cult bent on total dominance of the world by arachnids and others of their ilk.  The gates are massive, and the walls are guarded by fierce creatures.  Do you wish to attack?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch(true, 0, 0, "", "")
	if not branch.is_empty(): return branch
	GameGlobal.start_battle("Battle_38","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	await ScriptHelperFuncsClass.display_text_wait_noise('You have managed to battle your way past the gate.  Something tells you that the tough battles are yet to come.', 'message nod.wav')
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 27, 18, 0)
	return

static func AP28x47y2() : #28 at 47,2
	var textRect = UI.ow_hud.textRect
	# This AP teleports to level 5 at 81,39
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(5, 81, 39, 0)
	return

static func AP29x38y13() : #29 at 38,13
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You have walked into a tannery.  Many fine quality leather goods are made and sold here.', 'message nod.wav')
	GameGlobal.currentShop = 'shop_0'
	GameGlobal.allow_money_change(true)
	return

static func AP30x2y44() : #30 at 2,44
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('In this hut there is a wounded goblin lying on the floor.  Blood leaks slowly between his fingers as he clutches at his chest.  He sees you and his eyes grow wide in horror.  He topples over dead, his face locked in a horrible grimace.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('You search his body and turn up a map scribbled on a piece of bark.  What it represents, no one will ever know.  As you prepare to leave, you hear a loud thump. A  party of krise storm the village behind you.', 'message nod.wav')
	GameGlobal.minimaps[0][0]=1
	GameGlobal.start_battle("Battle_45","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	await ScriptHelperFuncsClass.display_text_wait_noise('Among the items, you find a sack with personal items belonging to the blacksmith\'s son.  It would seem you have killed the very group who had slain the smith\'s son.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(0)
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(0, 17, 100.0 / 100.0, 0, 0)
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 17, 39, 0)
	return

static func AP31x5y87() : #31 at 5,87
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You burst into the most flamboyant hut in the village.  The goblin king is inside with several of his most prominent warriors.  They jump in front of the king ready to attack.  However, the king barks out a sharp command to call off his dogs of war.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('He speaks in surprisingly good common, \"Why you come my land.  Me no have war with human king.  We no raid human village.  We only have war with krise sluk.  We fight sluk well.  We good warriors.  Why you no like goblin?\"', 'message nod.wav')
	await ScriptHelperFuncsClass.display_simple_encounter(0)
	return

static func AP32x24y89() : #32 at 24,89
	var textRect = UI.ow_hud.textRect
	# This AP teleports to level 0 at 24,88
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(0, 24, 88, 0)
	await ScriptHelperFuncsClass.display_simple_encounter(0)
	return

static func AP33x20y89() : #33 at 20,89
	var textRect = UI.ow_hud.textRect
	# This AP teleports to level 1 at 19,35
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(1, 19, 35, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('This passage leads to the underdark.', 'message nod.wav')
	return

static func AP34x6y18() : #34 at 6,18
	var textRect = UI.ow_hud.textRect
	pass
	return

static func AP35x77y37() : #35 at 77,37
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You find a cave behind a stone outcropping.  It is practically invisible unless you\'re right in front of the opening. This passage has lain hidden for ages.  It winds east through a jagged crevasse.', 'message nod.wav')
	return

static func AP36x79y37() : #36 at 79,37
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You step into a large valley.  It is completely shut out from the outside world by high peaks.  Towards the east you can make out a large cave in the distance.', 'message nod.wav')
	return

static func AP37x89y37() : #37 at 89,37
	var textRect = UI.ow_hud.textRect
	# This AP teleports to level 3 at 0,7
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(3, 0, 7, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('This is the cave that leads to the sunken city of Waterford.', 'message nod.wav')
	return

static func AP38x88y13() : #38 at 88,13
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('This is the shack belonging to the village chief.  His features are clouded by a worried expression.  During your conversation, you learn that his pregnant daughter is missing.  \"If you find my daughter, I will reward you.\"  He sends you on your way.', 'message nod.wav')
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 38, 32, 0)
	return

static func AP39x39y56() : #39 at 39,56
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('Just as Ranthog had promised, you find a sizable treasure larder.  Most of this stuff looks incredibly valuable.  Ranthog must have had no idea how valuable it was, or he would never have given it away.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(0)
	return

static func AP40x57y62() : #40 at 57,62
	var textRect = UI.ow_hud.textRect
	# This AP teleports to level 2 at 12,20
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(2, 12, 20, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('You notice a small cave opening along the shoreline.  A putrid smell pours out of the entrance. You suspect some creature must be living down there in its own offal.  Do you enter?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	return

static func AP41x58y58() : #41 at 58,58
	var textRect = UI.ow_hud.textRect
	# This AP teleports to level 2 at 19,13
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(2, 19, 13, 0)
	return

static func AP42x49y85() : #42 at 49,85
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The river flows into a large cave.  Shortly after entering the cave, the river disappears underground and becomes  subterranean.  The cave is not completely without interest.  The creatures that attack you can attest to this!', 'message nod.wav')
	GameGlobal.start_battle("Battle_95","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	return

static func AP43x89y88() : #43 at 89,88
	var textRect = UI.ow_hud.textRect
	# This AP teleports to level 2 at 30,4
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(2, 30, 4, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('A river emerges from below and flows out of the cave entrance.  You can smell the stench of some creature living inside.  Towards the back of the main chamber, there is a whole network of caves leading in various directions.  Do you enter?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	return

static func AP44x16y18() : #44 at 16,18
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The gate stands unguarded.  A notice from the king is posted.  It reads, \"Stanchion burial lands are closed until further notice.  All those that enter do so of their own accord and at their own risk.\" ', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('The graveyard has fallen into a state of total disrepair.  Most of the graves and crypts have been looted.  The caretakers have not been busy for quite some time.', 'message nod.wav')
	return

static func AP45x11y16() : #45 at 11,16
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The gate stands unguarded.  A notice from the king is posted.  It reads, \"Stanchion burial lands are closed until further notice.  All those that enter do so of their own accord and at their own risk.\" ', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('The graveyard has fallen into a state of total disrepair.  Most of the graves and crypts have been looted.  The caretakers have not been busy for quite some time.', 'message nod.wav')
	return

static func AP46x24y14() : #46 at 24,14
	var textRect = UI.ow_hud.textRect
	return ScriptHelperFuncs.get_ap_name_starting_with('AP'+str(2))

static func AP47x89y69() : #47 at 89,69
	var textRect = UI.ow_hud.textRect
	# This AP teleports to level 2 at 1,35
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(2, 1, 35, 0)
	return

static func AP48x50y4() : #48 at 50,4
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You find a secret passage into the courtyard of the spider tower.', 'message nod.wav')
	# Needs rework: sound file 'earth shake.wav' needs to be converted to sfx_id
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(0, 48, 3, 0)
	return

static func AP49x72y13() : #49 at 72,13
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You see a large iron door set into the mountain.  Inscribed into the steel of the door are strange runes.  They are an ancient but familiar script.  It tells of a great evil that has been banished beyond the mighty portal.  Do you open it?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	ScriptHelperFuncsClass.play_sound('door slam.wav', true)
	await ScriptHelperFuncsClass.display_text_wait_noise('A blast of stale air pours forth.  Along with a vile creature.', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound('wind.wav', true)
	GameGlobal.start_battle("Battle_148","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	await ScriptHelperFuncsClass.display_text_wait_noise('Strange footprints trail off to the east.  Something else would appear to live deeper within the cave.', 'message nod.wav')
	return

static func AP50x52y38() : #50 at 52,38
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You find the remains of an old grave.  It has been dug up and pilfered.  The bones of the buried lie about the area.  Do you bury the bones or leave them where they lay?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch(true, 0, 0, "Bury the bones", "Leave them be")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('A whisper from nowhere thanks you.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(0)
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func AP51x4y24() : #51 at 4,24
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter the gaming arena.  The master of the games asks if you wish to pit your skills in combat against dire creatures for a wager.  Do you wish to enter the games?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch(true, 0, 0, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_simple_encounter(0)
	return

static func AP52x7y24() : #52 at 7,24
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('A sign above the front gate reads,  \"Official Sanctioned Gaming Arena.\"  From inside you here the cheers of an excited crowd and the moans of the wounded and dying.', 'message nod.wav')
	return

static func AP53x17y21() : #53 at 17,21
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You find the small cave that leads to the stable.  You creep inside to see a large corral of beastmen.  They number a  baker\'s dozen.  This won\'t be easy.  Do you wish to attack these vermin now?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch(true, 0, 0, "Attack now", "Wait a while")
	if not branch.is_empty(): return branch
	GameGlobal.start_battle("Battle_114","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	await ScriptHelperFuncsClass.display_text_wait_noise('Having completed your handiwork, the man contacts you as planned.  He hands you a sizable leather pouch.  \"Here is the price as we agreed.  I have given ye a little something extra for your trouble.\"', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(0)
	return

static func AP54x65y88() : #54 at 65,88
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You step into a rather large cave only to find 8 eyes staring at you from 4 thick necks.', 'message nod.wav')
	GameGlobal.start_battle("Battle_57","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	return

static func AP55x89y79() : #55 at 89,79
	var textRect = UI.ow_hud.textRect
	# This AP teleports to level 1 at 5,63
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(1, 5, 63, 0)
	return

static func AP56x83y78() : #56 at 83,78
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You see the footprints of some two footed creatures with clawed feet.  Blood is smeared from floor to ceiling.  The bodies of several farmers have been ripped limb from limb and partially eaten.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('A bloody trail leads from the shack to the east.  Someone has been dragged from the shack kicking and screaming.', 'message nod.wav')
	return

static func AP57x79y79() : #57 at 79,79
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('As you walk in the small shack you witness a scene out of your worst nightmares.  Nailed to the walls are the half eaten corpses of a farmer and his wife.  From the way the blood has pooled at their feet it is obvious they were eaten alive.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('On a small table lies the remains of a small 10 year old girl.  Her arms and feet have been nailed to the table in order to make easy pickings for whatever has chosen to dine on her.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('A bloody trail leads from the shack to the east.  Someone has been dragged from the shack kicking and screaming.', 'message nod.wav')
	return

static func AP58x45y1() : #58 at 45,1
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You spot a small cave in the side of the mountain.  When you proceed inside to investigate the source of a strong acrid odor you are confronted by the true ruler of the Spider Tower - a powerful spider queen.', 'message nod.wav')
	# Needs rework: jmp_battle - probably needs await ScriptHelperFuncsClass.start_battle_in_range(174, 0, 0, '', 0)
	# Needs rework: change_rect - needs manual implementation as described in function declarations
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(5, 94, 100.0 / 100.0, 0, 0)
	ScriptHelperFuncsClass.change_map_tile_Divinity(0, 48, 2, 155, "land")
	ScriptHelperFuncsClass.play_sound('spell launch 1.wav', false)
	ScriptHelperFuncsClass.change_map_tile_Divinity(0, 48, 1, 155, "land")
	# XAP 156 content (recursively resolved):
	ScriptHelperFuncsClass.play_sound('spell launch 4.wav', false)
	ScriptHelperFuncsClass.change_map_tile_Divinity(0, 47, 1, 155, "land")
	ScriptHelperFuncsClass.play_sound('spell launch 3.wav', false)
	ScriptHelperFuncsClass.change_map_tile_Divinity(0, 47, 2, 155, "land")
	await ScriptHelperFuncsClass.display_text_wait_noise('With the Widow of the Web banished from the Realmz, her powers to keep the temple also in the Realmz fails.  The Widow will have to face Vixies and explain her failure to achieve victory over a few puny mortals.', 'message nod.wav')
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(5, 93, 0.0 / 100.0, 0, 0)
	# end of XAP 156 (with nested expansions)
	return

static func AP59x83y4() : #59 at 83,4
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You see several dozen dead orcs strewn about the cave.  Most of the bodies have been nibbled on somewhat by some creature that must be quiet large.  The cave continues off to the back.  You hear heavy breathing and the shuffling of great feet.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Do you wish to move to the back of the cave to investigate?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('You discover that this cave is inhabited by a mated pair of trolls.  Though you have approached with the stealth of a clemidian devil cat, the trolls can smell you as if you had sacks of bacon strapped to your backs.  Trolls like bacon!!!', 'message nod.wav')
	GameGlobal.start_battle("Battle_169","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	return

static func AP60x83y1() : #60 at 83,1
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You discover what can only be described as a nest for lack of a better word.  The bodies of even more orcs are heaped in mounds about the cave.  Beasts such as trolls need to eat a lot.  Why so many look to be hardly touched is a mystery.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('As you continue to look around for anything of interest you hear the wail of a baby troll coming from the west.', 'message nod.wav')
	return

static func AP61x81y1() : #61 at 81,1
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('In this end of the cave is a very frightened young troll. The babe must have witnessed you killing its parents.  Its eyes bulge like saucers as it looks at you in total fear. Suddenly the babe begins to relax.  The fear subsides for an unknown reason.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Unknown, that is, until you look behind you.  The babe\'s brothers and sisters have stalked up on you.  They charge you in an attempt to revenge their fallen parents and save their baby brother.', 'message nod.wav')
	GameGlobal.start_battle("Battle_170","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	await ScriptHelperFuncsClass.display_text_wait_noise('During the melee the babe has disappeared.  The remainder of the cave has nothing of interest.', 'message nod.wav')
	return

static func AP62x73y13() : #62 at 73,13
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('As you travel deeper into the cavern you find that the skeletal giant had a trio of rather nasty pets.', 'message nod.wav')
	GameGlobal.start_battle("Battle_171","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func AP63x26y41() : #63 at 26,41
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('As you are journey through a grove of oaks, large snakes drop from the branches.  They intend to make an easy meal of you.', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound('drop item.wav', true)
	ScriptHelperFuncsClass.play_sound('drop item.wav', true)
	ScriptHelperFuncsClass.play_sound('drop item.wav', true)
	GameGlobal.start_battle("Battle_175","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	return

static func AP64x30y26() : #64 at 30,26
	var textRect = UI.ow_hud.textRect
	return

static func AP65x27y25() : #65 at 27,25
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The cave dead ends here.  Chained on the wall are the remains of a hill giant that has been partially devoured.  You are unable to tell if the body parts were consumed before being chained to the wall or if it simply fell prey to scavengers.', 'message nod.wav')
	return

static func AP66x27y24() : #66 at 27,24
	var textRect = UI.ow_hud.textRect
	return

static func AP67x29y24() : #67 at 29,24
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You emerge into the musty confines of a large cavern.  It would appear the hapless giant was to be milk and cookies for the beast resting here.  Resting that is, until now!', 'message nod.wav')
	GameGlobal.start_battle("Battle_176","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(0, 68, -1.0 / 100.0, 0, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('You find a sizable cache of wealth and a small sack with a group of 4 daggers.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(0)
	return

static func AP68x27y21() : #68 at 27,21
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('Your skin prickles, and your hair stands completely on end as if you are rubbing your feet furiously on a bearskin rug while wearing wool socks.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('There must be a powerful source of electrical energy nearby.', 'message nod.wav')
	return

static func AP69x5y27() : #69 at 5,27
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.change_map_tile_Divinity(0, 3, 28, 193, "land")
	await ScriptHelperFuncsClass.display_text_wait_noise('You have found your way to the alley behind the combat arena.  You see a large shack in the distance that you had not seen before.', 'message nod.wav')
	return

static func AP70x4y27() : #70 at 4,27
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('As you approach the shack, a man wearing a leather harness exits from the hut and approaches.  \"What are you doing here?  This area is off limits.\"  He turns to go back inside when suddenly a huge creature bursts from the shack.', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound('door slam.wav', true)
	ScriptHelperFuncsClass.play_sound('glowl 3.wav', true)
	await ScriptHelperFuncsClass.display_text_wait_noise('The creature bears the remains of shackles.  Blood-soaked chains, wrapped about its fists, create crude but effective weapons.  The man in the leather harness yells, \"Look out!  It\'s loose!\" In hot pursuit, several armed men storm out the door.', 'angry mob.wav')
	GameGlobal.start_battle("Battle_177","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	await ScriptHelperFuncsClass.display_text_wait_noise('You discover a scroll inside the shack.  It contains orders that the corporal train the troll to fight in the arena.  Bad idea!', 'message nod.wav')
	return

static func AP71x75y53() : #71 at 75,53
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('Holes have been ripped into the thatched roof of an abandoned shack.  Bloodstains on the floor bear witness that the former occupant suffered a violent death.', 'message nod.wav')
	# Needs rework: Random chance should use ScriptHelperFuncsClass.branch_percent_chance_divinity(33, whatdo, type, number, lineskip) with var branch check
	return

static func AP72x65y87() : #72 at 65,87
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('Large piles of bones litter the cave\'s entrance to the south.', 'message nod.wav')
	return

static func AP73x42y88() : #73 at 42,88
	var textRect = UI.ow_hud.textRect
	return

static func AP74x46y87() : #74 at 46,87
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The creatures that caused the demise of the former occupant are now back searching for more food.', 'message nod.wav')
	GameGlobal.start_battle("Battle_182","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	return

static func AP75x13y10() : #75 at 13,10
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You notice a small wooden sign near the window.  It\'s so old and faded as to be almost illegible.  It reads, \"Madam Osswel\'s Specialty Shop.\"  It appears to be closed.                                                     ', 'message nod.wav')
	return

static func AP76x2y2() : #76 at 2,2
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.display_picture_file('0.png')
	await ScriptHelperFuncsClass.display_text_wait_noise('Welcome to \"The City of Bywater\", a scenario for use with the Realmz Scenario Driver.  If you enjoy playing Realmz and would like to see more scenarios developed, please support us by sending in your registration fee.', 'heal.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Once you have registered this copy of Realmz, you will be able to play the entire scenario.  This scenario is very loose.  It does not have a strong plot line.  You can adventure where you want for as long as you want.', 'heal.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Once you have registered this copy of Realmz, you will also be able to play test other scenarios BEFORE having to register them.  The fee for each additional scenario are $13 each.  For information on how to register, see chapter 3 of the Realmz Manual.', 'hallelujah.wav')
	# XAP 73 content (recursively resolved):
	await ScriptHelperFuncsClass.display_text_wait_noise('Other scenarios utilize the capabilities of the Realmz scenario driver to a greater extent.  These scenarios feature a definite plot line, new monsters, new magical items and more dangerous encounters.', 'message nod.wav')
	# end of XAP 73 (with nested expansions)
	return

static func AP77x18y9() : #77 at 18,9
	var textRect = UI.ow_hud.textRect
	# This AP teleports to level 5 at 52,3
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(5, 52, 3, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter a massive building.  It appears to be an endless maze of hallways and corridors.', 'message nod.wav')
	return

static func AP78x2y28() : #78 at 2,28
	var textRect = UI.ow_hud.textRect
	var nextap : String = await ScriptHelperFuncs.branch_on_quest_Divinity(20, 0, 0, 100, 0)
	if not nextap.is_empty() :
		return nextap
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter the slave prison.  A potbellied Corporal Sampson is slumped over a shaky table.  He\'s slept through the entire ordeal that just took place outside.  The smell of elderberry wine permeates his clothes.  You try to rouse him to collect your fee.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Sampson awakens with a jolt and sits up quickly.  An offensive stream of drool has slid across his left cheek.  Heavy bags underneath his eyes imply he hasn\'t slept well lately.  \"What\'s this?  Can a man have no rest?\" You promptly display your contract.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Sampson swiftly scans the contract with disbelief.  \"I see that you have been promised the sum of 100 gold Zelots.  Well, there is not that many gold Zelots in all of Bywater!  You may be very brave, but you are also very gullible!\"', 'talk 2.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('\"I can offer you a few silver for your trouble.  That is the best I can do.\"  He begins to search his belongings for a few paltry coins.  Suddenly, a nasty brawl breaks out between two of the beasts. ', 'message nod.wav')
	# XAP 82 content (recursively resolved):
	await ScriptHelperFuncsClass.display_text_wait_noise('During the battle with the mad troll, one of the troll\'s hands had been severed.  One of your charges hungrily snatched it up to eat.  However, another beast greedily attempted to steal the tender morsel.  This attempt has provoked an all-out brawl.', 'growl 1.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Before you are able to get the situation under control, the beasts erupt explosively into a convulsing ball of fur and slashing claws.  You are immediately  pulled into the fray.', 'message nod.wav')
	GameGlobal.start_battle("Battle_206","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	await ScriptHelperFuncsClass.display_simple_encounter(0)
	# end of XAP 82 (with nested expansions)
	return

static func AP79x34y2() : #79 at 34,2
	var textRect = UI.ow_hud.textRect
	# This AP teleports to level 4 at 2,25
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(4, 2, 25, 0)
	return

static func AP80x7y21() : #80 at 7,21
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You are just about to enter the king\'s private gardens.  Someone has posted a message at the front gate.  \"Closed until further notice.  Do not enter under any circumstances.  You have been warned!\"', 'message nod.wav')
	var nextap : String = await ScriptHelperFuncs.branch_on_quest_Divinity(32, 0, 0, 100, 0)
	if not nextap.is_empty() :
		return nextap
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter the king\'s gardens and begin to stalk for signs of the rabid beast.  Several  plants have been uprooted or mutilated.  You hear something up ahead on your right.  There are indications that the beast may not be alone.  Do you wish to continue?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	GameGlobal.start_battle("Battle_209","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	ScriptHelperFuncsClass.set_quest_id_flag_Divinity(0)
	return

static func AP81x5y5() : #81 at 5,5
	var textRect = UI.ow_hud.textRect
	pass
	return

static func AP82x6y3() : #82 at 6,3
	var textRect = UI.ow_hud.textRect
	var branch : String = ScriptHelperFuncs.branch_NPC_in_party_Divinity("Vodalian", 0, 1, 104, 0)
	if not branch.is_empty() :
		return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('A seedy looking group of gnomes are sitting at a vomit stained table.  They are swilling cheap grog from a clay jug.  They seem more concerned with getting more than their share of the wine and pay you little attention.', 'talk 2.wav')
	return

static func AP83x89y48() : #83 at 89,48
	var textRect = UI.ow_hud.textRect
	# Needs rework: set_dungeon - function not described in declarations, needs manual implementation
	return

static func AP84x71y78() : #84 at 71,78
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('big splat.wav', true)
	ScriptHelperFuncsClass.play_sound('big splat.wav', true)
	await ScriptHelperFuncsClass.display_text_wait_noise('You plow through thick clumps of fungus. Movement flashes at your side.  You halt and warily eye the surroundings.  A constant, steady rustling seems to come from all directions.  You feel quite on edge.  There\'s something odd about these plants.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Huge fungus-like plants grow throughout the area.  Each fungus is surrounded by small podlings attached by long vines.  The podlings slither in your direction.', 'message nod.wav')
	GameGlobal.start_battle("Battle_191","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	await ScriptHelperFuncsClass.display_text_wait_noise('A faint smell begins to permeate the air. It slowly gains strength.  You toy with the idea of capturing one of the creatures.  A wizard would pay dearly to use such a  plant in experiments.  The nasty odor hastily devours this thought.', 'message nod.wav')
	return

static func AP85x73y76() : #85 at 73,76
	var textRect = UI.ow_hud.textRect
	return ScriptHelperFuncs.get_ap_name_starting_with('AP'+str(0))

static func AP86x68y77() : #86 at 68,77
	var textRect = UI.ow_hud.textRect
	return ScriptHelperFuncs.get_ap_name_starting_with('AP'+str(0))

static func AP87x69y79() : #87 at 69,79
	var textRect = UI.ow_hud.textRect
	return ScriptHelperFuncs.get_ap_name_starting_with('AP'+str(0))

static func AP88x72y79() : #88 at 72,79
	var textRect = UI.ow_hud.textRect
	return ScriptHelperFuncs.get_ap_name_starting_with('AP'+str(0))

static func AP89x70y76() : #89 at 70,76
	var textRect = UI.ow_hud.textRect
	return ScriptHelperFuncs.get_ap_name_starting_with('AP'+str(0))

static func AP90x4y36() : #90 at 4,36
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('underwater laser.wav', true)
	await ScriptHelperFuncsClass.display_text_wait_noise('Open grassland is marred by a dark, gaping pit.  Muted bubbling fizzles below.  A large log lies near the pit\'s edge.  It might be possible to use it as a crude, makeshift ladder.  Do you push the log in and attempt to enter the pit?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch(true, 0, 0, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('You start to slowly clamber down the log.  With a heavy thump, the log shifts to the right and begins to shake with violent force.  Clinging for dear life, you scramble your way back up out of the pit.  Massive slime creatures slither up the log.', 'message nod.wav')
	GameGlobal.start_battle("Battle_218","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	return

static func AP91x6y3() : #91 at 6,3
	var textRect = UI.ow_hud.textRect
	pass
	return

static func AP92x6y3() : #92 at 6,3
	var textRect = UI.ow_hud.textRect
	pass
	return

static func AP93x6y3() : #93 at 6,3
	var textRect = UI.ow_hud.textRect
	pass
	return

static func AP94x88y12() : #94 at 88,12
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('A small orcish dwelling that belongs to the local witch doctor.  The owner gives you a toothless grin and offers to sell you a few potions and trinkets.', 'message nod.wav')
	GameGlobal.currentShop = 'shop_0'
	GameGlobal.allow_money_change(true)
	return
