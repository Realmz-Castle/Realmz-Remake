extends Node
## Utilties for handling screen resolution window size etc.
class_name ScreenUtils
static func set_window_scale(node: Node, scale: float):
	print("setting window scale: ", scale)
	var window = node.get_window()
	var relative_scale:float = scale / window.content_scale_factor
	window.content_scale_factor = scale
	window.size = window.size*relative_scale

static func get_logical_window_size(node: Node):
	var screen = DisplayServer.get_primary_screen()
	var scale = DisplayServer.screen_get_scale(screen)
	var window = node.get_window()

	return window.get_size() / scale
