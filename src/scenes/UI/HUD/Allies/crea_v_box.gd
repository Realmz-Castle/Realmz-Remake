extends VBoxContainer

var creature : Creature
var crea_summoner_name : String

@onready var button : Button = $CreaButton
@onready var namelabel : Label = $NameLabel
@onready var hplabel : Label = $HPLabel
@onready var splabel : Label = $SPLabel


signal  creabutton_toggled


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_creature(crea, summoner_name) :
	creature = crea
	button.icon = creature.textureR
	namelabel.text = crea.name
	hplabel.text = str(crea.get_stat("curHP"))+'/'+str(crea.get_stat("maxHP"))
	splabel.text = str(crea.get_stat("cur"+creature.used_resource))+'/'+str(crea.get_stat("max"+creature.used_resource))
	crea_summoner_name = summoner_name

func _on_crea_button_toggled(button_pressed):
	emit_signal("creabutton_toggled", crea_summoner_name, button_pressed)


func force_togggle_pressed() ->void :
	button.set_pressed_no_signal(true)
	emit_signal("creabutton_toggled", crea_summoner_name, true)
	
