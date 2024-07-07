extends Button

var cdata : Dictionary = {}
var cname : String = ''

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_creature(crea_data : Dictionary) :
	cdata = crea_data
	cname = crea_data["data"]["name"]
	var texrect : TextureRect = $NinePatchRect/TextureRect
	$Label.text = crea_data["data"]["name"]
	texrect.texture = crea_data["data"]["image"]
	var sizev = crea_data["data"]["image"].get_image().get_size()
	texrect.size = sizev
	texrect.position.x = 3-sizev.x/2
	texrect.position.y = 3-sizev.y/2
#$Label.text =  str( crea_data["data"]["image"].get_image().get_size() )

