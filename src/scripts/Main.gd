extends Control

@export var debug = false

#@onready var _combatSystem # child from main #
#onready var _gameState # child from main # Now Autoloaded

func _ready():
#	get_viewport().set_sdf_scale(2)
	#print("MAIN METHODS : \n",get_script().get_script_method_list())
	var _err1 = get_tree().root.connect("size_changed",Callable(NodeAccess.__Map(),"_on_viewport_size_changed"))
	#get_tree().root.max_size = Window.MODE_FULLSCREEN
	
	#var config = FileAccess.open(Paths.realmzfolderpath+"settings.cfg", FileAccess.ModeFlags.WRITE_READ)
	#if config:
		#printerr("MAIN : settings.cfg  EXISTS")
		#config.close()
	
	
	var def_screen_size : Vector2 = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
	print("Main.gd def_screen_size :  ", def_screen_size,  "isinstancevalid checkworks ?", not is_instance_valid(null) )
	if not is_instance_valid(def_screen_size) :
		def_screen_size = Vector2(1152, 648)
	var setting_screen_size_x : float = Utils.FileHandler.get_cfg_setting(Paths.settingspath,"SETTINGS","screen_size_x", def_screen_size.x)
	
	var setting_screen_size_y : float = Utils.FileHandler.get_cfg_setting(Paths.settingspath,"SETTINGS","screen_size_y", def_screen_size.y)
	#setting_screen_size_x = 300
	if not OS.has_feature("editor") :
		DisplayServer.window_set_size(Vector2(setting_screen_size_x,setting_screen_size_y))
		DisplayServer.window_set_max_size( DisplayServer.screen_get_size()-Vector2i(16,96) )
	




	NodeAccess.__Map()._on_viewport_size_changed()
	UI.show_only(UI.main_menu)
	
## THE MAIN LOOP GAME ARCHITECTURE #
#func _process(delta: float):	
	## 1) process input (dont need to manipulate, godot is already doing) #
	## 2) game update #
	## --> access your classes and update them, if they have any logic, process:
#
	## 3) render (can be done automatic by godot) # 
	#pass

func _exit_tree():
	if DisplayServer.get_name() == "headless":
		return
	Utils.FileHandler.set_cfg_setting(Paths.settingspath, "SETTINGS","screen_size_x", DisplayServer.window_get_size().x)
	Utils.FileHandler.set_cfg_setting(Paths.settingspath, "SETTINGS","screen_size_y", DisplayServer.window_get_size().y)
	pass
