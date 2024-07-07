extends NinePatchRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

@onready var musicSettings = $HBoxContainer/VBoxContainer/MusicSettingsRect


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _initialize() :
	musicSettings._initialize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ButtonDone_pressed():
	MusicStreamPlayer.play_music_map()
	#GameState.set_paused(false)
	hide()


func on_viewport_size_changed(screensize) :
	set_size(screensize)
