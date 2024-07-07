extends Node2D
class_name SpellAnimation

@onready var sprite : Sprite2D = $Sprite2D
var tween : Tween



static var name_to_frame_dict : Dictionary = {
	"Arrow" : 0, "Dart" : 1, "Axe" : 2, "Web" : 3,
	"Target" : 4, "Fire" : 5, "Miasma" : 6, "Cloud" : 7,
	"Ice" : 8, "Spark" : 9, "Spinny" : 10, "Slime" : 11,
	"Whirl" : 12, "Ball" : 13,"Sphere":14, "Thorns" : 15
}

var dir_to_proj_dir_dict : Dictionary = {
	Vector2i.UP:   0, Vector2i(1,-1) : 1,
	Vector2i.RIGHT:2, Vector2i(1,1)  : 3,
	Vector2i.DOWN: 4, Vector2i(-1,1) : 5,
	Vector2i.LEFT: 6, Vector2i(-1,-1): 7,
	Vector2i.ZERO : 0
}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(gfxname : String, origin : Vector2, dest : Vector2, is_proj : bool) :
	var type_int : int = name_to_frame_dict[gfxname]
	position = origin
	
	tween = get_tree().create_tween()
	tween.bind_node(self)
	tween.set_speed_scale(1/GameGlobal.gamespeed)
	
	
	if is_proj :
#		print("SpellAnimation create tween", origin, dest)
		tween.tween_property(self, "position", dest, 1.0)
		if type_int<3 :
			var dirv2 : Vector2 = (dest-origin).normalized()
			var dir : Vector2i = Vector2i(dirv2.round())
			print("dir ", dir)
			sprite.frame = type_int*8 + dir_to_proj_dir_dict[dir]
		else :
			sprite.frame = type_int*8
			tween.tween_property(sprite, "frame", type_int*8+7, 1.0)
		
	else :
#		tween.tween_property(self, "position", dest, 1.0)
		position = dest
		sprite.frame = type_int*8
#		tween.set_parallel(true)
		tween.tween_property(sprite, "frame", type_int*8+7, 1.0)
	tween.tween_callback(_on_tween_over)

func _on_tween_over() :
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	sprite.frame +=1
