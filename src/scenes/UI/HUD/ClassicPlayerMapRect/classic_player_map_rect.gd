extends ColorRect

signal closed

@onready var map_texture_rect: TextureRect = $VBoxContainer/MapArea/MapTextureRect
@onready var map_name_label: Label = $VBoxContainer/Footer/MapNameLabel
@onready var map_note_label: Label = $VBoxContainer/Footer/MapNoteLabel
@onready var done_button: Button = $VBoxContainer/Footer/DoneButton

var current_map_record: Dictionary = {}


func display_map(map_record: Dictionary, image_path: String) -> bool:
	var image := Image.new()
	if image.load(image_path) != OK or image.get_width() <= 0 or image.get_height() <= 0:
		return false
	var texture := ImageTexture.create_from_image(image)
	current_map_record = map_record.duplicate(true)
	map_texture_rect.texture = texture
	map_name_label.text = map_display_name(map_record)
	map_note_label.text = str(map_record.get("note", "")).strip_edges()
	show()
	done_button.grab_focus()
	return true


func close_map() -> void:
	hide()
	closed.emit()


static func map_display_name(map_record: Dictionary) -> String:
	for field: String in ["primaryName", "name", "secondaryName"]:
		var candidate := str(map_record.get(field, "")).strip_edges()
		if not candidate.is_empty():
			return candidate
	return "Player Map %d" % int(map_record.get("id", 0))


func _on_done_button_pressed() -> void:
	close_map()
