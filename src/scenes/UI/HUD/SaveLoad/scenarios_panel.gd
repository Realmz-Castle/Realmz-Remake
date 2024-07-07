extends Panel
class_name SaveLoad_Scenarios_Panel

var my_menu : SaveLoadCtrl

@export var scenarios_itemlist : ItemList
var scenarios_list : Array = []

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func fill(cur_scen_name : String) :
	scenarios_list = Utils.FileHandler.list_dirs_in_directory(Paths.campaignsfolderpath)
	scenarios_itemlist.clear()
	for c in scenarios_list :
		var i : int = scenarios_itemlist.add_item(c)
		if c==cur_scen_name :
			scenarios_itemlist.select(i)  #doesnt send  signal
	return


func _on_scenarios_item_list_item_selected(index):
	my_menu._on_scenario_selected(scenarios_list[index])
