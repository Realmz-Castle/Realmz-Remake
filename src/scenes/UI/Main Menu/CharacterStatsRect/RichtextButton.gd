extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var stat : String = ''
var plusminus : int = 0

func _init(nstat : String,nplusminus : int):
	stat = nstat
	plusminus = nplusminus

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
