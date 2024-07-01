extends Camera2D

var zoom_level := 1.0
var mouse_position := Vector2()
var pressed := false
var extents := Vector4(-128, -128, 128, 128)
@export var padding := 16
@onready var reset_zoom_button: Button = $"../UILayer/MarginContainer/HBoxContainer/ResetZoom"

const ZOOM_MAX: float = 10.0
const ZOOM_STEP: float = 0.4

func _ready() -> void:
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					pressed = true
					mouse_position = get_viewport().get_mouse_position()
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				MOUSE_BUTTON_WHEEL_DOWN:
					zoom_towards(zoom_level - ZOOM_STEP * zoom_level)
				MOUSE_BUTTON_WHEEL_UP:
					zoom_towards(zoom_level + ZOOM_STEP * zoom_level)

func _input(event: InputEvent) -> void:
	if pressed:
		if event is InputEventMouseMotion:
			position -= event.relative / zoom
		elif event is InputEventMouseButton && !event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			pressed = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_viewport().warp_mouse(mouse_position)

func zoom_towards(level: float, position: Vector2 = get_viewport().get_mouse_position()) -> void:
	var old_zoom_amount := zoom_level
	zoom_level = clampf(level, 1.0, 8.0)
	global_position -= (position - get_viewport().size * 0.5) * (1.0 / zoom_level - 1.0 / old_zoom_amount)
	zoom = Vector2(zoom_level, zoom_level)
	_update_zoom_text()

func _update_zoom_text() -> void:
	reset_zoom_button.text = str(floorf(zoom.x * 1000) / 10.0) + " %"

func _on_center_view_pressed() -> void:
	position = Vector2()

func _on_zoom_out_pressed() -> void:
	zoom_level = clampf(zoom_level - ZOOM_STEP * zoom_level, 1.0, ZOOM_MAX)
	zoom = Vector2(zoom_level, zoom_level)
	_update_zoom_text()

func _on_reset_zoom_pressed() -> void:
	zoom_level = 1.0
	zoom = Vector2(zoom_level, zoom_level)
	_update_zoom_text()

func _on_zoom_in_pressed() -> void:
	zoom_level = clampf(zoom_level + ZOOM_STEP * zoom_level, 1.0, ZOOM_MAX)
	zoom = Vector2(zoom_level, zoom_level)
	_update_zoom_text()
