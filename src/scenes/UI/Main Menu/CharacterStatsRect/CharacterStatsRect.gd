extends NinePatchRect
class_name NewCharStatsRect

const STAT_GROUPS : Array = [
	["Basics", ["MaxMovement","MaxActions","Weight_Limit","MaxSpellsPerRound"]],
	["Resources", ["maxHP","HP_regen_base","HP_regen_mult","maxSP","SP_regen_base","SP_regen_mult"]],
	["Attributes", ["Strength","Intellect","Wisdom","Dexterity","Vitality"]],
	["Accuracy", ["AccuracyMelee","AccuracyRanged","AccuracyMagic"]],
	["Evasion", ["EvasionMelee","EvasionRanged","EvasionMagic"]],
	["Resistances", ["ResistancePhysical","ResistanceMagic","ResistanceFire","ResistanceIce","ResistanceElect","ResistancePoison","ResistanceChemical","ResistanceDisease","ResistanceHealing"]],
	["Multipliers", ["MultiplierPhysical","MultiplierMagic","MultiplierFire","MultiplierIce","MultiplierElect","MultiplierPoison","MultiplierChemical","MultiplierDisease","MultiplierHealing"]],
]

# Display names for stat keys. Some are intentionally short ("Magic", "Melee")
# because they're shown under section headers (ACCURACY, EVASION, RESISTANCES,
# MULTIPLIERS) that supply the context. Don't read these in isolation.
const STAT_DISPLAY_NAMES : Dictionary = {
	"MaxMovement": "Movement",
	"MaxActions": "Actions / Turn",
	"MaxSpellsPerRound": "Spells / Turn",
	"Weight_Limit": "Weight Limit",
	"maxHP": "Max HP",
	"maxSP": "Max SP",
	"HP_regen_base": "HP Regen",
	"SP_regen_base": "SP Regen",
	"HP_regen_mult": "HP Regen %",
	"SP_regen_mult": "SP Regen %",
	"AccuracyMelee": "Melee",
	"AccuracyRanged": "Ranged",
	"AccuracyMagic": "Magic",
	"EvasionMelee": "Melee",
	"EvasionRanged": "Ranged",
	"EvasionMagic": "Magic",
	"ResistancePhysical": "Physical",
	"ResistanceMagic": "Magic",
	"ResistanceFire": "Fire",
	"ResistanceIce": "Ice",
	"ResistanceElect": "Electric",
	"ResistancePoison": "Poison",
	"ResistanceChemical": "Chemical",
	"ResistanceDisease": "Disease",
	"ResistanceHealing": "Healing",
	"MultiplierPhysical": "Physical",
	"MultiplierMagic": "Magic",
	"MultiplierFire": "Fire",
	"MultiplierIce": "Ice",
	"MultiplierElect": "Electric",
	"MultiplierPoison": "Poison",
	"MultiplierChemical": "Chemical",
	"MultiplierDisease": "Disease",
	"MultiplierHealing": "Healing",
}

const COLOR_POS : Color = Color(0.49, 0.7, 0.49, 1)
const COLOR_NEG : Color = Color(0.8, 0.4, 0.4, 1)
const COLOR_DIM : Color = Color(0.7, 0.7, 0.7, 1)
const COLOR_GOLD : Color = Color(1, 0.78, 0.27, 1)
const COLOR_DEFAULT : Color = Color(1, 1, 1, 1)
const COLOR_SECTION : Color = Color(0.85, 0.7, 0.45, 1)

@export var portraitrect : TextureRect
@export var namelabel : Label
@export var raceclasslabel : Label
@export var levellabel : Label
@export var pointslabel : Label
@export var statslist : VBoxContainer
@export var emptyprompt : Label

@onready var plusTexture : Texture2D = preload("res://scenes/UI/Main Menu/CharacterStatsRect/tinybutton_plus.png")
@onready var minusTexture : Texture2D = preload("res://scenes/UI/Main Menu/CharacterStatsRect/tinybutton_minus.png")
@onready var statsscroll : ScrollContainer = $VBox/StatsControl/StatsScroll

var character_level : int = 1
var stat_mods_dict : Dictionary = {}

# stat_name -> HBoxContainer row, so we can update value/badge in place.
var stat_rows : Dictionary = {}

var current_character = null


func _stat_display_name(sn : String) -> String :
	return STAT_DISPLAY_NAMES.get(sn, sn)


func display_name(charname : String) -> void :
	if charname == "" :
		namelabel.text = "— unnamed —"
	else :
		namelabel.text = charname


func display_portrait(portrait : Texture2D) -> void :
	portraitrect.texture = portrait


func set_character_level(level : int) -> void :
	character_level = level
	levellabel.text = str(level)


func display_partial_selection(racegd, classgd) -> void :
	var racetext : String = racegd.classrace_name if racegd else "no race"
	var classtext : String = classgd.classrace_name if classgd else "no class"
	raceclasslabel.text = racetext + " · " + classtext


func display_data(character) -> void :
	if character.classgd == null or character.racegd == null :
		if emptyprompt :
			emptyprompt.show()
		statsscroll.hide()
		raceclasslabel.text = "no race · no class"
		return
	if emptyprompt :
		emptyprompt.hide()
	statsscroll.show()
	portraitrect.texture = character.portrait
	var race_name: String = (
		str(character.get_display_race_name())
		if character.has_method("get_display_race_name")
		else str(character.racegd.classrace_name)
	)
	var caste_name: String = (
		str(character.get_display_caste_name())
		if character.has_method("get_display_caste_name")
		else str(character.classgd.classrace_name)
	)
	raceclasslabel.text = race_name + " · " + caste_name
	levellabel.text = str(character.level)
	current_character = character
	_rebuild_stats_list()
	_refresh_points_label()


# --- stat list construction ---

func _rebuild_stats_list() -> void :
	for c in statslist.get_children() :
		c.queue_free()
	stat_rows.clear()
	if current_character == null :
		return
	var first : bool = true
	for group in STAT_GROUPS :
		var header_text : String = group[0]
		var stats_in_group : Array = group[1]
		_make_section_header(header_text, first)
		first = false
		for sn in stats_in_group :
			_make_stat_row(sn)


func _make_section_header(header_text : String, is_first : bool) -> void :
	if not is_first :
		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(0, 6)
		statslist.add_child(spacer)
	var lbl := Label.new()
	lbl.text = header_text.to_upper()
	lbl.add_theme_color_override("font_color", COLOR_SECTION)
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.mouse_filter = Control.MOUSE_FILTER_PASS
	statslist.add_child(lbl)


func _make_stat_row(sn : String) -> void :
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.tooltip_text = _build_tooltip(sn)
	row.mouse_filter = Control.MOUSE_FILTER_PASS

	var name_lbl := Label.new()
	name_lbl.text = _stat_display_name(sn)
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_child(name_lbl)

	var value_lbl := Label.new()
	value_lbl.name = "Value"
	value_lbl.custom_minimum_size = Vector2(70, 0)
	value_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_lbl.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_child(value_lbl)

	var badge := Label.new()
	badge.name = "Badge"
	badge.custom_minimum_size = Vector2(40, 0)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	badge.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_child(badge)

	var minus := TextureButton.new()
	minus.texture_normal = minusTexture
	minus.custom_minimum_size = Vector2(20, 20)
	minus.ignore_texture_size = true
	minus.stretch_mode = TextureButton.STRETCH_SCALE
	minus.pressed.connect(_on_stat_button_pressed.bind(sn, -1))
	row.add_child(minus)

	var plus := TextureButton.new()
	plus.texture_normal = plusTexture
	plus.custom_minimum_size = Vector2(20, 20)
	plus.ignore_texture_size = true
	plus.stretch_mode = TextureButton.STRETCH_SCALE
	plus.pressed.connect(_on_stat_button_pressed.bind(sn, 1))
	row.add_child(plus)

	statslist.add_child(row)
	stat_rows[sn] = row
	_paint_row(sn)


func _paint_row(sn : String) -> void :
	if not stat_rows.has(sn) :
		return
	var row : HBoxContainer = stat_rows[sn]
	var value_lbl : Label = row.get_node("Value")
	var badge : Label = row.get_node("Badge")
	var base_value = current_character.get_stat(sn)
	var mod = stat_mods_dict.get(sn, 0)
	var final_value = _add_numbers(base_value, mod)
	value_lbl.text = _format_stat_value(final_value)
	if mod == 0 :
		badge.text = ""
		value_lbl.add_theme_color_override("font_color", COLOR_DEFAULT)
	else :
		var sign_str : String = "+" if mod > 0 else ""
		badge.text = sign_str + str(mod)
		var color : Color = COLOR_POS if mod > 0 else COLOR_NEG
		badge.add_theme_color_override("font_color", color)
		value_lbl.add_theme_color_override("font_color", color)


func _add_numbers(a, b) :
	if a is float or b is float :
		return float(a) + float(b)
	return int(a) + int(b)


func _format_stat_value(v) -> String :
	if v is float :
		# Drop trailing zeros: 1.00 -> 1, 1.06 -> 1.06, 0.50 -> 0.5.
		var s : String = "%.2f" % v
		if "." in s :
			s = s.rstrip("0").rstrip(".")
			if s == "" or s == "-" :
				s = "0"
		return s
	return str(v)


# --- tooltip ---

func _build_tooltip(sn : String) -> String :
	if current_character == null or current_character.classgd == null or current_character.racegd == null :
		return ""
	var cbs = current_character.classgd.base_stat_bonuses
	var clu = current_character.classgd.levelup_bonuses
	var rbs = current_character.racegd.base_stat_bonuses
	var rlu = current_character.racegd.levelup_bonuses
	var lines : Array = []
	lines.append("Class %s · Race %s" % [cbs.get(sn, 0), rbs.get(sn, 0)])
	lines.append("Class/lvl %s · Race/lvl %s" % [clu.get(sn, 0), rlu.get(sn, 0)])
	if stat_mods_dict.has(sn) :
		var v = stat_mods_dict[sn]
		var sign_str : String = "+" if v > 0 else ""
		lines.append("Player %s%s" % [sign_str, str(v)])
	return "\n".join(lines)


# --- button callback ---

func _on_stat_button_pressed(sn : String, delta : int) -> void :
	if stat_mods_dict.has(sn) :
		stat_mods_dict[sn] += delta
	else :
		stat_mods_dict[sn] = delta
	if stat_mods_dict[sn] == 0 :
		stat_mods_dict.erase(sn)
	_paint_row(sn)
	if stat_rows.has(sn) :
		stat_rows[sn].tooltip_text = _build_tooltip(sn)
	_refresh_points_label()


# --- points indicator ---

func _refresh_points_label() -> void :
	var spent : int = 0
	for v in stat_mods_dict.values() :
		spent += abs(v)
	if spent == 0 :
		pointslabel.text = "No stat changes"
		pointslabel.add_theme_color_override("font_color", COLOR_DIM)
	else :
		pointslabel.text = "Points spent: %d" % spent
		pointslabel.add_theme_color_override("font_color", COLOR_GOLD)


func clear() -> void :
	stat_mods_dict.clear()
	current_character = null
	for c in statslist.get_children() :
		c.queue_free()
	stat_rows.clear()
	raceclasslabel.text = "no race · no class"
	namelabel.text = "— unnamed —"
	levellabel.text = "1"
	character_level = 1
	pointslabel.text = "No stat changes"
	pointslabel.add_theme_color_override("font_color", COLOR_DIM)
	if emptyprompt :
		emptyprompt.show()
	statsscroll.hide()


# --- statnames compat (NewCharacterPanel may still iterate) ---

var statnames : Array :
	get :
		var flat : Array = []
		for group in STAT_GROUPS :
			for sn in group[1] :
				flat.append(sn)
		return flat
