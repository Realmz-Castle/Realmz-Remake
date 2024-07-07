# used only to initialize shops upon starting the scenario

var shops : Dictionary = {}

func build_shops(_items_book : Dictionary) :
	# pass items book from  game's resources node
	# in arrays : first = name in book, second = quantity,  third = pirce(default if negative)
	shops = {}
	var shop_1 : Dictionary = {"buy_rate" : 0.5, "sell_rate" : 2.0, "Weapons" : [], "Armor" : [], "Limbs":[], "Supplies" : [], "BuyBack" : []}
	var _weapons_1 = shop_1["Weapons"]
	_weapons_1.append(["Dagger", 6,-1])
	var _armor_1 = shop_1["Armor"]
	var _limbs_1 = shop_1["Limbs"]
	_limbs_1.append(["Leather Cap", 5,-1])
	_limbs_1.append(["Iron Cap", 5,-1])
	_limbs_1.append(["Buckler", 4,-1])
	_limbs_1.append(["Shield of the Blue Oxen", 1,-1])
	_limbs_1.append(["Ring of Regeneration", 1,-1])
	var _supplies_1 = shop_1["Supplies"]
	_supplies_1.append(["Health Potion", 10,-1])
	_supplies_1.append(["Lantern", 20,-1])
	shops = {"shop_1" : shop_1}
	return shops

func get_shop(_shopname : String, _shopdict : Dictionary) :
	return _shopdict