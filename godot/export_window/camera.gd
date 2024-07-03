extends Camera2D

var zoom_level := 1.0
var pressed := false
var extents := Vector4(-128, -128, 128, 128)
@export var padding := 16
@onready var reset_zoom_button: Button = $"../UILayer/MarginContainer/HBoxContainer/ResetZoom"

const ZOOM_MIN: float = 0.5
const ZOOM_MAX: float = 10.0
const ZOOM_STEP: float = 0.2
const ZOOM_STEP_MULT_KEYBOARD: float = 3.0

func _ready() -> void:
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					pressed = true
					Input.set_default_cursor_shape(Input.CURSOR_DRAG)
				MOUSE_BUTTON_WHEEL_DOWN:
					zoom_towards_cursor(zoom_level - ZOOM_STEP * zoom_level)
				MOUSE_BUTTON_WHEEL_UP:
					zoom_towards_cursor(zoom_level + ZOOM_STEP * zoom_level)

var ignore_next_mouse := false

func _input(event: InputEvent) -> void:
	if pressed:
		if event is InputEventMouseMotion:
			if ignore_next_mouse:
				ignore_next_mouse = false
				return
			position -= event.relative / zoom
			var mouse_position := get_viewport().get_mouse_position()
			var viewport_size := get_viewport_rect().size
			if mouse_position.x < 0 || mouse_position.x > viewport_size.x || mouse_position.y < 0 || mouse_position.y > viewport_size.y:
				mouse_position.x = posmod(mouse_position.x, viewport_size.x)
				mouse_position.y = posmod(mouse_position.y, viewport_size.y)
				Input.warp_mouse(mouse_position)
				ignore_next_mouse = true
		elif event is InputEventMouseButton && !event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
			pressed = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func zoom_towards_cursor(level: float) -> void:
	var old_zoom_amount := zoom_level
	zoom_level = clampf(level, ZOOM_MIN, ZOOM_MAX)
	global_position -= (get_viewport().get_mouse_position() - get_viewport().size * 0.5) * (1.0 / zoom_level - 1.0 / old_zoom_amount)
	zoom = Vector2(zoom_level, zoom_level)
	_update_zoom_text()

func _update_zoom_text() -> void:
	reset_zoom_button.text = str(floorf(zoom.x * 1000) / 10.0) + " %"

func _on_center_view_pressed() -> void:
	position = Vector2()

func _on_zoom_out_pressed() -> void:
	zoom_level = clampf(zoom_level - ZOOM_STEP * zoom_level * ZOOM_STEP_MULT_KEYBOARD, ZOOM_MIN, ZOOM_MAX)
	zoom = Vector2(zoom_level, zoom_level)
	_update_zoom_text()

func _on_reset_zoom_pressed() -> void:
	zoom_level = 1.0
	zoom = Vector2(zoom_level, zoom_level)
	_update_zoom_text()

func _on_zoom_in_pressed() -> void:
	zoom_level = clampf(zoom_level + ZOOM_STEP * zoom_level * ZOOM_STEP_MULT_KEYBOARD, ZOOM_MIN, ZOOM_MAX)
	zoom = Vector2(zoom_level, zoom_level)
	_update_zoom_text()
