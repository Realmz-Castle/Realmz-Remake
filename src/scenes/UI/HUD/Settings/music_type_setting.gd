extends Label

@onready var button : Button = $Button
@onready var popup : PopupPanel = $Button/PopupPanel
@onready var vbox  : VBoxContainer = $Button/PopupPanel/ScrollContainer/VBoxContainer

func set_type(type : String, favs_dict : Dictionary) :
	text = type.capitalize()+ ' : '
	button.text = favs_dict[type]

