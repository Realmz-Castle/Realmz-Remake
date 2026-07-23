extends NinePatchRect
class_name AbilitiesManagementRect

const COLOR_KNOWN : Color = Color(0.49, 0.7, 0.49, 1)
const COLOR_AVAIL : Color = Color(0.55, 0.55, 0.55, 1)
const COLOR_DIM : Color = Color(0.7, 0.7, 0.7, 1)
const COLOR_GOLD : Color = Color(1, 0.78, 0.27, 1)

@export var abBtnTSCN : PackedScene

@export var nameLabel : Label
@export var pointsLabel : Label
@export var portraitRect : TextureRect
@export var spellListCntnr : VBoxContainer
@export var lvbuttonCntnr : VBoxContainer
@export var costColumnCntnr : VBoxContainer
@export var infoNameLabel : Label
@export var infoStatsLabel : Label
@export var doneButton : Button

signal on_closed

var character : PlayerCharacter
var charspells : Array
var spells_book : Dictionary

# Per-level entries: {level: [spell_dict, ...]}
var spells_by_level : Dictionary = {1:[], 2:[], 3:[], 4:[], 5:[], 6:[], 7:[]}
var known_names_by_level : Dictionary = {1:{}, 2:{}, 3:{}, 4:{}, 5:{}, 6:{}, 7:{}}

var show_class_abs : bool = false
var extra_abs : Array = []

var char_sp : int = 0
var level : int = 1

# Filled by _build_level_buttons_and_costs(). Index 0 = level 1, etc.
var _cost_labels : Array = []


func _ready() -> void :
	_build_level_buttons_and_costs()


# Generate the Level 1..7 buttons + matching cost cells. Done in code so the
# two columns stay in lockstep.
func _build_level_buttons_and_costs() -> void :
	# Clear out anything that was placed in the editor (Header rows are kept).
	for c in lvbuttonCntnr.get_children() :
		if not c is Label :
			c.queue_free()
	for c in costColumnCntnr.get_children() :
		if not c is Label :
			c.queue_free()

	_cost_labels.clear()

	for lvl in range(1, 8) :
		var btn := Button.new()
		btn.toggle_mode = true
		btn.custom_minimum_size = Vector2(0, 32)
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		btn.text = "Level " + str(lvl)
		btn.add_theme_color_override("font_color", _level_color(lvl))
		var lvl_captured : int = lvl
		btn.pressed.connect(func() -> void: _on_s_level_button_pressed(lvl_captured))
		lvbuttonCntnr.add_child(btn)

		var cost_lbl := Label.new()
		cost_lbl.custom_minimum_size = Vector2(0, 32)
		cost_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
		cost_lbl.text = "—"
		cost_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cost_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cost_lbl.add_theme_color_override("font_color", COLOR_GOLD)
		cost_lbl.add_theme_font_size_override("font_size", 16)
		costColumnCntnr.add_child(cost_lbl)
		_cost_labels.append(cost_lbl)


# Yellow → red color ramp matching the original Realmz look.
func _level_color(lvl : int) -> Color :
	const RAMP : Array = [
		Color(1, 1, 0, 1),
		Color(1, 0.83, 0, 1),
		Color(1, 0.66, 0, 1),
		Color(1, 0.50, 0, 1),
		Color(1, 0.33, 0, 1),
		Color(1, 0.16, 0, 1),
		Color(1, 0, 0, 1),
	]
	return RAMP[clamp(lvl - 1, 0, 6)]


# extra_avail: array of [spellname, spell_level] arrays for spells the
# character can learn beyond what their class would normally allow.
func set_displayed_character(
	pc: PlayerCharacter,
	show_class_abilities: bool = false,
	extra_avail: Array = []
) -> void:
	extra_abs = extra_avail
	show_class_abs = show_class_abilities or pc.can_manage_ablt_anywhere()
	spells_book = NodeAccess.__Resources().spells_book
	character = pc
	character.prepare_ability_selection()
	charspells = character.spells
	nameLabel.text = pc.name
	char_sp = pc.get_ability_selection_points()
	portraitRect.texture = pc.portrait

	_rebuild_spell_lists()
	_refresh_points_label()
	_refresh_cost_column()
	_clear_info_panel()
	_on_s_level_button_pressed(1)


# Group spells by level: known first (in their stored order), then
# learnable-but-not-known (sorted by name). Each entry includes the
# spell_dict and its known/avail state.
func _rebuild_spell_lists() -> void :
	for lvl in range(1, 8) :
		spells_by_level[lvl] = []
		known_names_by_level[lvl] = {}

	var maxlevel : int = charspells.size()
	for lvl in range(1, maxlevel + 1) :
		for spell_dict : Dictionary in charspells[lvl - 1] :
			spells_by_level[lvl].append({"dict": spell_dict, "known": true})
			known_names_by_level[lvl][spell_dict["name"]] = true

	# Available-but-not-known: anything the class can learn at this level.
	var avail_by_level : Dictionary = {1:[], 2:[], 3:[], 4:[], 5:[], 6:[], 7:[]}
	for sa : Array in character.get_abilities_pc_can_learn() + extra_abs :
		var slvl : int = sa[1]
		var sn : String = sa[0]
		if slvl < 1 or slvl > 7 or slvl > maxlevel :
			continue
		if known_names_by_level[slvl].has(sn) :
			continue
		if not spells_book.has(sn) :
			continue
		avail_by_level[slvl].append(spells_book[sn])

	for lvl in range(1, 8) :
		var sorted : Array = avail_by_level[lvl]
		sorted.sort_custom(func(a, b) : return a["name"] < b["name"])
		for sp_dict in sorted :
			spells_by_level[lvl].append({"dict": sp_dict, "known": false})


# Cost ladder column: pick a representative cost for each level by sampling
# the first spell at that level the character can learn. If nothing's
# available, show "—".
func _refresh_cost_column() -> void :
	for i in range(_cost_labels.size()) :
		var cost : int = _cost_for_level(i + 1)
		_cost_labels[i].text = str(cost) if cost > 0 else "—"


func _cost_for_level(lvl : int) -> int :
	for entry in spells_by_level[lvl] :
		var c : int = character.get_selection_cost(entry["dict"]["script"])
		if c > 0 :
			return c
	return 0


func _on_s_level_button_pressed(index : int) -> void :
	level = index
	# Make the level button visually toggle (skip the LevelsHeader label).
	for child in lvbuttonCntnr.get_children() :
		if child is Button :
			child.set_pressed_no_signal(false)
	var btn_index : int = index  # Children: header, lvl1, lvl2, ..., lvl7 → index N is at child N
	if lvbuttonCntnr.get_child_count() > btn_index :
		var btn = lvbuttonCntnr.get_child(btn_index)
		if btn is Button :
			btn.set_pressed_no_signal(true)

	_clear_vbox(spellListCntnr)
	if charspells.size() < index :
		GameGlobal.play_sfx("target error.wav")
		return

	for entry in spells_by_level[index] :
		var btn_node : AbilityButton = abBtnTSCN.instantiate()
		spellListCntnr.add_child(btn_node)
		btn_node.initialize(entry["dict"], character, entry["known"], self)


func _clear_vbox(vbox : VBoxContainer) -> void :
	for child in vbox.get_children() :
		child.queue_free()


# --- callbacks from ability buttons ---

func on_abltbutton_pressed(btn : AbilityButton) -> void :
	_show_info(btn.spell_dict)
	if UI and UI.ow_hud and UI.ow_hud.textRect :
		UI.ow_hud.textRect.set_spell_info(btn.spell_dict, character, 1)


# Single-click toggle: learn or forget. Spells of the same level always cost
# the same so we only need to check char_sp.
func on_abltbutton_toggle_requested(btn : AbilityButton) -> void :
	var sn : String = btn.spell_dict["name"]
	if btn.is_known :
		# Forget: refund the cost.
		_set_known(level, sn, false)
		char_sp += btn.selection_cost
		btn.is_known = false
		btn.refresh_state()
	else :
		# Learn: must afford.
		if char_sp < btn.selection_cost :
			GameGlobal.play_sfx("target error.wav")
			return
		_set_known(level, sn, true)
		char_sp -= btn.selection_cost
		btn.is_known = true
		btn.refresh_state()
	_refresh_points_label()


func _set_known(lvl : int, sn : String, known : bool) -> void :
	for entry in spells_by_level[lvl] :
		if entry["dict"]["name"] == sn :
			entry["known"] = known
			break
	if known :
		known_names_by_level[lvl][sn] = true
	else :
		known_names_by_level[lvl].erase(sn)


# --- info panel ---

func _show_info(sp_dict : Dictionary) -> void :
	var sp = sp_dict["script"]
	infoNameLabel.text = sp_dict["name"]
	var lines : Array = []
	var dmg_min : int = sp.get_min_damage(1, character)
	var dmg_max : int = sp.get_max_damage(1, character)
	if dmg_max > 0 :
		lines.append("Damage: %d-%d" % [dmg_min, dmg_max])
	var rng : int = sp.get_range(1, character)
	if rng > 0 :
		lines.append("Range: %d" % rng)
	lines.append("Target: %s" % _target_label(sp))
	lines.append("Sight: %s" % ("Yes" if sp.los else "No"))
	if sp.in_combat and sp.in_field :
		lines.append("Cast: Field & Combat")
	elif sp.in_combat :
		lines.append("Cast: Combat only")
	elif sp.in_field :
		lines.append("Cast: Field only")
	infoStatsLabel.text = "  ·  ".join(lines)


func _target_label(sp) -> String :
	# 0=anywhere 1=creature 2=empty 3=nowall
	var t : int = sp.targettile
	match t :
		0: return "Any tile"
		1: return "Creature"
		2: return "Empty tile"
		3: return "Wall, can rotate" if sp.rot else "Non-wall tile"
	return "—"


func _clear_info_panel() -> void :
	infoNameLabel.text = "Select a spell to view details"
	infoStatsLabel.text = ""


# --- header ---

func _refresh_points_label() -> void :
	pointsLabel.text = "%d  Remaining Spell Selection Points" % char_sp


# --- done ---

func _on_done_button_pressed() -> void :
	# Persist the player's choices back onto the character.
	var maxlevel : int = charspells.size()
	for lvl in range(1, maxlevel + 1) :
		charspells[lvl - 1].clear()
		for entry in spells_by_level[lvl] :
			if entry["known"] :
				character.add_spell_drom_dict(entry["dict"], lvl)
	character.set_ability_selection_points(char_sp)
	emit_signal("on_closed")
	hide()
