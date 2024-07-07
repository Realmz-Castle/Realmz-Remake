extends ScrollContainer
class_name CharacterInventoryContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#does this display the inventory of the character selected in the main hud ?
@export var is_hud_selected : bool = false

@onready var mybox = self.get_child(0)
var inventoryrect = null

var belongstoally : bool = false  : set = set_belongstoally

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_belongstoally(value : bool) :
	belongstoally = value
	modulate = Color(1,1,1,0.75) if value else Color.WHITE

func _can_drop_data(_pos, data):
	if belongstoally :
		return false
	# good enough to prove it's an item !
	if (typeof(data[0]) == TYPE_DICTIONARY and data[0].has("imgdata") ) :
		var mycharacter = get_inventory_owner()
		var characteritemcamefrom = data[1]
		if typeof(characteritemcamefrom) != TYPE_STRING :
			if mycharacter == characteritemcamefrom :
				return true
			else :
				if data[0]["is_unique"] and  GameGlobal.enforce_unique_items :
					print("CharacterInventoryContainer "+name+" : Item is unique !")
					return not GameGlobal.does_party_have_same_item(data[0])[0] and (data[0]["tradeable"]==1 or data[1]=="Shop")
				return data[0]["tradeable"]==1 or data[1]=="Shop"
		else :
			if characteritemcamefrom == "Shop" :
				var shop = GameGlobal.get_shop(GameGlobal.currentShop)
				var price = int(data[0]["price"]*shop["sell_rate"])
				return mycharacter.can_add_inventory_item(data[0]) and  mycharacter.money[0]+GameGlobal.money_pool[0]>=price # check for money first
				
				
func _drop_data(_pos, data):
	print("CharacterInventoryContainer "+name+" _drop_data ")
	var item = data[0]
	var characteritemcamefrom = data[1]
	var mycharacter = get_inventory_owner()
	
	if typeof(characteritemcamefrom) != TYPE_STRING :
		if characteritemcamefrom == mycharacter :
			return
		else :
			
			if mycharacter.can_add_inventory_item(item) :
				#if selchar.drop_inventory_item(item) :
				characteritemcamefrom.inventory.erase(item)
				mycharacter.add_inventory_item(item)
			else :
				SfxPlayer.stream = NodeAccess.__Resources().sounds_book['generation error.ogg']
				SfxPlayer.play()
	else : 
		if characteritemcamefrom == "Shop" :
			print ("char money : ", mycharacter.money[0], ", pool : ", GameGlobal.money_pool[0])
			if mycharacter.can_add_inventory_item(item) :
				#if selchar.drop_inventory_item(item) :
				var shop = GameGlobal.get_shop(GameGlobal.currentShop)
#				characteritemcamefrom.inventory.erase(item)
				
				inventoryrect.shopRect.remove_one_from_stock(item )
				mycharacter.add_inventory_item(item)
				#deduct money
				var price = int(item["price"]*shop["sell_rate"])
				print("price : ", price)
				var  removed = min(price, mycharacter.money[0])
				mycharacter.money[0]-=removed
				price -= removed
				GameGlobal.money_pool[0]-=price
				print ("char money : ", mycharacter.money[0], ", pool : ", GameGlobal.money_pool[0])
				inventoryrect.shopRect.goldLabel.text = str(mycharacter.money[0])
				inventoryrect.shopRect.poolLabel.text = str( GameGlobal.money_pool[0] )
				inventoryrect.shopRect.fillVbox(inventoryrect.shopRect.current_shop_category)
			else :
				SfxPlayer.stream = NodeAccess.__Resources().sounds_book['generation error.ogg']
				SfxPlayer.play()

#		characteritemcamefrom.inventory.erase(item)
#		mycharacter.inventory.append(item)
		
	print("INcvoentoryContainer "+name+" fill_inventory_Vbox ", inventoryrect.inventoryBoxLeft, inventoryrect.inventoryBoxLeft.get_parent().get_inventory_owner() )
	inventoryrect.fill_inventory_Vbox(inventoryrect.inventoryBoxLeft, inventoryrect.inventoryBoxLeft.get_parent().get_inventory_owner())
	inventoryrect.fill_inventory_Vbox(inventoryrect.inventoryBoxRight, inventoryrect.inventoryBoxRight.get_parent().get_inventory_owner())
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_inventory_owner() :
	if is_hud_selected :
		return inventoryrect.hud.selected_character
	else :
		return inventoryrect.selectedTradeCharacter
