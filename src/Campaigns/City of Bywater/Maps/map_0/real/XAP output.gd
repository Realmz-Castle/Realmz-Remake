#Map Script generated from XAP format conversion

static func _on_map_load(_map) :
	print("mapscript _on_map_load() !!! ")
	# Add any initialization code here

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
	ScriptHelperFuncsClass.play_sound('battle start.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('Town guards rush towards you.  The corporal in charge screams, "They are the ones who murdered the good Magistrate.  Kill them!"  Troops are upon you before you can make good your escape.', 'message nod.wav')
	GameGlobal.start_battle("Battle_1","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
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
	GameGlobal.start_battle("Battle_3","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	ScriptHelperFuncsClass.flag_disabled_current_script()
	return

static func XAP6() : #6
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=0 start_coord=0,0 end_coord=41,18 [LRR0/0]
	await ScriptHelperFuncsClass.display_text_wait_noise('You come upon a shocking scene.  You spy a small group of town bullies attacking an old woman.  It would seem they are after a dagger she is clutching to her chest.  Do you wish to intervene on her behalf?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 0, "Your inspection has detected a trap!", "Who will attempt to break the door down?")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('The bullies do not have the stomach to fight and flee at your approach.  The old hag scowls at you, "Stay away!  You can\'t have it!"  The dagger she is clutching is rather ornate and seems very likely to be magical in nature.  What do you do?', 'message nod.wav')
	branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 1, 7, "This gate is locked.", "You could easily barricade this door and rest in this room undisturbed.")
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
	ScriptHelperFuncsClass.play_sound('battle start.wav', false)
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 0, "Your attempt at forcing the door has failed.  It is wedged shut.", "You collect anything you find on your vanquished foe before heading for the prize table to collect your winnings.")
	if not branch.is_empty(): return branch
	ScriptHelperFuncsClass.play_sound('teleport.wav', true)
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(0, 27, 5, 0)
	ScriptHelperFuncsClass.play_sound('teleport.wav', false)
	await ScriptHelperFuncsClass.display_text_wait_noise('"Oh, thank you so much!  Come, this way.  Hurry! Hurry!"  He leads you to the old abandoned well.  At the bottom, you see a miserable little mutt covered in mud.  The bucket for drawing water is so old it\'s completely useless.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_complex_encounter(9)
	return

static func XAP10() : #10
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You enter the town archives.  An old withered man with dried leather for skin sits perched behind a sturdy desk.  He is scratching at some parchment with an ink quill.  As you approach, he frowns and looks up with a furrowed brow.  "Sssshhhh!"', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('"You people make more noise than a herd of rampaging Trollocs."  He continues with a sour look upon his face, "What is it that you want?  We are very busy here.  You may look around, but do not bother me unless I am needed."', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_complex_encounter(1)
	return

static func XAP11() : #11
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('Thurfur and his men are at the east gate preparing to leave as you approach.  Many colored banners flap in the breeze depicting the King\'s standard-a huge gold dragon with a pair of swords clenched in its fists.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('"Ah!  Our heroes have come to join the fun!  Let us set out to crush the rabble!"  You make acquaintance with Thurfur\'s lieutenants and sergeants.  Amongst great fanfare from the townsfolk, you set out on your mission.', 'message nod.wav')
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(0, 84, 12, 10001)
	await ScriptHelperFuncsClass.display_text_wait_noise('At long last, your column comes to a halt.  You see an Orc village in the distance.  Thurfur rides up alongside, "I deem this to be the very tribe that waylaid Sestoon.  Let us charge in.  Surprise shall be a formidable ally to lead our just cause."', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('Thurfur raises a mail-clad arm to signal the bugle to sound the charge.  Your mounts churn up dust as they dash into the village.  Unaccustomed to fighting on horseback, you dismount once you\'re in the fray to fight on solid ground.', 'message nod.wav')
	GameGlobal.start_battle("Battle_21","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
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
	var branch = await ScriptHelperFuncsClass.branch_percent_chance_divinity(30, 1, 16, 0)
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
	GameGlobal.start_battle("Battle_23","map_0", true,false, true,true,true,[], "You manage to flee the cavern.  The speed of these huge creatures is amazing, and they dog your heels all the way to the entrance.  You get into the open, but it is of no use.  You will have to face these mighty foes.")
	var battle_outcome = await GameGlobal.battle_end
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
	GameGlobal.start_battle("Battle_39","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	return

static func XAP19() : #19
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('You burrow up through the last few feet of earth and emerge at the very foot of the tower.  You rush inside with your undead allies.  You come upon two clerics  discussing business.  There is a sizable contingent of arachnids in attendance.', 'message nod.wav')
	await ScriptHelperFuncsClass.display_text_wait_noise('They see you and your undead army rush in.  They command their sickly army to destroy you.  Arachnids and undead mix in a ghastly battle that can only resemble a freak show.', 'message nod.wav')
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(5, 81, 34, 0)
	GameGlobal.start_battle("Battle_44","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(1, 3, -1.0 / 100.0, 0, 0)
	ScriptHelperFuncsClass.set_divinity_script_enabled_flag(0, 27, -1.0 / 100.0, 0, 0)
	# change_rect level=0, id=2, times_in_10k=-1, new_battle_low=0, new_battle_high=0
	return call("XAP41")

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
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 0, "This cave continues off into the distance.  There is a pretty strong breeze of less than fresh air.", "You see a small band of ogres in the distance.  Do you wish to attack them?")
	if not branch.is_empty(): return branch
	GameGlobal.start_battle("Battle_51","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
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
	return call("XAP160")

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
	GameGlobal.start_battle("Battle_52","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	return

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

static func XAP30() : #30
	var textRect = UI.ow_hud.textRect
	GameGlobal.start_battle("Battle_54","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
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
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 1, 37, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('The reason no one has ever returned from this pit is that this tunnel leads to the surface!  The krise must have been so afraid of whatever dwells in the other tunnel, they never investigated this one!', 'message nod.wav')
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(1, 2, 48, 0)
	return

static func XAP37() : #37
	var textRect = UI.ow_hud.textRect
	GameGlobal.start_battle("Battle_57","map_0", true,false, true,true,true,[], "As you delve deeper into the tunnel, you begin to think the cave uninhabited.  Soon, a putrid smell surrounds you.  The cave is inhabited!")
	var battle_outcome = await GameGlobal.battle_end
	await ScriptHelperFuncsClass.display_text_wait_noise('The real reason no one has ever returned from this pit is because this tunnel leads to the surface!  You suspect that former victims of this evil band were immediately killed.  Those who weren\'t, probably  escaped to the surface through this very tunnel.', 'message nod.wav')
	await ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(1, 7, 48, 0)
	return

static func XAP38() : #38
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=1 rect_num=3 start_coord=25,33 end_coord=28,35 [LRR1/3]
	await ScriptHelperFuncsClass.display_text_wait_noise('You see a huge iron gate in the distance.  It is guarded by a small party of krise who are gathered around a reinforced chest.  They spot you and attack before you can slip back into the tunnels.', 'message nod.wav')
	GameGlobal.start_battle("Battle_61","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(0, 32, 99, 0)
	# simple_enc_del_any 10, choice=3
	await ScriptHelperFuncsClass.display_complex_encounter(5)
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
	return call("XAP43")

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
	GameGlobal.start_battle("Battle_216","map_0", true,false, true,true,true,[], "The Mush Men fight for their lives.  They have become completely surrounded.")
	var battle_outcome = await GameGlobal.battle_end
	return

static func XAP48() : #48
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.give_treasure_with_id(30)
	await ScriptHelperFuncsClass.display_text_wait_noise('"You are welcome to rest here as long as you like.  One of my ancestors knew some magic.  A permanent protection spell has been cast on this area.  Ogres and other creatures will not come near."', 'message nod.wav')
	return

static func XAP49() : #49
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_complex_encounter(7)
	ScriptHelperFuncsClass.add_Divinity_script_branch_flag(6, 2, 49, 0)
	return

static func XAP50() : #50
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=4 start_coord=67,46 end_coord=89,89 [LRR0/4]
	await ScriptHelperFuncsClass.display_text_wait_noise('You see a hill giant slumped against a tree.  He is wounded and is nearly dead.  He speaks, "Ranthog fight big bear.  Ranthog hurt.  You help Ranthog?"      What do you do?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 1, 51, "", "")
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
	GameGlobal.start_battle("Battle_79","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	return

static func XAP52() : #52
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=4 start_coord=67,46 end_coord=89,89 [LRR0/4]
	await ScriptHelperFuncsClass.display_text_wait_noise('You spot an adult hill giant teaching the finer points of setting up ambush to a small group of youngsters.  Do you wish to teach them a valuable lesson and set an ambush of your own?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	await ScriptHelperFuncsClass.display_text_wait_noise('The students have paid very close attention to their teacher.  Your ambush is spotted by one of them.  You are surprised as they set upon you.  They act as if they are seasoned veterans, not the greenhorn youngsters you expected them to be.', 'message nod.wav')
	GameGlobal.start_battle("Battle_81","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	return

static func XAP53() : #53
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=0 rect_num=4 start_coord=67,46 end_coord=89,89 [LRR0/4]
	await ScriptHelperFuncsClass.display_text_wait_noise('You spot what appears to be three young hill giants tormenting a large proto-badger.  Do you help the proto-badger against these evil folk?', 'message nod.wav')
	var branch = await ScriptHelperFuncsClass.yesno_branch_Divinity(true, 0, 137, "", "")
	if not branch.is_empty(): return branch
	GameGlobal.start_battle("Battle_80","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	return

static func XAP54() : #54
	var textRect = UI.ow_hud.textRect
	# RANDOM RECTANGLE REFERENCE land_level=2 rect_num=1 start_coord=1,11 end_coord=27,27 [LRR2/1]
	await ScriptHelperFuncsClass.display_text_wait_noise('You stumble into the most bizarre battle you have ever seen.  It appears to be a civil war between jelly-like monsters.  If you hadn\'t been dragged into its midst, you might have even been amused by the situation.', 'message nod.wav')
	ScriptHelperFuncsClass.play_sound('slime.wav', false)
	GameGlobal.start_battle("Battle_92","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
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
	GameGlobal.start_battle("Battle_147","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
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
	GameGlobal.start_battle("Battle_56","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
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
	GameGlobal.start_battle("Battle_144","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
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
	GameGlobal.start_battle("Battle_152","map_0", true,false, true,true,true,[], "Even as you watch many eggs are hatching.  Crawling around these eggs are hundreds of strange lizard creatures.  Some mistake you for food.")
	var battle_outcome = await GameGlobal.battle_end
	return

static func XAP69() : #69
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('teleport.wav', false)
	# set_dungeon land, level=0, x=5, y=17, dir=0
	return

static func XAP70() : #70
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('As you are leaving the cave you hear a loud roar behind you.  It comes from where you found the small child.  As you attempt to determine the identity of the creatures you see a group of large trolls running in your direction on flapping feet.', 'message nod.wav')
	GameGlobal.start_battle("Battle_158","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
	return

static func XAP71() : #71
	var textRect = UI.ow_hud.textRect
	await ScriptHelperFuncsClass.display_text_wait_noise('"Very well then.   Guards!  Show these fine people to the door, they have no valid business in the castle this day.  Farewell good people."', 'message nod.wav')
	return
