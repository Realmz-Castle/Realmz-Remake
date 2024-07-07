extends NinePatchRect
#BestiaryRect

@export var button_tscn : PackedScene  #"res://scenes/UI/HUD/Bestiary/bestiary_button.tscn"

@onready var entrycontainer = $HBoxContainer/ListRect/VBoxContainer/ListControl/ScrollContainer/EntryContainer

@onready var nameLabel : Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/LoreRect/NameLabel
@onready var descrLabel : Label =$HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/LoreRect/DescrLabel
@onready var texRect : TextureRect = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/LoreRect/NinePatchRect/TextureRect
@onready var lvlLabel : Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/LoreRect/NinePatchRect/LvlLabel
@onready var tagsLabel : Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/AbilitiesRect/TagsLabel2
@onready var abilitiesLabel : Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/AbilitiesRect/AbilitiesLabel2

@onready var physresLabel : Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/ResistRect/ResistHBox/ResistVBoxN1/PhysResnLabel
@onready var physmultLabel: Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/ResistRect/ResistHBox/ResistVBoxM1/PhysMultnLabel
@onready var magiresLabel : Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/ResistRect/ResistHBox/ResistVBoxN1/MagiResnLabel
@onready var magimultLabel: Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/ResistRect/ResistHBox/ResistVBoxM1/MagiMultnLabel
@onready var healresLabel : Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/ResistRect/ResistHBox/ResistVBoxN1/HealResnLabel
@onready var healmultLabel: Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/ResistRect/ResistHBox/ResistVBoxM1/HealMultLabel
@onready var mentresLabel : Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/ResistRect/ResistHBox/ResistVBoxN1/MentResnLabel
@onready var mentmultLabel: Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/ResistRect/ResistHBox/ResistVBoxM1/MentMultLabel
@onready var fireresLabel : Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/ResistRect/ResistHBox/ResistVBoxN2/FireResnLabel
@onready var firemultLabel: Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/ResistRect/ResistHBox/ResistVBoxM2/FireMultnLabel 
@onready var iceresLabel  : Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/ResistRect/ResistHBox/ResistVBoxN2/IceResnLabel
@onready var icemultLabel : Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/ResistRect/ResistHBox/ResistVBoxM2/IceMultnLabel
@onready var elecresLabel : Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/ResistRect/ResistHBox/ResistVBoxN2/ElecResnLabel
@onready var elecmultLabel: Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/ResistRect/ResistHBox/ResistVBoxM2/ElecMultLabel
@onready var poisresLabel : Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/ResistRect/ResistHBox/ResistVBoxN3/PosnResnLabel
@onready var poismultLabel: Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/ResistRect/ResistHBox/ResistVBoxM3/PoisMultnLabel
@onready var dissresLabel : Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/ResistRect/ResistHBox/ResistVBoxN3/DissResnLabel
@onready var dissmultLabel: Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/ResistRect/ResistHBox/ResistVBoxM3/DissMultnLabel
@onready var chemresLabel : Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/ResistRect/ResistHBox/ResistVBoxN3/ChemResnLabel
@onready var chemmultLabel: Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/ResistRect/ResistHBox/ResistVBoxM3/ChemMultnLabel

@onready var moveLabel : Label = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/StatsRect/StatsHBox/StatsVBox2/MovementnLabel
@onready var APRLabel : Label  = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/StatsRect/StatsHBox/StatsVBox2/APRnLabel
@onready var dmgLabel : Label  = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/StatsRect/StatsHBox/StatsVBox2/DamagenLabel
@onready var HPLabel : Label   = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/StatsRect/StatsHBox/StatsVBox4/HPnLabel
@onready var SPLabel : Label   = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/StatsRect/StatsHBox/StatsVBox4/SPnLabel
@onready var HPrLabel : Label   = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/StatsRect/StatsHBox/StatsVBox4/HPrnLabel
@onready var SPrLabel : Label   = $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/StatsRect/StatsHBox/StatsVBox4/SPrnLabel
@onready var accmeleeLabel : Label =  $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/StatsRect/StatsHBox/StatsVBox6/AccMeleenLabel
@onready var accrangeLabel : Label =  $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/StatsRect/StatsHBox/StatsVBox6/AccRangenLabel
@onready var accmagicLabel : Label =  $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/StatsRect/StatsHBox/StatsVBox6/AccMagicnLabel
@onready var evameleeLabel : Label =  $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/StatsRect/StatsHBox/StatsVBox8/EvaMeleenLabel
@onready var evarangeLabel : Label =  $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/StatsRect/StatsHBox/StatsVBox8/EvaRangenLabel
@onready var evamagicLabel : Label =  $HBoxContainer/InfoControl/ScrollContainer/VBoxContainer/StatsRect/StatsHBox/StatsVBox8/EvaMagicnLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _initialize() :
	var book = NodeAccess.__Resources().crea_book
	for c in book :
		if book[c]["data"]["in_bestiary"]>0 :
			var nb = button_tscn.instantiate()
			nb.set_creature(book[c])
			entrycontainer.add_child(nb)
			nb.connect("pressed", Callable(self,"_on_entry_pressed").bind(nb.cdata))

func _on_entry_pressed(cdata) :
#	print(cdata)
	nameLabel.text = str( cdata["data"]["name"] )
	descrLabel.text = str( cdata["data"]["description"] )
	lvlLabel.text = "Level "+str( cdata["data"]["level"] )
	texRect.texture = cdata["data"]["image"]
	var sizev = cdata["data"]["image"].get_image().get_size()
	texRect.size = sizev
	texRect.position.x = 35-sizev.x/2
	texRect.position.y = 35-sizev.y/2
	
	var tags : Array = cdata["data"]["tags"]
	var tagstext : String = ''
	for t in tags :
		tagstext += t + ', '
	tagstext.trim_suffix(', ')
	tagsLabel.text = tagstext
	var abilities : Array = cdata["tools"]["spells"]
	var abilitiestext : String = ''
	for s in abilities :
		abilitiestext += s[0] + ' lvl'+str(s[1])+', '
	abilitiestext.trim_suffix(', ')
	abilitiesLabel.text = abilitiestext
	
	physresLabel.text = str( cdata["stats"]["ResistancePhysical"] )
	physmultLabel.text = str( cdata["stats"]["MultiplierPhysical"] )
	magiresLabel.text = str( cdata["stats"]["ResistanceMagic" ] )
	magimultLabel.text = str( cdata["stats"]["MultiplierMagic" ] )
	healresLabel.text = str( cdata["stats"]["ResistanceHealing" ] )
	healmultLabel.text = str( cdata["stats"]["MultiplierHealing" ] )
	mentresLabel.text = str( cdata["stats"]["ResistanceMental" ] )
	mentmultLabel.text = str( cdata["stats"]["MultiplierMental"] )

	fireresLabel.text = str( cdata["stats"]["ResistanceFire"] )
	firemultLabel.text= str( cdata["stats"]["MultiplierFire"] )
	iceresLabel.text = str( cdata["stats"]["ResistanceIce"] )
	icemultLabel.text= str( cdata["stats"]["MultiplierIce"] )
	elecresLabel.text = str( cdata["stats"]["ResistanceElect"] )
	elecmultLabel.text= str( cdata["stats"]["MultiplierElect"] )

	poisresLabel.text = str( cdata["stats"]["ResistancePoison"] )
	poismultLabel.text= str( cdata["stats"]["MultiplierPoison"] )
	dissresLabel.text = str( cdata["stats"]["ResistanceDisease" ] )
	dissmultLabel.text= str( cdata["stats"]["MultiplierDisease"] )
	chemresLabel.text = str( cdata["stats"]["ResistanceChemical"] )
	chemmultLabel.text= str( cdata["stats"]["MultiplierChemical"] )

	moveLabel.text= str( cdata["stats"]["MaxMovement" ] )
	APRLabel.text= str( cdata["stats"]["MaxActions"] )
	dmgLabel.text= "NA"
	HPLabel.text= str( cdata["stats"]["maxHP"] )
	SPLabel.text= str( cdata["stats"]["maxSP"] )
	HPrLabel.text= str( cdata["stats"]["HP_regen_base" ] )
	SPrLabel.text= str( cdata["stats"]["SP_regen_base" ] )
	accmeleeLabel.text= str( cdata["stats"]["AccuracyMelee" ] )
	accrangeLabel.text= str( cdata["stats"]["AccuracyRanged" ] )
	accmagicLabel.text= str( cdata["stats"]["AccuracyMagic" ] )
	evameleeLabel.text= str( cdata["stats"]["EvasionMelee"] )
	evarangeLabel.text= str( cdata["stats"]["EvasionRanged" ] )
	evamagicLabel.text= str( cdata["stats"]["EvasionMagic" ] )

func _on_close_button_pressed():
	hide()
	StateMachine.transition_to("Exploration/ExWalking")


func _on_line_edit_text_changed(new_text: String):
	if new_text.is_empty() :
		for b in entrycontainer.get_children() :
			b.show()
		return
	var searched : String = new_text.to_lower()
	for b in entrycontainer.get_children() :
		b.visible = str(b.cname).to_lower().contains(searched)
