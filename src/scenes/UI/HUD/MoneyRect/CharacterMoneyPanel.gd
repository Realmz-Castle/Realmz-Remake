extends Control

@onready var selectedTexture = preload( "res://shared_assets/UI/buttonHOVER.png" )
@onready var unselectedTexture = preload( "res://shared_assets/UI/buttonUP.png" )

@onready var ninepatchrect : NinePatchRect = $NinePatchRect
@onready var portraitrect : TextureRect = $PortraitTextureRect
@onready var goldnlabel : Label = $GoldnLabel
@onready var gemsnlabel : Label = $GemsnLabel
@onready var jewelsnlabel:Label = $JewelsnLabel
@onready var weightnlabel:Label = $WeightnLabel
@onready var movenlabel : Label = $MovenLabel

var moneymenu = null
var character = null

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func setup(menu,chara) -> void :
	moneymenu = menu
	character = chara
	$PortraitTextureRect.texture = character.portrait
	$NameLabel.text = character.name
	$GoldnLabel.text = str(character.money[0])
	$GemsnLabel.text = str(character.money[1])
	$JewelsnLabel.text=str(character.money[2])
	$WeightnLabel.text = str(character.get_inventory_weight())+' / '+ str(character.get_stat("Weight_Limit"))
	$MovenLabel.text   = str(character.get_movement())

func set_selected(me : bool) :
	if me :
		$NinePatchRect.set_texture(selectedTexture)
	else :
		$NinePatchRect.set_texture(unselectedTexture)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed() -> void :
	print(" charmoneypan _on_Button_pressed , chara : ", character)
	moneymenu.character_button_pressed(self, character)
