extends Button
#ItemShopButton

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@onready var colorRect : ColorRect = $colorRect
@onready var iconsprite : Sprite2D = $"IconSprite"
@onready var namelabel : Label= $"ItemnameLabel"
@onready var infolabel : Label = $"IteminfoLabel"
@onready var priceLabel : Label = $"PricenLabel"
@onready var weightLabel : Label = $"WeightnLabel"
@onready var quantityLabel : Label = $"QuantityLabel"
#onready var inventoryrect : Control = get_parent().get_parent().inventoryrect
@onready var chargesLabel : Label = $ChargesLabel
@onready var statsLabel : Label = $ItemstatsLabel
@onready var selectedSprite : Sprite2D = $SpriteSelected

#onready var buttonJoin : Button = $JoinButton
#onready var buttonSplit : Button = $SplitButton
#onready var textfield : TextEdit = $TextEdit

var item = null
var shopVbox : Control = null
var inventoryrect : Control = null

# Called when the node enters the scene tree for the first time.
func _ready():
#	on_viewport_size_changed (get_window().get_size())
#	var screensize : Vector2 = get_window().get_size()
#	_set_size(Vector2(floor((screensize.x-320-44-20)/2), 40))
	pass # Replace with function body.


func on_viewport_size_changed(screensize):
	#needed to set size expand flags checked this AND the parent vcontainer
#	print("itembutton on_viewport_size_changed ", namelabel.text, floor((screensize.x-320-44-20)/2))
	chargesLabel._set_position( Vector2(floor((screensize.x-320-44-20)/2) - 85 -10, 4) )
	statsLabel._set_position( Vector2(floor((screensize.x-320-44-20)/2) - 205 -10, 20) )
	colorRect._set_size(Vector2(floor((screensize.x-320-44-20)/2), 60))
#	_set_size(Vector2(floor((screensize.x-320-44-20)/2), 40))

#	SfxPlayer.stream = NodeAccess.__Resources().sounds_book["slurpy.ogg"]
#	SfxPlayer.play()


func set_item(nitem : Dictionary, quantity, invrect, price) -> void :
	inventoryrect = invrect
#	print("item : ",item)
	var screensize : Vector2  = ScreenUtils.get_logical_window_size(self)
	colorRect._set_size(Vector2(floor((screensize.x-320-44-20)/2), 40))
	_set_size(Vector2(floor((screensize.x-320-44-20)/2), 40))
	iconsprite.set_texture( nitem["texture"] )
	namelabel.text = nitem["name"]
	infolabel.text = nitem["type"]
	priceLabel.text = str(price)
	weightLabel.text = str(nitem["weight"])
	quantityLabel.text = str(quantity)+' X'
	if nitem["charges_max"] == 0 :
		chargesLabel.hide()
	else :
		chargesLabel.show()
		chargesLabel.text = 'X ' + str(nitem["charges"]) + ' / '+ str(nitem["charges_max"])
#		var screensize : Vector2 = get_window().get_size()
		chargesLabel._set_position( Vector2(floor((screensize.x-320-44-20)/2) - 85 -10, 4) )
	if nitem.has("stats_mini") :
		statsLabel.text = nitem["stats_mini"]
#		var screensize : Vector2 = get_window().get_size()
		statsLabel._set_position( Vector2(floor((screensize.x-320-44-20)/2) - 205 -10, 20) )
	else :
		statsLabel.text = ''
	item = nitem
#
#	if nitem["splittable"]==0:
#		remove_child(buttonJoin)
#		remove_child(buttonSplit)
#		remove_child()
#		queue_free()

func update_display() -> void :
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _get_drag_data(_pos):
	if inventoryrect==null :
		return
	var itemprice = int( item["price"] * GameGlobal.get_shop(GameGlobal.currentShop)["sell_rate"] )
	var customer = inventoryrect.inventoryScrollRight.get_inventory_owner()
	print(itemprice ,"<>", customer.money[0], '+', GameGlobal.money_pool[0])
	if itemprice > customer.money[0] + GameGlobal.money_pool[0] : # if
		print(" NOT ENOUGH GOLD TO BUY THIS")
		GameGlobal.play_sfx("target error.wav")
		return
	# Use another colorpicker as drag preview
	var dragpreview = TextureRect.new()
	dragpreview.set_texture(item["texture"])
#	cpb.size = Vector2(50, 50)
	set_drag_preview(dragpreview)
	# Return item and its owner character as data
	return [item, "Shop" ]  #parent is the vbox it came from



#
#func _drop_data(_pos, data):
#	if inventoryrect==null :
#		return
#







#func _on_ItemSmallButton_gui_input(event):
	#pass

func _on_ItemSmallButton_mouse_entered():
	if inventoryrect==null :
		return
	inventoryrect.display_item_info(item)
	colorRect.color = Color(0.9, 0.9, 0.9, 1)

func _on_ItemSmallButton_mouse_exited():
	colorRect.color = Color(1,1,1, 1)
