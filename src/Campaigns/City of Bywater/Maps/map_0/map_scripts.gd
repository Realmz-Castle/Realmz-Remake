static func _on_map_load(_map) :  #Necessary even if unused, replace body with "pass" if so.
	print("mapscript _on_map_load() !!! ")
	if not GameGlobal.stuff_done.has("recruited_vodada") :
		_map.add_extra_image("Vodada", "CREA_Vodalian",Vector2(13,10))


static func scenario_start() :  #===== LAND AP level=0 id=76 x=2 y=2 [LAP0/76]
	if GameGlobal.stuff_done.has("scenario_start_seen") :
		return
	ScriptHelperFuncsClass.display_picture_file('Scenario_Start.png')
	
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('heal.wav', false)
	textRect.set_text('Welcome to "The City of Bywater", a scenario for use with the Realmz Scenario Driver.  If you enjoy playing Realmz and would like to see more scenarios developed, please support us by sending in your registration fee.', true)
	await textRect.interruption_over
	ScriptHelperFuncsClass.play_sound('heal.wav', false)
	textRect.set_text('Once you have registered this copy of Realmz, you will be able to play the entire scenario.  This scenario is very loose.  It does not have a strong plot line.  You can adventure where you want for as long as you want', true)
	await textRect.interruption_over
	ScriptHelperFuncsClass.play_sound('hallelujah.wav', false)
	textRect.set_text("Once you have registered this copy of Realmz, you will also be able to play test other scenarios BEFORE having to register them.  The fee for each additional scenario are $13 each.  For information on how to register, see chapter 3 of the Realmz Manual.", true)
	await textRect.interruption_over
	ScriptHelperFuncsClass.play_sound('swup.wav', false)
	textRect.set_text("Other scenarios utilize the capabilities of the Realmz scenario driver to a greater extent.  These scenarios feature a definite plot line, new monsters, new magical items and more dangerous encounters.", true)
	await textRect.interruption_over
	ScriptHelperFuncsClass.hide_picture()
	GameGlobal.stuff_done["scenario_start_seen"] = 1


static func guard_house() : #LAND AP level=0 id=0 x=9 y=17 [LAP0/0]
	var textRect = UI.ow_hud.textRect
	ScriptHelperFuncsClass.play_sound('swup.wav', false)
	textRect.set_text("You enter the guard house outside the main gate to Castle Anthrax.  Several guards keep a wary eye on you as you approach the head Magistrate.  He is a stately looking man in fine robes.", true)
	await textRect.interruption_over
	# SIMPLE ENCOUNTER id=0
	textRect.set_text("Judging by the man's large girth, robes are not all he fancies.  You approach his fine oak desk.  \"Present your invitation so I may validate it for passage to yon castle.\"", false)
	textRect.display_multiple_choices(["Exposition text_a\nwith\nextra lines","A wordy choice.", "YESNO","STOP"],["TEXT","answer_words", "YESNO","STOP"])

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
		GameGlobal.stuff_done["helped_boy"] = true
	if answer == "NO" :
		textRect.set_text("The boy walks away crying", false)

static func Secret_AP() :
	GameGlobal.play_sfx("generation good.wav")
	UI.ow_hud.textRect.set_text("You find a secret path in the mountain.", false)
