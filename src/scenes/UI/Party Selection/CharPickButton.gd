extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var selectable : bool = false
var character= null  # : GDScript
@onready var colorRect : ColorRect = $ColorRect

var my_menu

#onready var levelnLabel : Label = $LevelnLabel
#onready var portraitSprite : Sprite2D = $PortraitSprite
#onready var nameLabel : Label = $NameLabel
#onready var raceClassLabel : Label = $RaceClassLabel



# Called when the node enters the scene tree for the first time.
func _ready():
	if GameGlobal.honest_mode :
		set_custom_minimum_size(Vector2(200,60))
	pass # Replace with function body.

func set_character(chara, eligible:bool) :
	selectable = eligible
#	print("charîckbutton setcharacter ", chara)
	character = chara
	$NameLabel.text = chara.name
	$LevelnLabel.text = str(chara.level)
	$RaceClassLabel.text = chara.racegd.classrace_name+' '+chara.classgd.classrace_name
	$PortraitSprite.texture = chara.portrait
	if GameGlobal.honest_mode :
		$BusyLabel.text = chara.cur_campaign
		
	if not eligible :
		$NameLabel.add_theme_color_override("font_color", Color(0.7, 0.7, 0.5))
		$LevelnLabel.add_theme_color_override("font_color", Color(0.7, 0.7, 0.5))
		$RaceClassLabel.add_theme_color_override("font_color", Color(0.7, 0.7, 0.5))
		$PortraitSprite.set_flip_h(true)
		set_disabled(true)
#	else :


#func _on_CharPickButton_mouse_entered():
#	colorRect.color = Color(1.0, 1.0, 1.0, 0.1)
#
#func _on_CharPickButton_mouse_exited():
#	colorRect.color = Color(1.0, 1.0, 1.0, 0.0)

func _get_drag_data(_pos):
	if (not selectable) or disabled :
		return null
	var dragpreview = TextureRect.new()
	dragpreview.set_texture(character.portrait)
	set_drag_preview(dragpreview)
	return [character, self ]


func _can_drop_data(_pos, data):
	if not selectable :
		return false
	if data[0].has_method("level_up") :
		return data[1].selectable
	else :
		return false
	

func _drop_data(_pos, data):
	var mychar = character
	var otherchar = data[0]
	if selectable and data[1].selectable :
		set_character(otherchar,true)
		data[1].set_character(mychar,true)
		my_menu.check_party_ok()
	


func _on_CharPickButton_pressed():
	set_highlighted(true)
#	emit_signal("pressed")

#func other_button_pressed(bt) :
#	if bt != self :
#		colorRect.color = Color(1.0, 1.0, 1.0, 0.0)

func set_highlighted(hl : bool) :
	if hl :
		colorRect.color = Color(1.0, 1.0, 1.0, 0.2)
	else :
		colorRect.color = Color(1.0, 1.0, 1.0, 0.0)
