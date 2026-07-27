extends NinePatchRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

@onready var musicSettings = $HBoxContainer/VBoxContainer/MusicSettingsRect
@onready var mapDebugCheckButton : CheckButton = (
	$HBoxContainer/VBoxContainer/MusicSettingsRect/VBoxContainer/VolumeVbox/MapDebugCheckButton
)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _initialize() :
	musicSettings._initialize()
	mapDebugCheckButton.set_pressed_no_signal(GameGlobal.map_debug_overlays_enabled)


func _on_MapDebugCheckButton_toggled(button_pressed: bool) -> void:
	GameGlobal.set_map_debug_overlays_enabled(button_pressed)
	GameGlobal.save_map_debug_overlays_enabled(button_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ButtonDone_pressed():
	MusicStreamPlayer.play_music_map()
	#GameState.set_paused(false)
	hide()


func _on_MainMenuButton_pressed():
	$ConfirmRect.show()


func _on_CancelButton_pressed():
	$ConfirmRect.hide()


func _on_YesButton_pressed():
	$ConfirmRect.hide()
	_return_to_main_menu()


func _return_to_main_menu():
	StateMachine.transition_to("Inactive", {})
	GameGlobal.player_characters.clear()
	MusicStreamPlayer.stop()
	Input.set_custom_mouse_cursor(null)
	NodeAccess.__Map().hide()
	hide()
	UI.show_only(UI.main_menu)
	UI.main_menu.newCampaignPanel.hide()


func on_viewport_size_changed(screensize) :
	set_size(screensize)
