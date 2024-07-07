extends Button

func _ready():	
	var _err_connecttoself = connect("pressed",Callable(self,"_on_Button_pressed"))

func _on_Button_pressed() :
	print("QUITTING GAME")
	# http://docs.godotengine.org/en/latest/tutorials/misc/handling_quit_requests.html
	get_tree().quit()


#func _on_classrace_select(index, extra_arg_0):
#	pass # Replace with function body.
