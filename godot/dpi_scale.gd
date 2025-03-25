extends Node

func _ready() -> void:
	get_window().content_scale_factor = maxf(DisplayServer.screen_get_dpi() / 128.0, 1.0)
