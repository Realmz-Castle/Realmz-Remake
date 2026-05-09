@tool
extends AcceptDialog

const RealmzDumpParser := preload("res://addons/realmz_dump_importer/dump_parser.gd")
const RealmzScriptEmitter := preload("res://addons/realmz_dump_importer/script_emitter.gd")

## Modal dialog for the Realmz scenario dump importer.
##
## Default flow ("Import All"):
##   1. User picks a dump file + campaign Maps dir.
##   2. Parser auto-discovers every (LAND/DUNGEON, level) pair with APs.
##   3. For each pair, route LAND -> map_<N>/, DUNGEON -> mapd_<N>/.
##   4. Skip already-ported maps (heuristic: existing map_scripts.gd has many
##      `static func` defs) unless "Force overwrite" is on. This protects the
##      hand-ported map_0 by default.
##   5. Each map's outcome (WRITTEN / SKIPPED / ERROR) is summarised in a log
##      table.
##
## Advanced mode (toggle reveals controls): single-map override for cases where
## a maintainer wants to regenerate one specific level instead of the whole set.

const DEFAULT_CAMPAIGN_PATH := "res://Campaigns/City of Bywater/Maps/"

# Threshold for the "this map is already ported, don't clobber it" heuristic.
# map_0 has 95 LAP funcs + 168 XAP funcs (263 total) so anything well past the
# scaffolding count is treated as a hand-port we should preserve. Maps that the
# importer itself has filled previously will have AP-count-many funcs (e.g. 97
# for map_5), so the threshold also keeps generated content stable across
# re-runs. "Force overwrite" bypasses this.
const ALREADY_PORTED_FUNC_THRESHOLD := 20

var _dump_path_label : Label
var _campaign_path_edit : LineEdit
var _force_overwrite_check : CheckBox
var _dry_run_check : CheckBox
var _advanced_toggle : CheckBox
var _advanced_panel : VBoxContainer
var _single_map_check : CheckBox
var _level_spin : SpinBox
var _kind_options : OptionButton  # 0 = LAND, 1 = DUNGEON
var _log : TextEdit
var _file_dialog : FileDialog

var _run_count : int = 0

func _init() -> void:
	title = "Realmz: Import Scenario Dump"
	min_size = Vector2(720, 600)
	# Stay open after a click — the user often wants to tweak settings and
	# re-run, or read the log table after the import finishes.
	dialog_hide_on_ok = false
	get_ok_button().text = "Import All"
	add_button("Pick Dump File...", true, "pick_file")
	add_cancel_button("Close")

	var vbox := VBoxContainer.new()
	add_child(vbox)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# --- Inputs ---
	vbox.add_child(_make_path_row("Dump file:", "(none — click Pick Dump File...)", true))
	vbox.add_child(_make_campaign_row())

	# Force-overwrite is OFF by default — a fresh contributor running the
	# importer should not be one click away from wiping the hand-ported map_0.
	_force_overwrite_check = CheckBox.new()
	_force_overwrite_check.text = "Force overwrite (bypass already-ported skip — DANGEROUS for map_0)"
	_force_overwrite_check.button_pressed = false
	vbox.add_child(_force_overwrite_check)

	# Dry-run is ON by default — user sees a preview before committing to disk.
	_dry_run_check = CheckBox.new()
	_dry_run_check.text = "Dry-run (preview only — print to log, don't write files)"
	_dry_run_check.button_pressed = true
	vbox.add_child(_dry_run_check)

	# Advanced toggle — hides the per-map controls in the default flow so the
	# UI surface for "import everything" is just two paths and two checkboxes.
	_advanced_toggle = CheckBox.new()
	_advanced_toggle.text = "Show advanced options (single-map mode)"
	_advanced_toggle.toggled.connect(_on_advanced_toggled)
	vbox.add_child(_advanced_toggle)

	_advanced_panel = _build_advanced_panel()
	_advanced_panel.visible = false  # Hidden until the toggle is checked.
	vbox.add_child(_advanced_panel)

	# --- Log ---
	_log = TextEdit.new()
	_log.editable = false
	_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_log.text = "Ready. Pick a dump file and choose Import All (or enable advanced mode for single-map)."
	vbox.add_child(_log)

	# --- File picker ---
	_file_dialog = FileDialog.new()
	_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.add_filter("*.txt", "Text dump")
	_file_dialog.add_filter("*", "All files")
	_file_dialog.file_selected.connect(_on_dump_picked)
	add_child(_file_dialog)

	custom_action.connect(_on_custom_action)
	confirmed.connect(_on_confirmed)

# --- UI builders ----------------------------------------------------

func _make_path_row(label_text : String, default_value : String, is_dump_path : bool) -> HBoxContainer:
	var row := HBoxContainer.new()
	var lbl := Label.new()
	lbl.text = label_text
	lbl.custom_minimum_size = Vector2(140, 0)
	row.add_child(lbl)
	if is_dump_path:
		_dump_path_label = Label.new()
		_dump_path_label.text = default_value
		_dump_path_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(_dump_path_label)
	return row

func _make_campaign_row() -> HBoxContainer:
	var row := HBoxContainer.new()
	var lbl := Label.new()
	lbl.text = "Campaign Maps dir:"
	lbl.custom_minimum_size = Vector2(140, 0)
	row.add_child(lbl)
	_campaign_path_edit = LineEdit.new()
	_campaign_path_edit.text = DEFAULT_CAMPAIGN_PATH
	_campaign_path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Tooltip clarifies the cross-scenario reuse story: just point this at a
	# different scenario's Maps folder and the importer works for it too.
	_campaign_path_edit.tooltip_text = "Root containing the map_<N> / mapd_<N> folders. Change this to import a different scenario."
	row.add_child(_campaign_path_edit)
	return row

func _build_advanced_panel() -> VBoxContainer:
	var panel := VBoxContainer.new()
	# Divider so the advanced section visually separates from the main flow.
	var sep := HSeparator.new()
	panel.add_child(sep)

	_single_map_check = CheckBox.new()
	_single_map_check.text = "Single-map mode (only import the chosen level + kind below)"
	_single_map_check.button_pressed = false
	panel.add_child(_single_map_check)

	var sel_row := HBoxContainer.new()
	panel.add_child(sel_row)
	var lvl_lbl := Label.new()
	lvl_lbl.text = "Level:"
	lvl_lbl.custom_minimum_size = Vector2(140, 0)
	sel_row.add_child(lvl_lbl)
	_level_spin = SpinBox.new()
	_level_spin.min_value = 0
	_level_spin.max_value = 20
	_level_spin.value = 5
	sel_row.add_child(_level_spin)
	_kind_options = OptionButton.new()
	_kind_options.add_item("LAND (-> map_<N>/)", 0)
	_kind_options.add_item("DUNGEON (-> mapd_<N>/)", 1)
	_kind_options.selected = 0
	sel_row.add_child(_kind_options)

	return panel

# --- Signal handlers -------------------------------------------------

func _on_advanced_toggled(pressed : bool) -> void:
	_advanced_panel.visible = pressed

func _on_custom_action(action : StringName) -> void:
	# The "Pick Dump File..." button is registered as a custom action on the
	# dialog; this routes it to the file picker.
	if String(action) == "pick_file":
		_file_dialog.popup_centered_ratio(0.7)

func _on_dump_picked(path : String) -> void:
	_dump_path_label.text = path
	_log_line("Selected dump: %s" % path)

func _on_confirmed() -> void:
	# Stamp every run so a user clicking Import N times always sees a visible
	# change in the log even when results are identical to the previous run.
	_run_count += 1
	_log.text = "=== Run #%d @ %s ===" % [_run_count, Time.get_time_string_from_system()]

	var dump_path := _dump_path_label.text
	if not FileAccess.file_exists(dump_path):
		_log_line("ERROR: dump path is not a file: %s" % dump_path)
		return

	# Parse the dump once. The parser builds a list of section records covering
	# the whole file (~38k lines for CoB). Re-using one parser instance for all
	# (kind, level) emits is much cheaper than re-reading the file per map.
	var parser := RealmzDumpParser.new()
	_log_line("Parsing %s ..." % dump_path)
	if not parser.parse_file(dump_path):
		for e in parser.errors:
			_log_line("  parse error: %s" % e)
		return
	_log_line("  -> %d sections parsed" % parser.sections.size())

	# Decide which (kind, level) pairs to process. Single-map mode emits exactly
	# one tuple; the default mode auto-discovers everything in the dump.
	var targets : Array = _resolve_targets(parser)
	if targets.is_empty():
		_log_line("Nothing to import — the dump has no APs for the requested target(s).")
		return

	var camp_dir : String = _campaign_path_edit.text.rstrip("/")
	var force : bool = _force_overwrite_check.button_pressed
	var dry_run : bool = _dry_run_check.button_pressed
	_log_line("Mode: %s%s" % ["DRY-RUN " if dry_run else "WRITE ", "(force overwrite)" if force else "(skip already-ported)"])
	_log_line("")  # Blank line before the result table.
	_log_line("%-8s %-8s %-8s %s" % ["MAP", "KIND", "APs", "RESULT"])

	# Process each target. We always do this in a loop even when there's only
	# one target (single-map mode) so the result-table rendering and skip logic
	# stay identical — fewer code paths means fewer bugs.
	for t in targets:
		_process_one(parser, t, camp_dir, force, dry_run)

	_log_line("")
	_log_line("Done.")

# --- Core import -----------------------------------------------------

# Build the list of (kind, level) targets to process. Either the single-map
# selection from the advanced panel, or every level in the dump.
func _resolve_targets(parser) -> Array:
	if _advanced_toggle.button_pressed and _single_map_check.button_pressed:
		var kind_id : int = _kind_options.get_selected_id()
		# Map the OptionButton id back to the same string the parser uses so the
		# same downstream code handles both single-map and import-all paths.
		var kind_str : String = "LAND_AP" if kind_id == 0 else "DUNGEON_AP"
		var level := int(_level_spin.value)
		var ap_list : Array = parser.land_aps_for_level(level) if kind_id == 0 else parser.dungeon_aps_for_level(level)
		return [{"kind": kind_str, "level": level, "ap_count": ap_list.size()}]
	# Default: discover every (kind, level) the dump declares APs for.
	return parser.discover_ap_levels()

func _process_one(parser, target : Dictionary, camp_dir : String, force : bool, dry_run : bool) -> void:
	var kind_str : String = target["kind"]
	var level : int = target["level"]
	var ap_count : int = target["ap_count"]
	var dungeon : bool = kind_str == "DUNGEON_AP"

	# Folder convention:
	#   LAND  level=N -> map_<N>/   (overworld + interior land maps)
	#   DUNGEON level=N -> mapd_<N>/ (proper dungeons)
	# This matches the existing project layout: map_0..map_8 are LAND, mapd_0
	# and mapd_1 are DUNGEON. Other scenarios may have different counts but the
	# same folder convention.
	var folder_name : String = ("mapd_%d" if dungeon else "map_%d") % level
	var map_folder : String = "%s/%s" % [camp_dir, folder_name]
	var json_path : String = "%s/map_scriptareas.json" % map_folder
	var gd_path : String = "%s/map_scripts.gd" % map_folder

	# Run the emitter for this (level, kind). Each call rebuilds json_text +
	# gd_text on the emitter; we sample those right after.
	var emitter := RealmzScriptEmitter.new()
	emitter.emit(parser, level, dungeon)

	var label : String = "%-8s %-8s %-8d" % [folder_name, "DUNGEON" if dungeon else "LAND", ap_count]

	# Skip-if-already-ported gate. Reads the existing map_scripts.gd and counts
	# `static func` defs; if it's well past the scaffolding count, assume the
	# map has been hand-ported (or generated previously) and don't clobber.
	if not force and not dry_run:
		var existing_funcs : int = _count_existing_funcs(gd_path)
		if existing_funcs >= ALREADY_PORTED_FUNC_THRESHOLD:
			_log_line("%s SKIPPED (already ported: %d funcs — use Force overwrite to regenerate)" % [label, existing_funcs])
			return

	if dry_run:
		# Per-target dry-run line — no file is touched, but we report the size
		# of what would have been written so the user can spot suspiciously
		# small or empty outputs.
		_log_line("%s DRY-RUN (json %d B, gd %d B; %d unhandled opcodes)" % [
			label, emitter.json_text.length(), emitter.gd_text.length(), emitter.unhandled_opcodes.size()
		])
		return

	# Make sure the target map folder exists. We don't auto-create it: if the
	# project doesn't have a map_<N> folder, that's a project-layout question
	# the importer shouldn't silently answer.
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(map_folder)):
		_log_line("%s ERROR (target folder missing: %s)" % [label, map_folder])
		return

	if not _write_file(json_path, emitter.json_text):
		_log_line("%s ERROR (could not write %s)" % [label, json_path])
		return
	if not _write_file(gd_path, emitter.gd_text):
		_log_line("%s ERROR (could not write %s)" % [label, gd_path])
		return
	_log_line("%s WRITTEN (%d unhandled opcodes left as TODO comments)" % [label, emitter.unhandled_opcodes.size()])

# Count `static func` definitions in an existing map_scripts.gd. Used by the
# already-ported skip heuristic — the count is a coarse proxy for "has someone
# put real work into this file".
func _count_existing_funcs(path : String) -> int:
	if not FileAccess.file_exists(path):
		return 0
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return 0
	var content : String = f.get_as_text()
	f.close()
	# Multiline regex: every line that starts with `static func` counts as one
	# function. This catches both APs and XAPs in the existing hand-port.
	var re := RegEx.new()
	re.compile("(?m)^static func ")
	return re.search_all(content).size()

func _write_file(path : String, content : String) -> bool:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		_log_line("  open-for-write failed (%s, err %d)" % [path, FileAccess.get_open_error()])
		return false
	f.store_string(content)
	f.close()
	return true

func _log_line(s : String) -> void:
	_log.text += "\n" + s
	# scroll_vertical is in pixels in Godot 4; positioning the caret on the
	# last line is the reliable way to keep newest output visible.
	_log.set_caret_line(_log.get_line_count() - 1)
