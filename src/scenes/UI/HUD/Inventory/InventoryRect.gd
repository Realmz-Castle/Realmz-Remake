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




func on_viewport_size_changed(_screensize) :
	return
	##IDK IF STILL IMPORTANT
	#
	#_set_size(Vector2(screensize.x-320, screensize.y-200))
##	inventoryBoxRight
	#traderect._set_size(Vector2(floor((screensize.x-320-44-20)/2), screensize.y-210))
	#if tradeselectspritebutton != null :
		#tradeselectsprite.position = tradeselectspritebutton.get_rect().position
		#tradeselectsprite.show()
	#else :
		#tradeselectsprite.hide()
	#
	#var scrollW = floor((screensize.x-320-44-20)/2)
	#
	#inventoryScrollLeft._set_size(Vector2( scrollW , screensize.y-260))
	#
	#inventoryScrollRight._set_size(Vector2( scrollW, screensize.y-260))
	#var rightPanX = 54+floor((screensize.x-320-44-20)/2)
	#inventoryScrollRight._set_position(Vector2(rightPanX,10))
#
	#var buttonY = screensize.y-250
	#
	#var emptyspace = floor((scrollW-63-73-80-66)/3)
	#
	#buttonDone._set_position(Vector2( 10+floor((screensize.x-320-44-20)/2) , buttonY))
	#
	#buttonJoin._set_position(Vector2( 10+floor((screensize.x-320-44-20)/2) , buttonY-50))
	#buttonSplit._set_position(Vector2( 10+floor((screensize.x-320-44-20)/2) , buttonY-75))
	#
	#buttonUse._set_position(Vector2( rightPanX , buttonY))
	#buttonIdentify._set_position(Vector2( rightPanX+63+emptyspace , buttonY))
	#buttonIdenPay._set_position(Vector2( rightPanX+63+73+2*emptyspace , buttonY))
	#buttonDrop._set_position(Vector2 ( screensize.x-320-66-10 , buttonY ))
	#buttonTrade._set_position( Vector2(10, buttonY) )
#
	#buttonShow._set_position( Vector2(0, buttonY-10) )
##	buttonShop._set_position( Vector2(74, buttonY-10) )
	#tradeicons._set_position( Vector2(74+40, buttonY-10))
	#var columns = max( floor((scrollW-74-40)/16)-1 , 1)
	#tradeicons.set_columns(columns)
	#
##	infoRect._set_size(Vector2( screensize.x-320 , 200))
##	infoRect.get_node("InfoLabel")._set_size(Vector2( scrollW , screensize.y-260))
#
##	shopRect._set_size(Vector2( scrollW+10 , screensize.y-200-10))
	#var ratio = 1.0
	#if screensize.y<600 :
		#var buttonrectheight = max(screensize.y,400)-260
		#ratio = buttonrectheight/340
		#
	#shopButtonsRect.set_scale(Vector2(1.0,ratio))
	#if visible :
		#for i in inventoryBoxLeft.get_children() :
			#i.on_viewport_size_changed(screensize)
		#for i in inventoryBoxRight.get_children() :
			#i.on_viewport_size_changed(screensize)

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
	for item: ItemInstance in character.inventory_instances():
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

func display_item_info(item: ItemInstance) -> void:
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
	
	var definition := NodeAccess.__Resources().get_item_definition(
		selected_item_ctrl.item
	)
	if definition == null or not definition.splittable:
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
		var owner_character: Creature = (
			selected_item_ctrl.get_parent().get_parent().get_inventory_owner()
		)
		var dropped = owner_character.drop_inventory_item(selected_item_ctrl.item)
		if dropped :
			SfxPlayer.stream = NodeAccess.__Resources().sounds_book["drop item.wav"]
			SfxPlayer.play()
		
			var vbox = selected_item_ctrl.get_parent()
			fill_inventory_Vbox( vbox, owner_character )
		GameGlobal.refresh_OW_HUD()
#		fill_inventory_Vbox(inventoryBoxRight, hud.selected_character)

func _on_ButtonIdentify_pressed():
	if not is_instance_valid(selected_item_ctrl) : return
	if selected_item_ctrl.item.identified: return
	print("INventoryRect _on_ButtonIdentify_pressed ok")
	var chara_cancast_identify : Creature = null
	var resources = NodeAccess.__Resources()
	var id_spell = resources.spells_book["Identify Objects"]['script']
	var my_creas : Array = GameGlobal.player_allies + GameGlobal.player_characters
	var sp_cost : int = 0
	for c : Creature in my_creas :
		
		sp_cost = c.get_spell_resource_cost(id_spell, 1)
		print('InvRect   '+c.name+ ' cost: '+ str(sp_cost), '  knows? ',  c.does_crea_know_spell_named("Identify Objects") )
		if c.does_crea_know_spell_named("Identify Objects") and c.get_stat('curSP') >= sp_cost :
			chara_cancast_identify = c
			break
	if is_instance_valid(chara_cancast_identify) :
		SfxPlayer.stream = resources.sounds_book[id_spell.sounds[1]]
		SfxPlayer.play()
		chara_cancast_identify.change_cur_sp(-sp_cost)
		GameGlobal.identify_item(selected_item_ctrl.item)
		selected_item_ctrl.set_item(selected_item_ctrl.item)
		GameGlobal.refresh_OW_HUD()
	else :
		SfxPlayer.stream = resources.sounds_book['generation error.wav']
		SfxPlayer.play()
	
func _on_ButtonidentiPay_pressed():
	print("InvRect _on_ButtonIdentiPay_pressed")
	if not is_instance_valid(selected_item_ctrl) : return
	if selected_item_ctrl.item.identified: return
	if hud.selected_character.money[0] >= 10 or GameGlobal.money_pool[0] >= 10 :
		GameGlobal.identify_item(selected_item_ctrl.item)
		selected_item_ctrl.set_item(selected_item_ctrl.item)
		if hud.selected_character.money[0] >= 10 :
			hud.selected_character.money[0] -= 10
			shopRect.goldLabel.text = str( hud.selected_character.money[0] )
		else :
			GameGlobal.money_pool[0] -= 10
			shopRect.poolLabel.text = str( GameGlobal.money_pool[0] )
		GameGlobal.refresh_OW_HUD()
	else :
		SfxPlayer.stream = NodeAccess.__Resources().sounds_book['generation error.wav']
		SfxPlayer.play()


func _on_ButtonDone_pressed():
	print("InvRect _on_ButtonDone_pressed")
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
	if selected_item_ctrl == null:
		buttonJoin.hide()
		buttonSplit.hide()
		return
	var owner_character: Creature = (
		selected_item_ctrl.get_parent().get_parent().get_inventory_owner()
	)
	var selected_instance: ItemInstance = selected_item_ctrl.item
	var definition := NodeAccess.__Resources().get_item_definition(
		selected_instance
	)
	if definition == null or not definition.splittable:
		buttonJoin.hide()
		buttonSplit.hide()
		return
	var item_index_in_owner_inv := owner_character.item_inventory.find(
		selected_instance
	)
	#get the quantities for each item
	var total: int = selected_instance.charges
	var removed = int(float(total)/2.0)
	if removed == 0 :
		return
	var left = int(total-removed)
	selected_instance.charges = left
	owner_character.sync_item_runtime_state(selected_instance)
	var split_instance := NodeAccess.__Resources().copy_item_instance(
		selected_instance,
		{"charges": removed, "equipped": false},
	)
	if split_instance == null \
			or not owner_character.add_inventory_item(
				split_instance,
				item_index_in_owner_inv + 1,
			):
		selected_instance.charges = total
		owner_character.sync_item_runtime_state(selected_instance)
		return
	print("InvRect vbox of selected ctrl ? ", selected_item_ctrl.get_parent())
	
	var vbox = selected_item_ctrl.get_parent()
		
	var scrollvalue = vbox.get_parent().get_v_scroll()
	fill_inventory_Vbox( vbox, owner_character )
	#find the new selected ctrl :
	var ns = null
	for ctrl in vbox.get_children() :
		if ctrl.item == selected_instance:
			ns = ctrl
			break
	if ns != null :
		set_selected_item_ctrl(ns, false)
		vbox.get_parent().set_v_scroll(scrollvalue)


func _on_ButtonJoin_pressed():
	if selected_item_ctrl == null:
		buttonJoin.hide()
		buttonSplit.hide()
		return
	var owner_character: Creature = (
		selected_item_ctrl.get_parent().get_parent().get_inventory_owner()
	)
	var survivor: ItemInstance = selected_item_ctrl.item
	var definition := NodeAccess.__Resources().get_item_definition(survivor)
	if definition == null or not definition.splittable:
		buttonJoin.hide()
		buttonSplit.hide()
		return
	var item_index_in_owner_inv := owner_character.item_inventory.find(survivor)
	var matches: Array[ItemInstance] = []
	var totalcharges := 0
	for candidate: ItemInstance in owner_character.inventory_instances():
		if candidate.definition_id == survivor.definition_id:
			matches.append(candidate)
			totalcharges += candidate.charges
	for candidate: ItemInstance in matches:
		if candidate != survivor:
			owner_character.remove_inventory_item(candidate)
	var charges_max := definition.maximum_charges
	if charges_max <= 0:
		survivor.charges = totalcharges
	else:
		survivor.charges = mini(totalcharges, charges_max)
		var remaining := totalcharges - survivor.charges
		var insertion_index := mini(
			item_index_in_owner_inv + 1,
			owner_character.item_inventory.size(),
		)
		while remaining > 0:
			var stack_charges := mini(remaining, charges_max)
			var extra_stack := NodeAccess.__Resources().copy_item_instance(
				survivor,
				{"charges": stack_charges, "equipped": false},
			)
			if extra_stack == null \
					or not owner_character.add_inventory_item(
						extra_stack,
						insertion_index,
					):
				break
			remaining -= stack_charges
			insertion_index += 1
	owner_character.sync_item_runtime_state(survivor)

	var vbox = selected_item_ctrl.get_parent()
#	buttonSplit.hide()
#	buttonJoin.hide()
	fill_inventory_Vbox( vbox, owner_character )
	#find the new selected ctrl :
	var ns = null
	for ctrl in vbox.get_children() :
		if ctrl.item == survivor:
			ns = ctrl
			break
	if ns != null :
		set_selected_item_ctrl(ns, false)
#	buttonJoin.hide()
#	buttonSplit.hide()


func _on_ButtonShop_pressed():
	traderect.hide()
	shopRect.initialize()
	buttonIdenPay.show()
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
	var item: ItemInstance = selected_item_ctrl.item
	if item.equipped:
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
	var itemindexinselchar = selchar.item_inventory.find(item)
	var otherchar = othercontainer.get_inventory_owner()
	var scrollvalue = selcontainer.get_v_scroll()

	if otherchar.can_add_inventory_item(item) :
		#if selchar.drop_inventory_item(item) :
		selchar.transfer_inventory_item_to(otherchar, item)
	
	
	GameGlobal.refresh_OW_HUD()
	
	var selcharinvsize = selchar.item_inventory.size()
	if selcharinvsize>0 :
		itemindexinselchar = max(itemindexinselchar,1)
		itemindexinselchar = min(itemindexinselchar, selcharinvsize-1)

		var ns = null
		var targetitem: ItemInstance = selchar.item_inventory[
			itemindexinselchar - 1
		]
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



func use_item(item: ItemInstance, user: Creature, itemcontrol) -> void:
	var definition := NodeAccess.__Resources().get_item_definition(item)
	if definition == null:
		return
	print(
		"InventoryRect use_item() : "
		+ definition.display_name
		+ " , StateMachine state : "
		+ StateMachine._state_name
	)
	if user.has_method("can_use_inventory_item") \
			and not user.call("can_use_inventory_item", item):
		SfxPlayer.stream = (
			NodeAccess.__Resources().sounds_book["generation error.wav"]
		)
		SfxPlayer.play()
		return
	StateMachine.state.use_inventory_item(item, user)
	itemcontrol.set_item(item)


func refresh_inventory_lists() -> void:
	fill_inventory_Vbox(
		inventoryBoxRight,
		inventoryScrollRight.get_inventory_owner(),
	)
	if inventoryScrollLeft.visible and selectedTradeCharacter != null:
		fill_inventory_Vbox(
			inventoryBoxLeft,
			inventoryScrollLeft.get_inventory_owner(),
		)


func can_purchase_shop_item(
	customer: Creature,
	item: ItemInstance,
) -> bool:
	if customer == null or item == null:
		return false
	if not GameGlobal.current_shop_accepts_item(item):
		return false
	var definition := NodeAccess.__Resources().get_item_definition(item)
	if definition == null:
		return false
	if definition.unique and GameGlobal.enforce_unique_items:
		if GameGlobal.does_party_have_same_item(item)[0]:
			return false
	var price: int = shopRect.price_for(item)
	return (
		price >= 0
		and customer.can_add_inventory_item(item)
		and customer.money[0] + GameGlobal.money_pool[0] >= price
	)


func purchase_shop_item(
	customer: Creature,
	item: ItemInstance,
	target_index := -1,
) -> bool:
	if not can_purchase_shop_item(customer, item):
		return false
	var result: Dictionary = shopRect.purchase_item(
		customer,
		item,
		target_index,
	)
	if not bool(result.get("ok", false)):
		return false
	var price := int(result["price"])
	var balances: Array[int] = GameGlobal.shop_purchase_balances(
		customer.money[0],
		GameGlobal.money_pool[0],
		price,
	)
	customer.money[0] = balances[0]
	GameGlobal.money_pool[0] = balances[1]
	shopRect.goldLabel.text = str(customer.money[0])
	shopRect.poolLabel.text = str(GameGlobal.money_pool[0])
	shopRect.fillVbox(shopRect.current_shop_category)
	return true
