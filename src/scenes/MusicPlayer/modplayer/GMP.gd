"""
	Godot Mod Player Plugin by arlez80 (Yui Kinomoto)
"""

@tool
extends EditorPlugin

func _enter_tree( ):
	self.add_custom_type( "GodotModPlayer", "Node3D", preload("ModPlayer.gd"), preload("icon.png") )

func _exit_tree( ):
	self.remove_custom_type( "GodotModPlayer" )

func _has_main_screen():
	return true

func _make_visible( visible:bool ):
	pass

func _get_plugin_name( ):
	return "Godot Mod Player"
