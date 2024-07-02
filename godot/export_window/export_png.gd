extends Button

@onready var dialog: NativeFileDialog = $NativeFileDialog

func _ready() -> void:
	dialog.add_filter("*.png", "PNG Image (*.png)")
	GlobalSettings.export_setting_changed.connect(_on_export_setting_changed)
	_on_export_setting_changed()

func _on_export_setting_changed() -> void:
	visible = !GlobalSettings.export_animated

func _on_pressed() -> void:
	if DirAccess.dir_exists_absolute(GlobalSettings.last_save_location):
		dialog.root_subfolder = GlobalSettings.last_save_location
	else:
		dialog.root_subfolder = "./"
	dialog.show()

func _on_dialog_file_selected(path: String) -> void:
	var dir := path.substr(0, path.rfind("/") + 1)
	GlobalSettings.last_save_location = dir
	if !path.to_lower().ends_with(".png"):
		path += ".png"
	var viewport = SubViewport.new()
	viewport.size = Vector2(%ExportPreview.camera.extents.z - %ExportPreview.camera.extents.x, %ExportPreview.camera.extents.w - %ExportPreview.camera.extents.y)
	viewport.disable_3d = true
	viewport.transparent_bg = true
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	var camera := Camera2D.new()
	viewport.add_child(camera)
	viewport.add_child(%ExportPreview.background.duplicate())
	viewport.add_child(%ExportPreview.sprite_area.duplicate())
	add_child(viewport)
	await RenderingServer.frame_post_draw
	var img = viewport.get_texture().get_image()
	remove_child(viewport)
	img.save_png(path)
