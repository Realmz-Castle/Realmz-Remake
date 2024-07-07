extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

@export var itemLootButton : PackedScene

@onready var itemsRect = $itemsRect
@onready var expRect = $ExpRect
@onready var botrightpanel = $BotRightLootInfo
@onready var itemsContainer : GridContainer = $itemsRect/ScrollContainer/ItemContainer

@onready var itemTextureRect : TextureRect = $BotRightLootInfo/ItemInfoRect/ItemTextureRect
@onready var itemNameLabel : Label = $BotRightLootInfo/ItemInfoRect/ItemNameLabel
@onready var itemStatsLabel : Label = $BotRightLootInfo/ItemInfoRect/ItemStatsLabel
@onready var itemsWeightLabel : Label = $BotRightLootInfo/ItemInfoRect/ItemWeightLabel

@onready var explabel : Label = $ExpRect/ExpLabel

@onready var moneyLabel : Label = $BotRightLootInfo/ItemInfoRect/MoneynLabel

var exp : int = 0
var exp_receivers : Array = []

signal done_looting

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func on_viewport_size_changed(screensize : Vector2) :
	itemsRect._set_size(Vector2(screensize.x-320, screensize.y-24))
	expRect._set_position(Vector2(0,screensize.y-24))
	expRect._set_size(Vector2(screensize.x-320, 24))
	botrightpanel._set_position(Vector2(screensize.x-320,screensize.y-200))
	#set itemcontainer max columns
	var width = screensize.x-320
	var columns = floor(width/50)-1
	itemsContainer.set_columns(columns)  # 9 if width<480


# take inspiration from textrect script, money is  [gold,gems,jewels]
func display(items : Array, money : Array, experience : int) :
	exp = experience
	exp_receivers.clear()
	for pc : PlayerCharacter in GameGlobal.player_characters :
		if pc.get_stat("curHP")<=0 :
			continue
		for t in pc.traits :
			if t.trait_types.has("no_exp") :
				continue
		exp_receivers.append(pc)
			
	explabel.text = " Experience : "+ str(exp) +", split among " + str(exp_receivers.size()) + "characters"
	for c in range(3) :
		GameGlobal.money_pool[c] += money[c]
	update_money_label()
	#fill the gridcontainer
	for i in items :
		i["equipped"] = 0
		var newButton = itemLootButton.instantiate()
		var newtex : Texture2D = i["texture"]
		newButton.find_child("ItemTextureRect").set_texture( newtex )
		newButton.connect("pressed",Callable(self,"_on_itemlootbutton_pressed").bind(i, newButton))
		newButton.connect("mouse_entered",Callable(self,"_on_itemlootbutton_mouse_entered").bind(i,newButton))
		newButton.connect("mouse_exited",Callable(self,"_on_itemlootbutton_mouse_exited"))
		
		#ibutton.connect("pressed",Callable(self,"_on_dropentry_pressed").bind(i))
		itemsContainer.add_child(newButton)
#		display_money(money)
	show()

#func display_money(money : Array) :
#	var moneytext : String = str(money[0])+'\n'+str(money[1])+'\n'+str(money[2])
#	moneyLabel.text = moneytext

func _on_itemlootbutton_mouse_entered(item : Dictionary, button : Button) :
	if button.disabled :
		_on_itemlootbutton_mouse_exited()
		return
	itemTextureRect.show()
	itemNameLabel.show()
	itemStatsLabel.show()
	itemsWeightLabel.show()
	
	itemTextureRect.set_texture(item["texture"])
	var iname = item["name"]
	if item.has("charges_max") :
		if item["charges_max"]>0 :
			iname = iname + ' X' + str(item["charges"])
	itemNameLabel.text = iname+" ("+item["type"]+")"
	itemStatsLabel.text = item["stats_mini"]
	itemsWeightLabel.text = "Weight : " + str(item["weight"]+item["charges_weight"]*item["charges"])

func _on_itemlootbutton_mouse_exited() :
	itemTextureRect.hide()
	itemNameLabel.hide()
	itemStatsLabel.hide()
	itemsWeightLabel.hide()


func _on_itemlootbutton_pressed(item:Dictionary, button : Button) :
	var looter = UI.ow_hud.selected_character
#	print(looter.name," picks up ", item["name"])
#	return
	var looted : bool = looter.add_inventory_item(item)
	if looted :
		# to keep an empty spot
		button.set_disabled(true)
		button.release_focus()
#		button.disconnect("pressed",Callable(self,"_on_itemlootbutton_pressed"))
		for child in button.get_children() :
#			button.remove_child(child)
			child.queue_free()
		UI.ow_hud.updateCharPanelDisplay()

func close() :
	#empty the gridcontainer
	await GameGlobal.give_exp_to_pcs( floor( float(exp)/float(exp_receivers.size()) ) , exp_receivers )

	print("teasure_control got GameGlobal.done_giving_exp")
	for child in itemsContainer.get_children() :
		itemsContainer.remove_child(child)
		child.queue_free()
	get_parent().set_charactersRect_type(0)
	get_parent().moneyControl.close()
	NodeAccess.__Map().show()
	emit_signal("done_looting")
	print("teasure_control  close()")
	hide()


func _on_ButtonDone_pressed():
	close()

func update_money_label() :
	var moneytext : String = ''
	for c in GameGlobal.money_pool :
		moneytext += str(c)+'\n'
	moneyLabel.set_text(moneytext)

func _on_PoolButton_pressed():
	get_parent().moneyControl._on_PoolButton_pressed()
	update_money_label()


func _on_ShareButton_pressed():
	get_parent().moneyControl._on_ShareButton_pressed()
	update_money_label()


func _on_money_button_pressed():
	get_parent()._on_MoneyButton_pressed()
