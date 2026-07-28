class_name ScenarioPresentationHandler
extends ClassicOpcodeHandler


func _init() -> void:
	configure("core.presentation", PackedInt32Array([1, 9, 19, 26, 27, 62]))


func execute_on_runtime(instruction: Dictionary, runtime: Object) -> Dictionary:
	var code := int(instruction.get("code", 0))
	var record_id := int(instruction.get("id", 0))
	match code:
		1:
			return _invoke(runtime, "_yield_result", ["show_text", {
				"messageId": record_id,
				"message": runtime.bundle.get_message(record_id),
			}])
		9:
			return _invoke(runtime, "_yield_result", ["play_sound", {
				"soundId": record_id,
				"sound": runtime.bundle.get_sound(record_id),
			}])
		19:
			return _invoke(runtime, "_execute_random_text", [record_id])
		26:
			return _invoke(runtime, "_yield_result", ["wait_for_click", {
				"prompt": "Click Mouse",
				"soundId": 30005,
			}])
		27:
			return _invoke(runtime, "_yield_result", ["show_picture", {
				"pictureId": abs(record_id),
				"picture": runtime.bundle.get_picture(record_id),
			}])
		62:
			return _invoke(runtime, "_execute_scrolling_text", [record_id])
	return _unsupported(instruction)
