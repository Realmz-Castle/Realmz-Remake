static func GlyphScript_One() :
	print("GlyphScript_OneGlyphScript_OneGlyphScript_One")
	var map = NodeAccess.__Map()
	map.focuscharacter.move(Vector2(-9,11))
	var textRect = NodeAccess.Get.__UI().ow_hud.textRect
	#textRect.set_text("HELLLOOOO WOOOORLD !", true)
	#textRect.set_text("HELLLOOOO AGAAAIIIN !", true)
	
	#interruption_over
	textRect.set_text("The quick brown fox jumps over the lazy dog. Pack my box with five dozen liquor jugs. Jackdaws love my big sphinx of quartz. How vexingly quick daft zebras jump! \nSphinx of black quartz, judge my vow.", true)
	yield(textRect, "interruption_over")
	print('yield(textRect, "interruption_over") after world')
	textRect.set_text("HELLLOOOO AGAAAIIIN !", true)
	yield(textRect, "interruption_over")
	print('yield(textRect, "interruption_over") after again')

static func GlyphScript_Two() :
	if false :
		var hud = NodeAccess.Get.__UI().ow_hud
		hud.request_pc_pick(3)
		var picked = yield(hud, "pc_picked")
		print(picked)
		var pickednames = "picked characters : "
		for c in picked :
			pickednames = pickednames + c.name + ' '
		pickednames = pickednames + ", in this order."
		var textbox = NodeAccess.Get.__UI().ow_hud.textRect
		textbox.set_text(pickednames, false)
		return

	print("GlyphScript_TwoGlyphScript_TwoGlyphScript_Two")
	var textRect = NodeAccess.Get.__UI().ow_hud.textRect
	textRect.set_text("MULTIPLE CHOICE !", false)
	textRect.display_multiple_choices(["Exposition text_a\nwith\nextra lines","A wordy choice.", "YESNO","STOP"],["TEXT","answer_words", "YESNO","STOP"])
	var answer = yield(textRect, "choice_pressed")
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
	SfxPlayer.stream = NodeAccess.__Resources().sounds_book["generation good.ogg"]
	SfxPlayer.play()
	var textRect = NodeAccess.Get.__UI().ow_hud.textRect
	textRect.set_text("You may swap characters here. And exchange currencies. And shop at 'SimpleShop'.", false)
	GameGlobal.allow_character_swap(true)
	GameGlobal.currentShop = 'shop_1'
	MusicStreamPlayer.play_music_type("Dungeon")
	GameGlobal.currentSpecialEncounterName = "otherencounter.gd"
	#MusicStreamPlayer.play_music_specific("camp.mod")
	GameGlobal.set_money_change_enabled(true)

static func Find_Treasure() :
	var textRect = NodeAccess.Get.__UI().ow_hud.textRect
	textRect.set_text("You find some delicious loot !", true)
	yield(textRect, "interruption_over")
	var treasureControl = NodeAccess.Get.__UI().ow_hud.treasureControl
	var healpottemplate = NodeAccess.__Resources().items_book["Health Potion"]
	var treasureitems = []
	for i in range(200) :
		var healpotion = healpottemplate.duplicate(true)
		treasureitems.append(healpotion)
	GameGlobal.show_loot_menu(treasureitems,10,20)
	#yield(textRect, "interruption_over")

static func Take_Stairs_D() :
	var textRect = NodeAccess.Get.__UI().ow_hud.textRect
	textRect.set_text("You take the stairs down to rug_dungeon_floor !", true)
	GameGlobal.change_map("rug_dungeon_floor",3,3)