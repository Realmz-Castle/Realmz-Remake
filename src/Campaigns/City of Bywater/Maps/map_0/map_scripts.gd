#Map test Script generated from old AP format

static func _on_map_load(_map) :
	print("mapscript _on_map_load() !!! ")
	# Add any initialization code here

static func AP0x9y17() : #0 at 9,17
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter the guard house outside the main gate to Castle Anthrax.  Several guards keep a wary eye on you as you approach the head Magistrate.  He is a stately looking man in fine robes.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_simple_encounter_Divinity(0)
	return

static func AP1x8y16() : #1 at 8,16
	await ScriptHelperFuncsClass.display_text_wait_noise('You approach the main gate to Castle Anthrax.  As you near, the gate guard bars your path and asks to see your formal invitation.', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.branch_item_possession_divinity(990, 0, 0, 1, 2)
	if not branch.is_empty(): return branch
	return

static func AP2x6y16() : #2 at 6,16
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter the barracks of the town guard.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('As you enter, you hear sharp words being exchanged from two high-ranking men.  It would seem the guardsmen are split into two factions.  One faction appears to be headed by a man by the name of Haikur, the other by a man named Thurfur.', 'message nod.wav')
	if not ScriptHelperFuncsClass.does_party_have_item_named("Invitation") :
		return "XAP4"
	await ScriptHelperFuncsClass.display_text_wait_noise('Before you catch too much of the argument, the barracks falls silent as all heads turn to you.  Thurfur comes over and demands to know your business for being there.  Not satisfied with your answer, he orders you to leave.  Do you leave?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 1, 5, "", "")
	if not branch.is_empty(): return branch
	return

static func AP3x4y17() : #3 at 4,17
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
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 1, 24, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('\"Good!  It\'s settled then.  There is another secret agent of mine that is striving toward a similar goal.  If you cross paths, I decree you to help rather than hinder each other\'s efforts.  Well!  We all have much to do.\"', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('The steward tells you of the armory and asks you to take your pick of equipment.  He also gives you an item. \"Use this magic crown to return to the front gate of our fair castle.  It will work but 3 times so use it only in time of great need.\"', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(0)
	await ScriptHelperFuncsClass.display_text_wait_noise('The steward informs the kings provisioner to allow you to have anything you want from the kings storeroom.  \"You will find the storeroom near the entrance.  Fair thee well.\"', 'message nod.wav')
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 3, 25, 0)
	return
	# end of XAP 22 (with nested expansions)

static func AP4x23y12() : #4 at 23,12
	await ScriptHelperFuncsClass.display_text_wait_noise('The town patrol waves you through as they hand you a map showing where you can buy provisions.', 'message nod.wav')
	return

static func AP5x10y14() : #5 at 10,14
	return ScriptHelperFuncsClass.get_ap_name_starting_with('AP'+str(4))

static func AP6x41y7() : #6 at 41,7
	return ScriptHelperFuncsClass.get_ap_name_starting_with('AP'+str(2))

static func AP7x10y15() : #7 at 10,15
	await ScriptHelperFuncsClass.display_text_wait_noise('The corporal of the watch shouts \"Be sure to check in with the Magistrate in the guard house before entering.\"', 'message nod.wav')
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func AP8x9y13() : #8 at 9,13
	await ScriptHelperFuncsClass.display_text_wait_noise('You have entered a rather fine tavern filled with only the best citizens of Bywater.  Most of the tables are filled with patrons eating spiced potatoes and engaged in interesting discussions.  You find yourself a table near the back.', 'message nod.wav')
	return await ScriptHelperFuncsClass.display_simple_encounter_Divinity(3)

static func AP9x7y11() : #9 at 7,11
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter a pleasant little shop that seems well stocked.  The shopkeeper smiles and asks you to look around at his fine wares. ', 'message nod.wav')
	GameGlobal.allow_banking(true)
	GameGlobal.currentShop = 'shop_1'
	GameGlobal.allow_money_change(true)
	return

static func AP10x16y3() : #10 at 16,3
	await ScriptHelperFuncsClass.display_text_wait_noise('This is a temple dedicated to Sestuona, goddess of nature.  A portly-looking man wearing a green robe approaches and speaks.  \"Welcome travelers, to this most holy of temples.  If you like, you may partake of our healing skills.\"', 'message nod.wav')
	GameGlobal.allow_banking(true)
	ScriptHelperFuncsClass.enable_default_temple(1.00)
	ScriptHelperFuncsClass.play_sound('heal.wav', false)
	return

static func AP11x4y13() : #11 at 4,13
	pass
	return

static func AP12x27y5() : #12 at 27,5
	await ScriptHelperFuncsClass.display_text_wait_noise('This is an old abandoned well.  It looks to be a long ways down.  The bucket and crank are almost rotted out.  This well has not been in use for quite some time.', 'message nod.wav')
	return

static func AP13x26y7() : #13 at 26,7
	await ScriptHelperFuncsClass.display_text_wait_noise('You hear the yip of a frightened dog followed by a howl and barking.  A dog appears to be in distress somewhere close by.  Hopefully, someone does not intend to dine on poor man\'s filet mignon tonight.                                          ', 'message nod.wav')
	return

static func AP14x25y6() : #14 at 25,6
	await ScriptHelperFuncsClass.display_text_wait_noise('You come upon an inn and cookhouse.  The smell of hot meals and the sounds of good conversation waft to you from inside.   Do you step inside?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 1, 100, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_simple_encounter_Divinity(0)
	return

static func AP15x24y9() : #15 at 24,9
	# This AP teleports to level 6 at 80,42
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(6, 80, 42, 0)
	return

static func AP16x7y6() : #16 at 7,6
	# This AP teleports to level 6 at 8,1
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(6, 8, 1, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('You have come to the town brothel.  Perfume fills the air and covers any original odor that may come from this former boarding house.  A sign outside the building gives prices for various races and sexes.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('It appears to be well-managed and doing a lot of business.  There is a steady stream of customers going in the front door and another coming out the back.', 'message nod.wav')
	return

static func AP17x10y6() : #17 at 10,6
	await ScriptHelperFuncsClass.display_text_wait_noise('You have entered the blacksmith\'s shop.  The smith is hard at work on repairing the bellows.  His face is covered with soot except for a clean streak leading down each cheek.  It would appear he has been crying.                                           ', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('\"Hello.  Good people, what can I do for you today?\"  You ask him where his apprentice is that he must stoop to fixing the bellows.  \"My son was slain several days ago in the Barren mountains.  We found his body defiled by the evil sluk that live there.\"', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('\"I cannot get the King\'s men to rout out these foul vermin, and I do not have the gold to purchase retribution from mercenaries.  All I have is the sweat of my brow, and that buys little justice these days.  You would seem to be of hardy stock.\"', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('If you were to send these foul sluk to the pits that spawned them, I would be eternally grateful.\"  What do you do?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(false, 1, 14, "Avenge his son", "Wish him luck")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('\"I bid you good day then, for I have much work to do and can ill afford to waste my time telling my problems to every wayward band.\"                                                                                                                     ', 'message nod.wav')
	return

static func AP18x6y43() : #18 at 6,43
	await ScriptHelperFuncsClass.display_text_wait_noise('You see a small village in the distance.  It appears to be vacant.  Many of the straw huts have fallen into total decay.  Pieces of broken crockery and cooking utensils lie scattered about.  Whoever lived here seems to have beaten a hasty retreat.', 'message nod.wav')
	return

static func AP19x2y48() : #19 at 2,48
	GameGlobal.currentSpecialEncounterName = "encounter_0.gd"
	UI.ow_hud.show_special_encounter()
	return

static func AP20x2y50() : #20 at 2,50
	await ScriptHelperFuncsClass.display_text_wait_noise('You find the slain bodies of several goblins.  Their bodies have been scattered about the area.  You also see a small pile of what looks to be polished stones.  As you kick the pile around you notice a gem among them.  Do you wish to look for more?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(false, 1, 15, "Stay", "Leave")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('You search the remains of the cavern and find nothing of interest.', 'message nod.wav')
	return

static func AP21x39y9() : #21 at 39,9
	return ScriptHelperFuncsClass.get_ap_name_starting_with('AP'+str(2))

static func AP22x33y18() : #22 at 33,18
	await ScriptHelperFuncsClass.display_text_wait_noise('The town patrol waves you through as they hand you a map showing where you can buy provisions.', 'message nod.wav')
	return

static func AP23x6y19() : #23 at 6,19
	await ScriptHelperFuncsClass.display_text_wait_noise('This is an ancient secret passage into the courtyard of castle Anthrax.', 'message nod.wav')
	return

static func AP24x22y14() : #24 at 22,14
	await ScriptHelperFuncsClass.display_text_wait_noise('The gate stands unguarded.  A notice from the king is posted.  It reads, \"Stanchion burial lands are closed until further notice.  All those that enter do so of their own accord and at their own risk.\" ', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('The graveyard has fallen into a state of total disrepair.  Most of the graves and crypts have been looted.  The caretakers have not been busy for quite some time.', 'message nod.wav')
	return

static func AP25x16y17() : #25 at 16,17
	# This AP teleports to level 5 at 21,5
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(5, 21, 5, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('The doors on this crypt are broken as are most in the graveyard.  As you peer in, you happen to see a small crack in the floor.  Your investigation reveals that it is a trap door that leads to a subterranean crypt.', 'message nod.wav')
	return

static func AP26x13y17() : #26 at 13,17
	# This AP teleports to level 1 at 9,1
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(1, 9, 1, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('You come upon some fresh excavation.  It would seem that someone or something has burrowed up from below.  The tunnel is considerable in size and looks to be frequently used.  You venture inside.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('You descend approximately 60 feet below the surface by means of a well-trod slope.  It would take countless shuffling feet to compact the earth to such a flat and hard surface.  It is likely that you are not alone below the city of Bywater.', 'message nod.wav')
	return

static func AP27x47y5() : #27 at 47,5
	await ScriptHelperFuncsClass.display_text_wait_noise('This is the gate to enter the Spider Tower.  Herein dwells an evil cult bent on total dominance of the world by arachnids and others of their ilk.  The gates are massive, and the walls are guarded by fierce creatures.  Do you wish to attack?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 0, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.start_battle_in_range(38, 38, 30000, "", 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('You have managed to battle your way past the gate.  Something tells you that the tough battles are yet to come.', 'message nod.wav')
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 27, 18, 0)
	return

static func AP28x47y2() : #28 at 47,2
	# This AP teleports to level 5 at 81,39
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(5, 81, 39, 0)
	return

static func AP29x38y13() : #29 at 38,13
	await ScriptHelperFuncsClass.display_text_wait_noise('You have walked into a tannery.  Many fine quality leather goods are made and sold here.', 'message nod.wav')
	GameGlobal.currentShop = 'shop_0'
	GameGlobal.allow_money_change(true)
	return

static func AP30x2y44() : #30 at 2,44
	await ScriptHelperFuncsClass.display_text_wait_noise('In this hut there is a wounded goblin lying on the floor.  Blood leaks slowly between his fingers as he clutches at his chest.  He sees you and his eyes grow wide in horror.  He topples over dead, his face locked in a horrible grimace.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('You search his body and turn up a map scribbled on a piece of bark.  What it represents, no one will ever know.  As you prepare to leave, you hear a loud thump. A  party of krise storm the village behind you.', 'message nod.wav')
	GameGlobal.minimaps[0][0]=1
	await ScriptHelperFuncsClass.start_battle_in_range(45, 45, 10136, "", 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('Among the items, you find a sack with personal items belonging to the blacksmith\'s son.  It would seem you have killed the very group who had slain the smith\'s son.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(0)
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(0, 17, 100.0 / 100.0, 0, 0)
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 17, 39, 0)
	return

static func AP31x5y87() : #31 at 5,87
	await ScriptHelperFuncsClass.display_text_wait_noise('You burst into the most flamboyant hut in the village.  The goblin king is inside with several of his most prominent warriors.  They jump in front of the king ready to attack.  However, the king barks out a sharp command to call off his dogs of war.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('He speaks in surprisingly good common, \"Why you come my land.  Me no have war with human king.  We no raid human village.  We only have war with krise sluk.  We fight sluk well.  We good warriors.  Why you no like goblin?\"', 'message nod.wav')
	await ScriptHelperFuncsClass.display_simple_encounter_Divinity(0)
	return

static func AP32x24y89() : #32 at 24,89
	# This AP teleports to level 0 at 24,88
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(0, 24, 88, 0)
	await ScriptHelperFuncsClass.display_simple_encounter_Divinity(0)
	return

static func AP33x20y89() : #33 at 20,89
	# This AP teleports to level 1 at 19,35
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(1, 19, 35, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('This passage leads to the underdark.', 'message nod.wav')
	return

static func AP34x6y18() : #34 at 6,18
	pass
	return

static func AP35x77y37() : #35 at 77,37
	await ScriptHelperFuncsClass.display_text_wait_noise('You find a cave behind a stone outcropping.  It is practically invisible unless you\'re right in front of the opening. This passage has lain hidden for ages.  It winds east through a jagged crevasse.', 'message nod.wav')
	return

static func AP36x79y37() : #36 at 79,37
	await ScriptHelperFuncsClass.display_text_wait_noise('You step into a large valley.  It is completely shut out from the outside world by high peaks.  Towards the east you can make out a large cave in the distance.', 'message nod.wav')
	return

## This AP teleports to level 3 at 0,7
static func AP37x89y37() : #37 at 89,37
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(3, 0, 7, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('This is the cave that leads to the sunken city of Waterford.', 'message nod.wav')
	return

static func AP38x88y13() : #38 at 88,13
	await ScriptHelperFuncsClass.display_text_wait_noise('This is the shack belonging to the village chief.  His features are clouded by a worried expression.  During your conversation, you learn that his pregnant daughter is missing.  \"If you find my daughter, I will reward you.\"  He sends you on your way.', 'message nod.wav')
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 38, 32, 0)
	return

static func AP39x39y56() : #39 at 39,56
	await ScriptHelperFuncsClass.display_text_wait_noise('Just as Ranthog had promised, you find a sizable treasure larder.  Most of this stuff looks incredibly valuable.  Ranthog must have had no idea how valuable it was, or he would never have given it away.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(0)
	return

## This AP teleports to level 2 at 12,20
static func AP40x57y62() : #40 at 57,62
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(2, 12, 20, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('You notice a small cave opening along the shoreline.  A putrid smell pours out of the entrance. You suspect some creature must be living down there in its own offal.  Do you enter?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	return

## This AP teleports to level 2 at 19,13
static func AP41x58y58() : #41 at 58,58
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(2, 19, 13, 0)
	return

static func AP42x49y85() : #42 at 49,85
	await ScriptHelperFuncsClass.display_text_wait_noise('The river flows into a large cave.  Shortly after entering the cave, the river disappears underground and becomes  subterranean.  The cave is not completely without interest.  The creatures that attack you can attest to this!', 'message nod.wav')
	await ScriptHelperFuncsClass.start_battle_in_range(95, 95, 30003, "", 0)
	return

# This AP teleports to level 2 at 30,4
static func AP43x89y88() : #43 at 89,88
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(2, 30, 4, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('A river emerges from below and flows out of the cave entrance.  You can smell the stench of some creature living inside.  Towards the back of the main chamber, there is a whole network of caves leading in various directions.  Do you enter?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	return

static func AP44x16y18() : #44 at 16,18
	await ScriptHelperFuncsClass.display_text_wait_noise('The gate stands unguarded.  A notice from the king is posted.  It reads, \"Stanchion burial lands are closed until further notice.  All those that enter do so of their own accord and at their own risk.\" ', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('The graveyard has fallen into a state of total disrepair.  Most of the graves and crypts have been looted.  The caretakers have not been busy for quite some time.', 'message nod.wav')
	return

static func AP45x11y16() : #45 at 11,16
	await ScriptHelperFuncsClass.display_text_wait_noise('The gate stands unguarded.  A notice from the king is posted.  It reads, \"Stanchion burial lands are closed until further notice.  All those that enter do so of their own accord and at their own risk.\" ', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('The graveyard has fallen into a state of total disrepair.  Most of the graves and crypts have been looted.  The caretakers have not been busy for quite some time.', 'message nod.wav')
	return

static func AP46x24y14() : #46 at 24,14
	return ScriptHelperFuncsClass.get_ap_name_starting_with('AP'+str(2))

static func AP47x89y69() : #47 at 89,69
	# This AP teleports to level 2 at 1,35
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(2, 1, 35, 0)
	return

static func AP48x50y4() : #48 at 50,4
	await ScriptHelperFuncsClass.display_text_wait_noise('You find a secret passage into the courtyard of the spider tower.', 'message nod.wav')
	# Needs rework: sound file 'earth shake.wav' needs to be converted to sfx_id
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(0, 48, 3, 0)
	return

static func AP49x72y13() : #49 at 72,13
	await ScriptHelperFuncsClass.display_text_wait_noise('You see a large iron door set into the mountain.  Inscribed into the steel of the door are strange runes.  They are an ancient but familiar script.  It tells of a great evil that has been banished beyond the mighty portal.  Do you open it?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	ScriptHelperFuncsClass.play_sound('door slam.wav', true)
	await ScriptHelperFuncsClass.display_text_wait_noise('A blast of stale air pours forth.  Along with a vile creature.', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound('wind.wav', true)
	await ScriptHelperFuncsClass.start_battle_in_range(148, 148, 30002, "", 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('Strange footprints trail off to the east.  Something else would appear to live deeper within the cave.', 'message nod.wav')
	return

static func AP50x52y38() : #50 at 52,38
	await ScriptHelperFuncsClass.display_text_wait_noise('You find the remains of an old grave.  It has been dug up and pilfered.  The bones of the buried lie about the area.  Do you bury the bones or leave them where they lay?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 0, "Bury the bones", "Leave them be")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('A whisper from nowhere thanks you.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(0)
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func AP51x4y24() : #51 at 4,24
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter the gaming arena.  The master of the games asks if you wish to pit your skills in combat against dire creatures for a wager.  Do you wish to enter the games?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 0, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_simple_encounter_Divinity(0)
	return

static func AP52x7y24() : #52 at 7,24
	await ScriptHelperFuncsClass.display_text_wait_noise('A sign above the front gate reads,  \"Official Sanctioned Gaming Arena.\"  From inside you here the cheers of an excited crowd and the moans of the wounded and dying.', 'message nod.wav')
	return

static func AP53x17y21() : #53 at 17,21
	await ScriptHelperFuncsClass.display_text_wait_noise('You find the small cave that leads to the stable.  You creep inside to see a large corral of beastmen.  They number a  baker\'s dozen.  This won\'t be easy.  Do you wish to attack these vermin now?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 0, "Attack now", "Wait a while")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.start_battle_in_range(114, 114, 30002, "", 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('Having completed your handiwork, the man contacts you as planned.  He hands you a sizable leather pouch.  \"Here is the price as we agreed.  I have given ye a little something extra for your trouble.\"', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(0)
	return

static func AP54x65y88() : #54 at 65,88
	await ScriptHelperFuncsClass.display_text_wait_noise('You step into a rather large cave only to find 8 eyes staring at you from 4 thick necks.', 'message nod.wav')
	await ScriptHelperFuncsClass.start_battle_in_range(57, 57, 30001, "", 0)
	return

# This AP teleports to level 1 at 5,63
static func AP55x89y79() : #55 at 89,79
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(1, 5, 63, 0)
	return

static func AP56x83y78() : #56 at 83,78
	await ScriptHelperFuncsClass.display_text_wait_noise('You see the footprints of some two footed creatures with clawed feet.  Blood is smeared from floor to ceiling.  The bodies of several farmers have been ripped limb from limb and partially eaten.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('A bloody trail leads from the shack to the east.  Someone has been dragged from the shack kicking and screaming.', 'message nod.wav')
	return

static func AP57x79y79() : #57 at 79,79
	await ScriptHelperFuncsClass.display_text_wait_noise('As you walk in the small shack you witness a scene out of your worst nightmares.  Nailed to the walls are the half eaten corpses of a farmer and his wife.  From the way the blood has pooled at their feet it is obvious they were eaten alive.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('On a small table lies the remains of a small 10 year old girl.  Her arms and feet have been nailed to the table in order to make easy pickings for whatever has chosen to dine on her.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('A bloody trail leads from the shack to the east.  Someone has been dragged from the shack kicking and screaming.', 'message nod.wav')
	return

static func AP58x45y1() : #58 at 45,1
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
	await ScriptHelperFuncsClass.display_text_wait_noise('You see several dozen dead orcs strewn about the cave.  Most of the bodies have been nibbled on somewhat by some creature that must be quiet large.  The cave continues off to the back.  You hear heavy breathing and the shuffling of great feet.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Do you wish to move to the back of the cave to investigate?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('You discover that this cave is inhabited by a mated pair of trolls.  Though you have approached with the stealth of a clemidian devil cat, the trolls can smell you as if you had sacks of bacon strapped to your backs.  Trolls like bacon!!!', 'message nod.wav')
	await ScriptHelperFuncsClass.start_battle_in_range(169, 169, 30001, "", 0)
	return

static func AP60x83y1() : #60 at 83,1
	await ScriptHelperFuncsClass.display_text_wait_noise('You discover what can only be described as a nest for lack of a better word.  The bodies of even more orcs are heaped in mounds about the cave.  Beasts such as trolls need to eat a lot.  Why so many look to be hardly touched is a mystery.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('As you continue to look around for anything of interest you hear the wail of a baby troll coming from the west.', 'message nod.wav')
	return

static func AP61x81y1() : #61 at 81,1
	await ScriptHelperFuncsClass.display_text_wait_noise('In this end of the cave is a very frightened young troll. The babe must have witnessed you killing its parents.  Its eyes bulge like saucers as it looks at you in total fear. Suddenly the babe begins to relax.  The fear subsides for an unknown reason.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Unknown, that is, until you look behind you.  The babe\'s brothers and sisters have stalked up on you.  They charge you in an attempt to revenge their fallen parents and save their baby brother.', 'message nod.wav')
	await ScriptHelperFuncsClass.start_battle_in_range(170, 170, 0, "", 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('During the melee the babe has disappeared.  The remainder of the cave has nothing of interest.', 'message nod.wav')
	return

static func AP62x73y13() : #62 at 73,13
	await ScriptHelperFuncsClass.display_text_wait_noise('As you travel deeper into the cavern you find that the skeletal giant had a trio of rather nasty pets.', 'message nod.wav')
	await ScriptHelperFuncsClass.start_battle_in_range(171, 171, 0, "", 0)
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func AP63x26y41() : #63 at 26,41
	await ScriptHelperFuncsClass.display_text_wait_noise('As you are journey through a grove of oaks, large snakes drop from the branches.  They intend to make an easy meal of you.', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound('drop item.wav', true)
	ScriptHelperFuncsClass.play_sound('drop item.wav', true)
	ScriptHelperFuncsClass.play_sound('drop item.wav', true)
	await ScriptHelperFuncsClass.start_battle_in_range(175, 175, 30001, "", 0)
	return

static func AP64x30y26() : #64 at 30,26
	return

static func AP65x27y25() : #65 at 27,25
	await ScriptHelperFuncsClass.display_text_wait_noise('The cave dead ends here.  Chained on the wall are the remains of a hill giant that has been partially devoured.  You are unable to tell if the body parts were consumed before being chained to the wall or if it simply fell prey to scavengers.', 'message nod.wav')
	return

static func AP66x27y24() : #66 at 27,24
	return

static func AP67x29y24() : #67 at 29,24
	await ScriptHelperFuncsClass.display_text_wait_noise('You emerge into the musty confines of a large cavern.  It would appear the hapless giant was to be milk and cookies for the beast resting here.  Resting that is, until now!', 'message nod.wav')
	await ScriptHelperFuncsClass.start_battle_in_range(176, 176, 30002, "", 0)
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(0, 68, -1.0 / 100.0, 0, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('You find a sizable cache of wealth and a small sack with a group of 4 daggers.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(0)
	return

static func AP68x27y21() : #68 at 27,21
	await ScriptHelperFuncsClass.display_text_wait_noise('Your skin prickles, and your hair stands completely on end as if you are rubbing your feet furiously on a bearskin rug while wearing wool socks.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('There must be a powerful source of electrical energy nearby.', 'message nod.wav')
	return

static func AP69x5y27() : #69 at 5,27
	ScriptHelperFuncsClass.change_map_tile_Divinity(0, 3, 28, 193, "land")
	await ScriptHelperFuncsClass.display_text_wait_noise('You have found your way to the alley behind the combat arena.  You see a large shack in the distance that you had not seen before.', 'message nod.wav')
	return

static func AP70x4y27() : #70 at 4,27
	await ScriptHelperFuncsClass.display_text_wait_noise('As you approach the shack, a man wearing a leather harness exits from the hut and approaches.  \"What are you doing here?  This area is off limits.\"  He turns to go back inside when suddenly a huge creature bursts from the shack.', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound('door slam.wav', true)
	ScriptHelperFuncsClass.play_sound('glowl 3.wav', true)
	await ScriptHelperFuncsClass.display_text_wait_noise('The creature bears the remains of shackles.  Blood-soaked chains, wrapped about its fists, create crude but effective weapons.  The man in the leather harness yells, \"Look out!  It\'s loose!\" In hot pursuit, several armed men storm out the door.', 'angry mob.wav')
	await ScriptHelperFuncsClass.start_battle_in_range(177, 177, 10049, "", 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('You discover a scroll inside the shack.  It contains orders that the corporal train the troll to fight in the arena.  Bad idea!', 'message nod.wav')
	return

static func AP71x75y53() : #71 at 75,53
	await ScriptHelperFuncsClass.display_text_wait_noise('Holes have been ripped into the thatched roof of an abandoned shack.  Bloodstains on the floor bear witness that the former occupant suffered a violent death.', 'message nod.wav')
	# Needs rework: Random chance should use ScriptHelperFuncsClass.branch_percent_chance_divinity(33, whatdo, type, number, lineskip) with var branch check
	return

static func AP72x65y87() : #72 at 65,87
	await ScriptHelperFuncsClass.display_text_wait_noise('Large piles of bones litter the cave\'s entrance to the south.', 'message nod.wav')
	return

static func AP73x42y88() : #73 at 42,88
	return

static func AP74x46y87() : #74 at 46,87
	await ScriptHelperFuncsClass.display_text_wait_noise('The creatures that caused the demise of the former occupant are now back searching for more food.', 'message nod.wav')
	await ScriptHelperFuncsClass.start_battle_in_range(182, 182, 30001, "", 0)
	return

static func AP75x13y10() : #75 at 13,10
	await ScriptHelperFuncsClass.display_text_wait_noise('You notice a small wooden sign near the window.  It\'s so old and faded as to be almost illegible.  It reads, \"Madam Osswel\'s Specialty Shop.\"  It appears to be closed.                                                     ', 'message nod.wav')
	return

static func AP76x2y2() : #76 at 2,2
	ScriptHelperFuncsClass.display_picture_file('0.png')
	await ScriptHelperFuncsClass.display_text_wait_noise('Welcome to \"The City of Bywater\", a scenario for use with the Realmz Scenario Driver.  If you enjoy playing Realmz and would like to see more scenarios developed, please support us by sending in your registration fee.', 'heal.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Once you have registered this copy of Realmz, you will be able to play the entire scenario.  This scenario is very loose.  It does not have a strong plot line.  You can adventure where you want for as long as you want.', 'heal.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Once you have registered this copy of Realmz, you will also be able to play test other scenarios BEFORE having to register them.  The fee for each additional scenario are $13 each.  For information on how to register, see chapter 3 of the Realmz Manual.', 'hallelujah.wav')
	# XAP 73 content (recursively resolved):
	await ScriptHelperFuncsClass.display_text_wait_noise('Other scenarios utilize the capabilities of the Realmz scenario driver to a greater extent.  These scenarios feature a definite plot line, new monsters, new magical items and more dangerous encounters.', 'message nod.wav')
	# end of XAP 73 (with nested expansions)
	ScriptHelperFuncsClass.hide_picture()
	return

## This AP teleports to level 5 at 52,3
static func AP77x18y9() : #77 at 18,9
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(5, 52, 3, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter a massive building.  It appears to be an endless maze of hallways and corridors.', 'message nod.wav')
	return

static func AP78x2y28() : #78 at 2,28
	var nextap : String = await ScriptHelperFuncsClass.branch_on_quest_Divinity(20, 0, 0, 100, 0)
	if not nextap.is_empty() :
		return nextap
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter the slave prison.  A potbellied Corporal Sampson is slumped over a shaky table.  He\'s slept through the entire ordeal that just took place outside.  The smell of elderberry wine permeates his clothes.  You try to rouse him to collect your fee.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Sampson awakens with a jolt and sits up quickly.  An offensive stream of drool has slid across his left cheek.  Heavy bags underneath his eyes imply he hasn\'t slept well lately.  \"What\'s this?  Can a man have no rest?\" You promptly display your contract.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Sampson swiftly scans the contract with disbelief.  \"I see that you have been promised the sum of 100 gold Zelots.  Well, there is not that many gold Zelots in all of Bywater!  You may be very brave, but you are also very gullible!\"', 'talk 2.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('\"I can offer you a few silver for your trouble.  That is the best I can do.\"  He begins to search his belongings for a few paltry coins.  Suddenly, a nasty brawl breaks out between two of the beasts. ', 'message nod.wav')
	# XAP 82 content (recursively resolved):
	await ScriptHelperFuncsClass.display_text_wait_noise('During the battle with the mad troll, one of the troll\'s hands had been severed.  One of your charges hungrily snatched it up to eat.  However, another beast greedily attempted to steal the tender morsel.  This attempt has provoked an all-out brawl.', 'growl 1.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Before you are able to get the situation under control, the beasts erupt explosively into a convulsing ball of fur and slashing claws.  You are immediately  pulled into the fray.', 'message nod.wav')
	await ScriptHelperFuncsClass.start_battle_in_range(206, 206, 30001, "", 0)
	await ScriptHelperFuncsClass.display_simple_encounter_Divinity(0)
	# end of XAP 82 (with nested expansions)
	return

static func AP79x34y2() : #79 at 34,2
	# This AP teleports to level 4 at 2,25
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(4, 2, 25, 0)
	return

static func AP80x7y21() : #80 at 7,21
	await ScriptHelperFuncsClass.display_text_wait_noise('You are just about to enter the king\'s private gardens.  Someone has posted a message at the front gate.  \"Closed until further notice.  Do not enter under any circumstances.  You have been warned!\"', 'message nod.wav')
	var nextap : String = await ScriptHelperFuncsClass.branch_on_quest_Divinity(32, 0, 0, 100, 0)
	if not nextap.is_empty() :
		return nextap
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter the king\'s gardens and begin to stalk for signs of the rabid beast.  Several  plants have been uprooted or mutilated.  You hear something up ahead on your right.  There are indications that the beast may not be alone.  Do you wish to continue?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.start_battle_in_range(209, 209, 30001, "", 0)
	ScriptHelperFuncsClass.set_quest_id_flag_Divinity(0)
	return

static func AP81x5y5() : #81 at 5,5
	pass
	return

static func AP82x6y3() : #82 at 6,3
	var branch : String = ScriptHelperFuncsClass.branch_NPC_in_party_Divinity("Vodalian", 0, 1, 104, 0)
	if not branch.is_empty() :
		return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('A seedy looking group of gnomes are sitting at a vomit stained table.  They are swilling cheap grog from a clay jug.  They seem more concerned with getting more than their share of the wine and pay you little attention.', 'talk 2.wav')
	return

static func AP83x89y48() : #83 at 89,48
	# Needs rework: set_dungeon - function not described in declarations, needs manual implementation
	return

static func AP84x71y78() : #84 at 71,78
	ScriptHelperFuncsClass.play_sound('big splat.wav', true)
	ScriptHelperFuncsClass.play_sound('big splat.wav', true)
	await ScriptHelperFuncsClass.display_text_wait_noise('You plow through thick clumps of fungus. Movement flashes at your side.  You halt and warily eye the surroundings.  A constant, steady rustling seems to come from all directions.  You feel quite on edge.  There\'s something odd about these plants.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Huge fungus-like plants grow throughout the area.  Each fungus is surrounded by small podlings attached by long vines.  The podlings slither in your direction.', 'message nod.wav')
	await ScriptHelperFuncsClass.start_battle_in_range(191, 191, 30001, "", 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('A faint smell begins to permeate the air. It slowly gains strength.  You toy with the idea of capturing one of the creatures.  A wizard would pay dearly to use such a  plant in experiments.  The nasty odor hastily devours this thought.', 'message nod.wav')
	return

static func AP85x73y76() : #85 at 73,76
	return ScriptHelperFuncsClass.get_ap_name_starting_with('AP'+str(0))

static func AP86x68y77() : #86 at 68,77
	return ScriptHelperFuncsClass.get_ap_name_starting_with('AP'+str(0))

static func AP87x69y79() : #87 at 69,79
	return ScriptHelperFuncsClass.get_ap_name_starting_with('AP'+str(0))

static func AP88x72y79() : #88 at 72,79
	return ScriptHelperFuncsClass.get_ap_name_starting_with('AP'+str(0))

static func AP89x70y76() : #89 at 70,76
	return ScriptHelperFuncsClass.get_ap_name_starting_with('AP'+str(0))

static func AP90x4y36() : #90 at 4,36
	ScriptHelperFuncsClass.play_sound('underwater laser.wav', true)
	await ScriptHelperFuncsClass.display_text_wait_noise('Open grassland is marred by a dark, gaping pit.  Muted bubbling fizzles below.  A large log lies near the pit\'s edge.  It might be possible to use it as a crude, makeshift ladder.  Do you push the log in and attempt to enter the pit?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 0, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('You start to slowly clamber down the log.  With a heavy thump, the log shifts to the right and begins to shake with violent force.  Clinging for dear life, you scramble your way back up out of the pit.  Massive slime creatures slither up the log.', 'message nod.wav')
	await ScriptHelperFuncsClass.start_battle_in_range(218, 218, 30001, "", 0)
	return

static func AP91x6y3() : #91 at 6,3
	pass
	return

static func AP92x6y3() : #92 at 6,3
	pass
	return

static func AP93x6y3() : #93 at 6,3
	pass
	return

static func AP94x88y12() : #94 at 88,12
	await ScriptHelperFuncsClass.display_text_wait_noise('A small orcish dwelling that belongs to the local witch doctor.  The owner gives you a toothless grin and offers to sell you a few potions and trinkets.', 'message nod.wav')
	GameGlobal.currentShop = 'shop_0'
	GameGlobal.allow_money_change(true)
	return












#Map Script generated from XAP format conversion

static func XAP1() : #1
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The gate guards check your invitation and wave you through.', 'message nod.wav')
	return

static func XAP2() : #2
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('"Sorry citizen, without a formal invitation, the only way into the castle is in chains.  See the magistrate in yon building, he can explain all.  Now be off."', 'message nod.wav')
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(0, 9, 16, 0)
	return

static func XAP3() : #3
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('angry mob.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('Town guards rush towards you.  The corporal in charge screams, "They are the ones who murdered the good Magistrate.  Kill them!"  Troops are upon you before you can make good your escape.', 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(1, 1, 10136, "", 0)
	return

static func XAP4() : #4
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('Haikur recognizes you and walks over to greet you.  He introduces you to Thurfur who seems to take an immediate liking to you.  It is obvious both men have a certain distaste for each other, but a strong sense of duty keeps them from all out bloodshed.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('There have been several threats to Bywater as of late and disagreements on how to handle the situation.  You sit at a table and listen to both men as they tell their stories in an effort to win your assistance.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Haikur speaks, "There have always been Goblin raids on some of the more far-flung southern farmsteads, but recently they grow more and more bold.  In days past, they would steal a pig or two but would never harm the farmers."', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('"Yestereve, we discovered two farmsteads burned to cinders and nothing can be found of the peasants that worked the land.  I say we should squelch these foul vermin before they begin raiding some of the smaller hamlets."', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Thurfur speaks, "That can wait Haikur.  Our more immediate threat is to the east.  Orc tribes have been raiding our eastern provinces.  Just last week, Vesba was sacked and nearly fifty people lost their lives.  These orcs must pay for their crimes!"', 'message nod.wav')
	await ScriptHelperFuncsClass.display_simple_encounter_Divinity(5)
	return

static func XAP5() : #5
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('"We ask you to leave one last final time, citizens.  This area is restricted to you.  Do not make us take you by force."  Judging by the atmosphere in the barracks, you get the feeling they may attack if you stay any longer.  Do you leave?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(false, 1, 1, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('"Very well.  Now is a rather poor time to test my never plentiful supply of patience."  Thurfur draws steel and falls upon you.', 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(218, 218, 667, "", 0)
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func XAP6() : #6
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=0 start_coord=0,0 end_coord=41,18 [LRR0/0]
	await ScriptHelperFuncsClass.display_text_wait_noise('You come upon a shocking scene.  You spy a small group of town bullies attacking an old woman.  It would seem they are after a dagger she is clutching to her chest.  Do you wish to intervene on her behalf?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 0, "Rescue the woman", "Back away")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('The bullies do not have the stomach to fight and flee at your approach.  The old hag scowls at you, "Stay away!  You can\'t have it!"  The dagger she is clutching is rather ornate and seems very likely to be magical in nature.  What do you do?', 'message nod.wav')
	branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 1, 7, "Take the dagger", "Bid her goodday")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('"You young whelps!  You shall rot in hell for your evil ways!"  Having lost the dagger she shuffles away.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(3)
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 75, 65, 0)
	return

static func XAP7() : #7
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('As you walk away, she yells, "Come and see me at my shop.  I will give you a special price!"  She quickly disappears around a corner before you realize that you do not even know where her shop is.', 'message nod.wav')
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 75, 8, 0)
	return

static func XAP8() : #8
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('Madam Osswel\'s specialty shop appears to be open.  As you glance in through the window, you recognize Madam Osswel as the old hag you saved from the ruffians.', 'message nod.wav')
	GameGlobal.currentShop = 'shop_2'
	GameGlobal.allow_money_change(true)
	return

static func XAP9() : #9
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=0 start_coord=0,0 end_coord=41,18 [LRR0/0]
	await ScriptHelperFuncsClass.display_text_wait_noise('A wretched young gutter snipe runs up to you and begins crying so loud you can barely make out what he is saying.  "Oh, please help me, please, please!  My dog has fallen into the old well and I can\'t get him out.  Please help!"  What do you do?', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound('angry mob.wav', false)
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 4, 0, "Go with and help", "Shoo him away")
	if not branch.is_empty(): return branch
	ScriptHelperFuncsClass.play_sound('teleport.wav', true)
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(0, 27, 5, 0)
	ScriptHelperFuncsClass.play_sound('teleport.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('"Oh, thank you so much!  Come, this way.  Hurry! Hurry!"  He leads you to the old abandoned well.  At the bottom, you see a miserable little mutt covered in mud.  The bucket for drawing water is so old it\'s completely useless.', 'message nod.wav')
	await ScriptHelperFuncsClass.start_complex_encounter_Divinity(9)
	return

static func XAP10() : #10
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter the town archives.  An old withered man with dried leather for skin sits perched behind a sturdy desk.  He is scratching at some parchment with an ink quill.  As you approach, he frowns and looks up with a furrowed brow.  "Sssshhhh!"', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('"You people make more noise than a herd of rampaging Trollocs."  He continues with a sour look upon his face, "What is it that you want?  We are very busy here.  You may look around, but do not bother me unless I am needed."', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.start_complex_encounter_Divinity(1)
	return

static func XAP11() : #11
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('Thurfur and his men are at the east gate preparing to leave as you approach.  Many colored banners flap in the breeze depicting the King\'s standard-a huge gold dragon with a pair of swords clenched in its fists.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('"Ah!  Our heroes have come to join the fun!  Let us set out to crush the rabble!"  You make acquaintance with Thurfur\'s lieutenants and sergeants.  Amongst great fanfare from the townsfolk, you set out on your mission.', 'message nod.wav')
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(0, 84, 12, 10001)
	await ScriptHelperFuncsClass.display_text_wait_noise('At long last, your column comes to a halt.  You see an Orc village in the distance.  Thurfur rides up alongside, "I deem this to be the very tribe that waylaid Sestoon.  Let us charge in.  Surprise shall be a formidable ally to lead our just cause."', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Thurfur raises a mail-clad arm to signal the bugle to sound the charge.  Your mounts churn up dust as they dash into the village.  Unaccustomed to fighting on horseback, you dismount once you\'re in the fray to fight on solid ground.', 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(21, 21, 0, "", 0)
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 4, 12, 0)
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 6, 12, 0)
	return

static func XAP12() : #12
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The town patrol waves you through as they hand you a map showing where you can buy provisions.', 'message nod.wav')
	return

static func XAP13() : #13
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=1 rect_num=1 start_coord=2,27 end_coord=10,36 [LRR1/1]
	await ScriptHelperFuncsClass.display_text_wait_noise('This large cavern appears to be used as both a laboratory and a place of ritual.   Several pedestals have been built.  Their appearance suggests they\'ve been used  to strap human-sized beings in place for experiments.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('All are stained with dried blood and ichor.  Off to one side of the cave you see a decomposing pile of human appendages-  arms, legs, heads and all manner of organs.  It would appear that someone has been experimenting on bodies.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('One of the pedestals still has a body strapped to it.  The flesh on half of its body has decomposed so badly that it is literally falling off the bones.  Next to the body is a tray of long thin knives. Some madman has been flaying flesh.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('As you stand in witness to this awful carnal scene, the body on the pedestal begins to move slowly.  It makes no attempt to escape its bonds for it would appear to be a zombie.  Its creator has left it to decompose over the centuries.  Do you approach?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(false, 1, 17, "", "")
	if not branch.is_empty(): return branch
	return

static func XAP14() : #14
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The blacksmith hands you a map showing the location where they found his son\'s body.  As you depart he says, "Thank you, good people.  Return when you have cleansed the land of these foul vermin, and we shall celebrate."', 'message nod.wav')
	GameGlobal.minimaps[3] = 1
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func XAP15() : #15
	var textRect = UI.ow_hud.textRect
	var branch = await ScriptHelperFuncsClass.branch_percent_chance_divinity(30, 1, 16, 0, 0)
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('You kick around the stones and a small treasure of gems is revealed.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(6)
	await ScriptHelperFuncsClass.display_text_wait_noise('Do you wish to look for more gems?', 'message nod.wav')
	branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(false, 1, 15, "This passage leads to the surface.", "You have found a secret passage.  Do you enter?")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('You search the remains of the cavern and find nothing of interest.', 'message nod.wav')
	return

static func XAP16() : #16
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('earth shake.wav', true)
	ScriptHelperFuncsClass.play_sound('bear roar.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('As you are rummaging around in the polished stones, you hear a bizarre sound.  From around a large stalagmite a group of large cave bears come to investigate your scent.', 'message nod.wav')
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(0, 3, 48, 0)
	#start_battle(battlename : String, mapname : String, is_relative : bool, is_ambush : bool, allow_loss : bool, allow_escape : bool, npcs_allowed : bool, pc_participating : Array) :
	await ScriptHelperFuncsClass.display_text_wait_noise( "You manage to flee the cavern.  The speed of these huge creatures is amazing, and they dog your heels all the way to the entrance.  You get into the open, but it is of no use.  You will have to face these mighty foes.", 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(23, 23, 10048, "", 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('You finish your search of the stones and find a few remaining gems.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(6)
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func XAP17() : #17
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You end the misery of the poor sod who fell victim to this foul state.  As you search the area you see a blood-stained diary.  Most of the pages have been torn out and are nowhere to be found.  One page remains and it reads...', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('"The chamber has grown too small for my army.  I have to locate a larger cavern to continue my preparation of the assault on  Spider Tower.  In addition, I need more supplies from the king.  He seems reluctant to meet with his end of the bargain."', 'message nod.wav')
	# change_rect level=1, id=1, times_in_10k=-1, new_battle_low=0, new_battle_high=0
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func XAP18() : #18
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('After the thrashing you gave the creatures at the gate before, the gate is now only lightly guarded.', 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(39, 39, 0, "", 0)
	return

static func XAP19() : #19
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You burrow up through the last few feet of earth and emerge at the very foot of the tower.  You rush inside with your undead allies.  You come upon two clerics  discussing business.  There is a sizable contingent of arachnids in attendance.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('They see you and your undead army rush in.  They command their sickly army to destroy you.  Arachnids and undead mix in a ghastly battle that can only resemble a freak show.', 'message nod.wav')
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(5, 81, 34, 0)
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(44, 44, 0, "", 0)
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(1, 3, -1.0 / 100.0, 0, 0)
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(0, 27, -1.0 / 100.0, 0, 0)
	# change_rect level=0, id=2, times_in_10k=-1, new_battle_low=0, new_battle_high=0
	return "XAP41"

static func XAP20() : #20
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You execute the goblin king and gather whatever you find in the shack as spoils of war.  It appears he lived more like a pauper than a king.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(12)
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func XAP21() : #21
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=3 rect_num=0 start_coord=0,0 end_coord=27,48 [LRR3/0]
	await ScriptHelperFuncsClass.display_text_wait_noise('You hear growls.  Suddenly, there appears an ogre.  It is being chased by a beast even more fierce-a giant troll.  Do you wish to attempt to save the ogre from its obvious fate or do you stand back and enjoy evil destroying evil?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 0, "Attack the troll", "Leave them be")
	if not branch.is_empty(): return branch
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(21, 21, 0, "", 0)
	return

static func XAP22() : #22
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('but my own decrees of fairness prevent me from doing so. If you rid this town of this accursed tower, I could not reward you publicly.  In private, however, is another matter.  I charge you to rid Bywater of this foul cult!"', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('"What say you?  Will you accept my plea of help for this fair city?"', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 1, 24, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('"Good!  It\'s settled then.  There is another secret agent of mine that is striving toward a similar goal.  If you cross paths, I decree you to help rather than hinder each other\'s efforts.  Well!  We all have much to do."', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('The steward tells you of the armory and asks you to take your pick of equipment.  He also gives you an item. "Use this magic crown to return to the front gate of our fair castle.  It will work but 3 times so use it only in time of great need."', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(45)
	await ScriptHelperFuncsClass.display_text_wait_noise('The steward informs the kings provisioner to allow you to have anything you want from the kings storeroom.  "You will find the storeroom near the entrance.  Fair thee well."', 'message nod.wav')
	return "XAP160"

static func XAP23() : #23
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter Castle Anthrax.  Scant attention is paid to your presence.', 'message nod.wav')
	return

static func XAP24() : #24
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('"If that is your wish, then so be it.  I bid you good day then, for a king has many duties-duties that I neglect even now.  Steward, show these fine people to the door."  You are briskly ushered out the door.', 'message nod.wav')
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 3, 23, 0)
	return

static func XAP25() : #25
	var textRect = UI.ow_hud.textRect
	return

static func XAP26() : #26
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=0 start_coord=0,0 end_coord=41,18 [LRR0/0]
	await ScriptHelperFuncsClass.display_text_wait_noise('You are jumped by a pack of thieves, intent on slitting more than just your purse.', 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(52, 52, 10136, "", 0)
	return

static func XAP27() : #27
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=2 start_coord=50,5 end_coord=89,34 [LRR0/2]
	await ScriptHelperFuncsClass.display_text_wait_noise('As you top a knoll, you come upon an Orc female giving birth.  She looks quite pale, and is so weak she doesn\'t even notice you.  The baby is breached and will die if you do not help.  Do you aid her?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('You are successful at delivering the baby.  The mother only has time to see the face of her healthy newborn boy, before she slips into a coma and dies.  It would seem you have become parents by default.  What do you do?', 'message nod.wav')
	branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 0, "Take the child", "Leave the child")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('You wrap the babe in a blanket and secure him to your back.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(15)
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 38, 32, 0)
	return

static func XAP28() : #28
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=2 start_coord=50,5 end_coord=89,34 [LRR0/2]
	await ScriptHelperFuncsClass.display_text_wait_noise('You stumble upon an old Orc burial mound.   Several of the mounds seem to be untouched, but many have been dug up. Do you wish to excavate them in search for valuables?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('You break into several mounds and find nothing of value.  As you are excavating another mound, you feel a chill in the air.  A spirit rises from one of the mounds that is yet untouched and speaks in a voice that resembles leaves rustling.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('"This most sacred ground has been disturbed for the last time!  Foolish mortals, now you shall wish for the  everlasting peace that you so cruelly deny us!"  The spirit sweeps a wispy hand over the mounds.  The earth erupts as corpses rise.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('The air is filled with a musty smell as the dead stumble forth to attack.', 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(28, 28, 0, "", 0)
	return

static func XAP29() : #29
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=2 start_coord=50,5 end_coord=89,34 [LRR0/2]
	await ScriptHelperFuncsClass.display_text_wait_noise('You hear the sound of battle in the distance.  You see a band of orcs being attacked by a large group of goblins.  The orcs appear doomed unless you help.  The battle spreads out to engulf you.  Do you stand with the orcs or attack both parties?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(false, 1, 30, "Side with the orcs", "Attack both parties")
	if not branch.is_empty(): return branch
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(53, 53, 0, "", 0)
	return

static func XAP30() : #30
	var textRect = UI.ow_hud.textRect
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(54, 54, 0, "", 0)
	return

static func XAP31() : #31
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You come to a village of orcs.  Normally nomadic, it appears they have set up a temporary village.  You question some of the villagers as to why they have settled down.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('They tell of the chief\'s daughter who is pregnant.  The chief has ordered them to make camp for several weeks until his daughter gives birth.  Now the chief is worried, for his daughter has disappeared.', 'message nod.wav')
	return

static func XAP32() : #32
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The village chief greets you and asks you how the search for his daughter is going.', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.branch_item_possession_divinity(808, 0, 1, 33, 0)
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('"You keep looking!  I give big reward if you find daughter.  Now go!"  He shoves you out the door.', 'message nod.wav')
	return

static func XAP33() : #33
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The chief takes the babe and grins.  "This  babe will be a mighty warrior like his gamp!  You are welcome to travel in my territory."  He lifts a fur rug from the floor revealing a pit.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('From the pit, he pulls out two objects wrapped in animal skins.  He uncovers a set of throwing daggers and a throwing ax.  "You take!  Strong magic!  You take!"  He hands you the gifts and goes off to find his grandson a wet nurse.', 'message nod.wav')
	# change_item item=808, num=1, action=drop, charges=0, new_item=0
	await ScriptHelperFuncsClass.give_treasure_with_id(16)
	# change_rect level=0, id=2, times_in_10k=100, new_battle_low=0, new_battle_high=0
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func XAP34() : #34
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You happen upon a troll dining on a grizzly meal of krise.  The krise corpse is wearing a backpack.  The troll is eating so greedily that it is swallowing krise, backpack, and anything else it can stuff into its huge maw.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_simple_encounter_Divinity(11)
	return

static func XAP35() : #35
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('This is an old abandoned well.  It looks to be a long ways down.  The bucket and crank are almost rotted out.  This well has not been in use for quite some time.', 'message nod.wav')
	return

static func XAP36() : #36
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('A net drops over you from above.  A large group of krise quickly pounce with such numbers that any resistance is quickly squelched. You are trussed up and roughly dragged through a long set of tunnels.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('You are battered and bruised, but not seriously hurt.  They finally dump their cargo unceremoniously at the feet of their ruler.  You are unable to clearly understand their discussion, but you get the general gist.  You are to be today\'s entertainment.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('They plan on dumping you into a pit.  Apparently, the pit is filled with nasty beasts of the underworld.  No one has ever left the pit alive.  They drag you kicking and screaming into the pit and toss you in.', 'message nod.wav')
	# heal_party mult=-1, low_range=2, high_range=10, sound=10090, string="You land in the bottom with a loud thump.  Whatever is in the pit must be foul indeed, for they did not even bother to disarm you."
	ScriptHelperFuncsClass.play_sound('earth shake.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('You land in the bottom with a loud thump.  Whatever is in the pit must be foul indeed, for they did not even bother to disarm you.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('The pit has only two exits.  Both disappear into the blackness of the underworld.  Do you choose the left pit or the right?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 1, 37, "Left", "Right")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('The reason no one has ever returned from this pit is that this tunnel leads to the surface!  The krise must have been so afraid of whatever dwells in the other tunnel, they never investigated this one!', 'message nod.wav')
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(1, 2, 48, 0)
	return

static func XAP37() : #37
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise("As you delve deeper into the tunnel, you begin to think the cave uninhabited.  Soon, a putrid smell surrounds you.  The cave is inhabited!", 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(57, 57, 30001, "", 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('The real reason no one has ever returned from this pit is because this tunnel leads to the surface!  You suspect that former victims of this evil band were immediately killed.  Those who weren\'t, probably  escaped to the surface through this very tunnel.', 'message nod.wav')
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(1, 7, 48, 0)
	return

static func XAP38() : #38
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=1 rect_num=3 start_coord=25,33 end_coord=28,35 [LRR1/3]
	await ScriptHelperFuncsClass.display_text_wait_noise('You see a huge iron gate in the distance.  It is guarded by a small party of krise who are gathered around a reinforced chest.  They spot you and attack before you can slip back into the tunnels.', 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(61, 61, 10136, "", 0)
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 32, 99, 0)
	# simple_enc_del_any 10, choice=3
	await ScriptHelperFuncsClass.start_complex_encounter_Divinity(5)
	return

static func XAP39() : #39
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The blacksmith weeps as you hand him his son\'s possessions. "Thank you, friends.  Now, no one else will have to know what it is to lose a loved one to these vermin.   If I\'d only been a younger man, I would have ventured forth myself to right this wrong."', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('"But alas, I am old and withered.  I was saving these for when my son left the shelter of my home.  Now you may have them as payment."  He hands you a cloth  bundle containing leather goods and retreats to a back room to weep.', 'message nod.wav')
	# change_item item=807, num=1, action=drop, charges=0, new_item=0
	await ScriptHelperFuncsClass.give_treasure_with_id(19)
	return

static func XAP40() : #40
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You find a secret passage into the courtyard of the spider tower.', 'message nod.wav')
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(0, 48, 3, 10090)
	return

static func XAP41() : #41
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(1, 3, -1.0 / 100.0, 0, 0)
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 3, 60, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('The king\'s cleric takes charge of the situation.  He turns to you and says, "See the king for any reward you may have coming.  You are great friends of this kingdom."', 'message nod.wav')
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(0, 3, 100.0 / 100.0, 0, 0)
	ScriptHelperFuncsClass.change_map_tile_Divinity(5, 82, 36, 111, "land")
	ScriptHelperFuncsClass.change_map_tile_Divinity(5, 81, 36, 111, "land")
	return

static func XAP42() : #42
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('As you try to lift the pouch, you feel it resist and the floor shifts slightly.  It would seem you have discovered a trap.  Do you wish to trigger the trap and see what is below?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	return "XAP43"

static func XAP43() : #43
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('earth shake.wav', false)
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(2, 2, 5, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('You are in a dark cave.  As you search the immediate area, you notice numerous piles of ogre bones.  This trap has obviously trapped many before you and may have no exit.   With the tunnel\'s collapse, you could very well be its last victim.', 'message nod.wav')
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(3, 5, 46, 0)
	ScriptHelperFuncsClass.change_map_tile_Divinity(3, 26, 22, -16, "land")
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func XAP44() : #44
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=2 rect_num=0 start_coord=1,2 end_coord=26,9 [LRR2/0]
	await ScriptHelperFuncsClass.display_text_wait_noise('You pass a small group of ogres fighting against slime worms.   The ogres will surely lose in the long run.', 'message nod.wav')
	return

static func XAP45() : #45
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=2 rect_num=0 start_coord=1,2 end_coord=26,9 [LRR2/0]
	await ScriptHelperFuncsClass.display_text_wait_noise('You see a large group of slime worms feeding on ogre carcasses.', 'message nod.wav')
	return

static func XAP46() : #46
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('This is a rather ornate building.   Do you wish to explore the inside of the building?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('The collapse of the tunnel beneath the floor has caused a deep shift in the foundation of the building above it.  As a result, a portion of one wall has collapsed   to reveal a small, iron box.  It contains many items of worth.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(28)
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(3, 5, -1.0 / 100.0, 0, 0)
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func XAP47() : #47
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=3 rect_num=2 start_coord=0,54 end_coord=27,79 [LRR3/2]
	await ScriptHelperFuncsClass.display_text_wait_noise('You spot a large group of Mush Men under attack by an even larger group of reptile like creatures.  It would seem the reptiles are literally eating the Mush Men alive.  Do you with in jump in the fray?', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise("The Mush Men fight for their lives.  They have become completely surrounded.", 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(216, 216, 0, "", 0)
	return

static func XAP48() : #48
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.give_treasure_with_id(30)
	await ScriptHelperFuncsClass.display_text_wait_noise('"You are welcome to rest here as long as you like.  One of my ancestors knew some magic.  A permanent protection spell has been cast on this area.  Ogres and other creatures will not come near."', 'message nod.wav')
	return

static func XAP49() : #49
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.start_complex_encounter_Divinity(7)
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(6, 2, 49, 0)
	return

static func XAP50() : #50
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=4 start_coord=67,46 end_coord=89,89 [LRR0/4]
	await ScriptHelperFuncsClass.display_text_wait_noise('You see a hill giant slumped against a tree.  He is wounded and is nearly dead.  He speaks, "Ranthog fight big bear.  Ranthog hurt.  You help Ranthog?"      What do you do?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 1, 51, "Bind his wounds", "Slay him")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('"Ranthog thank you.  Ranthog give you big treasure."  He sketches a map on a piece of papyrus showing the location of a large, hollowed out tree.  He says the treasure is hidden inside the tree.  "Ranthog go home.  Ranthog tired."  He limps away.', 'message nod.wav')
	GameGlobal.minimaps[6] = 1
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(0, 39, 100.0 / 100.0, 0, 0)
	ScriptHelperFuncsClass.change_map_tile_Divinity(0, 39, 56, -1018, "land")
	ScriptHelperFuncsClass.change_map_tile_Divinity(0, 39, 55, -17, "land")
	return

static func XAP51() : #51
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('As you approach him, he sighs with a mighty wind and hoists himself up.  He does not plan on going down without a fight.', 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(79, 79, 10121, "", 0)
	return

static func XAP52() : #52
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=4 start_coord=67,46 end_coord=89,89 [LRR0/4]
	await ScriptHelperFuncsClass.display_text_wait_noise('You spot an adult hill giant teaching the finer points of setting up ambush to a small group of youngsters.  Do you wish to teach them a valuable lesson and set an ambush of your own?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('The students have paid very close attention to their teacher.  Your ambush is spotted by one of them.  You are surprised as they set upon you.  They act as if they are seasoned veterans, not the greenhorn youngsters you expected them to be.', 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(81, 81, 10136, "", 0)
	return

static func XAP53() : #53
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=4 start_coord=67,46 end_coord=89,89 [LRR0/4]
	await ScriptHelperFuncsClass.display_text_wait_noise('You spot what appears to be three young hill giants tormenting a large proto-badger.  Do you help the proto-badger against these evil folk?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(80, 80, 10121, "", 0)
	return

static func XAP54() : #54
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=2 rect_num=1 start_coord=1,11 end_coord=27,27 [LRR2/1]
	await ScriptHelperFuncsClass.display_text_wait_noise('You stumble into the most bizarre battle you have ever seen.  It appears to be a civil war between jelly-like monsters.  If you hadn\'t been dragged into its midst, you might have even been amused by the situation.', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound('slime.wav', false)
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(92, 92, 640, "", 0)
	return

static func XAP55() : #55
	var textRect = UI.ow_hud.textRect
	# heal_picked mult=-6, low_range=1, high_range=4, sound=659, string=0
	ScriptHelperFuncsClass.play_sound('energy blast.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('After the discharge of light beams, the protective energy field vanishes.  Inside the sphere, the vortex of mist forms the visage of a hideous beast.  It stares intently into your eyes and begins to communicate telepathically.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_simple_encounter_Divinity(14)
	return

static func XAP56() : #56
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=6 start_coord=1,79 end_coord=16,89 [LRR0/6]
	await ScriptHelperFuncsClass.display_text_wait_noise('You approach a goblin village. If you slip from hut to hut, it is possible to avoid contact with most of the dwellers.  You surmise that the goblin king lives towards the south in a hut noticeably larger than the rest.', 'message nod.wav')
	return

static func XAP57() : #57
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=5 rect_num=1 start_coord=0,0 end_coord=38,30 [LRR5/1]
	# RANDOM RECTANGLE REFERENCE dungeon_level=0 rect_num=1 start_coord=0,0 end_coord=38,30 [DRR0/1]
	await ScriptHelperFuncsClass.display_text_wait_noise('You hear a whisper that seems to come from nowhere and everywhere.  "Free us!  Our souls languish in eternal torment."  The whisper fades, but everyone seems to have heard the same thing.', 'message nod.wav')
	return

static func XAP58() : #58
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(0, 15, 65, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('Haikur is at the gate awaiting your arrival.  "Good, good.  Now, let us be off and rid the land of these foul goblins."  Several hours into the journey, you feel the hair on your neck prick.  Suddenly, you are ambushed by goblins.  This looks grim.', 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(147, 147, 10136, "", 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('Your force has been too badly wounded to continue.  Rumblings arise from the wounded.  They claim that you are cursed.  Haikur has no choice.  To avoid a mutiny, he casts you out.  You are now on your own, deep in no man\'s land.', 'message nod.wav')
	return

static func XAP59() : #59
	var textRect = UI.ow_hud.textRect
	return

static func XAP60() : #60
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_simple_encounter_Divinity(13)
	await ScriptHelperFuncsClass.display_text_wait_noise('The king races off to make plans for a celebration in your name.', 'message nod.wav')
	return

static func XAP61() : #61
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('As you follow the rites described on the page, you see the gold disks begin to glow.  A tendril of smoke wisps up from the center of the pentigram followed by a  spire of flame.  Your eyes widen as a huge sand demon steps from the flames.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('"I see the lackeys of the fool I dispatched earlier have arrived. You shall pay dearly for disturbing me!  I shall feast well on your lifeblood this day!"  He mutters a few words in some unknown tongue and summons two of his lieutenants.', 'message nod.wav')
	# jmp_battle battle_low=56, battle_high=0, loss_xap=back_up, sound=30000, string=0
	ScriptHelperFuncsClass.play_sound('demon summon.wav', false)
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(56, 56, 30000, "", 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('With the demise of these foul creatures, you collect the treasure in the area.  The page on which the demon\'s name was inscribed explodes into flames.', 'message nod.wav')
	# heal_party mult=-1, low_range=1, high_range=6, sound=642, string=0
	ScriptHelperFuncsClass.play_sound('magic heal.wav', false)
	ScriptHelperFuncsClass.change_map_tile_Divinity(1, 2, 42, 155, "land")
	await ScriptHelperFuncsClass.give_treasure_with_id(18)
	return

static func XAP62() : #62
	var textRect = UI.ow_hud.textRect
	var branch = await ScriptHelperFuncsClass.branch_on_quest_Divinity(1, false, 1, 62, 0)
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('You need to finish the quest.', 'message nod.wav')
	return

static func XAP63() : #63
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=7 start_coord=85,10 end_coord=89,16 [LRR0/7]
	await ScriptHelperFuncsClass.display_text_wait_noise('You come to a village of orcs.  Normally nomadic, it appears they have set up a temporary village.  You question some of the villagers as to why they have settled down.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('They tell of the chief\'s daughter who is pregnant.  The chief has ordered them to make camp for several weeks until his daughter gives birth.  Now the chief is worried, for his daughter has disappeared.', 'message nod.wav')
	return

static func XAP64() : #64
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=8 start_coord=0,0 end_coord=41,13 [LRR0/8]
	await ScriptHelperFuncsClass.display_text_wait_noise('A man approaches you and speaks in a hushed voice.  "My aides have told me of the arrival of an adventurous band.  Hear my offer before you leave."  He tells a story of an evil man who has a stable of wild beastmen.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('The man asks if you would eliminate the stable of beastmen for monetary compensation.  He offers you 400 gold pieces if you kill the foul creatures.  Do you agree?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(0, 53, 100.0 / 100.0, 0, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('The man gives you a map showing the location of a hidden cave just outside the town walls.   "Good luck friends.  I shall seek ye out and reward thee when the deed is done.  Now, good day to you."', 'message nod.wav')
	GameGlobal.minimaps[8] = 1
	return

static func XAP65() : #65
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('An old woman pokes her head out a window.  As soon as she sees you she screams, "Get ye away!  You stole my dagger!  I don\'t sell my wares to thieves such as you!  Now, begone before I call the guard!"  She slams the window shut.', 'message nod.wav')
	return

static func XAP66() : #66
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=9 start_coord=39,40 end_coord=45,44 [LRR0/9]
	ScriptHelperFuncsClass.play_sound('wasp buzz.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('As you are standing near a large group of huge shrub-like plants you hear a loud buzzing.  Before long huge wasps descend from above.  You must fight or end up as food for their larvae.', 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(144, 144, 668, "", 0)
	return

static func XAP67() : #67
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=1 rect_num=19 start_coord=50,24 end_coord=76,27 [LRR1/19]
	await ScriptHelperFuncsClass.display_text_wait_noise('Large rocks break loose from the ceiling.  Those who are not quick enough fail to get out of the way and take damage.', 'message nod.wav')
	# pick_misc type=move, parameter=10, who=all
	# heal_picked mult=-1, low_range=1, high_range=3, sound=10090, string=0
	ScriptHelperFuncsClass.play_sound('earth shake.wav', false)
	return

static func XAP68() : #68
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=1 rect_num=18 start_coord=76,19 end_coord=88,29 [LRR1/18]
	await ScriptHelperFuncsClass.display_text_wait_noise("Even as you watch many eggs are hatching.  Crawling around these eggs are hundreds of strange lizard creatures.  Some mistake you for food.", 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(152, 152, 30001, "", 0)
	return

static func XAP69() : #69
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('teleport.wav', false)
	# set_dungeon land, level=0, x=5, y=17, dir=0
	return

static func XAP70() : #70
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('As you are leaving the cave you hear a loud roar behind you.  It comes from where you found the small child.  As you attempt to determine the identity of the creatures you see a group of large trolls running in your direction on flapping feet.', 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(158, 158, 30001, "", 0)
	return

static func XAP71() : #71
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('"Very well then.   Guards!  Show these fine people to the door, they have no valid business in the castle this day.  Farewell good people."', 'message nod.wav')
	return


static func XAP72() : #72
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The creatures that caused the demise of the former occupant are now back searching for more food.', 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(178, 178, 0, "", 0)
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func XAP73() : #73
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('Other scenarios utilize the capabilities of the Realmz scenario driver to a greater extent.  These scenarios feature a definite plot line, new monsters, new magical items and more dangerous encounters.', 'message nod.wav')
	# redraw
	# [200 0 [1 1 0 14 15]]
	return

static func XAP74() : #74
	var textRect = UI.ow_hud.textRect
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	ScriptHelperFuncsClass.play_sound('ghost wail.wav', true)
	ScriptHelperFuncsClass.play_sound('spirit release.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('Free after so many centuries of bondage,  the ghostly apparition begins to wail forcefully.  Stabbing pain shoots up your spine and throughout your mind.', 'message nod.wav')
	# heal_party mult=-6, low_range=1, high_range=6, sound=10141, string=0
	ScriptHelperFuncsClass.play_sound('pain.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('Staggering about in pain, you are fallen upon by a host of ethereal beings intent on your destruction.  "Foolish mortals!  Now I shall give you your great gift-the eternal peace of death!"', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound('ghost summon.wav', false)
	return "XAP75"

static func XAP75() : #75
	var textRect = UI.ow_hud.textRect
	# jmp_battle battle_low=198, battle_high=0, loss_xap=back_up, sound=699, string=0
	ScriptHelperFuncsClass.play_sound('spirit release.wav', false)
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(198, 198, 699, "", 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('Though you have defeated this group of beings, the bond that imprisoned others of their kind to this room has been destroyed.  Dozens of wispy forms flee from the room.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Soon, ghostly wailing and the agonizing growls of dead and dying Dogre fills the halls.  Within minutes, the carnage is over.  The ghosts have sated their appetite for life. They return to the nether regions from which they have so long been absent.', 'message nod.wav')
	# victory_points 20000
	# change_rect level=7, id=18, times_in_10k=0, new_battle_low=0, new_battle_high=0
	# change_rect level=7, id=17, times_in_10k=0, new_battle_low=0, new_battle_high=0
	ScriptHelperFuncsClass.change_map_tile_Divinity(7, 40, 61, 111, "land")
	return

static func XAP76() : #76
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('"Well then, don\'t waste more of my time.  No one cares about old Bregwart.  I expect many believe that I disappeared from sight and died long ago.  I might as well end it all."  Clapping her hands twice, she disappears in a flash of smoke and sulfur.', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound('magic teleport.wav', true)
	ScriptHelperFuncsClass.play_sound('magic heal.wav', false)
	return

static func XAP77() : #77
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(8, 49, 68, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('Bregwart leads you to a cleverly hidden passage.  "This way leads to his private chambers.  Cragentooth believes that only he and his most trusted bodyguards are aware of its existence.  I discovered it several years ago."', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('"Have your blades drawn.  Be prepared with magic on your lips.  His warriors are quick of wit and blade.  Our advantage of surprise shall not last long.  He is located just west of here."', 'message nod.wav')
	ScriptHelperFuncsClass.change_map_tile_Divinity(8, 50, 68, 1001, "land")
	return

static func XAP78() : #78
	var textRect = UI.ow_hud.textRect
	# jmp_battle battle_low=204, battle_high=0, loss_xap=back_up, sound=0, string=0
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(204, 204, 0, "", 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('Do you wish to investigate the alcove that the ghostly figure retreated to?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('If you were in search of treasure, you are sadly disappointed.  If you desired to meet the ghostly figure, you\'re in luck.', 'message nod.wav')
	# jmp_battle battle_low=205, battle_high=0, loss_xap=back_up, sound=0, string=0
	battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(205, 205, 0, "", 0)
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(0, 8, 0.0 / 100.0, 0, 0)
	return

static func XAP79() : #79
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The guards watch you closely and exchange covert looks.  One suggests casually, "Looks like you could use some extra coin.  Want to take on the job?"  Do you offer to take the beasts to the gladiator games in exchange for 100 Gold Zembulian Zelots?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 1, 80, "", "")
	if not branch.is_empty(): return branch
	ScriptHelperFuncsClass.play_sound('happy cheer.wav', true)
	ScriptHelperFuncsClass.play_sound('beast roar.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('"Praise the maker, we have a taker!   We\'ll fetch the critters right quick.  Don\'t want to give you time enough to change your mind!"  The guards round up three large beasts imprisoned by heavy manacles. Chains link all three beasts together.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('They provide you with a map that shows  the location of the slave gladiator prison.  "Take them here.  You can give this note to Corporal Sampson.  He will be the one that pays you.  Good luck, but beware!  These beasts are not as dumb as they look!"', 'message nod.wav')
	ScriptHelperFuncsClass.set_quest_id_flag_Divinity(20)
	return "XAP81"

static func XAP80() : #80
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('"Fair enough.  We don\'t blame you.  It\'s not a job we\'re looking forward to.  Our pay barely makes the task worth the risk, but there are few good paying jobs around here to choose from."', 'message nod.wav')
	return

static func XAP81() : #81
	var textRect = UI.ow_hud.textRect
	GameGlobal.minimaps[9] = 1
	ScriptHelperFuncsClass.set_quest_id_flag_Divinity(20)
	return

static func XAP82() : #82
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('growl 1.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('During the battle with the mad troll, one of the troll\'s hands had been severed.  One of your charges hungrily snatched it up to eat.  However, another beast greedily attempted to steal the tender morsel.  This attempt has provoked an all-out brawl.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Before you are able to get the situation under control, the beasts erupt explosively into a convulsing ball of fur and slashing claws.  You are immediately  pulled into the fray.', 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(206, 206, 30001, "", 0)
	await ScriptHelperFuncsClass.display_simple_encounter_from_data("SE17")
	return

static func XAP83() : #83
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('battle start.wav', true)
	await ScriptHelperFuncsClass.display_text_wait_noise('Frenzied shouting suddenly breaks out.  A patrol of men rapidly approach your position.  "They\'re the ones!  They left Corporal Sampson to die like a wretched beast!  Seize them!"', 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(207, 207, 0, "", 0)
	return

static func XAP84() : #84
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('"You\'re wise not to associate with this man and his sordid past."  Two young priests are quickly appointed to carry Sampson off.  "Leave now!  Your business is done." He withdraws back into the temple.  There are sounds of the door being heavily barred.', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound('door close.wav', true)
	ScriptHelperFuncsClass.play_sound('door bar.wav', false)
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func XAP85() : #85
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You arrive at a temple dedicated to Sestuona, goddess of nature.  You will be permitted entry only if you are willing to pay an outrageous price for the temple\'s services.  Your presence here is opposed by a powerful enemy within the sect.', 'message nod.wav')
	# temple inflation_percent=300
	GameGlobal.allow_banking(true)
	GameGlobal.allow_temple(true)
	# Temple with 300% inflated prices
	ScriptHelperFuncsClass.play_sound('temple bell.wav', false)
	return

static func XAP86() : #86
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.clear_quest_id_flag_Divinity(31)
	await ScriptHelperFuncsClass.display_text_wait_noise('The magistrate\'s assistant informs her of your success.  He\'s given authorization to pay you.  You sign a receipt, receive your gold talons, and are quickly ushered back into the magistrate\'s office.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(53)
	await ScriptHelperFuncsClass.display_text_wait_noise('The magistrate thanks you gracefully.  She is notably impressed by your achievement and hopes that you will consider taking on another commission.  You proceed to look over another file.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('A rabid beast is wreaking havoc among the king\'s vast private gardens.  Two servants are dead.  One of the king\'s dear friends was attacked.  You will be rewarded handsomely if you destroy the beast.   Will you take this commission?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	GameGlobal.minimaps[10] = 1
	return "XAP93"

static func XAP87() : #87
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('Do you ask for more money because of the additional work you were required to perform in the king\'s gardens?  OR   Do you accept the original contract amount?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 1, 88, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('"You fools!  Your instructions were to kill one pet beast that had been infected with rabies. Instead, you have killed all of the king\'s pets. The king is beside himself! You have made a mockery of our contract and deserve nothing.  Leave!"', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('"If you don\'t exit this office immediately,  I shall summon my guards and have you thrown into prison."  You beat a hasty retreat out the door.', 'message nod.wav')
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(0, 0, -1.0 / 100.0, 65, 66)
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func XAP88() : #88
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The magistrate sees to it that you are rewarded handsomely with a bonus.  "You have earned it, my brave friends.  Come back later.  I may be able to offer you something in the future."', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(53)
	return

static func XAP89() : #89
	var textRect = UI.ow_hud.textRect
	var branch = await ScriptHelperFuncsClass.branch_on_quest_Divinity(33, false, 1, 87, 0)
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('The magistrate listens with courtesy as you relate your tale of progress.  When you have finished, she responds simply, "I assure you that you will receive your reward as soon as you have successfully cleared out the beast."', 'message nod.wav')
	return

static func XAP90() : #90
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('ground rumble.wav', true)
	ScriptHelperFuncsClass.play_sound('earth shake.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('From deep within the ground, you hear a  rumbling.  The stone floor begins to shake unsteadily.  Large cracks begin to split the stone surface.  Suddenly, the floor erupts into rubble.  An army of huge insects boil up out of the floor.', 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(212, 212, 10090, "", 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('The summoner of this plague of centipedes has disappeared from sight.', 'message nod.wav')
	return

static func XAP91() : #91
	var textRect = UI.ow_hud.textRect
	# jmp_battle battle_low=215, battle_high=0, loss_xap=back_up, sound=611, string="However, one goddess did take pity on the puny race.  She granted humans the power to learn and the ability to work together.  While preoccupied over these ancient myths, you utterly fail to notice the arrival of several strange, tentacled beings."
	ScriptHelperFuncsClass.play_sound('mythic tale.wav', false)
	#start_battle_in_range(low : int, high : int, sfx_id : int, displaytext : String, give_treasure : int) :
	ScriptHelperFuncsClass.start_battle_in_range(215,215, 611,"However, one goddess did take pity on the puny race.  She granted humans the power to learn and the ability to work together.  While preoccupied over these ancient myths, you utterly fail to notice the arrival of several strange, tentacled beings.", 0)
	var battle_outcome = await GameGlobal.battle_end
	await ScriptHelperFuncsClass.display_text_wait_noise('There\'s no doubt that these creatures could have virtually destroyed Realmz and its inhabitants.  Their tentacles try to attach as you strain your sword skills to the limits.  Although you manage to defeat them, you shrink at the mere thought of an army.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Those that inhabit the Realmz are fortunate that these horrendous creatures no longer exist in such vast numbers.', 'message nod.wav')
	# victory_points 15000
	return

static func XAP92() : #92
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=8 rect_num=15 start_coord=39,39 end_coord=50,52 [LRR8/15]
	# RANDOM RECTANGLE REFERENCE dungeon_level=1 rect_num=15 start_coord=39,39 end_coord=50,52 [DRR1/15]
	# spell_party spell=1408, power=1, drv_modifier=0, can_drv=yes
	ScriptHelperFuncsClass.castSpellOnPartyDivinity(1408, 1, 0, true)
	return

static func XAP93() : #93
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.set_quest_id_flag_Divinity(32)
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(5, 66, 89, 0)
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(5, 66, 100.0 / 100.0, 0, 0)
	ScriptHelperFuncsClass.clear_quest_id_flag_Divinity(31)
	return

static func XAP94() : #94
	var textRect = UI.ow_hud.textRect
	# cont_monster_present 134
	if GameGlobal.is_monster_type_present_in_battle(134):
		await ScriptHelperFuncsClass.display_text_wait_noise('The Rat Demi-Lord summons more rats to fight at it\'s side.', 'message nod.wav')
		# summon_monsters type=individual, 133, count=6, sound=30000
		ScriptHelperFuncsClass.play_sound('demon summon.wav', false)
		# summon_monsters type=individual, 125, count=3, sound=30000
		ScriptHelperFuncsClass.play_sound('demon summon.wav', false)
	return

static func XAP95() : #95
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.change_map_tile_Divinity(4, 62, 50, 111, "land")
	ScriptHelperFuncsClass.change_map_tile_Divinity(4, 63, 51, 111, "land")
	ScriptHelperFuncsClass.change_map_tile_Divinity(4, 64, 50, 111, "land")
	return

static func XAP96() : #96
	var textRect = UI.ow_hud.textRect
	return

static func XAP97() : #97
	var textRect = UI.ow_hud.textRect
	return

static func XAP98() : #98
	var textRect = UI.ow_hud.textRect
	return

static func XAP99() : #99
	var textRect = UI.ow_hud.textRect
	return

static func XAP100() : #100
	var textRect = UI.ow_hud.textRect
	return

static func XAP101() : #101
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func XAP102() : #102
	var textRect = UI.ow_hud.textRect
	return

static func XAP103() : #103
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=8 start_coord=0,0 end_coord=41,13 [LRR0/8]
	ScriptHelperFuncsClass.play_sound('friendly greeting.wav', true)
	ScriptHelperFuncsClass.play_sound('magic charm.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('You greet a passing wizard who smiles warmly at you.  You strike up a wonderful conversation and become friends.  He asks about your travels and would like to know if he may accompany you on your exploits?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('You return to his small shack to gather his things before you set off with your new found friend.  His name is Vodalian and he states that he simply loves adventure.', 'message nod.wav')
	# add_npc 71
	GameGlobal.add_npc_to_party(71)
	return

static func XAP104() : #104
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('tavern noise.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('A seedy looking group of gnomes are sitting at a vomit stained table.  They are swilling cheap grog from a clay jug.  They seem more concerned with getting more than their share of the wine and pay you little attention.', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound('battle start.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('Just as you\'re about to dismiss the group,  Vodalian rears up a glinting dagger and charges against one of the gnomes.  "Murderous scum!  I shall avenge my sweet Alex this very day!"', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound('blade clash.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('You burst forth in an attempt to restrain Vodalian.   Gnomes rush from the shadows to aid their drunken friends.', 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(217, 217, 0, "", 0)
	var branch = await ScriptHelperFuncsClass.branch_NPC_in_party_Divinity("71", 1, 105, 0, 0)
	if not branch.is_empty(): return branch
	return

static func XAP105() : #105
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('tavern noise.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('Vodalian thanks you for your aid.  "This vermin slew my son.  Alex was an extremely intelligent and talented pupil.  He could have grown to become a powerful mage.  This foul creature deserved a more cruel demise."', 'message nod.wav')
	return

static func XAP106() : #106
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=3 rect_num=3 start_coord=0,0 end_coord=90,90 [LRR3/3]
	return

static func XAP107() : #107
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('spell dispel.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('With the death of the cleric, the magical enchantments that animates his mindless undead army fades.  Without the magic to sustain them, the corpses collapse to the ground.', 'message nod.wav')
	# kill_lower_undead
	GameGlobal.remove_lower_undead_from_battle()
	return

static func XAP108() : #108
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('magic cast.wav', true)
	ScriptHelperFuncsClass.play_sound('spirit release.wav', false)
	# spell_picked spell=2301, power=1, drv_modifier=0, can_drv=yes
	ScriptHelperFuncsClass.castSpellOnPickedDivinity(2301, 1, 0, true)
	return

static func XAP109() : #109
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('blade clash.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('The goblins scatter.  The body of their chief lies broken and still.  Blood gurgles forth amid the lonely quiet.', 'message nod.wav')
	# rout_monsters 92, 129, 130, 116, 0
	GameGlobal.rout_monster_types_from_battle([92, 129, 130, 116])
	return

static func XAP110() : #110
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('organic death.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('Upon the destruction of the mush mound, the surrounding podlings wither and die.', 'message nod.wav')
	# destroy_related 37, count=8, unused=0, unused=0, force=false
	GameGlobal.destroy_related_monsters(37, 8, false)
	#Code 42: Branch on Percent Chance branch_on_random_divinity(type:int, low:int, high:int, sound_id:int, message : String)
	#branch_percent_chance_divinity(percent : int, whatdo : int, type : int, number : int, lineskip : int)
	var branch = await ScriptHelperFuncsClass.branch_percent_chance_divinity(75, 0, 0, 0, 0)
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('Your movements attract the attention of another mush mound.', 'message nod.wav')
	# summon_monsters type=219, 0, count=0, sound=640
	ScriptHelperFuncsClass.play_sound('slime.wav', false)
	return

static func XAP111() : #111
	var textRect = UI.ow_hud.textRect
	# set_dungeon 6, level=5, x=2, y=0, dir=0
	return

static func XAP112() : #112
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('organic death.wav', true)
	await ScriptHelperFuncsClass.display_text_wait_noise('Upon the destruction of the mush mound, the surrounding podlings wither and die.', 'message nod.wav')
	# destroy_related 42, count=all, unused=0, unused=0, force=false
	GameGlobal.destroy_related_monsters(42, -1, false)
	var branch = await ScriptHelperFuncsClass.branch_percent_chance_divinity(75, 0, 0, 0, 0)
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('Your movements attract the attention of another mush mound.', 'message nod.wav')
	# summon_monsters type=219, 0, count=0, sound=640
	ScriptHelperFuncsClass.play_sound('slime.wav', false)
	return

static func XAP113() : #113
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('spell summon.wav', true)
	ScriptHelperFuncsClass.play_sound('creature summon.wav', false)
	# summon_monsters type=individual, 62, count=6, sound=640
	ScriptHelperFuncsClass.play_sound('slime.wav', false)
	return

static func XAP114() : #114
	var textRect = UI.ow_hud.textRect
	# spell_picked spell=3202, power=2, drv_modifier=0, can_drv=yes
	ScriptHelperFuncsClass.castSpellOnPickedDivinity(3202, 2, 0, true)
	var branch = await ScriptHelperFuncsClass.branch_percent_chance_divinity(80, 0, 0, 0, 0)
	if not branch.is_empty(): return branch
	# summon_monsters type=individual, 73, count=2, sound=640
	ScriptHelperFuncsClass.play_sound('slime.wav', false)
	return

static func XAP115() : #115
	var textRect = UI.ow_hud.textRect
	# spell_picked spell=3202, power=2, drv_modifier=0, can_drv=yes
	ScriptHelperFuncsClass.castSpellOnPickedDivinity(3202, 2, 0, true)
	var branch = await ScriptHelperFuncsClass.branch_percent_chance_divinity(80, 0, 0, 0, 0)
	if not branch.is_empty(): return branch
	# summon_monsters type=individual, 72, count=2, sound=640
	ScriptHelperFuncsClass.play_sound('slime.wav', false)
	return

static func XAP116() : #116
	var textRect = UI.ow_hud.textRect
	var branch = await ScriptHelperFuncsClass.branch_percent_chance_divinity(85, 0, 0, 0, 0)
	if not branch.is_empty(): return branch
	# summon_monsters type=individual, 83, count=-3, sound=640
	ScriptHelperFuncsClass.play_sound('slime.wav', false)
	return

static func XAP117() : #117
	var textRect = UI.ow_hud.textRect
	# macro_criteria when=round_number, round_percent_chance=2, repeat=none, xap_low=118, xap_high=0
	# This would be handled by the battle system's macro criteria
	return

static func XAP118() : #118
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The cleric emits a low, guttural chant.  Near the cavern wall, corpses twitch and writhe.  Compelled to serve as  reinforcements to the cleric\'s unholy army, the grotesque bodies awkwardly disentangle themselves.', 'message nod.wav')
	# summon_monsters type=individual, 78, count=-10, sound=30002
	ScriptHelperFuncsClass.play_sound('beast roar.wav', false)
	return

static func XAP119() : #119
	var textRect = UI.ow_hud.textRect
	# macro_criteria when=percent_chance, round_percent_chance=25, repeat=each_round, xap_low=120, xap_high=0
	# This would be handled by the battle system's macro criteria
	return

static func XAP120() : #120
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('blade clash.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('The clamor of battle attracts the attention of several krise.  They rush to the aid of their clansmen.', 'message nod.wav')
	# summon_monsters type=individual, 80, count=-8, sound=30001
	ScriptHelperFuncsClass.play_sound('growl 1.wav', false)
	return

static func XAP121() : #121
	var textRect = UI.ow_hud.textRect
	# cont_monster_present 131
	# macro_criteria when=percent_chance, round_percent_chance=40, repeat=each_round, xap_low=122, xap_high=0
	# This would be handled by the battle system's macro criteria
	return

static func XAP122() : #122
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('battle start.wav', true)
	await ScriptHelperFuncsClass.display_text_wait_noise('Several warriors from the village rush to defend their chief.', 'message nod.wav')
	# summon_monsters type=individual, 92, count=-4, sound=10136
	ScriptHelperFuncsClass.play_sound('battle start.wav', false)
	# summon_monsters type=individual, 130, count=-2, sound=10136
	ScriptHelperFuncsClass.play_sound('battle start.wav', false)
	return

static func XAP123() : #123
	var textRect = UI.ow_hud.textRect
	# macro_criteria when=percent_chance, round_percent_chance=45, repeat=each_round, xap_low=124, xap_high=0
	# This would be handled by the battle system's macro criteria
	return

static func XAP124() : #124
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('demon summon.wav', true)
	await ScriptHelperFuncsClass.display_text_wait_noise('Several krise arrive on the scene.  The sounds of battle reverberating throughout the caverns have brought them running to investigate the commotion.', 'message nod.wav')
	# summon_monsters type=individual, 80, count=-10, sound=0
	return

static func XAP125() : #125
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('demon summon.wav', true)
	ScriptHelperFuncsClass.play_sound('magic teleport.wav', true)
	ScriptHelperFuncsClass.play_sound('spell launch 3.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('With the annihilation of Rewop, his companions are no longer able to remain in the Realmz.  They quickly fade away, returning to the smoky Abyss of their true home.', 'message nod.wav')
	# destroy_related 4, count=all, unused=0, unused=0, force=false
	GameGlobal.destroy_related_monsters(4, -1, false)
	return

static func XAP126() : #126
	var textRect = UI.ow_hud.textRect
	# macro_criteria when=percent_chance, round_percent_chance=25, repeat=each_round, xap_low=127, xap_high=0
	# This would be handled by the battle system's macro criteria
	return

static func XAP127() : #127
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('demon cast.wav', true)
	await ScriptHelperFuncsClass.display_text_wait_noise('Rewop summons a minor demon to fight at his side.  He is an intimidating, powerful foe.', 'message nod.wav')
	# summon_monsters type=individual, 4, count=1, sound=605
	ScriptHelperFuncsClass.play_sound('demon appear.wav', false)
	return

static func XAP128() : #128
	var textRect = UI.ow_hud.textRect
	# spell_picked spell=4606, power=3, drv_modifier=30, can_drv=yes
	ScriptHelperFuncsClass.castSpellOnPickedDivinity(4606, 3, 30, true)
	return

static func XAP129() : #129
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=3 rect_num=4 start_coord=26,72 end_coord=40,82 [LRR3/4]
	ScriptHelperFuncsClass.play_sound('lava bubble.wav', true)
	ScriptHelperFuncsClass.play_sound('growl 1.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('Deep crags and pits of sulfurous lava make the footing treacherous.  Periodically, growls belch from the hot inner recesses.  It\'s difficult to believe that some creature could breathe and survive these steamy, molten pits.', 'message nod.wav')
	# change_rect level=3, id=4, times_in_10k=300, new_battle_low=220, new_battle_high=220
	return

static func XAP130() : #130
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('insect swarm.wav', true)
	await ScriptHelperFuncsClass.display_text_wait_noise('More centipedes boil up from beneath the floor tiles.  Without a pause, they crunch over the dead husks of their own kind in their relentless pursuit of you.', 'message nod.wav')
	# summon_monsters type=individual, 1, count=12, sound=626
	ScriptHelperFuncsClass.play_sound('insect swarm.wav', false)
	return

static func XAP131() : #131
	var textRect = UI.ow_hud.textRect
	# cont_monster_present 31
	# macro_criteria when=percent_chance, round_percent_chance=25, repeat=each_round, xap_low=132, xap_high=0
	# This would be handled by the battle system's macro criteria
	return

static func XAP132() : #132
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The Widow of the Web possesses the ability to control lesser arachnids.  She draws on this power to compel her lesser cousins to aid her in battle.', 'message nod.wav')
	# summon_monsters type=individual, 76, count=-3, sound=626
	ScriptHelperFuncsClass.play_sound('insect swarm.wav', false)
	# summon_monsters type=individual, 21, count=-2, sound=626
	ScriptHelperFuncsClass.play_sound('insect swarm.wav', false)
	return

static func XAP133() : #133
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('At the death of their leader, troopers begin to scatter and run.  You repeatedly bellow out orders for them to stand their ground.  The situation deteriorates into panic and disorder.', 'message nod.wav')
	# rout_monsters 49, 0, 0, 0, 0
	GameGlobal.rout_monster_types_from_battle([49])
	return

static func XAP134() : #134
	var textRect = UI.ow_hud.textRect
	# macro_criteria when=round_number, round_percent_chance=1, repeat=none, xap_low=130, xap_high=0
	# This would be handled by the battle system's macro criteria
	return

static func XAP135() : #135
	var textRect = UI.ow_hud.textRect
	# cont_monster_present 439
	if GameGlobal.is_monster_type_present_in_battle(439):
		await ScriptHelperFuncsClass.display_text_wait_noise('You walk down a dimly lit passage.  The odor of cheap wine intermingles with   spiced potatoes.  The raucous din of drunken patrons swells the close, musty hallway.', 'message nod.wav')
		# rout_monsters 92, 93, 129, 130, 0
		GameGlobal.rout_monster_types_from_battle([92, 93, 129, 130])
	return

static func XAP136() : #136
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.set_quest_id_flag_Divinity(31)
	return

static func XAP137() : #137
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func XAP138() : #138
	var textRect = UI.ow_hud.textRect
	# cont_monster_present 132
	if GameGlobal.is_monster_type_present_in_battle(132):
		var branch = await ScriptHelperFuncsClass.branch_percent_chance_divinity(66, 0, 0, 0, 0)
		if not branch.is_empty(): return branch
		await ScriptHelperFuncsClass.display_text_wait_noise('Encouraged by countless mugs of ale, a few of Bigbelly\'s buddies rise to attack.', 'message nod.wav')
		# summon_monsters type=individual, 91, count=-4, sound=30000
		ScriptHelperFuncsClass.play_sound('demon summon.wav', false)
	return

static func XAP139() : #139
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.change_map_tile_Divinity(4, 3, 7, 111, "land")
	ScriptHelperFuncsClass.change_map_tile_Divinity(4, 3, 8, 111, "land")
	await ScriptHelperFuncsClass.display_text_wait_noise('The lava begins to drain from the pool.  It seeps into what must be an underground storage tank.', 'message nod.wav')
	ScriptHelperFuncsClass.set_quest_id_flag_Divinity(75)
	var branch = await ScriptHelperFuncsClass.branch_on_quest_Divinity(76, false, 1, 141, 0)
	if not branch.is_empty(): return branch
	return

static func XAP140() : #140
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.change_map_tile_Divinity(4, 3, 1, 118, "land")
	ScriptHelperFuncsClass.set_quest_id_flag_Divinity(76)
	var branch = await ScriptHelperFuncsClass.branch_on_quest_Divinity(75, false, 1, 141, 0)
	if not branch.is_empty(): return branch
	return

static func XAP141() : #141
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('earth shake.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('With both levers thrown, you feel a low rumble below ground.  In now dawns on you that fire and water don\'t mix.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('The minotaurs must have used the lava for heat and the cool water to drink.  However, with both the lava and water in the storage tank below, a great gush of steam fills the room.  You are literally cooking alive.', 'message nod.wav')
	# change_rect level=4, id=0, times_in_10k=7000, new_battle_low=0, new_battle_high=0
	return

static func XAP142() : #142
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=4 rect_num=0 start_coord=0,0 end_coord=16,11 [LRR4/0]
	# heal_party mult=-1, low_range=1, high_range=1, sound=699, string=0
	ScriptHelperFuncsClass.play_sound('spirit release.wav', false)
	return

static func XAP143() : #143
	var textRect = UI.ow_hud.textRect
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(222, 222, 0, "", 0)
	ScriptHelperFuncsClass.set_quest_id_flag_Divinity(77)
	return

static func XAP144() : #144
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(0, 46, 1, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('You are hurled back by the ferocity of the evil within.', 'message nod.wav')
	return

static func XAP145() : #145
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.change_map_tile_Divinity(6, 26, 56, 111, "land")
	ScriptHelperFuncsClass.change_map_tile_Divinity(6, 26, 57, 111, "land")
	await ScriptHelperFuncsClass.give_treasure_with_id(27)
	return

static func XAP146() : #146
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('Olif ponders for a moment and then nods.  "Very well, since you are so sure of yourself, you can indeed have what I have in my pocket."', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound('ghost summon.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('Olif reaches in his pocket and pulls out a bright copper tarsk.  He flips it at your feet and walks away, "Don\'t spend it all in one place!"', 'message nod.wav')
	return

static func XAP147() : #147
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.give_treasure_with_id(61)
	await ScriptHelperFuncsClass.display_text_wait_noise('He grudgingly hands you the sack of coins.  "If I were you, I would be moving on.  Quite a few in this fine establishment would not mind slitting your throat for that coin.  Now be gone before I have you thrown out!"', 'message nod.wav')
	return

static func XAP148() : #148
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('mechanism.wav', false)
	ScriptHelperFuncsClass.change_map_tile_Divinity(7, 81, 63, 71, "land")
	ScriptHelperFuncsClass.change_map_tile_Divinity(7, 79, 63, 111, "land")
	ScriptHelperFuncsClass.play_sound('mechanism.wav', false)
	ScriptHelperFuncsClass.change_map_tile_Divinity(7, 82, 63, 71, "land")
	ScriptHelperFuncsClass.change_map_tile_Divinity(7, 83, 63, 71, "land")
	ScriptHelperFuncsClass.play_sound('mechanism.wav', false)
	return "XAP149"

static func XAP149() : #149
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.change_map_tile_Divinity(7, 80, 63, 111, "land")
	ScriptHelperFuncsClass.play_sound('mechanism.wav', false)
	ScriptHelperFuncsClass.change_map_tile_Divinity(7, 81, 63, 111, "land")
	ScriptHelperFuncsClass.change_map_tile_Divinity(7, 82, 63, 111, "land")
	ScriptHelperFuncsClass.play_sound('magic heal.wav', false)
	ScriptHelperFuncsClass.change_map_tile_Divinity(7, 83, 63, 111, "land")
	# heal_party mult=-6, low_range=1, high_range=10, sound=642, string=0
	ScriptHelperFuncsClass.play_sound('magic heal.wav', false)
	#start_battle_in_range(low : int, high : int, sfx_id : int, displaytext : String, give_treasure : int)
	ScriptHelperFuncsClass.start_battle_in_range(187, 187, 30001, "You unwise decision to pull the lever has not only caused you to suffer searing pain, but has attracted the attention of a nearby group of apprentices.", 0)
	var battle_outcome = await GameGlobal.battle_end
	return

static func XAP150() : #150
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.start_battle_in_range(235,235,10107, "My enemy is dead, but you shall substitute in his place.\"  With lightning quick reflexes, he smashes a pair of amber crystals at his feet.  As you clear the smoke from your eyes you stair at the a pair of immense beings.", 0)
	var battle_outcome = await GameGlobal.battle_end
	ScriptHelperFuncsClass.change_map_tile_Divinity(7, 72, 75, 111, "land")
	return

static func XAP151() : #151
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.change_map_tile_Divinity(6, 14, 10, 437, "land")
	ScriptHelperFuncsClass.change_map_tile_Divinity(6, 13, 11, 490, "land")
	ScriptHelperFuncsClass.change_map_tile_Divinity(6, 12, 11, 488, "land")
	ScriptHelperFuncsClass.change_map_tile_Divinity(6, 13, 10, 487, "land")
	ScriptHelperFuncsClass.change_map_tile_Divinity(6, 12, 10, 486, "land")
	ScriptHelperFuncsClass.change_map_tile_Divinity(6, 11, 10, 489, "land")
	return

static func XAP152() : #152
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.change_map_tile_Divinity(6, 14, 10, 111, "land")
	ScriptHelperFuncsClass.change_map_tile_Divinity(6, 13, 10, 111, "land")
	ScriptHelperFuncsClass.change_map_tile_Divinity(6, 12, 10, 111, "land")
	ScriptHelperFuncsClass.change_map_tile_Divinity(6, 11, 10, 111, "land")
	ScriptHelperFuncsClass.change_map_tile_Divinity(6, 12, 11, 111, "land")
	ScriptHelperFuncsClass.change_map_tile_Divinity(6, 13, 11, 111, "land")
	ScriptHelperFuncsClass.start_battle_in_range(237,237,653, "As you clean your blades on the tunics of the fallen, you hear one of the employees of this establishment yell out the door to a group of nearby town militia.  She is calling for help.  You hear the clank of weapons and armor as they come running.", 0)
	var battle_outcome = await GameGlobal.battle_end
	await ScriptHelperFuncsClass.display_text_wait_noise('You hear the same woman call to yet another group.  However, they are far off and this gives you ample time to scram.', 'message nod.wav')
	return

static func XAP153() : #153
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('magic charm.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('Suddenly Reppep Rd stops attacking. "Oie!  Me be sorry folks. I guess I lost me head.  Twas the girl who me thinks took me coin.  Perhaps you will let me travel with you for a while. Tis a dangerous place to be traveling alone. Tink I tag along with ye."', 'message nod.wav')
	# end_battle
	GameGlobal.end_current_battle()
	return

static func XAP154() : #154
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=6 rect_num=16 start_coord=64,26 end_coord=87,29 [LRR6/16]
	await ScriptHelperFuncsClass.start_complex_encounter("CE10")
	return

static func XAP155() : #155
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You scrape the disgusting site clear and find a small skeletal figure.  The figure is without any ornaments save a leather belt, a wand clasped in one hand, and a scroll case in the other.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(67)
	await ScriptHelperFuncsClass.display_text_wait_noise('The scroll case holds writings that predict the rule of the Realmz by Vixies.  The spider god.', 'message nod.wav')
	GameGlobal.minimaps[13] = 1
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(0, 58, 100.0 / 100.0, 0, 0)
	return

static func XAP156() : #156
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('spell launch 4.wav', false)
	ScriptHelperFuncsClass.change_map_tile_Divinity(0, 47, 1, 155, "land")
	ScriptHelperFuncsClass.play_sound('spell launch 3.wav', false)
	ScriptHelperFuncsClass.change_map_tile_Divinity(0, 47, 2, 155, "land")
	await ScriptHelperFuncsClass.display_text_wait_noise('With the Widow of the Web banished from the Realmz, her powers to keep the temple also in the Realmz fails.  The Widow will have to face Vixies and explain her failure to achieve victory over a few puny mortals.', 'message nod.wav')
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(5, 93, 0.0 / 100.0, 0, 0)
	return

static func XAP157() : #157
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('Even with the great advantage of surprise on their side, they cannot hope to defeat the entire force of Dogre.  "You help, we help you.  We know big secret, but we too big to fit.  You help us?"  Do you ally with the gnath for now?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 1, 158, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('The gnath sketches out a crude map that shows a secret tunnel.  He claims there is treasure on the other side but they are too big to fit through the tunnel.  "Now you come with us.  We attack now why we still can."', 'message nod.wav')
	GameGlobal.minimaps[14] = 1
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(1, 69, 0.0 / 100.0, 0, 0)
	ScriptHelperFuncsClass.play_sound('friendly greeting.wav', false)
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(1, 42, 74, 0)
	return "XAP159"

static func XAP158() : #158
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('magic charm.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('"You no can tell  we here.  You are bad!"  The gnath warriors jump on you like a ton of bricks.', 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(245, 245, 30001, "", 0)
	# string 930 - This appears to be a reference number without actual text
	battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(245, 245, 30001, "", 0)
	return

static func XAP159() : #159
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You travel with your large but smelly friends past several turns in the hall.  "Behind is great Dogre army.  We surprise and kill all we can.  Then no more Dogre."', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound('door break.wav', true)
	ScriptHelperFuncsClass.play_sound('door bar.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('With the help of two strong gnath, you smash the door in.  Beyond is a large force of Dogre.  Perhaps too many.  Even the surprise on the gnath leaders face says that there are more Dogre than he anticipated.', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound('blade clash.wav', false)
	# jmp_battle battle_low=246, battle_high=0, loss_xap=back_up, sound=0, string="Loosing no time, you and your gnath friends wade into the throng and cut down as many as you can before they can form up.  However, there are so many that things soon turn against you."
	#branching_battle_Divinity(low: int, high : int, xap_or_backstep : int, sfx_id : int, displaytext : String) :
	#var branch = await ScriptHelperFuncs.branching_battle_Divinity()
	#if branch != "GO_ON" : return branch
	var branch = await ScriptHelperFuncs.branching_battle_Divinity(246,246,-1,0,"Loosing no time, you and your gnath friends wade into the throng and cut down as many as you can before they can form up.  However, there are so many that things soon turn against you.")
	if branch != "GO_ON" : return branch
	# jmp_battle battle_low=246, battle_high=0, loss_xap=back_up, sound=0, string=0
	branch = await ScriptHelperFuncs.branching_battle_Divinity(246,246,-1,0,"")
	if branch != "GO_ON" : return branch
	# jmp_battle battle_low=247, battle_high=0, loss_xap=back_up, sound=0, string=0
	branch = await ScriptHelperFuncs.branching_battle_Divinity(247,247,-1,0,"")
	if branch != "GO_ON" : return branch
	return

static func XAP160() : #160
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 3, 25, 0)
	return

static func XAP161() : #161
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('organic death.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('Upon the destruction of the mush mound, the surrounding podlings wither and die.', 'message nod.wav')
	# destroy_related 44, count=all, unused=0, unused=0, force=false
	GameGlobal.destroy_related_monsters(44, -1, false)
	var branch = await ScriptHelperFuncsClass.branch_percent_chance_divinity(75, 0, 0, 0, 0)
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('Your movements attract the attention of another mush mound.', 'message nod.wav')
	# summon_monsters type=219, 0, count=0, sound=640
	ScriptHelperFuncsClass.play_sound('slime.wav', false)
	return

static func XAP162() : #162
	var textRect = UI.ow_hud.textRect
	# picture 32128
	ScriptHelperFuncsClass.display_picture_file('32128.png')
	return

static func XAP163() : #163
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('spirit release.wav', false)
	# change_tileset new_tileset=10, dark=no, level=0
	GameGlobal.change_tileset(10, false, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('You arrived in Bywater just in time as a winter storm has just covered the entire region in a thick blanket of snow.', 'message nod.wav')
	return

static func XAP164() : #164
	var textRect = UI.ow_hud.textRect
	return

static func XAP165() : #165
	var textRect = UI.ow_hud.textRect
	return

static func XAP166() : #166
	var textRect = UI.ow_hud.textRect
	#start_battle_in_range(low : int, high : int, sfx_id : int, displaytext : String, give_treasure : int) :
	ScriptHelperFuncsClass.start_battle_in_range(208,208,0, "From behind you, several heavily armed orcs approach.  Congratulations!  It appears that with just a minimum amount of forethought, you have managed to wedge yourself between a rock and a hard place.", 0)
	var battle_outcome = await GameGlobal.battle_end
	ScriptHelperFuncsClass.set_quest_id_flag_Divinity(31)
	return

static func XAP167() : #167
	var textRect = UI.ow_hud.textRect
	# change_rect level=1, id=3, times_in_10k=0, new_battle_low=0, new_battle_high=0
	await ScriptHelperFuncsClass.start_complex_encounter_Divinity(5)
	return

static func XAP168() : #168
	var textRect = UI.ow_hud.textRect
	# revive_npc_after
	GameGlobal.revive_npcs_after_battle()
	return





















static func SE0XAP0():
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The lump of a man leans close so the guards do not hear. "For 300 Gold, I shall give you an invitation, but you must swear to use it but once. To do so more than once will raise my ire."', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 1, 0, "Pay 300 gold", "Decline")
	if not branch.is_empty(): return branch
	var has_money = await ScriptHelperFuncsClass.take_money_if_possible(300)
	if has_money:
		await ScriptHelperFuncsClass.display_text_wait_noise('He hands you an invitation to the Castle Anthrax.', 'message nod.wav')
		await ScriptHelperFuncsClass.give_treasure_with_id(0)
		await ScriptHelperFuncsClass.display_text_wait_noise('In a booming voice, he pronounces you valid petitioners and bids the guards to let you pass into Castle Anthrax.', 'message nod.wav')
	return

static func SE0XAP1():
	var textRect = UI.ow_hud.textRect
	var branch = await ScriptHelperFuncsClass.branch_item_possession_divinity(990, 0, 0, 1, 2)
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('The Magistrate gazes at you and speaks "Without an invitation you will not be allowed through the main gate. Perhaps we can work something out."', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('The lump of a man leans close so the guards do not hear. "For 300 Gold, I shall give you a writ of entrance, but you will be able to use it but once."', 'message nod.wav')
	branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 1, 3, "Pay 300 gold", "Decline")
	if not branch.is_empty(): return branch
	var has_money = await ScriptHelperFuncsClass.take_money_if_possible(300)
	if has_money:
		await ScriptHelperFuncsClass.give_treasure_with_id(0)
		await ScriptHelperFuncsClass.display_text_wait_noise('In a booming voice, he pronounces you valid petitioners and bids the guards to let you pass into Castle Anthrax.', 'message nod.wav')
	return

static func SE0XAP2():
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The Magistrate examines your invitation carefully and nods with approval. "Everything seems to be in order. You may proceed to Castle Anthrax."', 'message nod.wav')
	return

static func SE0XAP3():
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('He bids you farewell as you make your way from the gate house.', 'message nod.wav')
	return

static func SE1XAP0():
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The sergeant of the guard grins in anticipation. "You shall swing from the gallows ere today\'s sun bids us farewell." The battle is joined.', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound('30000', true)
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(1, 1, 30000, "", 0)
	#ScriptHelperFuncsClass.change_rect_Divinity(0, 0, 150, 4, 8, 0, 0) #TODO MANUALLY
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func SE1XAP1():
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The Magistrate screeches in fear. "Hold men, for I fear they have foul intentions!" With your hostage you manage to beat a hasty retreat from the guardhouse and disappear. Twas a difficult task with such bulk in tow.', 'message nod.wav')
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(0, 4, 3, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('With the reluctant aid of the Magistrate you find your way to a secluded alley. From the shouts you here in the streets, it would seem the whole kingdom is in search of your whereabouts.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_simple_encounter_Divinity(2)
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(0, 0, -100.0 / 100.0, 0, 0)
	return

static func SE1XAP2():
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('The guards begin to pursue when you here the Magistrate bellow with laughter as he calls them back. "Run foul vermin, for we are far too busy to chase the likes of you!" It would seem they did not take you as too serious a threat.', 'message nod.wav')
	return

static func SE1XAP3():
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('After you explain that you only want to gain entrance to the court on honest business, the Magistrate is so amused that he lets you enter. "Since you chose not to resist, I deem you to be honest folk, and this is an honest kingdom. Enter as you will."', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('He hands you an invitation to the Castle Anthrax.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(0)
	return

static func SE2XAP0():
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('As he flees, he shouts to no one in particular. "Help, I am being waylaid. Help....Help!" Unfortunately for you, the streets are filled with troops searching for you and they stream towards you. They do not even ask you to throw down your arms.', 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(2, 2, 10136, "", 0)
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func SE2XAP1():
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You send him to the gods. In his dying whispers he says a prayer to an unfamiliar god. It would seem he has cursed you with his last gasp. One might hope he was not held in high regard by his deity. You search the body.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(1)
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 4, 3, 0, 0)
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 1, 3, 0, 0)
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 0, 3, 0, 0)
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(0, 0, -100.0 / 100.0, 0, 0)
	#ScriptHelperFuncsClass.change_rect_Divinity(0, 0, 150, 4, 8, 0, 0)  #TODO fix  manually
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func SE2XAP2():
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You take all his possessions as you strip him down to his breeches. "You ruffians shall pay dearly for this! The King will spare no expense at expunging you and your kind!" he cries.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(1)
	ScriptHelperFuncsClass.eliminate_current_se_option_divinity(3)
	ScriptHelperFuncsClass.eliminate_current_se_option_divinity(4)
	#ScriptHelperFuncsClass.change_rect_Divinity(0, 0, 150, 4, 8, 0, 0)
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func SE2XAP3():
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('"Well, I should guess so. I shall explain the error of your ways to the city guard. It is fortunate for you that I am a patient man. Now be gone, for I must return to my duties."', 'message nod.wav')
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func SE3XAP0():
	var textRect = UI.ow_hud.textRect
	var has_money = await ScriptHelperFuncsClass.take_money_if_possible(2)
	if has_money:
		var branch = await ScriptHelperFuncsClass.branch_percent_chance_divinity(50, 1, 1, 2, 0)
		if not branch.is_empty(): return branch
		await ScriptHelperFuncsClass.display_text_wait_noise('"The way I see it, those trolls need to be taught a lesson. If the king won\'t take care of it, then the town council should. I\'m telling ya. Someone better do something right quick. People are afraid to leave town and travel the roads at night."', 'message nod.wav')
	return

static func SE3XAP1():
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('"Word has it, there\'s a 5,000 gold piece reward for the capture of the leader of a band of Orcs that have been raiding the village of Sestoon. I believe it, too. A big band of mercenaries arrived today to set out and claim that reward."', 'message nod.wav')
	return

static func SE3XAP2():
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('1100', false)
	var has_money = await ScriptHelperFuncsClass.take_money_if_possible(5)
	if has_money:
		await ScriptHelperFuncsClass.display_text_wait_noise('"Thanks friend." He pockets the coins and pats you on the back. He seems a bit more friendly to you.', 'message nod.wav')
	return

static func SE3XAP3():
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('1101', true)
	ScriptHelperFuncsClass.play_sound('1103', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('"What you want?" "Me no make trouble! Good King say me no have to leave!" His panic quickly subsides as it begins to dawn in his puny mind that you are not the King\'s men and you are not there to kick him out of town.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('"Targ no go out of town. Targ being chased. You help Targ?" He grasps at your sleeve as he stands. "Me go with you, tell big secret. We go to see big iron box near lake and...AAAARRRRGGGG!!" You see a steel point sprout from his chest.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('He pitches forward with a red feathered shaft growing from his back. As bile spews from his slack jaw, he thrusts a slip of paper into your grasp. You see his assassins at the bar. Three very large orcs smiling a toothy grin and brandishing weapons.', 'message nod.wav')
	GameGlobal.minimaps[0][5]=1
	await ScriptHelperFuncsClass.display_simple_encounter_Divinity(4)
	return

static func SE4XAP0():
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('"Oh, I don\'t really know much." She smiles and points to the seedy looking man. "Ask him, he\'s been telling me all kinds of stories all day."', 'message nod.wav')
	ScriptHelperFuncsClass.eliminate_current_se_option_divinity(4)
	return

static func SE4XAP1():
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('As you step from the door, you meet a hailstorm of arrows. They seem to appear from nowhere and pin you down in the doorway. You are forced to retreat inside. By now, they have surely made it to safety.', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound_divinity(-619)
	ScriptHelperFuncsClass.play_sound_divinity(-619)
	ScriptHelperFuncsClass.play_sound_divinity(619)
	await ScriptHelperFuncsClass.heal_party_Divinity(-1, 1, 6, 619)
	ScriptHelperFuncsClass.eliminate_current_se_option_divinity(1)
	return

static func SE4XAP2():
	await ScriptHelperFuncsClass.display_text_wait_noise('Who will do it?', 'message nod.wav')
	await ScriptHelperFuncsClass.request_pc_pick(1)
	var success = await ScriptHelperFuncsClass.pick_chara_on_attribute_or_special_Divinity(6, 45, 0, 0)
	await ScriptHelperFuncsClass.heal_picked_Divinity(-1, 1, 3, 652, 'His body is filthy and unwashed. You find several copper coins that are all but worthless. In your haste to search him you take less caution than is wise and prick yourself on a poison needle concealed in his sleeve.')
	await ScriptHelperFuncsClass.give_Divinity_condition(1, 9, -1, 0)
	await ScriptHelperFuncsClass.eliminate_current_se_option_divinity(3)
	await ScriptHelperFuncsClass.eliminate_current_se_option_divinity(1)

static func SE4XAP3():
	await ScriptHelperFuncsClass.display_text_wait_noise('The town guard is quick to arrive. You explain your view of what happened. The guards prepare to leave with the body and begin a search for his assassins.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('The man in charge of the guards is known by the name of Haikur. He invites you to visit him at the guard\'s barracks. He hands you a paper. "This will allow you to enter Castle Anthrax so you may visit. I believe we have much in common. Good day."', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(2)
	await ScriptHelperFuncsClass.eliminate_se_option_divinity(3, 3)
	await ScriptHelperFuncsClass.eliminate_se_option_divinity(3, 4)

static func SE5XAP0():
	await ScriptHelperFuncsClass.display_text_wait_noise('Thurfur scowls as he walks away. "So be it, fools. The kingdom shall not suffer for your foolish choice. Men, we march east in a few days. With or without Haikur and his friends! Gather your gear and assemble at the east gate! Good day citizens."', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Haikur turns to you, "Thurfur has always had a hot temper. He seldom sees things clearly as do I. Let us prepare for the upcoming battle! Meet me and my men at the south gate when you are ready to depart. These evil goblin folk shall rue this day!"', 'message nod.wav')
	await ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 22, 58, 0, 0)
	await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE5XAP1():
	await ScriptHelperFuncsClass.display_text_wait_noise('Haikur scowls as he walks away. "Very well. I count you amongst fools for not seeing the more serious danger. There seems little I can do. My men march south. All right men! Fall out to the south gate! Good day fine people, to you as well Thurfur."', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Thurfur turns to you, "He is but a fool! We have many preparations to make. Meet me at the east gate when you are ready to depart. We shall teach these foolish Orc tribes that we are their betters! Remember, the east gate. May Adon smile upon us!"', 'message nod.wav')
	await ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 6, 11, 0, 0)
	#await ScriptHelperFuncsClass.change_rect(0, 0, 150, 0, 0) #TODO manually
	await ScriptHelperFuncsClass.set_divinity_script_enabled_flag(0, 38, -1, 0, 0)
	await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE5XAP2():
	await ScriptHelperFuncsClass.display_text_wait_noise('Both men are determined to complete their quest on their own and bid you good day. They set about making preparations for their upcoming battles.', 'message nod.wav')

static func SE6XAP0():
	await ScriptHelperFuncsClass.display_text_wait_noise('He smiles a toothy grin, "Ah, thank you fine people. For a very special price of but 10 Gold, I will let you taste this fine wine." He pulls a rather crusty looking bottle from a pocket and offers it to you. What do you do?', 'message nod.wav')
	var continue_option = await ScriptHelperFuncsClass.yesno_branch_Divinity(1,2,3, "Pay the gold.", "Refuse his offer.")
	if continue_option:
		var has_money = await ScriptHelperFuncsClass.take_money_if_possible(10)
		if has_money:
			await ScriptHelperFuncsClass.display_text_wait_noise('Before you drink the wine, you read the label. It is Bordeaux Sal La Sal, House of Chalingrad, Waterford, 1423. You mention to the cook that you believed the city of Waterford to be but a legend.', 'message nod.wav')
			await ScriptHelperFuncsClass.display_text_wait_noise('"Oh, well. I guess not. I don\'t really know much about such things. I was given this bottle by Master Thew, the chief librarian across the street." The cook bids you good day and departs for the kitchen.', 'message nod.wav')

static func SE6XAP1():
	await ScriptHelperFuncsClass.display_text_wait_noise('The cook\'s face grows red as veins bulge from his neck. He produces a meat cleaver and charges you yelling obscenities. You easily hold him at bay until other patrons pull him into the kitchen. You decide that now is a good time to leave.', 'message nod.wav')

static func SE6XAP2():
	await ScriptHelperFuncsClass.display_text_wait_noise('"Very well. Please feel free to visit this humble house of finery again." The cook retreats to the kitchen as you decide to leave the remnants of your meal to feed the squalor bins.', 'message nod.wav')

static func SE7XAP0():
	var has_money = await ScriptHelperFuncsClass.take_money_if_possible(50)
	if has_money:
		var random_text = await ScriptHelperFuncsClass.display_random_text_from_array_wait(
			['"You\'re cute, honey! Hey, are you one of them mercenary types that\'s here to collect that 5000 gold piece reward I been hearing about? How much of that 5000 do you get? You know, I kinda like you."',
			'"I hear master Thew over at the library is giving away wine from Waterford. I always thought that place was just a legend. If your interested I\'m sure master Thew could tell you all about the place."'
		])
		await ScriptHelperFuncsClass.display_text_wait_noise(random_text, 'message nod.wav')
		#branch_percent_chance_divinity percent_chance=25, action=jump, target_type=simple, target=2, code_index=0
		var random_chance = randi()%100<25
		if random_chance:
			await ScriptHelperFuncsClass.display_simple_encounter_Divinity(2)

static func SE7XAP1():
	await ScriptHelperFuncsClass.display_text_wait_noise('He looks around to see that nobody else is watching too closely. He whispers, "Follow me upstairs. The treasure is ready to be split up."', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('You follow him to a room upstairs. You are standing in the room with seven large men. The door behind you slams shut and you hear a jam being placed behind it. It would seem you have walked into a trap.', 'message nod.wav')
	#teleport_to_map_and_pos_divinity(map_id : int, posx : int, posy : int, sfx_id : int) :
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(6, 73, 7, 0)
	await ScriptHelperFuncsClass.change_tile_anymap_add_flag("map_6",8,7,"ForestDay",111,0 )
	#await ScriptHelperFuncsClass.change_tile(6, 8, 7, 111, "land")
	#ow=22, surprise, high=0, sound_or_lose_xap=10136, string="Yo
	#order should be start_battle_in_range(low : int, high : int, sfx_id : int, displaytext : String, give_treasure : int)
	await ScriptHelperFuncsClass.start_battle_in_range(22, 22, 10136, "You push on the door to attempt a quick escape but it's no use. Your stuck in this room and will have to fight for your lives.", 0)
	#await ScriptHelperFuncsClass.change_rect(6, 19, 0, 0, 0)  #TODO fix manually
	await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE7XAP2():
	await ScriptHelperFuncsClass.display_text_wait_noise('The dwarf thanks you for your interest and asks you to look around. "Ha Ha Ha! You\'ll come back. They always do."', 'message nod.wav')

static func SE7XAP3():
	await ScriptHelperFuncsClass.display_text_wait_noise('As you rejoin the group, you notice you feel a little strange. It becomes apparent that you have caught some kind of disease. It would seem a trip to the Blue Temple is in order. What would your mother say?', 'message nod.wav')
	GameGlobal.last_picked_characters= [UI.ow_hud.selected_character]
	await ScriptHelperFuncsClass.give_Divinity_condition(1, 28, -1, 0)

static func SE8XAP0():
	await ScriptHelperFuncsClass.display_text_wait_noise('You FEEL rather than see a corpse in the coffin. You come to the conclusion that the corpse inside must be invisible. You feel around the corpse and discover a necklace. You remove it and the corpse reappears. You find keys as well.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(7)
	await ScriptHelperFuncsClass.display_text_wait_noise('You could easily barricade this door and rest in this room undisturbed.', 'message nod.wav')
	await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE8XAP1():
	await ScriptHelperFuncsClass.display_text_wait_noise('You carefully place the lid as it was and stand back. Except for the disturbed dust, all is as it was before you entered.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('You could easily barricade this door and rest in this room undisturbed.', 'message nod.wav')

static func SE8XAP2():
	await ScriptHelperFuncsClass.display_text_wait_noise('In the process of demolishing the coffin, a corpse appears out of nowhere. It was in the coffin wearing an ornate necklace that has slipped off its neck. A large piece of stone has destroyed the necklace. However, you do find some iron keys.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(9)
	await ScriptHelperFuncsClass.display_text_wait_noise('You could easily barricade this door and rest in this room undisturbed.', 'message nod.wav')
	await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE9XAP0():
	await ScriptHelperFuncsClass.display_text_wait_noise('He shouts, "You shall pay for your interference! You are a minor problem to deal with!" Zombies shuffle forth to attack you. Their forces are bolstered by myconids and a few ghouls.', 'message nod.wav')
	#battle   low=37, high=0, sound_or_lose_xap=10048, string=0, treasure_mode=all
	#start_battle_in_range(low : int, high : int, sfx_id : int, displaytext : String, give_treasure : int) :
	await ScriptHelperFuncsClass.start_battle_in_range(37, 37, 10048, "", 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('Now that the cleric has perished, the remaining ghouls flee. All the remaining zombies collapse in heaps. One zombie, however, does not collapse. In fact, it turns to you and speaks.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('"Thank you, fools! I was imprisoned by this foppish man and bound to do his bidding. Now that you have set me free of his bonds, I shall take my revenge-not on him, but on ALL the living." He waves his hands and disappears in a ball of flame.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('You gather together the dead bodies and burn them. It would seem there is a new enemy-one who is both undead and magical.', 'message nod.wav')
	await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE9XAP1():
	await ScriptHelperFuncsClass.display_text_wait_noise('"Excellent! After this final batch, my army shall be more than strong enough to defeat the puny defenses of that accursed Spider Tower. Bring them in here and lay them next to the wall."', 'message nod.wav')
	await ScriptHelperFuncsClass.eliminate_current_se_option_divinity(2)

static func SE9XAP2():
	await ScriptHelperFuncsClass.display_text_wait_noise('"I assume that you are not here to deliver bodies. My name is Arrock, high priest of the king\'s archdiocese. He has tasked me to rid the city of that accursed Spider Tower in any manner I see fit. My army of undead will deal the fatal blow."', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('"The days of that foul Spider cult are at an end. In fact, I was expecting one final shipment of bodies to add to my army before I commenced my attack. However, if you were to join me, we would be more than strong enough to attack now. What say ye?"', 'message nod.wav')
	#continue_option=yes, target_type=simple, target=3,
	var continue_option = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 2,3,"YESSS.", "NOPENOPE.")
	if continue_option:
		await ScriptHelperFuncsClass.display_text_wait_noise('"Good! Good! Let us be off to mete out the king\'s justice. I have had my forces digging a tunnel under the Spider Tower for several weeks. Now all is ready to seal their doom. Ha! We shall arrive at their very doorstep."', 'message nod.wav')
		#await ScriptHelperFuncsClass.change_tile(0, 47, 4, -16, "land")
		await ScriptHelperFuncsClass.change_tile_anymap_add_flag("map_0",47,4,"ForestDay",16,0 )
		#modify_ap                level=5, id=89, source_xap=19, level_type=same, result_code=0
		await ScriptHelperFuncsClass.add_Divinity_script_branch_flag(5, 89, 19, 0, 0)
		await ScriptHelperFuncsClass.teleport_to_map_and_pos("map_0", Vector2(47, 3), '')
	else:
		await ScriptHelperFuncsClass.display_text_wait_noise('"In any case, I have waited far too long for the last shipment of bodies. I depart now to deal with this foul tower. Farewell. Tell the king he shall once again be sole master of this fine city." He marches out with his army of undead.', 'message nod.wav')
		await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE10XAP0():
	await ScriptHelperFuncsClass.change_tile_anymap_add_flag('map_6', 26, 56, "Cave", 111)
	await ScriptHelperFuncsClass.start_battle_in_range(46, 46, 10136, "His goblin dogs rush you, literally bowling you over and out the door before you can set up a good defensive position. Goblins join the fray from every direction. It would seem that you have made a gross miscalculation of the goblin king's forces.",0)
	await ScriptHelperFuncsClass.display_text_wait_noise('You have defeated the goblin king\'s strongest warriors. The remaining goblins in the village flee in panic. Inside his hut, the goblin king awaits his fate. As you approach, he begs your mercy as only a goblin could. Do you grant it?', 'message nod.wav')
	var continue_option = await ScriptHelperFuncsClass.yesno_branch_Divinity(0,2,3, "", "")
	if not continue_option:
		await ScriptHelperFuncsClass.display_text_wait_noise('You execute the goblin king and gather whatever you find in the shack as spoils of war. It appears he lived more like a pauper than a king.', 'message nod.wav')
		await ScriptHelperFuncsClass.give_treasure_with_id(12)
		#await ScriptHelperFuncsClass.change_rect(5, 1, -1, 0, 0) #TODO fix manually
		await ScriptHelperFuncsClass.flag_disabled_current_script()
	else:
		await ScriptHelperFuncsClass.display_text_wait_noise('He whimpers in excitement at being spared and speaks, "My people stand no chance now. We must flee, for the krise sluk are too numerous. I show you where they live so you shall know where not to go as well." He gives you a map.', 'message nod.wav')
		await ScriptHelperFuncsClass.give_minimap(4)
		await ScriptHelperFuncsClass.change_tile_anymap_add_flag('map_6', 26, 56,"Cave", 111)
		await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE10XAP1():
	await ScriptHelperFuncsClass.display_text_wait_noise('"I let you go if you pay. You pay king 500 gold and me let you go. You no pay, me have warriors kill you and take gold. PAY!" Do you pay?', 'message nod.wav')
	var continue_option = await ScriptHelperFuncsClass.yesno_branch_Divinity(1,2,0, "", "")
	if continue_option:
		var has_money = await ScriptHelperFuncsClass.take_money_if_possible(500)
		if has_money:
			await ScriptHelperFuncsClass.change_tile_anymap_add_flag('map_6', 26, 56, "Cave",  111)
			await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE10XAP2():
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('"Me king! Lead sneak attack now. You come." He stands and dons his armor and weapons and leads his force to a secret cave just west of the great iron door. "We sneak here. Krise not know we come. We kill them from behind."', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('"Goblin and krise always fight. Now krise have powerful wizard. They kill many goblin. We need kill all krise, but they hide behind great iron door. We no can break it down. Now we find secret cave and sneak up behind. We kill all krise."', 'message nod.wav')
	ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(1, 19, 35, 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('He leads the war party into a long, twisting, turning crevasse. It is barely wide enough to squeeze through. You exit into a large alcove. Once the entire force is assembled, the goblin king leads a small scouting party ahead to set up the ambush.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('You come upon a small band of krise manning a great iron door. It is massive and obviously beyond their building capabilities. The goblin king believes it is the work of a wizard who made a pact with the krise and has helped them kill many goblins.', 'message nod.wav')
	var battle_outcome = await ScriptHelperFuncsClass.start_battle_in_range(47, 47, 10136, "", 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('Plans are laid, and the rest of the force is brought up. On the king\'s command, goblins storm the iron door in great force. The puny krise seem to stand little chance.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('He turns to you and speaks, "You go. We kill krise now. We need your help no more. You go." He turns and leads his forces deeper into the caves in search of krise to kill.', 'message nod.wav')
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 32, 99, 0, 0)
#\t# XAP 167 content (recursively resolved):\n\tScriptHelperFuncsClass.change_rect_Divinity(1, 3, 0, 0, 0, 0, 0)\n\tawait ScriptHelperFuncsClass.display_simple_encounter_Divinity(5)\n\t# end of XAP 167 (with nested expansions)

static func SE11XAP0():
	await ScriptHelperFuncsClass.play_sound('30000', true)
	await ScriptHelperFuncsClass.start_battle_in_range(55, 55, 30001, "", 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('As you search the remains of the troll and goblin, you discover one item of value. A scroll case is jammed in the backpack. It is an odd item for a krise to be carrying.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(17)
	await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE11XAP1():
	await ScriptHelperFuncsClass.display_text_wait_noise('As the troll finishes his meal with a loud belch, he pulls something from a tooth. It appears to be a ribbon commonly used to bind scrolls. His meal included more than first met the eye. The troll wanders off.', 'message nod.wav')
	await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE11XAP2():
	await ScriptHelperFuncsClass.display_text_wait_noise('You leave the ugly brute to dine on his meal. You weren\'t hungry anyway.', 'message nod.wav')
	await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE12XAP0():
	await ScriptHelperFuncsClass.display_text_wait_noise('Small sliders open in the face of the door. Crossbow bolts and rocks hail down on you. Behind the door, you can hear the harsh guttural laughter and sneers of krise.', 'message nod.wav')
	await ScriptHelperFuncsClass.heal_party_Divinity(-3, 1, 4, 619)

static func SE12XAP1():
	await ScriptHelperFuncsClass.display_text_wait_noise('Small sliders open in the face of the door. Crossbow bolts and rocks hail down on you. Behind the door, you can hear the harsh guttural laughter and sneers of krise.', 'message nod.wav')
	await ScriptHelperFuncsClass.heal_party_Divinity(-3, 1, 4, 619)

static func SE12XAP2():
	await ScriptHelperFuncsClass.display_text_wait_noise('Small sliders open in the face of the door. Crossbow bolts and rocks hail down on you. Behind the door, you can hear the harsh guttural laughter and sneers of krise.', 'message nod.wav')
	await ScriptHelperFuncsClass.heal_party_Divinity(-3, 1, 4, 619)

static func SE13XAP0():
	await ScriptHelperFuncsClass.give_treasure_with_id(20)
	await ScriptHelperFuncsClass.display_text_wait_noise('The king races off to make plans for a celebration in your name.', 'message nod.wav')
	await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE13XAP1():
	await ScriptHelperFuncsClass.give_treasure_with_id(21)
	await ScriptHelperFuncsClass.display_text_wait_noise('The king races off to make plans for a celebration in your name.', 'message nod.wav')
	await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE13XAP2():
	await ScriptHelperFuncsClass.give_treasure_with_id(22)
	await ScriptHelperFuncsClass.display_text_wait_noise('The king races off to make plans for a celebration in your name.', 'message nod.wav')
	await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE14XAP0():
	await ScriptHelperFuncsClass.display_text_wait_noise('"I think not, puny mortals. Your destruction is beneath the likes of me. However, it is not beneath the duty of my lieutenants!" The beast\'s hideous laugh courses through your brain. At the same time you hear a low growl sound behind you.', 'message nod.wav')
	await ScriptHelperFuncsClass.start_battle_in_range(106, 106, 30000, "", 0)
	await ScriptHelperFuncsClass.eliminate_current_se_option_divinity(1)

static func SE14XAP1():
	await ScriptHelperFuncsClass.display_text_wait_noise('"How dare you treat me as inferior! Now you shall know why mortals fear death!" The beast materializes before you. It stands nearly 13 feet at the shoulder. You may have made a very big mistake in enraging the creature to this point.', 'message nod.wav')
	await ScriptHelperFuncsClass.start_battle_in_range(107, 107, 30000, "", 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('You have done a great deed this day. You have destroyed the body of this foul demon. Though not permanently dead, it will be many years before it may torment the Realmz again.', 'message nod.wav')
	#await ScriptHelperFuncsClass.change_tile_anymap_add_flag("map_6",8,7,"ForestDay",111,0 )
	await ScriptHelperFuncsClass.change_tile_anymap_add_flag('map_6', 22, 55,"ForestDay", 95)
	await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE14XAP2():
	await ScriptHelperFuncsClass.display_text_wait_noise('Just as you are about to make contact with the sphere, the living flesh net that holds it aloft forms into a hideous demon. It immediately attacks you.', 'message nod.wav')
	await ScriptHelperFuncsClass.start_battle_in_range(105, 105, 30000, "", 0)
	await ScriptHelperFuncsClass.display_text_wait_noise('The sphere fades as the beast speaks one last time. "Fear for your short lives, mortals! You will be hard-pressed to escape my house alive. Hard-pressed, indeed!"', 'message nod.wav')
	await ScriptHelperFuncsClass.change_tile_anymap_add_flag('map_6', 22, 55, "Cave", 95)
	await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE14XAP3():
	await ScriptHelperFuncsClass.display_text_wait_noise('Unstoppable, the beast\'s hideous laughter courses throughout your brain. "Ha! Ha! Ha! Ha! Run, puny insects! Run, while you may! You shall soon see that it is already far too late!" As evil permeates the room, you manage to safely reach the doorway.', 'message nod.wav')
	await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE15XAP0():
	await ScriptHelperFuncsClass.display_text_wait_noise('Who is so brave as to volunteer?', 'message nod.wav')
	await ScriptHelperFuncsClass.request_pc_pick(1)
	await ScriptHelperFuncsClass.display_text_wait_noise('The statue comes alive, turns toward the defiler, and speaks, "Your base attitude shall beget you nothing." A sudden flash of light overtakes the vandal, just before statue fades into nothingness.', 'message nod.wav')
	await ScriptHelperFuncsClass.heal_picked_Divinity(-1, 6, 10, '642', '')
	await ScriptHelperFuncsClass.change_tile_anymap_add_flag('map_6', 4, 54,"ForestDay", 73)
	await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE15XAP1():
	await ScriptHelperFuncsClass.give_treasure_with_id(34)
	await ScriptHelperFuncsClass.display_text_wait_noise('The statue comes alive, turns towards the defiler and speaks, "You have taken that which is freely given and offended me. You shall not partake of my gifts again." Along with the pool of water, the statue fades into nothingness.', 'message nod.wav')
	await ScriptHelperFuncsClass.change_tile_anymap_add_flag('map_6', 4, 54,"Castle", 73)
	await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE15XAP2():
	await ScriptHelperFuncsClass.display_text_wait_noise('Who is so brave as to volunteer?', 'message nod.wav')
	await ScriptHelperFuncsClass.request_pc_pick(1)
	await ScriptHelperFuncsClass.display_text_wait_noise('Magic courses throughout your body. You are healed.', 'message nod.wav')
	await ScriptHelperFuncsClass.heal_picked_Divinity(10, 10, 20, 695, '')

static func SE15XAP3():
	await ScriptHelperFuncsClass.display_text_wait_noise('Who is so brave as to volunteer?', 'message nod.wav')
	await ScriptHelperFuncsClass.request_pc_pick(1)
	await ScriptHelperFuncsClass.display_text_wait_noise('You feel a deep, warm, tingling sensation. The calluses on your travel-weary feet slowly disappear.', 'message nod.wav')
	await ScriptHelperFuncsClass.heal_picked_Divinity(1, 1, 2, 695, '')

static func SE16XAP0():
	await ScriptHelperFuncsClass.display_text_wait_noise('Who is so brave as to volunteer?', 'message nod.wav')
	await ScriptHelperFuncsClass.request_pc_pick(1)
	await ScriptHelperFuncsClass.display_text_wait_noise('Let the games begin!', 'message nod.wav')
	await ScriptHelperFuncsClass.start_battle_in_range(115, 119, 30000, '', 38)

static func SE16XAP1():
	await ScriptHelperFuncsClass.display_text_wait_noise('Who is so brave as to volunteer?', 'message nod.wav')
	await ScriptHelperFuncsClass.request_pc_pick(2)
	await ScriptHelperFuncsClass.display_text_wait_noise('Let the games begin!', 'message nod.wav')
	await ScriptHelperFuncsClass.start_battle_in_range(120, 124, 30002, '', 39)

static func SE16XAP2():
	await ScriptHelperFuncsClass.display_text_wait_noise('Who is so brave as to volunteer?', 'message nod.wav')
	await ScriptHelperFuncsClass.request_pc_pick(3)
	await ScriptHelperFuncsClass.display_text_wait_noise('Let the games begin!', 'message nod.wav')
	await ScriptHelperFuncsClass.start_battle_in_range(125, 129, 30001, '', 40)

static func SE16XAP3():
	await ScriptHelperFuncsClass.display_text_wait_noise('Who is so brave as to volunteer?', 'message nod.wav')
	await ScriptHelperFuncsClass.request_pc_pick(4)
	await ScriptHelperFuncsClass.display_text_wait_noise('Let the games begin!', 'message nod.wav')
	await ScriptHelperFuncsClass.start_battle_in_range(130, 134, 30002, '', 41)

static func SE17XAP0():
	await ScriptHelperFuncsClass.display_text_wait_noise('"Thank you, good people. I didn\'t look forward to facing Father Yenovich. Years ago, I ran off with his sister and ended up exposing her to the black sickness. She died soon afterwards, and I returned to the city alone. He\'s never forgiven me."', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('He thanks you and rewards you with a huge amount of coin. "I bid you a well and safe journey." You feel awkward about this magnanimous offering. You suspect that it is all he owns. However, local customs dictate that it would be improper to refuse.', 'message nod.wav')
	await ScriptHelperFuncsClass.give_treasure_with_id(51)
	await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE17XAP1():
	await ScriptHelperFuncsClass.display_text_wait_noise('You transport him to the village temple for healing. A cleric is immediately summoned. Upon seeing that the injured party is Sampson, his eyes narrow with recognition. He demands, "Is this man a friend of yours?" What is your reply?', 'message nod.wav')
	await ScriptHelperFuncsClass.teleport_to_map_and_pos("map_0", Vector2(16, 4), '')
	var continue_option = await ScriptHelperFuncsClass.yesno_branch_Divinity(1,1,84, "", "")
	if continue_option:
		await ScriptHelperFuncsClass.display_text_wait_noise('"You have made a poor choice. Though I may be a man of the cloth, I cannot condone this man\'s past actions. Your decision to be friends of this fiend has condemned you all to suffering." Before you can respond, he casts a spell upon you.', 'message nod.wav')
		await ScriptHelperFuncsClass.castSpellOnPartyDivinity(2304, 7, -45, true)
		await ScriptHelperFuncsClass.display_text_wait_noise('As your head clears from the initial impact of the spell, you catch a glimpse of the cleric swiftly disappearing behind the temple\'s fortified door.', 'message nod.wav')
		await ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 10, 85, 0, 0)
		await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE17XAP2():
	await ScriptHelperFuncsClass.play_sound('10136', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('"Vipers! You shall hang for this! You yellow dogs have not seen the last of me!"', 'message nod.wav')
	await ScriptHelperFuncsClass.alter_time_event_divinity(0, 100, 0, 1, 7)
	await ScriptHelperFuncsClass.flag_disabled_current_script()

static func SE17XAP3():
	await ScriptHelperFuncsClass.play_sound('638', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('Never one to miss an opportunity, you snatch up one of the dead beast\'s claws and slash Sampson\'s throat. His life blood gushes out to drench the trampled grass.', 'message nod.wav')
	await ScriptHelperFuncsClass.play_sound('631', true)
	await ScriptHelperFuncsClass.play_sound('1101', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('In his last dying moments, he gazes up at you with eyes of pure hatred. "You will regret this. My dying image shall haunt your nightmares again and again. I vow to avenge myself for the sake of my children, now forced to grow up fatherless."', 'message nod.wav')
	await ScriptHelperFuncsClass.alter_time_event_divinity(0, 100, 0, 1, 7)
	await ScriptHelperFuncsClass.give_treasure_with_id(52)
	await ScriptHelperFuncsClass.flag_disabled_current_script()

# Empty encounters 18 and 19 are included for completeness
static func simple_encounter_18() :
	var textRect = UI.ow_hud.textRect

	var choices = [
		"",
		"",
		"",
		""
	]
	# This encounter is empty

static func simple_encounter_19() :
	var textRect = UI.ow_hud.textRect

	var choices = [
		"",
		"",
		"",
		""
	]
	# This encounter is empty
