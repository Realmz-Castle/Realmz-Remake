@tool
extends EditorPlugin

## Realmz: Import Scenario Dump
##
## Adds a "Realmz: Import Scenario Dump..." entry under Project > Tools that
## opens a dialog for converting a City of Bywater (or compatible) text dump
## into map_scriptareas.json + map_scripts.gd files for a chosen map level.
##
## See README.md in this folder for usage and the opcode coverage table.

const RealmzImportDialog := preload("res://addons/realmz_dump_importer/import_dialog.gd")

const MENU_ITEM_LABEL := "Realmz: Import Scenario Dump..."

var _dialog

func _enter_tree() -> void:
	add_tool_menu_item(MENU_ITEM_LABEL, _on_menu_item_pressed)

func _exit_tree() -> void:
	remove_tool_menu_item(MENU_ITEM_LABEL)
	if _dialog and is_instance_valid(_dialog):
		_dialog.queue_free()
		_dialog = null

func _on_menu_item_pressed() -> void:
	if _dialog == null or not is_instance_valid(_dialog):
		_dialog = RealmzImportDialog.new()
		EditorInterface.get_base_control().add_child(_dialog)
	_dialog.popup_centered_ratio(0.6)
