extends NinePatchRect

@export var button_tscn : PackedScene  #"res://scenes/UI/HUD/Bestiary/bestiary_button.tscn"

@export var listrect : Control
@export var entrycontainer : VBoxContainer
@export var search_lineedit : LineEdit

@export var portrait_texrect : TextureRect
@export var portrait_lvl_label : Label
@export var name_label : Label
@export var subtitle_label : Label
@export var hp_label : Label
@export var sp_label : Label

@export var stats_grid : GridContainer
@export var resists_grid : GridContainer

@export var tags_header : Label
@export var tags_label : Label
@export var special_grid : GridContainer
@export var abil_spacer : Control
@export var abilities_header : Label
@export var abilities_label : Label
@export var descr_label : Label
@export var close_button : Button

const COLOR_HEADER : Color = Color(1, 0.98, 0, 1)
const COLOR_LABEL : Color = Color(0.85, 0.85, 0.85, 1)
const COLOR_VALUE : Color = Color(1, 1, 1, 1)
const COLOR_DIM : Color = Color(0.65, 0.65, 0.65, 1)
const COLOR_GOOD : Color = Color(0.55, 0.85, 0.55, 1)
const COLOR_BAD : Color = Color(1, 0.5, 0.5, 1)
const COLOR_SHADOW : Color = Color(0, 0, 0, 1)

const STAT_ROWS : Array = [
	["Movement", "MaxMovement"],
	["Actions / Round", "MaxActions"],
	["Weight Limit", "Weight_Limit"],
	["Strength", "Strength"],
	["Intellect", "Intellect"],
	["Wisdom", "Wisdom"],
	["Dexterity", "Dexterity"],
	["Vitality", "Vitality"],
	["Max HP", "maxHP"],
	["HP Regen", "HP_regen_base"],
	["Max SP", "maxSP"],
	["SP Regen", "SP_regen_base"],
	["Acc · Melee", "AccuracyMelee"],
	["Eva · Melee", "EvasionMelee"],
	["Acc · Ranged", "AccuracyRanged"],
	["Eva · Ranged", "EvasionRanged"],
	["Acc · Magic", "AccuracyMagic"],
	["Eva · Magic", "EvasionMagic"],
]

const RESIST_ROWS : Array = [
	["Physical", "Physical"],
	["Magic", "Magic"],
	["Mental", "Mental"],
	["Healing", "Healing"],
	["Fire", "Fire"],
	["Ice", "Ice"],
	["Electric", "Elect"],
	["Poison", "Poison"],
	["Disease", "Disease"],
	["Chemical", "Chemical"],
]

var _list_seeded : bool = false
var _expanded : bool = false
var _original_parent : Node = null
var _original_index : int = -1


func _initialize() :
	set_character_mode(false)
	if _list_seeded :
		return
	var book = NodeAccess.__Resources().crea_book
	for c in book :
		if book[c]["data"]["in_bestiary"] > 0 :
			var nb = button_tscn.instantiate()
			nb.set_creature(book[c])
			entrycontainer.add_child(nb)
			nb.connect("pressed", Callable(self, "_on_entry_pressed").bind(nb.cdata))
	_list_seeded = true


func show_for_character(cdata) -> void :
	set_character_mode(true)
	_on_entry_pressed(cdata)
	show()


# Toggle "character" view (full-screen, no list) vs "bestiary" view (default).
# Public so OWHUDControl can reset this when opening the bestiary normally.
func set_character_mode(enabled : bool) -> void :
	if enabled :
		_enter_expanded()
		listrect.hide()
	else :
		_exit_expanded()
		listrect.show()


# In expanded mode we reparent to the HUD root so we draw on top of HBoxBot,
# rather than hiding TextRect/CreatureRect (which reflows HBoxBot and pushes
# BotRightPanel under us).
func _enter_expanded() -> void :
	if _expanded :
		return
	_expanded = true
	var hud = UI.ow_hud
	var hud_size : Vector2 = hud.size if hud else Vector2(1152, 648)
	_original_parent = get_parent()
	_original_index = get_index()
	var parent_w : float = _original_parent.size.x if _original_parent else 832.0
	if hud and _original_parent != hud :
		_original_parent.remove_child(self)
		hud.add_child(self)
	top_level = true
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	position = Vector2.ZERO
	size = Vector2(parent_w, hud_size.y)


func _exit_expanded() -> void :
	if not _expanded :
		return
	_expanded = false
	top_level = false
	if _original_parent != null and get_parent() != _original_parent :
		get_parent().remove_child(self)
		_original_parent.add_child(self)
		if _original_index >= 0 :
			_original_parent.move_child(self, _original_index)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_original_parent = null
	_original_index = -1


func _on_entry_pressed(cdata) -> void :
	var data : Dictionary = cdata.get("data", {})
	var stats : Dictionary = cdata.get("stats", {})
	var tools : Dictionary = cdata.get("tools", {})

	name_label.text = str(data.get("name", "Unknown"))

	var lvl : int = int(data.get("level", 1))
	portrait_lvl_label.text = "Lv %d" % lvl

	var img = data.get("image", null)
	if img != null :
		portrait_texrect.texture = img

	# Subtitle: explicit override (e.g. "Gnome Warlock") wins; else fall back to
	# "Level X · first-tag" for creatures.
	var tags : Array = data.get("tags", [])
	var subtitle_override = data.get("subtitle", null)
	if subtitle_override != null and not str(subtitle_override).is_empty() :
		subtitle_label.text = "Level %d · %s" % [lvl, str(subtitle_override)]
	else :
		var subtitle_parts : Array = ["Level %d" % lvl]
		if tags.size() > 0 :
			subtitle_parts.append(str(tags[0]))
		subtitle_label.text = " · ".join(subtitle_parts)

	# HP / SP
	var max_hp : int = int(stats.get("maxHP", 0))
	var max_sp : int = int(stats.get("maxSP", 0))
	hp_label.text = "HP %d" % max_hp
	sp_label.text = "SP %d" % max_sp

	_rebuild_stats_grid(stats)
	_rebuild_resists_grid(stats)
	_populate_aux_panel(cdata, tags, tools)

	descr_label.text = str(data.get("description", ""))


# The bottom-left panel shows TAGS+ABILITIES for creatures, or SPECIAL SKILLS
# for player characters when cdata["special_skills"] is provided.
func _populate_aux_panel(cdata, tags : Array, tools : Dictionary) -> void :
	var special_skills : Array = cdata.get("special_skills", [])
	if special_skills.size() > 0 :
		tags_header.text = "SPECIAL SKILLS"
		tags_label.hide()
		abil_spacer.hide()
		abilities_header.hide()
		abilities_label.hide()
		_rebuild_special_grid(special_skills)
		special_grid.show()
		return

	special_grid.hide()
	tags_label.show()
	tags_header.text = "TAGS"
	if tags.is_empty() :
		tags_label.text = "—"
	else :
		tags_label.text = ", ".join(tags.map(func(t): return str(t)))
	abil_spacer.show()
	abilities_header.show()
	abilities_label.show()
	var abilities : Array = tools.get("spells", [])
	if abilities.is_empty() :
		abilities_label.text = "—"
	else :
		var parts : Array = []
		for s in abilities :
			parts.append("%s (Lv %s)" % [s[0], s[1]])
		abilities_label.text = ", ".join(parts)


func _rebuild_special_grid(skills : Array) -> void :
	for c in special_grid.get_children() :
		c.queue_free()
	for entry in skills :
		var name_lbl := Label.new()
		name_lbl.text = str(entry[0])
		name_lbl.add_theme_font_size_override("font_size", 13)
		name_lbl.add_theme_color_override("font_color", COLOR_LABEL)
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		special_grid.add_child(name_lbl)

		var val_str : String = str(entry[1])
		var val_lbl := Label.new()
		val_lbl.text = val_str
		val_lbl.add_theme_font_size_override("font_size", 13)
		val_lbl.add_theme_color_override("font_color", _color_for_signed_str(val_str))
		val_lbl.custom_minimum_size = Vector2(72, 0)
		val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		special_grid.add_child(val_lbl)


# Color positive/negative formatted strings (e.g. "+12.5%" -> green, "-3" -> red).
func _color_for_signed_str(s : String) -> Color :
	if s.begins_with("-") :
		return COLOR_BAD
	if s.begins_with("+") :
		return COLOR_GOOD
	return COLOR_VALUE


func _rebuild_stats_grid(stats : Dictionary) -> void :
	for c in stats_grid.get_children() :
		c.queue_free()
	for row in STAT_ROWS :
		_add_stat_cell(row[0], false)
		_add_stat_cell(_format_stat(stats.get(row[1], 0)), true)


func _add_stat_cell(text : String, is_value : bool) -> void :
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_shadow_color", COLOR_SHADOW)
	lbl.add_theme_constant_override("shadow_offset_x", 1)
	lbl.add_theme_constant_override("shadow_offset_y", 1)
	if is_value :
		lbl.add_theme_color_override("font_color", COLOR_VALUE)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	else :
		lbl.add_theme_color_override("font_color", COLOR_LABEL)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stats_grid.add_child(lbl)


func _rebuild_resists_grid(stats : Dictionary) -> void :
	for c in resists_grid.get_children() :
		c.queue_free()

	# Column header row
	_add_resist_header("TYPE", HORIZONTAL_ALIGNMENT_LEFT)
	_add_resist_header("RES", HORIZONTAL_ALIGNMENT_RIGHT)
	_add_resist_header("MULT", HORIZONTAL_ALIGNMENT_RIGHT)

	for row in RESIST_ROWS :
		var display_name : String = row[0]
		var key : String = row[1]
		var res_val = stats.get("Resistance" + key, 0)
		var mult_val = stats.get("Multiplier" + key, 1.0)
		_add_resist_label(display_name, COLOR_LABEL, HORIZONTAL_ALIGNMENT_LEFT)
		_add_resist_value(_format_resist_pct(res_val), _color_for_resist(res_val), HORIZONTAL_ALIGNMENT_RIGHT)
		_add_resist_value(_format_mult(mult_val), _color_for_mult(mult_val), HORIZONTAL_ALIGNMENT_RIGHT)


func _add_resist_header(text : String, align : int) -> void :
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", COLOR_DIM)
	lbl.add_theme_color_override("font_shadow_color", COLOR_SHADOW)
	lbl.add_theme_constant_override("shadow_offset_x", 1)
	lbl.add_theme_constant_override("shadow_offset_y", 1)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.horizontal_alignment = align
	resists_grid.add_child(lbl)


func _add_resist_label(text : String, color : Color, align : int) -> void :
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_shadow_color", COLOR_SHADOW)
	lbl.add_theme_constant_override("shadow_offset_x", 1)
	lbl.add_theme_constant_override("shadow_offset_y", 1)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.horizontal_alignment = align
	resists_grid.add_child(lbl)


func _add_resist_value(text : String, color : Color, align : int) -> void :
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_color_override("font_shadow_color", COLOR_SHADOW)
	lbl.add_theme_constant_override("shadow_offset_x", 1)
	lbl.add_theme_constant_override("shadow_offset_y", 1)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.horizontal_alignment = align
	resists_grid.add_child(lbl)


func _format_stat(v) -> String :
	if v is float :
		# Drop trailing zeros: 1.00 -> 1, 1.06 -> 1.06.
		var s : String = "%.2f" % v
		if "." in s :
			s = s.rstrip("0").rstrip(".")
			if s == "" or s == "-" :
				s = "0"
		return s
	return str(v)


func _format_resist_pct(v) -> String :
	var f : float = float(v)
	if abs(f) < 0.005 :
		return "0"
	return "%d%%" % int(round(f * 100.0)) if abs(f) < 1.5 else "%d" % int(round(f))


func _format_mult(v) -> String :
	var f : float = float(v)
	if abs(f - 1.0) < 0.005 :
		# Default multiplier (no modifier) — render blank to avoid visual noise.
		return ""
	# Show 2 decimals trimmed.
	var s : String = "%.2f" % f
	if "." in s :
		s = s.rstrip("0").rstrip(".")
	return "×" + s


func _color_for_resist(v) -> Color :
	var f : float = float(v)
	if f > 0.005 :
		return COLOR_GOOD
	if f < -0.005 :
		return COLOR_BAD
	return COLOR_DIM


func _color_for_mult(v) -> Color :
	var f : float = float(v)
	if f < 1.0 - 0.005 :
		return COLOR_GOOD
	if f > 1.0 + 0.005 :
		return COLOR_BAD
	return COLOR_DIM


func _on_close_button_pressed() -> void :
	set_character_mode(false)
	hide()
	StateMachine.transition_to("Exploration/ExWalking")


func _on_line_edit_text_changed(new_text : String) -> void :
	if new_text.is_empty() :
		for b in entrycontainer.get_children() :
			b.show()
		return
	var searched : String = new_text.to_lower()
	for b in entrycontainer.get_children() :
		b.visible = str(b.cname).to_lower().contains(searched)
