extends Node
class_name State #, "res://StateMachine/state.svg"
"""
STate interface to use in Hierarchcal State Machines.
The lowest leaf tries to handle callbacks, and if it can't, it delegates the work to its parent.
It's up to  the user to call the parent state's functions, e.g 'get_parent().physics_process(delta)'
Use State as a child of a StateMachine node.
"""

@onready var _state_machine = _get_state_machine(self)

func _get_state_machine(node : Node) -> Node :
#	print("STATE : "+name+"._get_state_machine  on "+node.name)
#	print("    is "+node.name+"'s group state_machine ? ", )
	if node!=null and  not node.is_in_group("state_machine") :
#		print("    STATE : "+node.name+" calls _get_state_machine from "+node.name)
		return _get_state_machine(node.get_parent())
#	print("    STATE : "+name+" call _get_state_machine returns "+node.name)
	return node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func enter(_msg : Dictionary = {} ) -> void :
	return

func exit() -> void :
	return

func unhandled_input(_event : InputEvent) -> void :
	return

func physics_process(_delta : float) -> void :
	return

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
