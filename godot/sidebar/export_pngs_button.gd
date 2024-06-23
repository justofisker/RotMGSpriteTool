extends Button

@onready var dialog: NativeFileDialog = $NativeFileDialog
@export var sprite : AnimatedSprite2D

func _ready() -> void:
	dialog.add_filter("*.png", "*.png (PNG Image)")
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if DirAccess.dir_exists_absolute(GlobalSettings.last_save_location):
		dialog.root_subfolder = GlobalSettings.last_save_location
	else:
		dialog.root_subfolder = "./"
	dialog.show()

func _on_dialog_file_selected(path: String) -> void:
	var dir := path.substr(0, path.rfind("/"))
	GlobalSettings.last_save_location = dir
	
	var sprite_frames = sprite.sprite_frames
	var animation = sprite.animation
	
	var viewports : Array[SubViewport] = []
	
	for idx in sprite_frames.get_frame_count(animation):
		var vsprite := Sprite2D.new()
		vsprite.texture = sprite_frames.get_frame_texture(animation, idx).duplicate()
		vsprite.scale = Vector2(GlobalSettings.export_scale, GlobalSettings.export_scale)
		vsprite.material = sprite.material.duplicate()
		vsprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var viewport := SubViewport.new()
		viewport.size = vsprite.texture.get_size() * GlobalSettings.export_scale
		viewport.disable_3d = true
		viewport.transparent_bg = true
		viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		var camera := Camera2D.new()
		viewport.add_child(camera)
		viewport.add_child(vsprite)
		viewports.push_back(viewport)
		add_child(viewport)
	
	await RenderingServer.frame_post_draw
	
	path = path.trim_suffix(".png")
	if viewports.size() == 1:
		viewports[0].get_texture().get_image().save_png("%s.png" % path)
	else:
		path = path.trim_suffix("_0")
		for idx in viewports.size():
			viewports[idx].get_texture().get_image().save_png("%s_%d.png" % [path, idx])
