extends Button
class_name AbilityButton

const COLOR_KNOWN_DOT : Color = Color(0.30, 0.85, 0.35, 1)
const COLOR_AVAIL_DOT_OUTLINE : Color = Color(0.55, 0.55, 0.55, 0.6)
const COLOR_NAME_KNOWN : Color = Color(1, 0.95, 0.7, 1)
const COLOR_NAME_AVAIL : Color = Color(0.85, 0.85, 0.85, 1)

@onready var namelabel : Label = $NameLabel
@onready var stateDot : ColorRect = $StateDot

var spell_dict : Dictionary
var ability  # GDScript instance for the spell
var character : PlayerCharacter
var selection_cost : int = 0
var is_known : bool = false
var my_menu : AbilitiesManagementRect


func initialize(sp_dict : Dictionary, pc : PlayerCharacter, known : bool, menu : AbilitiesManagementRect) -> void :
	my_menu = menu
	spell_dict = sp_dict
	ability = sp_dict["script"]
	character = pc
	is_known = known
	selection_cost = pc.get_selection_cost(ability)
	namelabel.text = sp_dict["name"]
	if not pressed.is_connected(_on_self_pressed) :
		pressed.connect(_on_self_pressed)
	refresh_state()


func refresh_state() -> void :
	if is_known :
		stateDot.color = COLOR_KNOWN_DOT
		namelabel.add_theme_color_override("font_color", COLOR_NAME_KNOWN)
	else :
		stateDot.color = COLOR_AVAIL_DOT_OUTLINE
		namelabel.add_theme_color_override("font_color", COLOR_NAME_AVAIL)


func _on_self_pressed() -> void :
	if my_menu == null :
		return
	my_menu.on_abltbutton_pressed(self)
	my_menu.on_abltbutton_toggle_requested(self)
