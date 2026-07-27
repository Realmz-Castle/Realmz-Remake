"""
Author: Francisco de Biaso Neto
email: kikinhobiaso@gmail.com

##################
### NodeAccess ###
##################

This module represents should implement all functions to get specific node.
"""
extends Node
#
## singletons #
#class Get:
#	static func __UI() -> Node:
#		return UI
#
## instances #
func __MainScene() -> Node:
	return get_node_or_null("/root/Main")
#
func __Resources() ->CampaignResources:
#	print ("get resources node here")
	return get_node_or_null("/root/Main/Resources") as CampaignResources
#
func __Map() ->Node:
#	print("NodeAccess __Map() : ", get_node("/root/Main/Map").name)
	return get_node_or_null("/root/Main/Map")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
