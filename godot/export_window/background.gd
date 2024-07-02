extends ColorRect

func _ready() -> void:
	GlobalSettings.setting_changed.connect(_on_setting_changed)

func _on_setting_changed() -> void:
	color = GlobalSettings.export_background_color
	if !GlobalSettings.export_background_enabled:
		color.a = 0

func _process(_delta: float) -> void:
	size = get_viewport().size
	position = -size / 2.0
