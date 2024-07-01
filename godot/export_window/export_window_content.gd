extends HBoxContainer

@onready var export_preview: Node2D = $Control/SubViewport/ExportPreview

var export_data: ExportData = null :
	set(value):
		export_data = value
		if is_instance_valid(export_preview):
			setup()

func setup() -> void:
	match export_data.export_mode:
		ExportData.ExportMode.MULTITEXTURES:
			pass
		ExportData.ExportMode.MULTITEXTURES_TIMED:
			export_preview.setup_animation(export_data.textures, export_data.durations)
		ExportData.ExportMode.SINGLE_TEXTURE:
			export_preview.setup_texture(export_data.texture)
		ExportData.ExportMode.ANIMATED_TEXTURE:
			export_preview.setup_animated_texture(export_data.animated_textures)

func _ready() -> void:
	setup()
	GlobalSettings.export_setting_changed.connect(setup)
