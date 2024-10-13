extends NinePatchRect
class_name LevelupRect

# This actually takes care of the entire PlayerCharacter Leveling up process
# as it's needed for the stat changes display


var character : PlayerCharacter

@onready var portraitrect : TextureRect = $Top/PortraitRect
@onready var namelabel : Label = $Top/NameLabel
@onready var levellabel : Label = $Top/LevelLabel
@onready var statsbox : VBoxContainer = $ColorRect/ScrollContainer/StatsVBox

signal closed_lvlup_popup

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func levelup_character(chara : PlayerCharacter) :
	get_parent().popup()
	character = chara
	namelabel.text = character.name
	portraitrect.texture = character.portrait
	var level : int = character.level
	levellabel.text = "Reached level "+str(level+1)+" !"
	var stats_before : Dictionary = character.stats.duplicate()
	var selpts_before : int = chara.selection_pts
	character.level_up()
	for sl  in statsbox.get_children() :
		sl.queue_free()
	for s in stats_before :
		if stats_before[s] != character.stats[s] :
			var newlabel : Label = Label.new()
			newlabel.custom_minimum_size = Vector2(0,20)
			newlabel.text = s + ' : ' + str(stats_before[s]) + ' -> ' + str(character.stats[s])
			statsbox.add_child(newlabel)
	if chara.selection_pts != selpts_before :
		var newlabel : Label = Label.new()
		newlabel.custom_minimum_size = Vector2(0,20)
		newlabel.text = 'Ability Selection Points : ' + str(selpts_before) + ' -> ' + str(chara.selection_pts)
		statsbox.add_child(newlabel)

func _on_close_button_pressed():
	get_parent().hide()
	emit_signal("closed_lvlup_popup")
