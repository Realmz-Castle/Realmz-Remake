extends Control
class_name PCMicroCtrl

@export var texture_rect : TextureRect
@export var name_label : Label
@export var lvl_class_label : Label
@export var health_label : Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_char_info(charname : String, level : int, caste : String, health : int, portrait : Texture2D) :
	texture_rect.texture = portrait
	name_label.text = charname
	lvl_class_label.text = "Lv"+str(level)+' '+caste
	health_label.text = str(health)+'%HP'
