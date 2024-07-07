extends Button
class_name OW_Player
## A character or other mobile scripted object checked the overworld (out of combat)


var map = null
var tile_position_x = 0
var tile_position_y = 0

@onready var sprite : Sprite2D = get_node("Sprite2D")


# Called when the node enters the scene tree for the first time.
func _ready():	
#	print("OWcharacter _ready")
	# Player start Layer #
#	z_index = 4
	map = NodeAccess.__Map()
#	move(Vector2(3,3))


func set_icon(icon : Texture2D) :
	sprite.texture = icon


# Game inputs #
#func _input(event):
#	if event is InputEventKey and event.pressed:
#		if event is InputEventKey and event.scancode == KEY_UP:
#			position.y -= Utils.GRID_SIZE
#			tile_position_y-=1
#		elif event is InputEventKey and event.scancode == KEY_DOWN:
#			position.y += Utils.GRID_SIZE
#			tile_position_y+=1
#		elif event is InputEventKey and event.scancode == KEY_RIGHT:
#			position.x += Utils.GRID_SIZE
#			tile_position_x+=1
#		elif event is InputEventKey and event.scancode == KEY_LEFT:
#			position.x -= Utils.GRID_SIZE
#			tile_position_x-=1
#		if self==map.focuscharacter :
#			map.update()

func move(dir : Vector2) :
	position  = position  + Utils.GRID_SIZE * dir
	tile_position_x += dir.x
	tile_position_y += dir.y
	if dir.x<0 :
		sprite.set_flip_h(false)
	if dir.x>0 :
		sprite.set_flip_h(true) 
	if self== map.focuscharacter :
		map.queue_redraw()

#used to move the camera  focus in combat mostly
func set_tile_position(pos : Vector2) :
	position = Utils.GRID_SIZE * pos
	tile_position_x = pos.x
	tile_position_y = pos.y
	map.queue_redraw()
#func _process(delta):
#	pass
#
#func on_thing_enter():
#	pass
#
#func on_thing_leave():
#	pass

func get_pixel_position()->Vector2 :
	return position
