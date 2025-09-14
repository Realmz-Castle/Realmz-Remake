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
	GameGlobal.start_battle("Battle_1","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
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
	GameGlobal.start_battle("Battle_2","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
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
	await ScriptHelperFuncsClass.teleport_to_map_and_pos("map_6", Vector2(73, 7), '')
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
		#modify_ap                level=5, id=89, source_xap=19, level_type=same, result_code=0#add_AP_replaced_flag(_mapname : String, _ap_name : String, _newap_name : String)
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
	GameGlobal.start_battle("Battle_47","map_0", true,false, true,true,true,[])
	var battle_outcome = await GameGlobal.battle_end
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
