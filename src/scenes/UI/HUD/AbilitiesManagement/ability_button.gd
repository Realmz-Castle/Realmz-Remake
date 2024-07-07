extends Button
class_name AbilityButton

#@export var abBtnTSCN : PackedScene

@onready var namelabel : Label = $LabelsControl/NameLabel
@onready var ptslabel : Label = $LabelsControl/PointsLabel
@onready var colorRect : ColorRect = $LabelsControl/ColorRect
var spellname : String = ''
var ability  #gdscript
var spell_dict : Dictionary
var character : PlayerCharacter
var selection_cost : int = 0
var column : int = 0
var my_menu = AbilitiesManagementRect


var attrColorDict : Dictionary = {"Fire" : Color.ORANGE, "Ice" : Color.CYAN, "Electric" : Color.MEDIUM_SLATE_BLUE,
	"Poison" : Color.FOREST_GREEN, "Chemical" : Color.GREEN_YELLOW, "Disease" : Color.YELLOW, "Healing" : Color.WHITE, "Mental" : Color.DEEP_PINK, 
	"Physical" : Color.LIGHT_CYAN, "Magical" : Color.CORNFLOWER_BLUE}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize(sp_dict : Dictionary, pc : PlayerCharacter, col : int, menu : AbilitiesManagementRect) :
	my_menu = menu
	spell_dict = sp_dict
	spellname = sp_dict["name"]
	column = col
	ability = sp_dict["script"]
	character = pc
	selection_cost = pc.get_selection_cost(ability)
	namelabel.text = spellname
	ptslabel.text = str(selection_cost)
	var color = Color.GRAY
	for attr in ability.attributes :
		if attrColorDict.has(attr) :
			color = attrColorDict[attr]
			break
	colorRect.color = color
	pressed.connect(my_menu.on_abltbutton_pressed.bind(self))


func _get_drag_data(_pos):
	var dragpreview = Label.new()
	dragpreview.set_text(spellname)
	set_drag_preview(dragpreview)
	return [spellname, ability, character, column, self]

func _can_drop_data(_pos, data) ->bool :
		return data[3]!=column or column==0

func _drop_data(_pos, data):
	var indexinparent : int = get_index()
	my_menu.move_abilbutton_from_to(data[4], my_menu.ablboxes[1-column], my_menu.ablboxes[column])
	my_menu.ablboxes[column].move_child(data[4], indexinparent)
