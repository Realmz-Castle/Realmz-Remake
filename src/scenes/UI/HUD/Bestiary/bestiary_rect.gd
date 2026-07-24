extends NinePatchRect

# Creature browser. Hosts the creature list (left) plus a CreatureInfoPanel
# (right) that handles the actual stat/resist/abilities/lore display. Selecting
# a creature button calls info_panel.populate(cdata). Closing the panel hides
# the bestiary entirely.

@export var button_tscn : PackedScene  # res://scenes/UI/HUD/Bestiary/bestiary_button.tscn

@export var entrycontainer : VBoxContainer
@export var search_lineedit : LineEdit
@export var info_panel : CreatureInfoPanel

const SELECTED_MODULATE : Color = Color(1.2, 1.15, 0.7, 1)
const UNSELECTED_MODULATE : Color = Color(1, 1, 1, 1)

var _list_seeded : bool = false
var _selected_button : Button = null


func _ready() :
	if info_panel != null :
		info_panel.close_requested.connect(_on_close_requested)
	visibility_changed.connect(_on_visibility_changed)


func _initialize() :
	if _list_seeded :
		return
	var book = NodeAccess.__Resources().crea_book
	var first_button : Button = null
	for c in book :
		if book[c]["data"]["in_bestiary"] > 0 :
			var nb = button_tscn.instantiate()
			nb.set_creature(book[c])
			entrycontainer.add_child(nb)
			nb.connect("pressed", Callable(self, "_on_entry_pressed").bind(nb))
			if first_button == null :
				first_button = nb
	_list_seeded = true
	if first_button != null :
		_select_button(first_button)


func _on_entry_pressed(button : Button) -> void :
	_select_button(button)


func _select_button(button : Button) -> void :
	if _selected_button != null and is_instance_valid(_selected_button) :
		_selected_button.modulate = UNSELECTED_MODULATE
	_selected_button = button
	button.modulate = SELECTED_MODULATE
	if info_panel != null :
		info_panel.populate(button.cdata)


func _on_visibility_changed() -> void :
	if not visible :
		return
	if _selected_button == null or not is_instance_valid(_selected_button) :
		return
	# Wait a frame for layout to settle (especially when the bestiary was just
	# made visible — ScrollContainer needs valid sizes to scroll correctly).
	var scroll = entrycontainer.get_parent()
	if scroll is ScrollContainer :
		await get_tree().process_frame
		scroll.ensure_control_visible(_selected_button)


func _on_close_requested() -> void :
	hide()


func _on_line_edit_text_changed(new_text : String) -> void :
	if new_text.is_empty() :
		for b in entrycontainer.get_children() :
			b.show()
		return
	var searched : String = new_text.to_lower()
	for b in entrycontainer.get_children() :
		b.visible = str(b.cname).to_lower().contains(searched)
