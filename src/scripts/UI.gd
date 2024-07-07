"""
Author: Francisco de Biaso Neto
email: kikinhobiaso@gmail.com

##########
### UI ###
##########

This module represents a user interface.
All operations over UI should use this wrapper.
"""
extends Node

@onready var main_menu : CanvasItem = $MainMenuControl
@onready var ow_hud : Control = $OWHUDControl
@onready var allmenus : Array = [main_menu, ow_hud]


var cursor_sword = load("res://shared_assets/cursors/sword.png")
var cursor_N = load("res://shared_assets/cursors/north.png")
var cursor_NE = load("res://shared_assets/cursors/northeast.png")
var cursor_E = load("res://shared_assets/cursors/east.png")
var cursor_SE = load("res://shared_assets/cursors/southeast.png")
var cursor_S = load("res://shared_assets/cursors/south.png")
var cursor_SW = load("res://shared_assets/cursors/southwest.png")
var cursor_W = load("res://shared_assets/cursors/west.png")
var cursor_NW = load("res://shared_assets/cursors/northwest.png")
var cursor_stop = load("res://shared_assets/cursors/stop.png")
var cursor_bandaid = load("res://shared_assets/cursors/bandaid.png")
var cursor_map_dict : Dictionary = {Vector2(0,1) : cursor_S, Vector2(1,1) : cursor_SE,
									Vector2(1,0) : cursor_E, Vector2(1,-1) : cursor_NE,
									Vector2(0,-1) : cursor_N, Vector2(-1,-1) : cursor_NW,
									Vector2(-1,0) : cursor_W, Vector2(-1,1) : cursor_SW,
									Vector2.ZERO : cursor_stop}
var cursor_click = load("res://shared_assets/cursors/click.png")
var cursor_0 = load("res://shared_assets/cursors/number_0.png")
var cursor_1 = load("res://shared_assets/cursors/number_1.png")
var cursor_2 = load("res://shared_assets/cursors/number_2.png")
var cursor_3 = load("res://shared_assets/cursors/number_3.png")
var cursor_4 = load("res://shared_assets/cursors/number_4.png")
var cursor_5 = load("res://shared_assets/cursors/number_5.png")
var cursor_6 = load("res://shared_assets/cursors/number_6.png")
var cursor_7 = load("res://shared_assets/cursors/number_7.png")
var cursor_8p = load("res://shared_assets/cursors/number_8p.png")
var cursor_numbers = [cursor_0,cursor_1,cursor_2,cursor_3,cursor_4,cursor_5,cursor_6,cursor_7,cursor_8p]



func _ready():	
	pass

# Hide all user interface #
func __hide():
	# 0 is the root above canvasLayer #
	get_child(0).hide()

func show_only(menu : CanvasItem) :
	print(allmenus)
	for m in allmenus :
		if menu == m :
			menu.show()
		else :
			m.hide()

func set_cursor_number(n:int) :
	Input.set_custom_mouse_cursor(cursor_numbers[clamp(n,0,8)])
