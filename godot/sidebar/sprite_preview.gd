extends AnimatedSprite2D

func _ready() -> void:
	GlobalSettings.export_setting_changed.connect(_on_export_setting_changed)
	_on_export_setting_changed()
	
func _on_export_setting_changed() -> void:
	scale = Vector2(GlobalSettings.export_scale, GlobalSettings.export_scale)
	get_parent()._resize_to_animation()
	get_parent()._reposition_frame()
	material.set_shader_parameter("scale", GlobalSettings.export_scale)
	material.set_shader_parameter("outline_size", GlobalSettings.export_outline_size)
	material.set_shader_parameter("outline_color", GlobalSettings.export_outline_color)
