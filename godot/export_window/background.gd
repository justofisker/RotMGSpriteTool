extends ColorRect

func _ready() -> void:
	GlobalSettings.setting_changed.connect(_on_setting_changed)
	get_viewport().size_changed.connect(resize)
	resize()

func _on_setting_changed() -> void:
	color = GlobalSettings.export_background_color
	if !GlobalSettings.export_background_enabled:
		color.a = 0

func resize() -> void:
	size = get_viewport().size * 2
	position = -size / 2.0
