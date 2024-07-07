extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#onready var yesButton = $"ChoicesYesNoBox/YesButton"
#onready var noButton = $"ChoicesYesNoBox/NoButton"

signal pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_YesButton_pressed():
	emit_signal("pressed")


func _on_NoButton_pressed():
	emit_signal("pressed")

func connectbuttonstome(obj : Object) :
	var yesButton = $"ChoicesYesNoBox/YesButton"
	var noButton = $"ChoicesYesNoBox/NoButton"
	yesButton.connect("pressed",Callable(obj,"_on_choice_button_pressed").bind("YES"))
	noButton.connect("pressed",Callable(obj,"_on_choice_button_pressed").bind("NO"))
#	newButton.connect("pressed",Callable(self,"_on_choice_button_pressed").bind(scripts[i))
