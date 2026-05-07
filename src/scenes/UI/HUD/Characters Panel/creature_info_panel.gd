extends NinePatchRect
class_name CreatureInfoPanel

# Shared 4-panel info display (header + stats + resists + tags/abilities/lore).
# Used standalone as the in-game character stat sheet (instanced directly under
# OWHUDControl), and embedded inside the bestiary next to the creature list.
#
# Public API:
#   - populate(cdata)            — fill the panel from cdata
#   - show_for_character(cdata)  — populate + show; for standalone usage
#   - signal close_requested     — emitted on close button press; the parent
#                                  decides what to hide and which state to
#                                  transition to
signal close_requested


func _ready() -> void :
	# Total inset from the visible outer stone border to the section panels is
	# 16 in both contexts. Standalone: this panel provides all 16. Embedded:
	# the parent provides all 16, so this panel adds 0.
	var outer = get_node_or_null("OuterMargin")
	var inner_margin : int = 16 if show_outer_bg else 0
	if outer :
		outer.add_theme_constant_override("margin_left", inner_margin)
		outer.add_theme_constant_override("margin_top", inner_margin)
		outer.add_theme_constant_override("margin_right", inner_margin)
		outer.add_theme_constant_override("margin_bottom", inner_margin)
	if not show_outer_bg :
		# Drop the redundant stone bg — parent already provides one.
		texture = null


# Per-instance customization. Char panel keeps the defaults (4-column stats,
# show all stats). Bestiary embed overrides to 2 columns + skip-zero + hide
# stats that don't apply to creatures (Weight Limit, etc.).
@export var stats_columns : int = 4
@export var skip_zero_stats : bool = false
@export var hidden_stat_keys : Array[String] = []
# When this panel is embedded inside another stone-pattern frame (e.g. the
# bestiary), the outer stone here would be a redundant third layer.
@export var show_outer_bg : bool = true

@export var portrait_texrect : TextureRect
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

const COLOR_LABEL : Color = Color(0.85, 0.85, 0.85, 1)
const COLOR_VALUE : Color = Color(1, 1, 1, 1)
const COLOR_DIM : Color = Color(0.65, 0.65, 0.65, 1)
const COLOR_GOOD : Color = Color(0.55, 0.85, 0.55, 1)
const COLOR_BAD : Color = Color(1, 0.5, 0.5, 1)

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


func show_for_character(cdata) -> void :
	populate(cdata)
	show()


func populate(cdata) -> void :
	var data : Dictionary = cdata.get("data", {})
	var stats : Dictionary = cdata.get("stats", {})
	var tools : Dictionary = cdata.get("tools", {})

	name_label.text = str(data.get("name", "Unknown"))

	var lvl : int = int(data.get("level", 1))

	var img = data.get("image", null)
	if img != null :
		portrait_texrect.texture = img

	# Subtitle: explicit override (e.g. "Gnome Warlock") wins; else fall back to
	# "Lv X · first-tag".
	var tags : Array = data.get("tags", [])
	var subtitle_override = data.get("subtitle", null)
	if subtitle_override != null and not str(subtitle_override).is_empty() :
		subtitle_label.text = "Lv %d · %s" % [lvl, str(subtitle_override)]
	else :
		var parts : Array = ["Lv %d" % lvl]
		if tags.size() > 0 :
			parts.append(str(tags[0]))
		subtitle_label.text = " · ".join(parts)

	var max_hp : int = int(stats.get("maxHP", 0))
	var max_sp : int = int(stats.get("maxSP", 0))
	hp_label.text = "HP %d" % max_hp
	sp_label.text = "SP %d" % max_sp

	_rebuild_stats_grid(stats)
	_rebuild_resists_grid(stats)
	_populate_aux_panel(cdata, tags, tools)

	descr_label.text = str(data.get("description", ""))


# Bottom-left panel: SPECIAL SKILLS for player chars (when cdata provides
# special_skills); falls back to TAGS+ABILITIES (allies/summons may set tags).
func _populate_aux_panel(cdata, tags : Array, tools : Dictionary) -> void :
	var special_skills : Array = cdata.get("special_skills", [])
	if special_skills.size() > 0 :
		tags_header.text = "Special Skills"
		tags_label.hide()
		abil_spacer.hide()
		abilities_header.hide()
		abilities_label.hide()
		_rebuild_special_grid(special_skills)
		special_grid.show()
		return

	special_grid.hide()
	tags_label.show()
	tags_header.text = "Tags"
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


func _rebuild_stats_grid(stats : Dictionary) -> void :
	stats_grid.columns = stats_columns
	for c in stats_grid.get_children() :
		c.queue_free()
	for row in STAT_ROWS :
		if row[1] in hidden_stat_keys :
			continue
		var v = stats.get(row[1], 0)
		if skip_zero_stats and _is_zero(v) :
			continue
		_add_stat_cell(row[0], false)
		_add_stat_cell(_format_stat(v), true)


func _is_zero(v) -> bool :
	if v is float :
		return abs(v) < 0.005
	return int(v) == 0


func _add_stat_cell(text : String, is_value : bool) -> void :
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 13)
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
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.horizontal_alignment = align
	resists_grid.add_child(lbl)


func _add_resist_label(text : String, color : Color, align : int) -> void :
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", color)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.horizontal_alignment = align
	resists_grid.add_child(lbl)


func _add_resist_value(text : String, color : Color, align : int) -> void :
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", color)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.horizontal_alignment = align
	resists_grid.add_child(lbl)


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


func _color_for_signed_str(s : String) -> Color :
	if s.begins_with("-") :
		return COLOR_BAD
	if s.begins_with("+") :
		return COLOR_GOOD
	return COLOR_VALUE


func _format_stat(v) -> String :
	if v is float :
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
		return ""
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
	emit_signal("close_requested")
