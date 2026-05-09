@tool
extends RefCounted

## Parser for the City of Bywater scenario text dump. The dump is a sequence of
## sections, each starting with a line that begins "===== <KIND> ...".
## Indented lines below a header are opcodes for that section, e.g.:
##
##     ===== LAND AP level=0 id=25 x=16 y=17 to_level=5 to_x=21 to_y=5 [LAP0/25]
##       string                   "...trap door..."#200, no_wait
##       exit_ap
##
## The dump as shipped contains stray null bytes inside string payloads.
## We strip them on read so downstream regex / split logic doesn't choke.
##
## Output schema (per section):
##     {
##         "kind"     : "LAND_AP" | "DUNGEON_AP" | "LAND_RR" | "DUNGEON_RR" | "XAP" | ...,
##         "header"   : original header line (without the "===== " prefix),
##         "fields"   : parsed key=value attrs from the header (level, id, x, y, ...),
##         "tag"      : the [LAPN/I] tag from the header (or "" if none),
##         "opcodes"  : Array of { "name": String, "raw": String, "args": String },
##     }

const KIND_PATTERNS := {
	"LAND_AP": "^LAND AP ",
	"DUNGEON_AP": "^DUNGEON AP ",
	"LAND_RR": "^LAND RANDOM RECTANGLE ",
	"DUNGEON_RR": "^DUNGEON RANDOM RECTANGLE ",
	"XAP": "^XAP ",
	"LAND_MAP": "^LAND MAP ",
	"DUNGEON_MAP": "^DUNGEON MAP ",
	"SIMPLE_ENCOUNTER": "^SIMPLE ENCOUNTER ",
	"COMPLEX_ENCOUNTER": "^COMPLEX ENCOUNTER ",
	"ROGUE_ENCOUNTER": "^ROGUE ENCOUNTER ",
	"BATTLE": "^BATTLE ",
	"MONSTER": "^MONSTER ",
	"ITEM": "^ITEM ",
	"SHOP": "^SHOP ",
	"TREASURE": "^TREASURE ",
	"TILESET": "^TILESET ",
	"GLOBAL_METADATA": "^GLOBAL METADATA",
	"SCENARIO_METADATA": "^SCENARIO METADATA",
	"RESTRICTIONS": "^RESTRICTIONS",
	"NEGATIVE_TILE_PROPERTIES": "^NEGATIVE TILE PROPERTIES",
}

var sections : Array = []  # Array[Dictionary]
var errors : Array = []   # Array[String]

func parse_file(path : String) -> bool:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		errors.append("Could not open dump file: %s (err %d)" % [path, FileAccess.get_open_error()])
		return false
	var raw := f.get_buffer(f.get_length())
	f.close()
	# Strip null bytes — the dump as shipped has interspersed \0 inside strings.
	var cleaned := PackedByteArray()
	cleaned.resize(raw.size())
	var w := 0
	for i in range(raw.size()):
		if raw[i] != 0:
			cleaned[w] = raw[i]
			w += 1
	cleaned.resize(w)
	# Latin-1 round-trips bytes 1:1 — safer than UTF-8 for files with rare junk.
	var text := cleaned.get_string_from_ascii()
	if text.is_empty():
		# get_string_from_ascii fails on bytes >127. Fall back manually.
		text = ""
		for i in range(cleaned.size()):
			text += char(cleaned[i])
	return parse_text(text)

func parse_text(text : String) -> bool:
	sections.clear()
	# Normalize line endings.
	text = text.replace("\r\n", "\n").replace("\r", "\n")
	var lines := text.split("\n", false)
	var current : Dictionary = {}
	for line_raw in lines:
		var line : String = line_raw
		if line.begins_with("===== "):
			if not current.is_empty():
				sections.append(current)
			current = _parse_header(line.substr(6))
			current["opcodes"] = []
		elif current.is_empty():
			continue  # Skip prelude before first header.
		else:
			# Opcode lines start with whitespace.
			var stripped := line.strip_edges(true, false)
			if stripped.is_empty():
				continue
			# An opcode line: leading whitespace then "name<spaces>args".
			# Or for RR sections, free-form "key = value" body lines — treat the
			# whole line as the "raw" value, with name="" (handler-specific).
			var opc := _parse_opcode_line(line)
			if opc.size() > 0:
				current["opcodes"].append(opc)
	if not current.is_empty():
		sections.append(current)
	return true

func _parse_header(after_marker : String) -> Dictionary:
	# after_marker like: 'LAND AP level=0 id=25 x=16 y=17 to_level=5 to_x=21 to_y=5 [LAP0/25]'
	var d : Dictionary = {
		"kind": "",
		"header": after_marker,
		"fields": {},
		"tag": "",
	}
	# Pull out the trailing [TAG] if present.
	var tag_re := RegEx.new()
	tag_re.compile("\\[([^\\]]+)\\]\\s*$")
	var tag_match := tag_re.search(after_marker)
	var body := after_marker
	if tag_match:
		d["tag"] = tag_match.get_string(1)
		body = after_marker.substr(0, tag_match.get_start()).strip_edges()
	# Identify kind by longest matching prefix.
	for k in KIND_PATTERNS:
		var pre : String = KIND_PATTERNS[k]
		# pre is a regex; for prefix matching just use the literal after stripping ^.
		var literal : String = pre.trim_prefix("^").trim_suffix(" ")
		if body == literal or body.begins_with(literal + " ") or body.begins_with(literal):
			d["kind"] = k
			body = body.substr(literal.length()).strip_edges()
			break
	# Parse remaining "key=value" tokens.
	var kv_re := RegEx.new()
	# value may be a quoted string, a number, or an unquoted token (no whitespace, no '=').
	kv_re.compile('([a-zA-Z_][a-zA-Z0-9_]*)=("(?:[^"\\\\]|\\\\.)*"|[^\\s]+)')
	for m in kv_re.search_all(body):
		var key : String = m.get_string(1)
		var val : String = m.get_string(2)
		d["fields"][key] = val
	return d

func _parse_opcode_line(line : String) -> Dictionary:
	# Match "  <name>   <args>" — name is the first token, args the rest.
	var stripped := line.strip_edges(true, false)
	if stripped.is_empty():
		return {}
	var sp := stripped.find(" ")
	var name : String
	var args : String
	if sp == -1:
		name = stripped
		args = ""
	else:
		name = stripped.substr(0, sp)
		args = stripped.substr(sp + 1).strip_edges(true, false)
	return {
		"name": name,
		"args": args,
		"raw": stripped,
	}

# --- Convenience filters ---

func sections_of_kind(kind : String) -> Array:
	var out : Array = []
	for s in sections:
		if s["kind"] == kind:
			out.append(s)
	return out

func land_aps_for_level(level : int) -> Array:
	var out : Array = []
	for s in sections:
		if s["kind"] == "LAND_AP" and int(s["fields"].get("level", "-1")) == level:
			out.append(s)
	return out

func dungeon_aps_for_level(level : int) -> Array:
	var out : Array = []
	for s in sections:
		if s["kind"] == "DUNGEON_AP" and int(s["fields"].get("level", "-1")) == level:
			out.append(s)
	return out

# Enumerate every (kind, level) pair that has at least one AP in the dump.
# Used by the dialog's "Import All" path to drive a one-click bulk import
# without making the user remember which levels exist.
#
# Returns an Array of dictionaries:
#   [{"kind": "LAND_AP" | "DUNGEON_AP", "level": int, "ap_count": int}, ...]
# Sorted by kind (LAND first, DUNGEON second) then by ascending level so the
# log output reads top-to-bottom in a predictable order.
func discover_ap_levels() -> Array:
	# Bucket APs into kind -> level -> count using a nested dict so we can
	# report the AP count per map alongside the (kind, level) tuple.
	var counts : Dictionary = {"LAND_AP": {}, "DUNGEON_AP": {}}
	for s in sections:
		var kind : String = s["kind"]
		if not counts.has(kind):
			continue  # XAP / encounters / monsters / etc. don't drive map files.
		var level := int(s["fields"].get("level", "-1"))
		if level < 0:
			continue  # Defensive — every AP in the dump has a level field.
		counts[kind][level] = int(counts[kind].get(level, 0)) + 1
	var out : Array = []
	# LAND first, then DUNGEON — matches the natural reading order (overworld
	# before dungeons) and groups results visually in the log.
	for kind in ["LAND_AP", "DUNGEON_AP"]:
		var levels : Array = counts[kind].keys()
		levels.sort()
		for lvl in levels:
			out.append({
				"kind": kind,
				"level": lvl,
				"ap_count": counts[kind][lvl],
			})
	return out
