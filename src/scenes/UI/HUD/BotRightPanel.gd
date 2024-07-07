extends TextureRect
class_name BotRightPanel

@export var spellCastButton : Button

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func disable_all_except(btn_name : String, selected_crea : Creature) :
	for b in get_children() :
		if b.is_class('BaseButton') :
			b.disabled = not btn_name==b.name
	spellCastButton.disabled = (selected_crea.spells.size()==0)

func enable_all(selected_crea : Creature) :
	for b in get_children() :
		if b.is_class('BaseButton') :
			b.disabled = false
	spellCastButton.disabled = (selected_crea.spells.size()==0)
