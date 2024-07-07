extends VBoxContainer

@export var hbox : HBoxContainer

@onready var sumLabel : Label = $SummonerHBox/SummonerLabel
@onready var maxLabel : Label = $SummonerHBox/MaxLabel

var character : PlayerCharacter
var max_s : int = 0 : set = _set_max
var cur_s : int = 0 : set = _set_cur

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_character(pc : PlayerCharacter) :
	character = pc
	sumLabel.text = character.name+"'s summoned creatures :"
	_set_max( character.get_max_perma_summons() )
	
	maxLabel.text = "(Max "+ str(max_s) +")"

func _set_max(m : int) :
	max_s = m
	maxLabel.text = "("+ str(cur_s)+'/'+str(max_s) +")"
func _set_cur(c : int) :
	cur_s = c
	maxLabel.text = "("+ str(cur_s)+'/'+str(max_s) +")"
