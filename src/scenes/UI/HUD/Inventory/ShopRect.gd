extends NinePatchRect
class_name ShopRect

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@onready var inventoryrect = $"../../../.."
@onready var vbox : VBoxContainer = $"InvScrollContainerShop/VBoxContainerL"
@onready var itemShopButtonTSCN : PackedScene = preload("res://scenes/UI/HUD/Inventory/ItemShopButton.tscn")
@onready var resources = NodeAccess.__Resources()

@onready var goldLabel : Label = $"MoneyRect/GoldnLabel"
@onready var poolLabel : Label = $"MoneyRect/PoolnLabel"

var buy_rate : float = 1.0
var sell_rate : float = 1.0
var weapons : Array = []	# arrays of itemshopbuttons
var armor : Array = []
var limbs : Array = []
var supplies : Array = []
var buyback : Array = []
var types = {"Weapons":weapons, "Armor":armor, "Limbs":limbs, "Supplies":supplies, "BuyBack":buyback}
var current_shop_category : String = "Weapons"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize() :
	print("INITIALIZING shoprect's inventoryrect ", inventoryrect)
	#display selected character's gold
	var chara = $"../../../..".hud.selected_character
	goldLabel.text = str( chara.money[0] )
	poolLabel.text = str( GameGlobal.money_pool[0] )
#	pass # GameGlobal.currentShop : String
	weapons.clear()
	armor.clear()
	limbs.clear()
	supplies.clear()
	buyback.clear()
	
	var curshopname : String = GameGlobal.currentShop
	print("shoprect curshopname : ",curshopname)
#	var shopscript = resources.shopsGD
	if curshopname == '' :
		return
	var curShop = GameGlobal.get_shop(curshopname)
	buy_rate = curShop["buy_rate"]
	sell_rate = curShop["sell_rate"]
#	print(curShop)
	for t in types :
		for i in curShop[t] :
			
			var newitemdict = null
			if typeof(i[0]) == TYPE_STRING :
				newitemdict = resources.items_book[i[0]].duplicate()
			else :
				newitemdict = i[0]
			
			
#			var newitem = resources.generate_item_from_json_dict(newitemdict)
#			print("ShopRect newitemdict : ", newitemdict)
#			print("ShopRect newitem : ", newitem)


			var price = i[2]
			if i[2]<=0 :
				price = sell_rate * newitemdict["price"]
			var quantity : int = i[1]
#			await newshopitembutton.ready #doesnt happen until added to tree !
			types[t].append([newitemdict, quantity, price])
#			print("adding "+newitemdict["name"]+" to "+t)
#	print(types)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_LeaveShopButton_pressed():
	if visible :
		weapons.clear()
		armor.clear()
		limbs.clear()
		supplies.clear()
		buyback.clear()
		inventoryrect.hud.set_charactersRect_type(0)
		hide()
		inventoryrect.hud.moneyControl._on_ShareButton_pressed()
#		$"../../MoneyRect"._on_ShareButton_pressed()

func _on_character_selected(chara) :
	goldLabel.text = str( chara.money[0] )
	poolLabel.text = str( GameGlobal.money_pool[0] )


func _on_PoolButton_pressed():
#	$"../../MoneyRect".initialize(GameGlobal.player_characters)
#	$"../../MoneyRect"._on_PoolButton_pressed()
	inventoryrect.hud.moneyControl.initialize(GameGlobal.player_characters)
	inventoryrect.hud.moneyControl._on_PoolButton_pressed()
	
	goldLabel.text = '0'
	poolLabel.text = str( GameGlobal.money_pool[0] )
	


func _on_ShopButton_pressed(type : String):
	print("ShopRect _on_ShopButton_pressed "+type)
	fillVbox(type)
	current_shop_category = type

func fillVbox(type : String) :
#	print("ShopRect fillVbox"+type)
	for child in vbox.get_children() :
		vbox.remove_child(child)
		child.queue_free()
	for itemshoparray in types[type] :
		var newshopitembutton = itemShopButtonTSCN.instantiate()
		vbox.add_child(newshopitembutton)
		newshopitembutton.set_item(itemshoparray[0], itemshoparray[1], inventoryrect, itemshoparray[2])
		
#		itemcontrol.update_display()


func remove_one_from_stock(item :  Dictionary) :
	# find the first empty slot in category then buybackArray
	for s in types[current_shop_category] :
		if (s[0]["name"]==item["name"]
		and s[0]["stats_mini"] == item["stats_mini"]
		and s[0]["weight"] == item["weight"]
		and s[0]["price"] == item["price"]
		and s[0]["charges"] == item["charges"]
		):  # lower quantity count by one
			s[1] -= 1
			break
