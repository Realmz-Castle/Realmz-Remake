extends Button

@onready var colorRect: ColorRect = $colorRect
@onready var iconsprite: Sprite2D = $IconSprite
@onready var namelabel: Label = $ItemnameLabel
@onready var infolabel: Label = $IteminfoLabel
@onready var priceLabel: Label = $PricenLabel
@onready var weightLabel: Label = $WeightnLabel
@onready var quantityLabel: Label = $QuantityLabel
@onready var chargesLabel: Label = $ChargesLabel
@onready var statsLabel: RichTextLabel = $ItemstatsRTLabel
@onready var selectedSprite: Sprite2D = $SpriteSelected

var item: ItemInstance = null
var shopVbox: Control = null
var inventoryrect: Control = null
var listed_price: int = 0


func on_viewport_size_changed(screensize: Vector2) -> void:
	var item_width: float = floorf((screensize.x - 320 - 44 - 20) / 2)
	chargesLabel.position = Vector2(item_width - 95, 4)
	statsLabel.position = Vector2(item_width - 215, 20)
	colorRect.size = Vector2(item_width, 60)


func set_item(
	new_item: ItemInstance,
	quantity: int,
	invrect: Control,
	price: int,
) -> void:
	item = new_item
	inventoryrect = invrect
	listed_price = price
	var definition: ItemDefinition = (
		NodeAccess.__Resources().get_item_definition(item)
	)
	if definition == null:
		return
	var screensize: Vector2 = ScreenUtils.get_logical_window_size(self)
	var item_width: float = floorf(
		(screensize.x - 320 - 44 - 20) / 2
	)
	colorRect.size = Vector2(item_width, 40)
	size = Vector2(item_width, 40)
	iconsprite.texture = NodeAccess.__Resources().item_texture(item)
	namelabel.text = definition.display_name_for(item)
	infolabel.text = definition.display_type
	priceLabel.text = str(price)
	weightLabel.text = str(definition.total_weight(item))
	quantityLabel.text = "%d X" % quantity
	if definition.maximum_charges > 0:
		chargesLabel.show()
		chargesLabel.text = "X %d / %d" % [
			item.charges,
			definition.maximum_charges,
		]
		chargesLabel.position = Vector2(item_width - 95, 4)
	else:
		chargesLabel.hide()
	if not definition.stats_summary.is_empty():
		statsLabel.parse_bbcode(definition.stats_summary)
		statsLabel.position = Vector2(item_width - 215, 20)
	else:
		statsLabel.clear()


func update_display() -> void:
	pass


func _get_drag_data(_pos: Vector2) -> Variant:
	if inventoryrect == null or item == null:
		return null
	var customer: Creature = inventoryrect.inventoryScrollRight.get_inventory_owner()
	if not inventoryrect.can_purchase_shop_item(customer, item):
		GameGlobal.play_sfx("target error.wav")
		return null
	var dragpreview := TextureRect.new()
	dragpreview.texture = NodeAccess.__Resources().item_texture(item)
	set_drag_preview(dragpreview)
	return [item, "Shop"]


func _on_ItemSmallButton_mouse_entered() -> void:
	if inventoryrect == null or item == null:
		return
	inventoryrect.display_item_info(item)
	colorRect.color = Color(0.9, 0.9, 0.9, 1)


func _on_ItemSmallButton_mouse_exited() -> void:
	colorRect.color = Color.WHITE
