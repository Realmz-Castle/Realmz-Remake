"""
Author: Francisco de Biaso Neto
email: kikinhobiaso@gmail.com

###################
### Definitions ### 
###################

This module is responsible for encapsulating the const global variables 
contained in the game.
"""
extends Node

class_name definition

# Render variables #
class Render:
	enum LAYERS {UI = 10,GAME = 0}
	static func get_layer_space():
		return 0.1

func _ready():
	pass # Replace with function body.
