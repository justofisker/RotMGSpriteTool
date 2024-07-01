extends Node2D

@onready var camera: Camera2D = get_viewport().get_camera_2d()
@onready var viewport: SubViewport = get_viewport()
@export var grid_size := Vector2(64, 64)
@export var color := Color(0.8, 0.8, 0.8, 0.1)

func _ready() -> void:
	GlobalSettings.export_setting_changed.connect(_update_grid_size)
	_update_grid_size()

func _update_grid_size() -> void:
	grid_size = Vector2(8, 8) * GlobalSettings.export_scale

func _process(delta):
	queue_redraw()

func _draw():
	var vp_size: = viewport.size
	var cam_pos: = camera.position
	var vp_right: = vp_size.x / camera.zoom.x
	var vp_bottom: = vp_size.y / camera.zoom.y
	
	var leftmost: = -vp_right + cam_pos.x
	var topmost: = -vp_bottom + cam_pos.y
	
	var left: = ceilf(leftmost / grid_size.x) * grid_size.x
	var bottommost: = vp_bottom + cam_pos.y
	for x in range(0, vp_size.x / camera.zoom.x + 1):
		draw_line(Vector2(left, topmost), Vector2(left, bottommost), color)
		left += grid_size.x

	var top: = ceilf(topmost / grid_size.y) * grid_size.y
	var rightmost: = vp_right + cam_pos.x
	for y in range(0, vp_size.y / camera.zoom.y + 1):
		draw_line(Vector2(leftmost, top), Vector2(rightmost, top), color)
		top += grid_size.y
