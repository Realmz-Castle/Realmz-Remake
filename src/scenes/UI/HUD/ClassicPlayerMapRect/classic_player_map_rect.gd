extends ColorRect

signal closed

@onready var map_texture_rect: TextureRect = $VBoxContainer/MapArea/MapTextureRect
@onready var missing_media_label: Label = $VBoxContainer/MapArea/MissingMediaLabel
@onready var map_name_label: Label = $VBoxContainer/Footer/MapNameLabel
@onready var map_note_label: Label = $VBoxContainer/Footer/MapNoteLabel
@onready var previous_button: Button = $VBoxContainer/Footer/PreviousButton
@onready var next_button: Button = $VBoxContainer/Footer/NextButton
@onready var done_button: Button = $VBoxContainer/Footer/DoneButton

var current_map_record: Dictionary = {}
var map_entries: Array = []
var current_map_index := -1


func display_map(map_record: Dictionary, image_path: String) -> bool:
	map_entries.clear()
	current_map_index = -1
	_update_navigation()
	return _display_map_record(map_record, image_path)


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
	if _display_map_record(entry["record"], runtime_path):
		return true
	return _display_map_record(entry["record"], "") if not runtime_path.is_empty() else false


func _display_map_record(map_record: Dictionary, image_path: String) -> bool:
	current_map_record = map_record.duplicate(true)
	map_texture_rect.texture = null
	map_texture_rect.visible = false
	missing_media_label.visible = true
	if not image_path.is_empty():
		var image := Image.new()
		if image.load(image_path) != OK or image.get_width() <= 0 \
				or image.get_height() <= 0:
			return false
		map_texture_rect.texture = ImageTexture.create_from_image(image)
		map_texture_rect.visible = true
		missing_media_label.visible = false
	map_name_label.text = map_display_name(map_record)
	map_note_label.text = str(map_record.get("note", "")).strip_edges()
	show()
	done_button.grab_focus()
	return true


func close_map() -> void:
	hide()
	closed.emit()


func _update_navigation() -> void:
	var has_multiple_maps := map_entries.size() > 1
	previous_button.disabled = not has_multiple_maps
	next_button.disabled = not has_multiple_maps


static func map_display_name(map_record: Dictionary) -> String:
	for field: String in ["primaryName", "name", "secondaryName"]:
		var candidate := str(map_record.get(field, "")).strip_edges()
		if not candidate.is_empty():
			return candidate
	return "Player Map %d" % int(map_record.get("id", 0))


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
