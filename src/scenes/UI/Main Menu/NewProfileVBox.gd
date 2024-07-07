extends VBoxContainer
#NewProfileVBox

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@export var lineEdit : LineEdit

var my_menu
@export var honest_checkbox : CheckBox


# Called when the node enters the scene tree for the first time.
#func _ready():
#	var _err_connecttoself = connect("pressed",Callable(self,"_on_Button_pressed"))

func _on_NPButton_pressed()  -> void :
	var new_text : String = lineEdit.text
	var is_honest : bool = honest_checkbox.button_pressed
	if new_text == '' or new_text=="Profile Created !" :
		return
	var validity_array : Array = Utils.FileHandler.is_valid_file_name(new_text)
	if validity_array[0]<=0 :
		lineEdit.text = validity_array[1]
		return
	var success = GameGlobal.create_new_profile(new_text, is_honest)
	if success :
		GameGlobal.set_current_profile(new_text)
		my_menu.honest_mode_label.visible = GameGlobal.honest_mode
		lineEdit.text = "Profile Created !"
		my_menu.build_profiles_list()
		my_menu.profilebutton.set_text(new_text)
	else :
		print("This directory already exists !")
		lineEdit.text = "Profile already exists !"
