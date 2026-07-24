extends ScrollContainer
class_name ShopInventoryContainer

const WEAPON_TYPES := [
	"Mace", "Club", "Hammer", "Warhammer/Maul",
	"Dagger", "Shortsword", "Arming Sword", "Longsword",
	"Short Axe", "Staff", "Pole Axe", "Spear", "Eastern Weapon",
	"Dart", "Throwing Bottle", "Throwing Dagger", "Throwing Rock",
	"Throwing Axe", "Throwing Hammer", "Throwing Spear", "Whip", "Bow",
	"Crossbow", "Quiver", "Throwing Aid", "Misc. Melee Weapon",
	"Misc Ranged Weapon",
]
const LIMB_TYPES := [
	"Belt", "Necklace", "Ring", "Hat", "Soft Helmet", "Light3D Helmet",
	"Great Helm", "Small Shield", "Medium Shield", "Large Shield", "Bracers",
	"Cloth Gloves", "Leather Gloves", "Metal Gloves", "Soft Boots", "Hard Boots",
]
const ARMOR_TYPES := [
	"Cloak/Cape", "Robe", "Gambeson", "Leather Armor", "Chainmail Armor",
	"Splint Armor", "Plate Armor",
]
const SUPPLY_TYPES := [
	"Potion", "Consumable", "Food", "Scroll Case", "Scroll", "Parchment",
]


func _can_drop_data(_pos: Vector2, data: Variant) -> bool:
	if not (
		data is Array
		and data.size() >= 2
		and data[0] is ItemInstance
		and data[1] is Creature
	):
		return false
	var item: ItemInstance = data[0]
	var definition := NodeAccess.__Resources().get_item_definition(item)
	return (
		definition != null
		and definition.tradeable
		and not item.equipped
		and GameGlobal.current_shop_accepts_item(item)
	)


func _drop_data(_pos: Vector2, data: Variant) -> void:
	if not _can_drop_data(_pos, data):
		return
	var item: ItemInstance = data[0]
	var owner: Creature = data[1]
	var shoprect: ShopRect = get_parent()
	var result := shoprect.sell_item(owner, item)
	if not bool(result.get("ok", false)):
		GameGlobal.play_sfx("generation error.ogg")
		return
	GameGlobal.money_pool[0] += int(result["price"])
	shoprect.initialize()
	GameGlobal.refresh_OW_HUD()
	shoprect.fillVbox(shoprect.current_shop_category)
	var hudselectedchar: Creature = shoprect.inventoryrect.hud.selected_character
	shoprect.goldLabel.text = str(hudselectedchar.money[0])
	shoprect.poolLabel.text = str(GameGlobal.money_pool[0])
