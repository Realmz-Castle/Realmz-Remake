extends Node
## Utilties for handling screen resolution window size etc.
class_name ScreenUtils

const HD: Vector2 = Vector2(1920, 1080)

## Sets the window content_scale_factor to the given value and scales the window size accordingly
static func set_window_scale(node: Node, scale: float) -> void:
	print("setting window scale: ", scale)
	var window = node.get_window()
	var relative_scale:float = scale / window.content_scale_factor
	window.content_scale_factor = scale
	window.size = window.size*relative_scale
	window.move_to_center()

## Returns the window size in logical pixels (not physical pixels)
static func get_logical_window_size(node: Node) -> Vector2:
	var window = node.get_window()
	var scale = window.content_scale_factor

	return window.get_size() / scale

## Returns true if the screen is considered HD
static func screen_is_hd() -> bool:
	var window = DisplayServer.screen_get_size()
	return window.x >= HD.x and window.y >= HD.y

## Platform specific best guess for whether to use HD mode by default
static func get_hd_mode_default() -> bool:
	var is_retina = OS.get_name() == "macOS" and DisplayServer.screen_get_scale() == 2.0

	if is_retina:
		return true
	else:
		if screen_is_hd():
			# Assume 2x scale for high resolution displays
			return true
		# Assume 1x scale for other platforms
		return false
