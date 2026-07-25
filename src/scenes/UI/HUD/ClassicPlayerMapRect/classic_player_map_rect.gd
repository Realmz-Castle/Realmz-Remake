extends ColorRect

signal closed

const PlayerMapRendererScript = preload(
	"res://scripts/classic_runtime/classic_player_map_renderer.gd"
)

@onready var map_texture_rect: TextureRect = $VBoxContainer/MapArea/MapTextureRect
@onready var scrolling_text_background: ColorRect = \
	$VBoxContainer/MapArea/ScrollingTextBackground
@onready var scrolling_text_label: RichTextLabel = \
	$VBoxContainer/MapArea/ScrollingTextLabel
@onready var missing_media_label: Label = $VBoxContainer/MapArea/MissingMediaLabel
@onready var map_name_label: Label = $VBoxContainer/Footer/MapNameLabel
@onready var map_note_label: Label = $VBoxContainer/Footer/MapNoteLabel
@onready var previous_button: Button = $VBoxContainer/Footer/PreviousButton
@onready var next_button: Button = $VBoxContainer/Footer/NextButton
@onready var done_button: Button = $VBoxContainer/Footer/DoneButton

var current_map_record: Dictionary = {}
var map_entries: Array = []
var current_map_index := -1


func display_map(
	map_record: Dictionary,
	image_path: String,
	native_map_name := "",
	current_position: Dictionary = {}
) -> bool:
	map_entries.clear()
	current_map_index = -1
	_update_navigation()
	return _display_map_record(map_record, image_path, native_map_name, current_position)


func display_catalog(entries: Array, preferred_map_id := -1) -> bool:
	map_entries.clear()
	for entry_value: Variant in entries:
		if not (entry_value is Dictionary):
			continue
		var map_record: Variant = entry_value.get("record", {})
		if not (map_record is Dictionary) or map_record.is_empty():
			continue
		map_entries.append(entry_value.duplicate(true))
	if map_entries.is_empty():
		return false
	current_map_index = 0
	if preferred_map_id >= 0:
		for entry_index: int in map_entries.size():
			if int(map_entries[entry_index]["record"].get("id", -1)) == preferred_map_id:
				current_map_index = entry_index
				break
	_update_navigation()
	return _display_catalog_entry()


func _display_catalog_entry() -> bool:
	if current_map_index < 0 or current_map_index >= map_entries.size():
		return false
	var entry: Dictionary = map_entries[current_map_index]
	var runtime_path := str(entry.get("runtimeMediaPath", ""))
	var native_map_name := str(entry.get("nativeMapName", ""))
	var current_position: Dictionary = entry.get("currentPosition", {})
	if _display_map_record(entry["record"], runtime_path, native_map_name, current_position):
		return true
	return _display_map_record(
		entry["record"],
		"",
		native_map_name,
		current_position
	) if not runtime_path.is_empty() else false


func _display_map_record(
	map_record: Dictionary,
	image_path: String,
	native_map_name := "",
	current_position: Dictionary = {}
) -> bool:
	current_map_record = map_record.duplicate(true)
	map_texture_rect.texture = null
	map_texture_rect.visible = false
	scrolling_text_background.visible = false
	scrolling_text_label.bbcode_enabled = false
	scrolling_text_label.text = ""
	scrolling_text_label.visible = false
	missing_media_label.visible = true
	var scrolling_text: Variant = map_record.get("scrollingText")
	if scrolling_text is Dictionary and scrolling_text.get("text") is String:
		var presentation: Variant = scrolling_text.get("presentation")
		if presentation is Dictionary \
				and str(presentation.get("format", "")) == "portable-rich-text-v1":
			scrolling_text_label.bbcode_enabled = true
			scrolling_text_label.text = portable_scrolling_text_bbcode(scrolling_text)
		else:
			scrolling_text_label.text = str(scrolling_text["text"])
		scrolling_text_background.visible = true
		scrolling_text_label.visible = true
		scrolling_text_label.scroll_to_line(0)
		missing_media_label.visible = false
	elif not image_path.is_empty():
		var image := Image.new()
		if image.load(image_path) != OK or image.get_width() <= 0 \
				or image.get_height() <= 0:
			return false
		map_texture_rect.texture = ImageTexture.create_from_image(image)
		map_texture_rect.visible = true
		missing_media_label.visible = false
	elif not native_map_name.is_empty():
		var generated_texture := _render_native_map(
			map_record,
			native_map_name,
			current_position
		)
		if generated_texture != null:
			map_texture_rect.texture = generated_texture
			map_texture_rect.visible = true
			missing_media_label.visible = false
	map_name_label.text = map_display_name(map_record)
	map_note_label.text = str(map_record.get("note", "")).strip_edges()
	show()
	done_button.grab_focus()
	return true


static func portable_scrolling_text_bbcode(scrolling_text: Dictionary) -> String:
	var text := str(scrolling_text.get("text", ""))
	var presentation: Variant = scrolling_text.get("presentation", {})
	if not (presentation is Dictionary) \
			or str(presentation.get("format", "")) != "portable-rich-text-v1":
		return _escape_bbcode(text)
	var runs_value: Variant = presentation.get("runs", [])
	if not (runs_value is Array):
		return _escape_bbcode(text)
	var output := ""
	var cursor := 0
	for run_value: Variant in runs_value:
		if not (run_value is Dictionary):
			continue
		var run: Dictionary = run_value
		var start := clampi(int(run.get("start", cursor)), cursor, text.length())
		var end := clampi(int(run.get("end", start)), start, text.length())
		if start > cursor:
			output += _escape_bbcode(text.substr(cursor, start - cursor))
		if end > start:
			output += _portable_style_run_bbcode(
				text.substr(start, end - start),
				run
			)
		cursor = end
	if cursor < text.length():
		output += _escape_bbcode(text.substr(cursor))
	return output


static func _portable_style_run_bbcode(text: String, run: Dictionary) -> String:
	var prefix := "[color=%s][font_size=%d]" % [
		str(run.get("color", "#ffffff")),
		clampi(int(run.get("fontSize", 18)), 8, 72),
	]
	var suffix := "[/font_size][/color]"
	if bool(run.get("bold", false)):
		prefix += "[b]"
		suffix = "[/b]" + suffix
	if bool(run.get("italic", false)):
		prefix += "[i]"
		suffix = "[/i]" + suffix
	if bool(run.get("underline", false)):
		prefix += "[u]"
		suffix = "[/u]" + suffix
	return prefix + _escape_bbcode(text) + suffix


static func _escape_bbcode(text: String) -> String:
	return text.replace("[", "[lb]")


func close_map() -> void:
	hide()
	closed.emit()


func _update_navigation() -> void:
	var has_multiple_maps := map_entries.size() > 1
	previous_button.disabled = not has_multiple_maps
	next_button.disabled = not has_multiple_maps


static func map_display_name(map_record: Dictionary) -> String:
	for field: String in ["primaryName", "name", "secondaryName"]:
		var field_value: Variant = map_record.get(field)
		if field_value == null:
			continue
		var candidate := str(field_value).strip_edges()
		if not candidate.is_empty():
			return candidate
	return "Player Map %d" % int(map_record.get("id", 0))


func _render_native_map(
	map_record: Dictionary,
	native_map_name: String,
	current_position: Dictionary
) -> ImageTexture:
	var node_access := get_node_or_null("/root/NodeAccess")
	var resources: Object = node_access.call("__Resources") \
		if node_access != null and node_access.has_method("__Resources") else null
	if resources == null:
		return null
	var maps_value: Variant = resources.get("maps_book")
	if not (maps_value is Dictionary) or not maps_value.has(native_map_name):
		return null
	var native_map: Variant = maps_value[native_map_name]
	if not (native_map is Array) or native_map.is_empty() or not (native_map[0] is Array):
		return null
	return PlayerMapRendererScript.render(map_record, native_map[0], current_position)


func _on_done_button_pressed() -> void:
	close_map()


func _on_previous_button_pressed() -> void:
	if map_entries.size() <= 1:
		return
	current_map_index = wrapi(current_map_index - 1, 0, map_entries.size())
	_display_catalog_entry()


func _on_next_button_pressed() -> void:
	if map_entries.size() <= 1:
		return
	current_map_index = wrapi(current_map_index + 1, 0, map_entries.size())
	_display_catalog_entry()
