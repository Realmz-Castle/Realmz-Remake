#Map test Script generated from old AP format

static func _on_map_load(_map) :
	print("mapscript _on_map_load() !!! ")
	# Add any initialization code here


static func XAP27() : #27
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=2 start_coord=50,5 end_coord=89,34 [LRR0/2]
	await ScriptHelperFuncsClass.display_text_wait_noise('As you top a knoll, you come upon an Orc female giving birth.  She looks quite pale, and is so weak she doesn\'t even notice you.  The baby is breached and will die if you do not help.  Do you aid her?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('You are successful at delivering the baby.  The mother only has time to see the face of her healthy newborn boy, before she slips into a coma and dies.  It would seem you have become parents by default.  What do you do?', 'message nod.wav')
	branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 0, "You see the corpses of over 3 dozen Dogre.  Many are nothing but armor stretched over withered bones but several are considerably more fresh.  Even though, the flesh on some seems to be withered as if aged hundreds of years in just moments.", "You see a group of Dogre in the distance.  Do you want to attack them?")
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
	GameGlobal.start_battle("Battle_28","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	return

static func XAP29() : #29
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=2 start_coord=50,5 end_coord=89,34 [LRR0/2]
	await ScriptHelperFuncsClass.display_text_wait_noise('You hear the sound of battle in the distance.  You see a band of orcs being attacked by a large group of goblins.  The orcs appear doomed unless you help.  The battle spreads out to engulf you.  Do you stand with the orcs or attack both parties?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(false, 1, 30, "", "")
	if not branch.is_empty(): return branch
	GameGlobal.start_battle("Battle_53","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	return

static func AP55x89y79() : #55 at 89,79
	var textRect = UI.ow_hud.textRect
	# This AP teleports to level 1 at 5,63
	ScriptHelperFuncsClass.teleport_to_map_and_pos("map_1", Vector2(5,63), '')
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
	# TODO: Implement jmp_battle battle_low=174, battle_high=0, loss_xap=144, sound=0, string=0
	# TODO: Implement change_rect level=0, id=19, times_in_10k=0, new_battle_low=0, new_battle_high=0
	#ScriptHelperFuncsClass.set_scrip_enabled_flag(5, 94, 100 / 100, 0, 0)
	ScriptHelperFuncsClass.change_map_tile_Divinity(0, 48, 2, 155, "land")
	ScriptHelperFuncsClass.play_sound('spell launch 1.wav', false)
	ScriptHelperFuncsClass.change_map_tile_Divinity(0, 48, 1, 155, "land")
	# XAP 156 content (recursively resolved):
	ScriptHelperFuncsClass.play_sound('spell launch 4.wav', false)
	ScriptHelperFuncsClass.change_map_tile_Divinity(0, 47, 1, 155, "land")
	ScriptHelperFuncsClass.play_sound('spell launch 3.wav', false)
	ScriptHelperFuncsClass.change_map_tile_Divinity(0, 47, 2, 155, "land")
	await ScriptHelperFuncsClass.display_text_wait_noise('With the Widow of the Web banished from the Realmz, her powers to keep the temple also in the Realmz fails.  The Widow will have to face Vixies and explain her failure to achieve victory over a few puny mortals.', 'message nod.wav')
	#ScriptHelperFuncsClass.set_scrip_enabled_flag(5, 93, 0 / 100, 0, 0)
	# end of XAP 156 (with nested expansions)
	return

static func AP59x83y4() : #59 at 83,4
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You see several dozen dead orcs strewn about the cave.  Most of the bodies have been nibbled on somewhat by some creature that must be quiet large.  The cave continues off to the back.  You hear heavy breathing and the shuffling of great feet.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Do you wish to move to the back of the cave to investigate?', 'message nod.wav')
	#await ScriptHelperFuncsClass.yesno_branch("yes", "back_up", 137, "0", "0")
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
	#ScriptHelperFuncsClass.flag_disabled_ap(ap_name)
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
	#ScriptHelperFuncsClass.set_scrip_enabled_flag(0, 68, -1 / 100, 0, 0)
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
	# Random chance 33% to jump to xap 72 - needs implementation
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
	await ScriptHelperFuncsClass.display_text_wait_noise('UGUU you have registered this copy of Realmz, you will be able to play the entire scenario.  This scenario is very loose.  It does not have a strong plot line.  You can adventure where you want for as long as you want.', 'heal.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Once you have registered this copy of Realmz, you will also be able to play test other scenarios BEFORE having to register them.  The fee for each additional scenario are $13 each.  For information on how to register, see chapter 3 of the Realmz Manual.', 'hallelujah.wav')

	# XAP 73 content (recursively resolved):
	await ScriptHelperFuncsClass.display_text_wait_noise('Other scenarios utilize the capabilities of the Realmz scenario driver to a greater extent.  These scenarios feature a definite plot line, new monsters, new magical items and more dangerous encounters.', 'message nod.wav')
	# end of XAP 73 (with nested expansions)
	ScriptHelperFuncsClass.hide_picture()
	#GameGlobal.stuff_done["scenario_start_seen"] = 1

	#ScriptHelperFuncsClass.set_divinity_script_enabled_flag(0, 76, 0.0, 0, 0)

	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0,76, 99, 0,0)
	#ScriptHelperFuncsClass.change_currmap_tile(4,4,0, "ForestDay", 55)

	var nextap =  await ScriptHelperFuncsClass.display_simple_encounter_from_data('SE0')
	return nextap

	#var flags =ScriptHelperFuncsClass.change_tile_anymap_add_flag("map_0", 4, 4, "ForestDay", 55, 0)
	#printerr(flags)#["TileSwaps.map_0", "x4y4l0", [4, 4, 0, "ForestDay", 55]]
	return 'jumptome'

static func AP77x18y9() : #77 at 18,9
	var textRect = UI.ow_hud.textRect
	# This AP teleports to level 5 at 52,3
	ScriptHelperFuncsClass.teleport_to_map_and_pos("map_5", Vector2(52,3), '')
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter a massive building.  It appears to be an endless maze of hallways and corridors.', 'message nod.wav')
	return

static func AP78x2y28() : #78 at 2,28
	var textRect = UI.ow_hud.textRect
	# TODO: Implement jmp_quest check=set, target_type=xap, target=100, code_index=0
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter the slave prison.  A potbellied Corporal Sampson is slumped over a shaky table.  He\'s slept through the entire ordeal that just took place outside.  The smell of elderberry wine permeates his clothes.  You try to rouse him to collect your fee.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Sampson awakens with a jolt and sits up quickly.  An offensive stream of drool has slid across his left cheek.  Heavy bags underneath his eyes imply he hasn\'t slept well lately.  \"What\'s this?  Can a man have no rest?\" You promptly display your contract.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Sampson swiftly scans the contract with disbelief.  \"I see that you have been promised the sum of 100 gold Zelots.  Well, there is not that many gold Zelots in all of Bywater!  You may be very brave, but you are also very gullible!\"', 'talk 2.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('\"I can offer you a few silver for your trouble.  That is the best I can do.\"  He begins to search his belongings for a few paltry coins.  Suddenly, a nasty brawl breaks out between two of the beasts. ', 'message nod.wav')
	# XAP 82 content (recursively resolved):
	await ScriptHelperFuncsClass.display_text_wait_noise('During the battle with the mad troll, one of the troll\'s hands had been severed.  One of your charges hungrily snatched it up to eat.  However, another beast greedily attempted to steal the tender morsel.  This attempt has provoked an all-out brawl.', 'growl 1.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Before you are able to get the situation under control, the beasts erupt explosively into a convulsing ball of fur and slashing claws.  You are immediately  pulled into the fray.', 'message nod.wav')
	GameGlobal.start_battle("Battle_206","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	#await ScriptHelperFuncsClass.display_simple_encounter(0)
	# end of XAP 82 (with nested expansions)
	return

static func AP79x34y2() : #79 at 34,2
	var textRect = UI.ow_hud.textRect
	# This AP teleports to level 4 at 2,25
	ScriptHelperFuncsClass.teleport_to_map_and_pos("map_4", Vector2(2,25), '')
	return

static func AP80x7y21() : #80 at 7,21
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You are just about to enter the king\'s private gardens.  Someone has posted a message at the front gate.  \"Closed until further notice.  Do not enter under any circumstances.  You have been warned!\"', 'message nod.wav')
	# TODO: Implement jmp_quest check=set, target_type=xap, target=100, code_index=0
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter the king\'s gardens and begin to stalk for signs of the rabid beast.  Several  plants have been uprooted or mutilated.  You hear something up ahead on your right.  There are indications that the beast may not be alone.  Do you wish to continue?', 'message nod.wav')
	#await ScriptHelperFuncsClass.yesno_branch("yes", "back_up", 137, "0", "0")
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
	# XAP 104 content (integrated):
	ScriptHelperFuncsClass.play_sound('talk 2.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('A seedy looking group of gnomes are sitting at a vomit stained table.  They are swilling cheap grog from a clay jug.  They seem more concerned with getting more than their share of the wine and pay you little attention.', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound('angry mob.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('Just as you\'re about to dismiss the group,  Vodalian rears up a glinting dagger and charges against one of the gnomes.  "Murderous scum!  I shall avenge my sweet Alex this very day!"', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound('sword hit.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('You burst forth in an attempt to restrain Vodalian.   Gnomes rush from the shadows to aid their drunken friends.', 'message nod.wav')
	GameGlobal.start_battle("Battle_217","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	# XAP 105 content (integrated):
	ScriptHelperFuncsClass.play_sound('talk 2.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('Vodalian thanks you for your aid.  "This vermin slew my son.  Alex was an extremely intelligent and talented pupil.  He could have grown to become a powerful mage.  This foul creature deserved a more cruel demise."', 'message nod.wav')
	return

static func AP83x89y48() : #83 at 89,48
	var textRect = UI.ow_hud.textRect
	# TODO: Implement set_dungeon level=0, x=33, y=72, dir=east
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
	# TODO: Implement use_ap level=44, id=0
	return

static func AP86x68y77() : #86 at 68,77
	var textRect = UI.ow_hud.textRect
	# TODO: Implement use_ap level=44, id=0
	return

static func AP87x69y79() : #87 at 69,79
	var textRect = UI.ow_hud.textRect
	# TODO: Implement use_ap level=44, id=0
	return

static func AP88x72y79() : #88 at 72,79
	var textRect = UI.ow_hud.textRect
	# TODO: Implement use_ap level=44, id=0
	return

static func AP89x70y76() : #89 at 70,76
	var textRect = UI.ow_hud.textRect
	# TODO: Implement use_ap level=44, id=0
	return

static func AP90x4y36() : #90 at 4,36
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('underwater laser.wav', true)
	await ScriptHelperFuncsClass.display_text_wait_noise('Open grassland is marred by a dark, gaping pit.  Muted bubbling fizzles below.  A large log lies near the pit\'s edge.  It might be possible to use it as a crude, makeshift ladder.  Do you push the log in and attempt to enter the pit?', 'message nod.wav')
	#await ScriptHelperFuncsClass.yesno_branch("yes", "back_up", 0, "0", "0")
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



static func XAP6x0y0x41y18() :
	return

static func XAP9x0y0x41y18() :
	return

static func XAP21x0y0x27y48() :
	return

static func XAP26x0y0x41y18() :
	return

static func XAP44x1y2x26y9() :
	return

static func XAP45x1y2x26y9() :
	return

static func XAP54x1y11x27y27():
	return

static func XAP57x0y0x38y30() :
	return

static func XAP64x0y0x41y13() :
	return

static func XAP103x0y0x41y13() :
	return

static func XAP106x0y0x90y90() :
	return

static func XAP142x0y0x16y11() :
	return

static func XAP99x99y99x99y99() :
	await ScriptHelperFuncsClass.display_text_wait_noise('XAP99 : You already saw the intro.', 'message nod.wav')
	return

static func jumptome() :
	await ScriptHelperFuncsClass.display_text_wait_noise('Successfully jumped to another AP  after executing one.', 'metal hit.wav')
	return


#static func LRR1() :
	#pass
	#if randi()%10000>=option_chance : return
	#start_battle_in_range(low : int, high : int, sfx_id : int, displaytext : String, 0) :
	#var battle_outcome = await GameGlobal.battle_end


static func SE0XAP0() :
	await ScriptHelperFuncsClass.display_text_wait_noise('This is SE0XAP0.', 'message nod.wav')
static func SE0XAP1() :
	await ScriptHelperFuncsClass.display_text_wait_noise('This is SE0XAP1.', 'message nod.wav')
static func SE0XAP2() :
	await ScriptHelperFuncsClass.display_text_wait_noise('This is SE0XAP2.', 'message nod.wav')
static func SE0XAP3() :
	await ScriptHelperFuncsClass.display_text_wait_noise('This is SE0XAP3.', 'message nod.wav')
