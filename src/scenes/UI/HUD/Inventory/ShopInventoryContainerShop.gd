extends ScrollContainer
class_name ShopInventoryContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var weapon_types : Array = ["Mace","Club","Hammer","Warhammer/Maul", # Two handed big blunt weapons
	"Dagger","Shortsword", "Arming Sword","Longsword",
	"Short Axe","Staff","Pole Axe","Spear","Eastern Weapon",
	"Dart","Throwing Bottle","Throwing Dagger","Throwing Rock","Throwing Axe","Throwing Hammer","Throwing Spear",
	"Whip","Bow","Crossbow","Quiver","Throwing Aid",
	"Misc. Melee Weapon","Misc Ranged Weapon"]
var limb_types : Array = ["Belt","Necklace","Ring",
	"Hat","Soft Helmet","Light3D Helmet","Great Helm",
	"Small Shield","Medium Shield","Large Shield", 
	"Bracers","Cloth Gloves","Leather Gloves","Metal Gloves",
	"Soft Boots","Hard Boots"]
var armor_types : Array = [	"Cloak/Cape","Robe",
	"Gambeson","Leather Armor","Chainmail Armor",
	"Splint Armor","Plate Armor"]
var supply_types : Array = ["Potion","Consumable",
	"Food", "Scroll Case", "Scroll", "Parchment"]

	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _can_drop_data(_pos, data) ->bool :
	# good enough to prove it's an item ! not from the Shop !
	var item = data[0]
	var itemowner = data[1]
	if not ( (typeof(item) == TYPE_DICTIONARY 
		and item.has("imgdata") ) 
		and typeof(itemowner) != TYPE_STRING) :
		return false
	return true

func _drop_data(_pos, data):
	print(" shop invscrollContainer _drop_data ", data[0]["name"])
	
	var item = data[0]
	var itemowner = data[1]
	var shopDict = GameGlobal.shops_dict[GameGlobal.currentShop]

	
#
#	# determine in what category the item belongs :
	var itemType = item["type"]
	var itemshoptype = ''
	if itemType in weapon_types :
		itemshoptype = "Weapons"
	elif itemType in armor_types :
		itemshoptype = "Armor"
	elif itemType in limb_types :
		itemshoptype = "Limbs"
	elif itemType in supply_types :
		itemshoptype = "Supplies"
	print(" item 's category is " + itemshoptype)
#
	
	
	# find the first empty slot in category then buybackArray
	var pickedslot : int = -1
	var sidx : int = 0
	var replaceslot : bool = true # if false, add to quantity instead
	var shoprect = get_parent()
	for s in shoprect.types[itemshoptype] :

		if (s[0]["name"]==item["name"]
		and s[0]["stats_mini"] == item["stats_mini"]
		and s[0]["weight"] == item["weight"]
		and s[0]["price"] == item["price"]
		and s[0]["charges"] == item["charges"]
		):  #check for free/already here slot in shop buyback 
			pickedslot = sidx
			replaceslot = false
			print("identified as "+s[0]['name']+" in "+itemshoptype)
			break
		sidx +=1
	
	if pickedslot <0 :
		itemshoptype = 'BuyBack'
	print("item belongs  in array "+itemshoptype)
	
	var buybackArray : Array = shopDict["BuyBack"]
	if itemshoptype == 'BuyBack' :
		for s in buybackArray :
			if s[1]<=0 :
				pickedslot = sidx
				replaceslot = true
				break
			elif (s[0]["name"]==item["name"]
			and s[0]["stats_mini"] == item["stats_mini"]
			and s[0]["weight"] == item["weight"]
			and s[0]["price"] == item["price"]
			and s[0]["charges"] == item["charges"]
			):  #check for free/already here slot in shop buyback 
				pickedslot = sidx
				replaceslot = false
				break
			sidx += 1
	
	var shopTypeArray = shopDict[itemshoptype]
	
	if pickedslot == -1 :
		# didnt find an empty/same slot, must append to buybackArray
		buybackArray.append([item, 1, int(item["price"] * shopDict["buy_rate"]) ])
	else :
		# found an empty/Same slot, replace it ?
#		print("# found an empty/Same slot",pickedslot," in array ",shopTypeArray,", replace it ?")
		if replaceslot :
#			print("yes")
			shopTypeArray[pickedslot] = [item, 1, int(item["price"] * shopDict["buy_rate"]) ]
		else :
#			print("no")
			print(typeof(shopTypeArray[pickedslot]))
			print(shopTypeArray[pickedslot][1])
			shopTypeArray[pickedslot][1] += 1
#	print(shopDict["BuyBack"].size())
	itemowner.inventory.erase(item)
	GameGlobal.money_pool[0] += int(item["price"] * shopDict["buy_rate"])
#	SfxPlayer.stream = NodeAccess.__Resources().sounds_book['generation error.ogg']
#	SfxPlayer.play()

	shoprect.initialize()
	GameGlobal.refresh_OW_HUD()
#	if shoprect.current_shop_category == itemshoptype :
#		shoprect.fillVbox("BuyBack")
	shoprect.fillVbox(shoprect.current_shop_category)
	var hudselectedchar = shoprect.inventoryrect.hud.selected_character
	shoprect.goldLabel.text = str( hudselectedchar.money[0] )
	shoprect.poolLabel.text = str( GameGlobal.money_pool[0] )	
		


