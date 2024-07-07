"""
Author: Francisco de Biaso Neto
email: kikinhobiaso@gmail.com

####################
### Thing Module ###
####################

This module represents a Game Thning object used to create game data as
structures, grounds, items, creatures, etc.
"""

extends Node2D

# Signals, called when a player enter or leaves this obj #
signal on_thing_enter
signal on_thing_leave

# Constructor #
func new(xy, texture):
	position = xy
	$Sprite2D.set_texture(texture)
	return self

func _ready():
	pass # Replace with function body.

func _on_Thing_area_entered(area):
	emit_signal("on_thing_enter")	

func _on_Thing_area_exited(area):
	emit_signal("on_thing_leave")
