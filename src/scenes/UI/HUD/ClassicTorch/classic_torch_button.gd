class_name ClassicTorchButton
extends Button

const FLAME_FRAMES: Array[Texture2D] = [
	preload("res://scenes/UI/HUD/ClassicTorch/classic_torch_146.png"),
	preload("res://scenes/UI/HUD/ClassicTorch/classic_torch_147.png"),
	preload("res://scenes/UI/HUD/ClassicTorch/classic_torch_148.png"),
	preload("res://scenes/UI/HUD/ClassicTorch/classic_torch_149.png"),
	preload("res://scenes/UI/HUD/ClassicTorch/classic_torch_150.png"),
	preload("res://scenes/UI/HUD/ClassicTorch/classic_torch_151.png"),
	preload("res://scenes/UI/HUD/ClassicTorch/classic_torch_152.png"),
	preload("res://scenes/UI/HUD/ClassicTorch/classic_torch_153.png"),
]
const FUEL_MARKER: Texture2D = preload(
	"res://scenes/UI/HUD/ClassicTorch/classic_torch_154.png"
)
const FRAME_INTERVAL := 1.0 / 6.0
const FLAME_BASE_Y := 36
const FUEL_BASE_Y := 60
const FUEL_STEP := 7

var _classic_active := false
var _light_condition := 0
var _has_torch := false
var _flame_stage := 0
var _frame_elapsed := 0.0


func _process(delta: float) -> void:
	if not visible or _light_condition <= 0:
		return
	_frame_elapsed += delta
	if _frame_elapsed < FRAME_INTERVAL:
		return
	var advanced_frames := int(floor(_frame_elapsed / FRAME_INTERVAL))
	_frame_elapsed -= float(advanced_frames) * FRAME_INTERVAL
	_flame_stage = (_flame_stage + advanced_frames) % FLAME_FRAMES.size()
	queue_redraw()


func sync_status(
	classic_active: bool,
	light_condition: int,
	has_torch: bool,
	can_activate: bool
) -> void:
	_classic_active = classic_active
	_light_condition = max(0, light_condition)
	_has_torch = has_torch
	visible = _classic_active
	disabled = not can_activate
	if _light_condition > 0:
		tooltip_text = (
			"Light is active. Click to use another Torch."
			if can_activate
			else "Light is active; no Torch is available."
		)
	elif _has_torch:
		tooltip_text = (
			"Light a Torch"
			if can_activate
			else "Return to exploration to light a Torch."
		)
	else:
		tooltip_text = "No Torches in party inventory."
	if _light_condition <= 0:
		_flame_stage = 0
		_frame_elapsed = 0.0
	queue_redraw()


func fuel_segment_count() -> int:
	if _light_condition > 0:
		return maxi(1, int(_light_condition / 31) + 1)
	return 2 if _has_torch else 0


func flame_y() -> int:
	return clampi(FLAME_BASE_Y - int(_light_condition / 4), 0, FLAME_BASE_Y)


func flame_frame_count() -> int:
	return FLAME_FRAMES.size()


func _draw() -> void:
	if not _classic_active:
		return
	var tint := Color.WHITE if _has_torch else Color(1.0, 1.0, 1.0, 0.6)
	for segment_index: int in fuel_segment_count():
		var marker_y := FUEL_BASE_Y - (segment_index + 1) * FUEL_STEP
		draw_texture(FUEL_MARKER, Vector2(8, marker_y), tint)
	if _light_condition > 0:
		draw_texture(FLAME_FRAMES[_flame_stage], Vector2(4, flame_y()), tint)
