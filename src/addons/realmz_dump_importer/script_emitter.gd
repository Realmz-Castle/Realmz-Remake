@tool
extends RefCounted

const RealmzDumpParser := preload("res://addons/realmz_dump_importer/dump_parser.gd")

## Emits map_scriptareas.json + map_scripts.gd from parsed RealmzDumpParser
## sections, for one map level at a time.
##
## This first cut handles the most common opcodes one-to-one against helpers
## already in scripts/ScriptHelperFuncs.gd:
##
##   string                   -> display_text_wait_noise
##   set_dungeon (land target) -> teleport_to_map_and_pos_divinity
##   simple_enc               -> display_simple_encounter_Divinity
##   complex_enc              -> start_complex_encounter_Divinity
##   treasure                 -> give_treasure_with_id
##   give_map                 -> give_minimap
##   sound                    -> play_sound_divinity
##   exit_ap                  -> return
##
## Anything else is emitted as a `# TODO[<opcode>]: <raw args>` line so a
## reviewer can spot exactly what still needs hand-translation. The output is
## meant to be a faithful starting point that compiles, not a finished port.

const APS_HEADER := "#Map test Script generated from old AP format"
const SFX_DEFAULT := "'message nod.wav'"

var aps : Array = []          # parsed LAND_AP / DUNGEON_AP records for the chosen level
var rrs : Array = []          # parsed LAND_RR / DUNGEON_RR records for the chosen level
var paths : Array = []        # passthrough — currently empty for new maps
var secrets : Array = []      # passthrough — currently empty for new maps

var json_text : String = ""
var gd_text : String = ""
var unhandled_opcodes : Dictionary = {}  # name -> count (for reporter)

func emit(parser, level : int, dungeon : bool) -> void:
	if dungeon:
		aps = parser.dungeon_aps_for_level(level)
		rrs = _filter_rrs(parser, level, "DUNGEON_RR")
	else:
		aps = parser.land_aps_for_level(level)
		rrs = _filter_rrs(parser, level, "LAND_RR")
	json_text = _build_scriptareas_json()
	gd_text = _build_scripts_gd()

func _filter_rrs(parser, level : int, kind : String) -> Array:
	var out : Array = []
	for s in parser.sections:
		if s["kind"] == kind and int(s["fields"].get("level", "-1")) == level:
			out.append(s)
	return out

# ------------------------------------------------------------------
# JSON output
# ------------------------------------------------------------------

func _build_scriptareas_json() -> String:
	# Match the human-readable indentation style used in existing map_5/map_scriptareas.json.
	var lines : Array[String] = []
	lines.append("{")
	lines.append("")
	lines.append("\"ScriptRects\" : {")
	var entries : Array[String] = []
	for ap in aps:
		entries.append(_json_entry_for_ap(ap))
	for rr in rrs:
		entries.append(_json_entry_for_rr(rr))
	lines.append(",\n".join(entries))
	lines.append("},")
	lines.append('"Paths" : %s,' % JSON.stringify(paths))
	lines.append('"Secrets" : %s' % JSON.stringify(secrets))
	lines.append("}")
	return "\n".join(lines) + "\n"

func _json_entry_for_ap(ap : Dictionary) -> String:
	var id_str := str(ap["fields"].get("id", "?"))
	var x := int(ap["fields"].get("x", "0"))
	var y := int(ap["fields"].get("y", "0"))
	var name := "AP%sx%dy%d" % [id_str, x, y]
	return "   \"%s\":\n   {\n      \"scriptRectangle\": [ [%d,%d], [%d,%d] ],\n      \"scriptToLoad\": \"%s\"\n   }" % [name, x, y, x, y, name]

func _json_entry_for_rr(rr : Dictionary) -> String:
	var lvl := int(rr["fields"].get("level", "0"))
	var id_str := str(rr["fields"].get("id", "?"))
	var x1 := int(rr["fields"].get("x1", "0"))
	var y1 := int(rr["fields"].get("y1", "0"))
	var x2 := int(rr["fields"].get("x2", "0"))
	var y2 := int(rr["fields"].get("y2", "0"))
	# chance="75/10000" — convert to float fraction.
	var chance_raw := str(rr["fields"].get("chance", "0/10000")).trim_prefix("\"").trim_suffix("\"")
	var chance := _parse_chance(chance_raw)
	var name := "LRR%d.%s" % [lvl, id_str]
	# RR_Battle body — the parser stored each opcode line; for RRs the whole body
	# is "battle_range = [a,b], option_chance = N%, ..." which we leave as a TODO
	# for the human importer phase. Just emit the rect + chance for now.
	return "   \"%s\":\n   {\n      \"scriptRectangle\": [ [%d,%d], [%d,%d] ],\n      \"chance\": %s,\n      \"scriptToLoad\": []\n   }" % [name, x1, y1, x2, y2, str(chance)]

func _parse_chance(raw : String) -> float:
	# "75/10000" -> 0.0075
	var parts := raw.split("/")
	if parts.size() == 2 and parts[0].is_valid_int() and parts[1].is_valid_int():
		var num := parts[0].to_int()
		var den := parts[1].to_int()
		if den != 0:
			return float(num) / float(den)
	return 0.0

# ------------------------------------------------------------------
# GDScript output
# ------------------------------------------------------------------

func _build_scripts_gd() -> String:
	unhandled_opcodes.clear()
	var lines : Array[String] = []
	lines.append(APS_HEADER)
	lines.append("")
	lines.append("static func _on_map_load(_map) :")
	lines.append("\tprint(\"mapscript _on_map_load() !!! \")")
	lines.append("\t# Add any initialization code here")
	lines.append("")
	for ap in aps:
		lines.append_array(_emit_ap(ap))
		lines.append("")
	return "\n".join(lines)

func _emit_ap(ap : Dictionary) -> Array:
	var id_str := str(ap["fields"].get("id", "?"))
	var x := int(ap["fields"].get("x", "0"))
	var y := int(ap["fields"].get("y", "0"))
	var name := "AP%sx%dy%d" % [id_str, x, y]
	var lines : Array = []
	lines.append("static func %s() : #%s at %d,%d" % [name, id_str, x, y])
	# If the AP has a to_level/to_x/to_y header, emit a teleport hint comment.
	var fields : Dictionary = ap["fields"]
	if fields.has("to_level") and fields.has("to_x") and fields.has("to_y"):
		lines.append("\t# Header teleport: to_level=%s to_x=%s to_y=%s" % [fields["to_level"], fields["to_x"], fields["to_y"]])
		lines.append("\tScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(%s, %s, %s, 0)" % [fields["to_level"], fields["to_x"], fields["to_y"]])
	var emitted_anything := fields.has("to_level")
	for opc in ap["opcodes"]:
		var rendered := _emit_opcode(opc)
		if rendered.is_empty():
			continue
		for r in rendered:
			lines.append("\t" + r)
		emitted_anything = true
	if not emitted_anything:
		lines.append("\tpass")
	lines.append("\treturn")
	return lines

func _emit_opcode(opc : Dictionary) -> Array:
	var name : String = opc["name"]
	var args : String = opc["args"]
	match name:
		"exit_ap":
			# `return` is appended unconditionally at the end of every AP, so
			# emitting nothing for an explicit exit_ap is fine.
			return []
		"string":
			return [_emit_string(args)]
		"sound":
			return [_emit_sound(args)]
		"set_dungeon":
			return _emit_set_dungeon(args)
		"simple_enc":
			return ["await ScriptHelperFuncsClass.display_simple_encounter_Divinity(%s)" % _strip_prefix_int(args, "SEC")]
		"complex_enc":
			return ["await ScriptHelperFuncsClass.start_complex_encounter_Divinity(%s)" % _strip_prefix_int(args, "CEC")]
		"treasure":
			return ["await ScriptHelperFuncsClass.give_treasure_with_id(%s)" % _strip_prefix_int(args, "TSR")]
		"give_map":
			return ["ScriptHelperFuncsClass.give_minimap(%s)" % args.strip_edges()]
		"enable_dungeon_map", "disable_dungeon_map":
			return ["# TODO[%s]: %s" % [name, args]]
		_:
			unhandled_opcodes[name] = int(unhandled_opcodes.get(name, 0)) + 1
			return ["# TODO[%s]: %s" % [name, args]]

func _emit_string(args : String) -> String:
	# args looks like:  "...text..."#200, no_wait
	# or                "...text..."
	# or                0   (meaning "no string" — original game uses sentinel)
	var s := args.strip_edges()
	if s == "0":
		return "# TODO[string]: sentinel-zero (no text)"
	# Pull out the quoted body.
	var first_q := s.find('"')
	if first_q == -1:
		return "# TODO[string]: %s" % s
	# Find matching unescaped close quote.
	var i := first_q + 1
	while i < s.length():
		var c := s[i]
		if c == "\\":
			i += 2
			continue
		if c == '"':
			break
		i += 1
	if i >= s.length():
		return "# TODO[string]: %s" % s
	var body := s.substr(first_q + 1, i - first_q - 1)
	# Convert to a single-quoted GDScript literal, escaping single quotes and
	# leaving existing escape sequences alone.
	var literal := _to_gd_single_quoted(body)
	return "await ScriptHelperFuncsClass.display_text_wait_noise(%s, %s)" % [literal, SFX_DEFAULT]

func _to_gd_single_quoted(body : String) -> String:
	# Existing files emit single-quoted strings with embedded \" escapes intact.
	# We don't need to re-escape inner double-quotes (since we wrap in single
	# quotes), but we must escape literal single quotes and backslashes.
	var out := ""
	var i := 0
	while i < body.length():
		var c := body[i]
		if c == "\\" and i + 1 < body.length():
			# Pass through original escape (e.g. \" or \\) unchanged.
			out += body.substr(i, 2)
			i += 2
			continue
		if c == "'":
			out += "\\'"
		else:
			out += c
		i += 1
	return "'" + out + "'"

func _emit_sound(args : String) -> String:
	# args looks like:  30000           or  30000, pause
	var first := args.split(",")[0].strip_edges()
	if first.is_valid_int():
		return "ScriptHelperFuncsClass.play_sound_divinity(%s)" % first
	return "# TODO[sound]: %s" % args

func _emit_set_dungeon(args : String) -> Array:
	# args:  1(land), level=5, x=21, y=5, dir=0
	# or     0(dungeon), level=N, x=X, y=Y, dir=D    (we don't have a divinity
	# helper for dungeon-target teleports yet — emit TODO for those)
	var mode_re := RegEx.new()
	mode_re.compile("^(\\d+)\\(([a-zA-Z]+)\\)")
	var m := mode_re.search(args)
	if m == null:
		return ["# TODO[set_dungeon]: %s" % args]
	var dest_kind : String = m.get_string(2)
	if dest_kind != "land":
		return ["# TODO[set_dungeon to %s]: %s" % [dest_kind, args]]
	var lvl : int = _kv_int(args, "level")
	var tx : int = _kv_int(args, "x")
	var ty : int = _kv_int(args, "y")
	if lvl < 0 or tx < 0 or ty < 0:
		return ["# TODO[set_dungeon]: %s" % args]
	return ["ScriptHelperFuncsClass.teleport_to_map_and_pos_divinity(%d, %d, %d, 0)" % [lvl, tx, ty]]

# ------------------------------------------------------------------
# helpers
# ------------------------------------------------------------------

func _strip_prefix_int(s : String, prefix : String) -> String:
	var t := s.strip_edges()
	if t.begins_with(prefix):
		return t.substr(prefix.length())
	return t  # leave as-is; review will catch it

func _kv_int(args : String, key : String) -> int:
	# Returns the int value of `key=N` in `args`, or -1 if missing/unparseable.
	var re := RegEx.new()
	re.compile("\\b%s=(-?\\d+)" % key)
	var m := re.search(args)
	if m == null:
		return -1
	return m.get_string(1).to_int()
