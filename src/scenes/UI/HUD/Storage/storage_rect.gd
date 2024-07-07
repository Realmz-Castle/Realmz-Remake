extends NinePatchRect
class_name Honest_Storage

@onready var  itemLootButtonTSCN : PackedScene = preload("res://scenes/UI/HUD/Looting/ItemLootButton.tscn")

@export var profilenameLabel : Label
@export var charanameLabel : Label

@export var charaGrid : GridContainer
@export var storageGrid : GridContainer

var selected_item_type : String = "All"
var cur_chara : Creature

var  storage_inventory : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize() :
	selected_item_type = "All"
	if not GameGlobal.honest_mode :
		_on_exit_button_pressed()
	if GameGlobal.cur_save_name.is_empty() :
		UI.ow_hud._on_q_save_button_pressed()
	profilenameLabel.text = GameGlobal.currentprofile+"'s Storage"
	_on_character_selected(UI.ow_hud.selected_character)
	load_storage_inventory()
	set_selected_type(selected_item_type)
	UI.ow_hud.set_charactersRect_type(1, false)

func load_storage_inventory() :
	storage_inventory.clear()
	var save_path : String = Paths.profilesfolderpath + GameGlobal.currentprofile
	if not FileAccess.file_exists(save_path+"/storage.json") :
		print("load_storage_inventory ",  )
		var storage_file = FileAccess.open(save_path+"/storage.json", FileAccess.ModeFlags.WRITE)
		if storage_file==null :
			print("ERROR storage_rect load_storage_inventory get_open_error() : ", FileAccess.get_open_error() )
		storage_file.store_string('{ "storage" : [] }')
		storage_file=null
		
	var inv_array : Array = Utils.FileHandler.read_json_dic_from_file(save_path+"/storage.json")["storage"]
	var resourcenode = NodeAccess.__Resources()
	for i in inv_array :
#		print("PC ITEM has(imgdata): ", item.has("imgdata"))
		var item = resourcenode.generate_item_from_json_dict(i)
		storage_inventory.append(item)


func set_selected_type(type : String) :
	# Weapons Armor Limbs Supplies  All
	selected_item_type = type
	_on_character_selected(cur_chara)

func _on_character_selected(crea : Creature) :
	if not crea.get("classgd") :
		UI.ow_hud.called_on_CharPanel_SelectButton_pressed(UI.ow_hud.charsVContainer.get_child(0))
		UI.ow_hud.selected_character = GameGlobal.player_characters[0]
	cur_chara = crea
	charanameLabel.text = cur_chara.name+"'s inventory"
	fill_grids(cur_chara,selected_item_type)

func is_item_of_type(item : Dictionary, type : String) :
	if type=="All" :
		return true
	if not item.has("slots") :
		return (type=="Supplies" or type=="All")
	var slots : Array = item["slots"]
	match type :
		"Weapons" :
			return ( slots.has("Melee Weapon") or slots.has("Ranged Weapon") or slots.has("Ammunition"))
		"Armor" :
			return item["slots"].has("Armor")
		"Limbs" :
			return ( slots.has("Shield") or slots.has("Head") or slots.has("Legs"))

func fill_grids(chara, type : String) :
	#fill the gridcontainer
	for c in charaGrid.get_children() :
		c.queue_free()
	for c in storageGrid.get_children() :
		c.queue_free()
	for i in cur_chara.inventory :
		if not is_item_of_type(i,type) :
			continue
#		if i["equipped"]<=0 :
		var newButton : Button = create_chara_item_button(chara, i)
			#ibutton.connect("pressed",Callable(self,"_on_dropentry_pressed").bind(i))
		charaGrid.add_child(newButton)
	for i in storage_inventory :
		if not is_item_of_type(i,type) :
			continue
#		if i["equipped"]<=0 :
		var newButton = create_storage_item_button(i)
			#ibutton.connect("pressed",Callable(self,"_on_dropentry_pressed").bind(i))
		storageGrid.add_child(newButton)

func create_chara_item_button(_chara, item : Dictionary) -> Button :
	var newButton = itemLootButtonTSCN.instantiate()
	var newtex : Texture2D = item["texture"]
	newButton.find_child("ItemTextureRect").set_texture( newtex )
	newButton.connect("pressed",Callable(self,"_on_itembutton_pressed").bind(item,1, cur_chara, newButton))
	newButton.connect("mouse_entered",Callable(self,"_on_itembutton_mouse_entered").bind(item,newButton))
	newButton.connect("mouse_exited",Callable(self,"_on_itembutton_mouse_exited"))
	newButton.disabled = item["equipped"]>0
	return newButton

func create_storage_item_button(item : Dictionary) -> Button :
	var newButton = itemLootButtonTSCN.instantiate()
	var newtex : Texture2D = item["texture"]
	newButton.find_child("ItemTextureRect").set_texture( newtex )
	newButton.connect("pressed",Callable(self,"_on_itembutton_pressed").bind(item,0, null, newButton))
	newButton.connect("mouse_entered",Callable(self,"_on_itembutton_mouse_entered").bind(item, newButton))
	newButton.connect("mouse_exited",Callable(self,"_on_itembutton_mouse_exited"))
	item["equipped"]=0
	return newButton

func _on_itembutton_pressed(item : Dictionary, side : int, chara, button : Button) :
	print("storagerect _on_itembutton_pressed "+item["name"],' ',side)
	if side==0 : #clicked in storage
		var looted : bool = cur_chara.add_inventory_item(item)
		if looted :
			storage_inventory.erase(item)
			button.set_disabled(true)
			button.release_focus()
			button.queue_free()
	#		button.disconnect("pressed",Callable(self,"_on_itemlootbutton_pressed"))
#			for child in button.get_children() :
#	#			button.remove_child(child)
#				child.queue_free()
			var newcharitembutton : Button = create_chara_item_button(cur_chara, item)
			charaGrid.add_child(newcharitembutton)
			GameGlobal.gamescreenInstance.updateCharPanelDisplay()
		return
	if side==1 : #clicked in character's inventory
		if chara.drop_inventory_item(item) :
			storage_inventory.append(item)
			button.set_disabled(true)
			button.release_focus()
			button.queue_free()
			var newstorageitembutton : Button = create_storage_item_button(item)
			storageGrid.add_child(newstorageitembutton)
			GameGlobal.gamescreenInstance.updateCharPanelDisplay()
			return

func _on_itembutton_mouse_entered(item : Dictionary, _button : Button) :
#	print("storagerect _on_itembutton_mouse_entered "+item["name"])
	UI.ow_hud.textRect.set_item_info(item)

func _on_itembutton_mouse_exited() :
#	print("storagerect _on_itembutton_mouse_exited ")
	UI.ow_hud.textRect.set_text("", false, "")


func _on_exit_button_pressed():
	#save the storage.json, quicksave the game  and close
	
	var inv_string : String = '[\n'
	var addcomma : String = ''
	for item in storage_inventory :
#		print("CREATURE ITEM HAS imgdatasize ??? ", item["name"], item.has("imgdatasize"))
		var inventoryJSONstring : String = JSON.stringify(item)
		inv_string += ('\n'+addcomma+inventoryJSONstring)
		addcomma = ','
	inv_string += ('\n]')
	
	var save_path : String = Paths.profilesfolderpath + GameGlobal.currentprofile +"/storage.json"
	var storage_file = FileAccess.open(save_path, FileAccess.ModeFlags.WRITE)
	if storage_file==null :
			print("ERROR storage_rect _on_exit_button_pressed get_open_error() : ", FileAccess.get_open_error() )
	storage_file.store_string('{ "storage" : '+inv_string+' }')
	storage_file=null
	
	UI.ow_hud._on_q_save_button_pressed()
	UI.ow_hud.set_charactersRect_type(0, false)
	UI.ow_hud.close_storage_rect()
