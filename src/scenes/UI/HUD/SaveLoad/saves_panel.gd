extends Panel
class_name SaveLoad_Saves_Panel

@export var saves_itemlist : ItemList

var saves_list : Array = []
var my_menu : SaveLoadCtrl

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func fill(campaignname : String) :
	if campaignname.is_empty() :
		return
	saves_itemlist.clear()
	var campsavespath : String = Paths.profilesfolderpath +"/" + GameGlobal.currentprofile + "/Saves/" + campaignname + "/"
	if not DirAccess.dir_exists_absolute(campsavespath) :
		DirAccess.make_dir_recursive_absolute(campsavespath)
	saves_list = Utils.FileHandler.list_dirs_in_directory(campsavespath)
	if GameGlobal.honest_mode :
		my_menu.disable_create_new_save(saves_list.size()>0)
	for c in saves_list :
		var _i : int = saves_itemlist.add_item(c)
#	if saves_list.size() > 0 :
#		saves_itemlist.select(0)
#		my_menu.on_save_selected(saves_list[0])
#	else :
	my_menu.on_save_selected('')
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_saves_item_list_item_selected(index):
			my_menu.on_save_selected(saves_list[index])
