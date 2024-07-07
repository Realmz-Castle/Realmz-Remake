static func _on_map_load(map) :  #Necessary even if unused, replace body with "pass" if so.
	print("mapscript _on_map_load() !!! ")
	if not GameGlobal.stuff_done.has("recruited_vodada") :
		map.add_extra_image("Vodada", "CREA_Vodalian",Vector2(13,10))


static func Vodada() :
	if GameGlobal.stuff_done.has("recruited_vodada") :
		return
	var textRect = UI.ow_hud.textRect
	textRect.set_text("Your old friend Vodada is here waiting for you !", false)
	textRect.display_multiple_choices(["He really wants to tag along with you.\nDo you recruit him ?","YESNO"],["TEXT", "YESNO"])
	var answer = await textRect.choice_pressed
	print("mapscript answer : "+answer)
	if answer == "YES" :
		var CreatureGD : GDScript = load('res://Creature/Creature.gd')
		var creascript = CreatureGD.new()
		creascript.initialize_from_bestiary_dict("Vodada !")
		GameGlobal.add_npc_ally(creascript)
		GameGlobal.stuff_done["recruited_vodada"] = 1
		GameGlobal.map.remove_extra_image("Vodada")
		print("MAPSCRIPT"+creascript.name+" IS SO HAPPY !")
		textRect.set_text("Vodada hugs  you and makes you  promise to never leave him again.", false)
	

static func GlyphScript_One() :
	print("GlyphScript_OneGlyphScript_OneGlyphScript_One")
	var map = NodeAccess.__Map()
	map.focuscharacter.move(Vector2(-9,11))
	var textRect = UI.ow_hud.textRect
	#textRect.set_text("HELLLOOOO WOOOORLD !", true)
	#textRect.set_text("HELLLOOOO AGAAAIIIN !", true)
	
	#interruption_over
	textRect.set_text("The quick brown fox jumps over the lazy dog. Pack my box with five dozen liquor jugs. Jackdaws love my big sphinx of quartz. How vexingly quick daft zebras jump! \nSphinx of black quartz, judge my vow.", true)
	await textRect.interruption_over
	print('yield(textRect, "interruption_over") after world')
	textRect.set_text("HELLLOOOO AGAAAIIIN !", true)
	await textRect.interruption_over
	print('yield(textRect, "interruption_over") after again')

static func GlyphScript_Two() :
	if true :
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
	var treasureControl = UI.ow_hud.treasureControl
	var healpottemplate = NodeAccess.__Resources().items_book["Health Potion"]
	var treasureitems = []
	for i in range(200) :
		var healpotion = healpottemplate.duplicate(true)
		treasureitems.append(healpotion)
	await GameGlobal.show_loot_menu(treasureitems,[10,5,3],2000)
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