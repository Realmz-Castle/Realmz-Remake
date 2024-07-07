extends Panel
class_name SaveLoad_Preview_Panel

var my_menu : SaveLoadCtrl

@export var PCMicroCtrlTSCN : PackedScene
@export var savename_label : Label
@export var pc_micro_box : Container
@export var notesTextEdit : TextEdit
@export var save_button : Button
@export var load_button : Button

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func display_this_game_preview() -> void :
	
	
	for c in pc_micro_box.get_children() :
		c.queue_free()
	for pc  in GameGlobal.player_characters :
		var prvw : PCMicroCtrl = PCMicroCtrlTSCN.instantiate()
		pc_micro_box.add_child(prvw)
		prvw.set_char_info(pc.name, pc.level, pc.classgd.classrace_name, floor( 100.0*pc.get_stat("curHP")/pc.get_stat("maxHP") ) , pc.portrait )
	notesTextEdit.set_text(GameGlobal.cur_save_descrition)
	if  GameGlobal.cur_save_name.is_empty() :
		savename_label.text = "Create a new save folder first."
		set_save_button_disabled(true)
	else :
		savename_label.text = GameGlobal.cur_save_name
		set_save_button_disabled(false)

func display_save_preview(campaign_name : String, save_name : String) ->void :
	set_save_button_disabled( (campaign_name != GameGlobal.currentcampaign) or GameGlobal.cur_save_name.is_empty() )
	load_button.disabled = false
	for c in pc_micro_box.get_children() :
		c.queue_free()
	#load the json
	var save_path : String = Paths.profilesfolderpath + GameGlobal.currentprofile + "/Saves/"+ campaign_name + "/"+ save_name

	var profcharapath : String = Paths.profilesfolderpath+Paths.currentProfileFolderName+'/Characters/'

#	print("display_save_preview save_path : ",save_path,  ", save name : ", save_name," campaign_name : ", campaign_name)
	
	print("SAVE PREVIEW PANEL L47 display_save_preview : save_path is : "+save_path)
	
	var save_dict : Dictionary = Utils.FileHandler.read_json_dic_from_file(save_path+'/data.json')
	for arr in save_dict["preview"] : #[name,lvl,class,health]  need portrait !
		var char_name : String= arr[0]
		var char_lvl : int = arr[1]
		var char_class : String = arr[2]
		var char_health : int = arr[3]
		var portrait_path : String = save_path + '/Characters/'+char_name+'/portrait.png'
		if GameGlobal.honest_mode :
			portrait_path = profcharapath+char_name+'/portrait.png'
		var char_portrait =  Utils.FileHandler.load_img_texture(portrait_path)
		var prvw : PCMicroCtrl = PCMicroCtrlTSCN.instantiate()
		pc_micro_box.add_child(prvw)
		prvw.set_char_info(char_name, char_lvl, char_class, char_health , char_portrait )
	notesTextEdit.set_text(save_dict["notes"])
	savename_label.text = save_name
	
		
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_save_button_pressed():
	my_menu.save_game(GameGlobal.currentcampaign, GameGlobal.cur_save_name)

func set_save_button_disabled(dis : bool) :
	save_button.disabled = dis

func _on_load_button_pressed():
	my_menu.on_load_button_pressed()
