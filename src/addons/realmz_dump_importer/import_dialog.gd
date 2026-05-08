@tool
extends AcceptDialog

const RealmzDumpParser := preload("res://addons/realmz_dump_importer/dump_parser.gd")
const RealmzScriptEmitter := preload("res://addons/realmz_dump_importer/script_emitter.gd")

## Modal dialog for the Realmz scenario dump importer. Lets the user pick a
## dump file, choose a target campaign + level + map kind (LAND or DUNGEON),
## preview what would be written, and either copy the output to the clipboard
## (dry-run) or write it directly into the campaign's Maps folder.

const DEFAULT_CAMPAIGN_PATH := "res://Campaigns/City of Bywater/Maps/"

var _dump_path_label : Label
var _campaign_path_edit : LineEdit
var _level_spin : SpinBox
var _kind_options : OptionButton  # 0 = LAND, 1 = DUNGEON
var _dry_run_check : CheckBox
var _log : TextEdit
var _file_dialog : FileDialog

var _last_emitter

func _init() -> void:
	title = "Realmz: Import Scenario Dump"
	min_size = Vector2(640, 540)
	dialog_hide_on_ok = false
	get_ok_button().text = "Import"
	add_button("Pick Dump File...", true, "pick_file")
	add_cancel_button("Close")

	var vbox := VBoxContainer.new()
	add_child(vbox)
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Dump path row
	var dump_row := HBoxContainer.new()
	vbox.add_child(dump_row)
	var dump_lbl := Label.new()
	dump_lbl.text = "Dump file:"
	dump_lbl.custom_minimum_size = Vector2(120, 0)
	dump_row.add_child(dump_lbl)
	_dump_path_label = Label.new()
	_dump_path_label.text = "(none — click Pick Dump File...)"
	_dump_path_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dump_row.add_child(_dump_path_label)

	# Campaign path row
	var camp_row := HBoxContainer.new()
	vbox.add_child(camp_row)
	var camp_lbl := Label.new()
	camp_lbl.text = "Campaign Maps dir:"
	camp_lbl.custom_minimum_size = Vector2(120, 0)
	camp_row.add_child(camp_lbl)
	_campaign_path_edit = LineEdit.new()
	_campaign_path_edit.text = DEFAULT_CAMPAIGN_PATH
	_campaign_path_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	camp_row.add_child(_campaign_path_edit)

	# Level / Kind row
	var sel_row := HBoxContainer.new()
	vbox.add_child(sel_row)
	var lvl_lbl := Label.new()
	lvl_lbl.text = "Level:"
	lvl_lbl.custom_minimum_size = Vector2(120, 0)
	sel_row.add_child(lvl_lbl)
	_level_spin = SpinBox.new()
	_level_spin.min_value = 0
	_level_spin.max_value = 20
	_level_spin.value = 5
	sel_row.add_child(_level_spin)
	_kind_options = OptionButton.new()
	_kind_options.add_item("LAND (outdoor / interior)", 0)
	_kind_options.add_item("DUNGEON", 1)
	_kind_options.selected = 0
	sel_row.add_child(_kind_options)

	# Dry-run row
	_dry_run_check = CheckBox.new()
	_dry_run_check.text = "Dry-run (preview only — print to log, don't write files)"
	_dry_run_check.button_pressed = true
	vbox.add_child(_dry_run_check)

	# Log
	_log = TextEdit.new()
	_log.editable = false
	_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_log.text = "Ready. Pick a dump file and choose Import."
	vbox.add_child(_log)

	# File dialog
	_file_dialog = FileDialog.new()
	_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.add_filter("*.txt", "Text dump")
	_file_dialog.add_filter("*", "All files")
	_file_dialog.file_selected.connect(_on_dump_picked)
	add_child(_file_dialog)

	custom_action.connect(_on_custom_action)
	confirmed.connect(_on_confirmed)

func _on_custom_action(action : StringName) -> void:
	if String(action) == "pick_file":
		_file_dialog.popup_centered_ratio(0.7)

func _on_dump_picked(path : String) -> void:
	_dump_path_label.text = path
	_log_line("Selected dump: %s" % path)

func _on_confirmed() -> void:
	var dump_path := _dump_path_label.text
	if not FileAccess.file_exists(dump_path):
		_log_line("ERROR: dump path is not a file: %s" % dump_path)
		return

	var parser := RealmzDumpParser.new()
	_log_line("Parsing %s ..." % dump_path)
	if not parser.parse_file(dump_path):
		for e in parser.errors:
			_log_line("  parse error: %s" % e)
		return
	_log_line("  -> %d sections parsed" % parser.sections.size())

	var emitter := RealmzScriptEmitter.new()
	var level := int(_level_spin.value)
	var dungeon := _kind_options.get_selected_id() == 1
	emitter.emit(parser, level, dungeon)
	_last_emitter = emitter

	_log_line("APs for %s level=%d: %d   RRs: %d" % ["DUNGEON" if dungeon else "LAND", level, emitter.aps.size(), emitter.rrs.size()])
	if emitter.unhandled_opcodes.size() > 0:
		_log_line("Unhandled opcodes (left as TODO comments):")
		var keys := emitter.unhandled_opcodes.keys()
		keys.sort()
		for k in keys:
			_log_line("  %s : %d occurrences" % [k, emitter.unhandled_opcodes[k]])

	var camp_dir := _campaign_path_edit.text.rstrip("/")
	var map_folder := "%s/map_%d" % [camp_dir, level]
	var json_path := "%s/map_scriptareas.json" % map_folder
	var gd_path := "%s/map_scripts.gd" % map_folder

	if _dry_run_check.button_pressed:
		_log_line("Dry-run: would write %s (%d bytes)" % [json_path, emitter.json_text.length()])
		_log_line("Dry-run: would write %s (%d bytes)" % [gd_path, emitter.gd_text.length()])
		_log_line("--- map_scriptareas.json preview (first 800 chars) ---")
		_log_line(emitter.json_text.substr(0, 800))
		_log_line("--- map_scripts.gd preview (first 800 chars) ---")
		_log_line(emitter.gd_text.substr(0, 800))
		return

	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(map_folder)):
		_log_line("ERROR: target folder does not exist: %s" % map_folder)
		return

	if not _write_file(json_path, emitter.json_text):
		return
	if not _write_file(gd_path, emitter.gd_text):
		return
	_log_line("Wrote %s and %s. Resave the open scene / re-enter map to refresh." % [json_path, gd_path])

func _write_file(path : String, content : String) -> bool:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		_log_line("ERROR: could not open %s for writing (err %d)" % [path, FileAccess.get_open_error()])
		return false
	f.store_string(content)
	f.close()
	return true

func _log_line(s : String) -> void:
	_log.text += "\n" + s
	_log.scroll_vertical = _log.get_line_count()
