extends VBoxContainer
class_name AbilistContainer

@export var column : int
@export var otherbox : AbilistContainer

var my_menu : AbilitiesManagementRect

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#	return [spellname, ability, character, column, self]
func _can_drop_data(_pos, data):
	var datcolumn = data[3]
	return datcolumn != column


func _drop_data(_pos, data):
	my_menu.move_abilbutton_from_to(data[4], otherbox,self )
