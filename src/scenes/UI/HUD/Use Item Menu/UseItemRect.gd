extends NinePatchRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@onready var  itemLootButton : PackedScene = preload("res://scenes/UI/HUD/Looting/ItemLootButton.tscn")

@onready var charportrait : TextureRect = $CharFaceRect
@onready var charnamelabel : Label = $CharNameLabel
@onready var itemsContainer = $"itemsRect/ScrollContainer/ItemContainer"
@onready var itempreview = $ItemPreview
var character = null
enum  {ALL,FIELD,BATTLE}
var itemkind : int = ALL

signal item_picked

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func display_character_inventory() :
	if character == null :
		return
	charportrait.set_texture(character.portrait)
	charnamelabel.set_text(character.name)
	itempreview.set_item({"name":'', "type":'',"texture":null,"charges_max":0, "stats_mini":'', "equipped":0})
	for child in itemsContainer.get_children() :
		itemsContainer.remove_child(child)
		child.queue_free()
	
	#fill the gridcontainer
	for i in character.inventory :
		var validitem : bool = false
		if itemkind == ALL :
			validitem = true
		elif itemkind == FIELD :
			validitem = i.has("_on_field_use")
		elif itemkind == BATTLE :
			validitem = i.has("_on_battle_use")
		
		if validitem :
			var newButton = itemLootButton.instantiate()
			var newtex : Texture2D = i["texture"]
			newButton.find_child("ItemTextureRect").set_texture( newtex )
			newButton.connect("pressed",Callable(self,"_on_itembutton_pressed").bind(i, character))
			newButton.connect("mouse_entered",Callable(self,"_on_itembutton_mouse_entered").bind(i))
			newButton.connect("mouse_exited",Callable(self,"_on_itembutton_mouse_exited"))
			
			#ibutton.connect("pressed",Callable(self,"_on_dropentry_pressed").bind(i))
			itemsContainer.add_child(newButton)

func _on_LeftButton_pressed():
	var charindex = GameGlobal.player_characters.find(character)
	var indexminus = charindex-1
	if indexminus <0 :
		indexminus = GameGlobal.player_characters.size()-1
	character = GameGlobal.player_characters[indexminus]
	display_character_inventory()

func _on_RightButton_pressed():
	var charindex = GameGlobal.player_characters.find(character)
	var indexplus = (charindex+1) % GameGlobal.player_characters.size()
	character = GameGlobal.player_characters[indexplus]
	display_character_inventory()
	
	
func _on_itembutton_mouse_entered(item : Dictionary) :
	itempreview.set_item(item)

func _on_itemlootbutton_mouse_exited() :
	itempreview.iconequipped.hide()
	itempreview.namelabel.text = ''
	itempreview.iconsprite.set_texture( null )
	itempreview.statsLabel.text = ''
	itempreview.chargesLabel.text = ''
	

func _on_itembutton_pressed(item : Dictionary, chara) :
	emit_signal("item_picked", item, chara)


func _on_CancelButton_pressed():
	hide()
