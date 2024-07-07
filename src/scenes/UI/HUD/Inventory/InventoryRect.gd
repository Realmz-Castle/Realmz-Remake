extends NinePatchRect
class_name InventoryControl

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#var itemsmallpanelTSCN : PackedScene = preload("res://scenes/UI/HUD/ItemSmallPanel.tscn")

const numberscancodes : Array = [KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9, KEY_0]

var itemsmallbuttonTSCN : PackedScene = preload("res://scenes/UI/HUD/Inventory/ItemSmallButton.tscn")

var selectedTradeCharacter = null

var selected_item_ctrl = null

@export var storage_button : Button

@onready var traderect : Control = $VBoxContainer/TopHBox/LeftPage/TradeRect
@onready var shopRect : Control = $VBoxContainer/TopHBox/LeftPage/ShopRect
@onready var shopButtonsRect : Control = $VBoxContainer/TopHBox/MiddleColumn/ShopButtonsRect
@onready var inventoryScrollLeft : ScrollContainer = $VBoxContainer/TopHBox/LeftPage/TradeRect/InvScrollContainerL
@onready var inventoryBoxLeft : VBoxContainer = $VBoxContainer/TopHBox/LeftPage/TradeRect/InvScrollContainerL/VBoxContainerL  # in trade panel
@onready var inventoryScrollRight : ScrollContainer = $VBoxContainer/TopHBox/RightPage/InvScrollContainerR
@onready var inventoryBoxRight : VBoxContainer = $VBoxContainer/TopHBox/RightPage/InvScrollContainerR/VBoxContainerR
@onready var inventoryBoxShop : VBoxContainer = $VBoxContainer/TopHBox/LeftPage/ShopRect/InvScrollContainerShop/VBoxContainerL


@onready var shopButton : Button = $VBoxContainer/BotHBox/HBoxLeft/ButtonShop
var infoRect : Control  #set by ow hud control


@onready var buttonTrade : Button = $VBoxContainer/BotHBox/HBoxLeft/ButtonTrade
@onready var buttonUse : Button = $VBoxContainer/BotHBox/HBoxRight/ButtonUse
@onready var buttonIdentify : Button = $VBoxContainer/BotHBox/HBoxRight/ButtonIdentify
@onready var buttonIdenPay : Button = $VBoxContainer/BotHBox/HBoxRight/ButtonidentiPay
@onready var buttonDrop : Button = $VBoxContainer/BotHBox/HBoxRight/ButtonDrop
@onready var buttonDone : Button = $VBoxContainer/BotHBox/MiddleColumn/ButtonDone

@onready var buttonJoin : TextureButton = $VBoxContainer/TopHBox/MiddleColumn/VBoxJoinSplit/ButtonJoin
@onready var buttonSplit : TextureButton = $VBoxContainer/TopHBox/MiddleColumn/VBoxJoinSplit/ButtonSplit

@onready var buttonShow : Button = $VBoxContainer/TopHBox/LeftPage/TradeRect/ButtonShow
#onready var buttonShop : Button = $TradeRect/ButtonShop
@onready var tradeicons : GridContainer = $VBoxContainer/TopHBox/LeftPage/TradeRect/CharTradeSelectGrid

@onready var hud : Control = $"../../../.."
#onready var chartradeselectbox : HBoxContainer = $"TradeRect/CharTradeSelectBox"
@onready var tradechargrid : GridContainer  = $VBoxContainer/TopHBox/LeftPage/TradeRect/CharTradeSelectGrid
@onready var tradeselectsprite : Sprite2D = $VBoxContainer/TopHBox/LeftPage/TradeRect/CharTradeSelectGrid/CharSelectSprite
@onready var tradeselectspritebutton : TextureButton = null

#var belongstoally : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	inventoryBoxLeft.add_theme_constant_override ("separation",0)
	inventoryBoxRight.add_theme_constant_override ("separation",0)
	tradechargrid.add_theme_constant_override ("v_separation",0)
	tradechargrid.add_theme_constant_override ("h_separation",0)

	inventoryScrollRight.inventoryrect = self
	inventoryScrollLeft.inventoryrect = self




func on_viewport_size_changed(screensize) :
	return
	
	
	_set_size(Vector2(screensize.x-320, screensize.y-200))
#	inventoryBoxRight
	traderect._set_size(Vector2(floor((screensize.x-320-44-20)/2), screensize.y-210))
	if tradeselectspritebutton != null :
		tradeselectsprite.position = tradeselectspritebutton.get_rect().position
		tradeselectsprite.show()
	else :
		tradeselectsprite.hide()
	
	var scrollW = floor((screensize.x-320-44-20)/2)
	
	inventoryScrollLeft._set_size(Vector2( scrollW , screensize.y-260))
	
	inventoryScrollRight._set_size(Vector2( scrollW, screensize.y-260))
	var rightPanX = 54+floor((screensize.x-320-44-20)/2)
	inventoryScrollRight._set_position(Vector2(rightPanX,10))

	var buttonY = screensize.y-250
	
	var emptyspace = floor((scrollW-63-73-80-66)/3)
	
	buttonDone._set_position(Vector2( 10+floor((screensize.x-320-44-20)/2) , buttonY))
	
	buttonJoin._set_position(Vector2( 10+floor((screensize.x-320-44-20)/2) , buttonY-50))
	buttonSplit._set_position(Vector2( 10+floor((screensize.x-320-44-20)/2) , buttonY-75))
	
	buttonUse._set_position(Vector2( rightPanX , buttonY))
	buttonIdentify._set_position(Vector2( rightPanX+63+emptyspace , buttonY))
	buttonIdenPay._set_position(Vector2( rightPanX+63+73+2*emptyspace , buttonY))
	buttonDrop._set_position(Vector2 ( screensize.x-320-66-10 , buttonY ))
	buttonTrade._set_position( Vector2(10, buttonY) )

	buttonShow._set_position( Vector2(0, buttonY-10) )
#	buttonShop._set_position( Vector2(74, buttonY-10) )
	tradeicons._set_position( Vector2(74+40, buttonY-10))
	var columns = max( floor((scrollW-74-40)/16)-1 , 1)
	tradeicons.set_columns(columns)
	
#	infoRect._set_size(Vector2( screensize.x-320 , 200))
#	infoRect.get_node("InfoLabel")._set_size(Vector2( scrollW , screensize.y-260))

#	shopRect._set_size(Vector2( scrollW+10 , screensize.y-200-10))
	var ratio = 1.0
	if screensize.y<600 :
		var buttonrectheight = max(screensize.y,400)-260
		ratio = buttonrectheight/340
		
	shopButtonsRect.set_scale(Vector2(1.0,ratio))
	if visible :
		for i in inventoryBoxLeft.get_children() :
			i.on_viewport_size_changed(screensize)
		for i in inventoryBoxRight.get_children() :
			i.on_viewport_size_changed(screensize)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func when_Items_Button_pressed() :
	show()
	fill_inventory_Vbox(inventoryBoxRight, hud.selected_character)
	if GameGlobal.currentShop == '' :
		shopButton.hide()
	else :
		shopButton.show()
	_on_ButtonShow_pressed()
#	on_viewport_size_changed (get_window().get_size())


func fill_inventory_Vbox(vbox : VBoxContainer, character) :
	print("INventoryrect fill_inventory_Vbox : ", vbox.name)
#	infoRect = UI.ow_hud.textRect


	if character == null  and vbox==inventoryBoxLeft :
		return
#	print(vbox.name)
	vbox.get_parent().belongstoally = character.is_npc_ally
	selected_item_ctrl = null
#	buttonJoin.hide()
#	buttonSplit.hide()

	for child in vbox.get_children() :
		vbox.remove_child(child)
		child.queue_free()
	for item in character.inventory :
#		print(item["name"])
		# problem was here because the Vcontainer set its size to its minimum size !
		var itempanel = itemsmallbuttonTSCN.instantiate()
		itempanel.belongstoally = character.is_npc_ally
#		var itempanel = itemsmallpanelTSCN.instantiate()
		vbox.add_child(itempanel)
		itempanel.inventoryrect = self
		itempanel.set_item(item)
		itempanel.update_display()
#		itempanel.on_viewport_size_changed(get_window().get_size())
		

func reset_trade_panel() :
	# cleans up  the trade panel and forces player to pick a character to  trade qwith again if they want to
	traderect.hide()
	_on_trade_char_select_button_pressed(hud.selected_character, null )
	selectedTradeCharacter = null
	tradeselectsprite.hide()
	tradeselectspritebutton = null

func display_item_info(item : Dictionary) :
	infoRect.set_item_info( item )

func set_selected_item_ctrl( itemctrl , _movejoinsplit = true) :
	for ictrl in inventoryBoxRight.get_children() :
		ictrl.selectedSprite.hide()
	for ictrl in inventoryBoxLeft.get_children() :
		ictrl.selectedSprite.hide()
	if itemctrl == null :
		print("inventoryrect  selected_item_ctrl set to  null")
		selected_item_ctrl = null
		buttonJoin.hide()
		buttonSplit.hide()
		return
	itemctrl.selectedSprite.show()
	selected_item_ctrl = itemctrl
	
	if selected_item_ctrl.item["splittable"]==0:
		buttonJoin.hide()
		buttonSplit.hide()
	else :
		if shopRect.visible :
			buttonJoin.hide()
			buttonSplit.hide()
		else :
			buttonJoin.show()
			buttonSplit.show()
		
			var screensize = hud.get_mofified_screensize()
			if _movejoinsplit :
				var selecteditemctrlpos = selected_item_ctrl.get_global_position()
				buttonJoin._set_position(Vector2( 10+floor((screensize.x-320-44-20)/2) , selecteditemctrlpos.y))
				buttonSplit._set_position(Vector2( 10+floor((screensize.x-320-44-20)/2) , selecteditemctrlpos.y+20))
	


func _on_ButtonTrade_pressed():
	buttonTrade.hide()
	shopButtonsRect.hide()
	traderect.show()
	hud.set_charactersRect_type(1, false)
#	tradecharlist.clear()
	for child in tradechargrid.get_children() :
		if child != tradeselectsprite :
			tradechargrid.remove_child(child)
			child.queue_free()
#	var emptycharsnumber = GameGlobal.player_characters.size()
	
	var butnumber : int = 0
	for character in GameGlobal.player_characters :
		var newbutton : TextureButton = TextureButton.new()
		
#		var miniportrait : ImageTexture = Utils.FileHandler.load_img_texture()

#	static func load_img_texture(path) ->ImageTexture :
#		var img = Image.new()
#		var err = img.load(path)
#		if (err!=0) :
#			print("error ",err," loading img at "+ path)
#			return ImageTexture.new()
#		else :
#			var tex = ImageTexture.create_from_image(img)
#			return tex


#		var miniportraitimg : Image = character.portrait.get_image()
#		var miniportrait : ImageTexture = ImageTexture.new()
#
#
#		miniportraitimg.resize(20,20, miniportraitimg.INTERPOLATE_NEAREST)
#
#		miniportrait.create_from_image(miniportraitimg)
		
		var miniportraitimg : Image = character.portrait.get_image()
		miniportraitimg.resize(20,20, miniportraitimg.INTERPOLATE_NEAREST)
		var miniportrait : ImageTexture = ImageTexture.create_from_image(miniportraitimg)
		
		
		newbutton.set_texture_normal( miniportrait )
		newbutton.set_texture_pressed( miniportrait )
		newbutton.set_texture_hover( miniportrait )
		newbutton.set_texture_disabled( miniportrait )
		newbutton.set_texture_focused( miniportrait )
		newbutton.set_size(Vector2(20,20))
		var clickzone : BitMap = BitMap.new()
		clickzone.create(Vector2(20,20))
		clickzone.set_bit_rect(Rect2(0,0,20,20), true)
		newbutton.set_click_mask(clickzone)
#		newbutton.set_scale(Vector2(5.0/11.0,5.0/11.0))
		var _err = newbutton.connect("pressed",Callable(self,"_on_trade_char_select_button_pressed").bind(character, newbutton))
#		print("error signal ? ", err)
	#		var newbutton = Button.new()
	##		newbutton.set_expand_icon(true) 
	#		newbutton.add_theme_constant_override("h_separation",0)
	#		newbutton.set_flat(true)
	#		var newStyle : StyleBoxTexture = StyleBoxTexture.new()
	#		newStyle.set_draw_center(false)
	#		newStyle.set_texture( character.portrait )
	#
	#		newbutton.add_theme_stylebox_override("hover", newStyle )
	#		newbutton.add_theme_stylebox_override("pressed", newStyle )
	#		newbutton.add_theme_stylebox_override("focus", newStyle )
	#		newbutton.add_theme_stylebox_override("disabled", newStyle )
	#		newbutton.add_theme_stylebox_override("normal", newStyle )
	#		newbutton.text= "(!)"
	#		newbutton.set_size(Vector2(40,40))

#		newbutton.set_button_icon(character.portrait )

#			newbutton.add_theme_constant_override("h_separation",0)
#			#void add_theme_stylebox_override ( StringName name, StyleBox stylebox )
#			newbutton.set_flat(true)
#			newbutton.set_size(Vector2(40,40))
#			newbutton.add_theme_stylebox_override("hover", StyleBoxFlat )
#			newbutton.add_theme_stylebox_override("pressed", StyleBoxFlat )
#			newbutton.add_theme_stylebox_override("focus", StyleBoxFlat )
#			newbutton.add_theme_stylebox_override("disabled", StyleBoxFlat )
#			newbutton.add_theme_stylebox_override("normal", StyleBoxFlat )
#			print(character.name, character.portrait)
#			newbutton.set_button_icon(character.portrait )
		
#		var hotkey = InputEvent() # weird, but no `.new`
		if butnumber>0 and butnumber<=10:
			var hotkey = InputEventKey.new() # weird, but no `.new`
			hotkey.set_keycode( numberscancodes[butnumber] )
			var shortcut = Shortcut.new()
#			shortcut.set_shortcut(hotkey)
			shortcut.events = [hotkey]
			# and then checked BaseButton
			newbutton.set_shortcut(shortcut)
		butnumber +=1
		
		
		tradechargrid.add_child(newbutton)

func _on_ButtonShow_pressed():
	traderect.hide()
	buttonTrade.show()
	hud.set_charactersRect_type(0)

func _on_ButtonUse_pressed():
	if selected_item_ctrl != null :
		var owner_character = selected_item_ctrl.get_parent().get_parent().get_inventory_owner()
		use_item(selected_item_ctrl.item, owner_character, selected_item_ctrl)
		#selected_item_ctrl.use_item(true) #true =  from use button

func _on_ButtonDrop_pressed():
	if selected_item_ctrl != null :
		var dropped = hud.selected_character.drop_inventory_item(selected_item_ctrl.item)
		if dropped :
			SfxPlayer.stream = NodeAccess.__Resources().sounds_book["drop item.wav"]
			SfxPlayer.play()
		
			var owner_character = selected_item_ctrl.get_parent().get_parent().get_inventory_owner()
			var vbox = selected_item_ctrl.get_parent()
			fill_inventory_Vbox( vbox, owner_character )
		GameGlobal.refresh_OW_HUD()
#		fill_inventory_Vbox(inventoryBoxRight, hud.selected_character)

func _on_ButtonIdentify_pressed():
	print("_on_ButtonIdentify_pressed TBI, doesnt  use  spell yet")
	for i in hud.selected_character.inventory :
		GameGlobal.identify_item(i)
	GameGlobal.refresh_OW_HUD()

func _on_ButtonidentiPay_pressed():
	print("_on_ButtonIdentiPay_pressed TBI")

func _on_ButtonDone_pressed():
	print("_on_ButtonDone_pressed")
	hud._on_InventoryButton_pressed()


func _on_trade_char_select_button_pressed(character, button ) -> void :
#	print("_on_trade_char_select_button_pressed")
#	print("char name : ", character)
	if character == hud.selected_character :
		inventoryScrollLeft.hide()
#		inventoryBoxLeft.hide()
		selectedTradeCharacter = null
		tradeselectsprite.hide()
		tradeselectspritebutton = null
		return
	else :
		inventoryScrollLeft.show()
		selectedTradeCharacter = character
		fill_inventory_Vbox( inventoryBoxLeft , character)
		
		tradeselectspritebutton = button
		tradeselectsprite.show()
		tradeselectsprite.position = tradeselectspritebutton.get_rect().position
		# tradeselectsprite
		# tradeselectspritebutton
		# super.get_global_rect().position





func _on_ButtonSplit_pressed():
	if selected_item_ctrl == null or selected_item_ctrl.item["splittable"]==0:
		buttonJoin.hide()
		buttonSplit.hide()
		return
	var owner_character = selected_item_ctrl.get_parent().get_parent().get_inventory_owner()
	print("owner of ", selected_item_ctrl.item["name"]," is ", owner_character.name)
	var item_index_in_owner_inv = owner_character.inventory.find(selected_item_ctrl.item)
	var selitem = selected_item_ctrl.item
	var itemcopy = selitem.duplicate(true)
	#get the quantities for each item
	var total : int = selected_item_ctrl.item["charges"]
	var removed = int(float(total)/2.0)
	if removed == 0 :
		return
	var left = int(total-removed)
	selected_item_ctrl.item["charges"] = left
	itemcopy["charges"] = removed
	owner_character.inventory.insert(item_index_in_owner_inv+1,itemcopy)
	print("vbox of selected ctrl ? ", selected_item_ctrl.get_parent())
	
	var vbox = selected_item_ctrl.get_parent()
		
	var scrollvalue = vbox.get_parent().get_v_scroll()
	fill_inventory_Vbox( vbox, owner_character )
	#find the new selected ctrl :
	var ns = null
	for ctrl in vbox.get_children() :
		if ctrl.item == selitem :
			ns = ctrl
			break
	if ns != null :
		set_selected_item_ctrl(ns, false)
		vbox.get_parent().set_v_scroll(scrollvalue)


func _on_ButtonJoin_pressed():
	if selected_item_ctrl == null or selected_item_ctrl.item["splittable"]==0:
		buttonJoin.hide()
		buttonSplit.hide()
		return
	var owner_character = selected_item_ctrl.get_parent().get_parent().get_inventory_owner()
	var item_index_in_owner_inv = owner_character.inventory.find(selected_item_ctrl.item)
	var itemcopy = selected_item_ctrl.item.duplicate(true)
	var eraseafterloop : Array = []
	var totalcharges : int = 0
	for i in owner_character.inventory :
		#equality betwene discts checks for pointers not data...
		if (i["name"]==itemcopy["name"]) and (i["stats_mini"]==itemcopy["stats_mini"]) and (i["weight"]==itemcopy["weight"]) :
			totalcharges += i["charges"]
			eraseafterloop.append(i)
	for i in eraseafterloop :
		owner_character.inventory.erase(i)
	itemcopy["charges"] = totalcharges
		#danger, indexmust not be bigger than inv size !
	item_index_in_owner_inv = min(item_index_in_owner_inv, owner_character.inventory.size())
	#depending checked max charges, add several objetcs :
	if itemcopy.has("charges_max") :
		var chargesmax = itemcopy["charges_max"]
		itemcopy["charges"] = chargesmax
		while totalcharges > chargesmax :
			var itemadded = itemcopy.duplicate(true)
			owner_character.inventory.insert(item_index_in_owner_inv,itemadded)
			totalcharges -= chargesmax
		itemcopy["charges"] = totalcharges
		owner_character.inventory.insert(item_index_in_owner_inv,itemcopy)
	else :
		owner_character.inventory.insert(item_index_in_owner_inv,itemcopy)

	var vbox = selected_item_ctrl.get_parent()
#	buttonSplit.hide()
#	buttonJoin.hide()
	fill_inventory_Vbox( vbox, owner_character )
	#find the new selected ctrl :
	var ns = null
	for ctrl in vbox.get_children() :
		if ctrl.item == itemcopy :
			ns = ctrl
			break
	if ns != null :
		set_selected_item_ctrl(ns, false)
#	buttonJoin.hide()
#	buttonSplit.hide()


func _on_ButtonShop_pressed():
	traderect.hide()
	shopRect.initialize()
	buttonJoin.hide()
	buttonSplit.hide()
	hud.set_charactersRect_type(1)
	shopRect.show()
	shopRect._on_ShopButton_pressed("Weapons")
	shopButtonsRect.show()


func _on_ButtonEquip_pressed():
	if selected_item_ctrl == null :
		return
	selected_item_ctrl.equip_item()



func _on_ButtonTradeItem_pressed():
	if selected_item_ctrl == null :
		return
	var item = selected_item_ctrl.item
	if item["equipped"] == 1 :
		SfxPlayer.stream = NodeAccess.__Resources().sounds_book['generation error.wav']
		SfxPlayer.play()
		return
	var selvbox = selected_item_ctrl.get_parent()
	var selcontainer = selected_item_ctrl.get_parent().get_parent()
	var othercontainer = null
	if selcontainer == inventoryScrollLeft :
		othercontainer = inventoryScrollRight
	else :
		othercontainer = inventoryScrollLeft
	var selchar = selcontainer.get_inventory_owner()
	var itemindexinselchar = selchar.inventory.find(selected_item_ctrl.item)
	var otherchar = othercontainer.get_inventory_owner()
	var scrollvalue = selcontainer.get_v_scroll()

	#needed  to use  methods add_inventory_item
#	otherchar.inventory.append(item)
#	selchar.inventory.erase(item)
	if otherchar.can_add_inventory_item(item) :
		#if selchar.drop_inventory_item(item) :
		selchar.inventory.erase(item)
		otherchar.add_inventory_item(item)
	
	
	GameGlobal.refresh_OW_HUD()
	
	var selcharinvsize = selchar.inventory.size()
	if selcharinvsize>0 :
		itemindexinselchar = max(itemindexinselchar,1)
		itemindexinselchar = min(itemindexinselchar, selcharinvsize-1)

		var ns = null
		var targetitem = selchar.inventory[itemindexinselchar-1]
		for ctrl in selvbox.get_children() :
			if ctrl.item == targetitem :
				ns = ctrl
				break
		if ns != null :
			
			set_selected_item_ctrl(ns)
			selcontainer.set_v_scroll(scrollvalue)


func _on_button_storage_pressed():
		shopRect._on_LeaveShopButton_pressed()
		hud.open_storage_rect()

func set_allow_honest_storage(yes : bool) :
	storage_button.visible = GameGlobal.honest_mode and yes



func use_item(item : Dictionary, user : Creature, itemcontrol) :
	print("InventoryRect use_item() : "+item["name"]+" , StateMachine state : "+StateMachine._state_name)
	StateMachine.state.use_inventory_item(item, user)
	itemcontrol.set_item(item)
