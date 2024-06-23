extends Button

@onready var dialog: NativeFileDialog = $NativeFileDialog

func _ready() -> void:
	pressed.connect(_on_pressed)
	dialog.add_filter("*.gif", "GIF Image (*.gif)")

func _on_pressed() -> void:
	if DirAccess.dir_exists_absolute(GlobalSettings.last_save_location):
		dialog.root_subfolder = GlobalSettings.last_save_location
	else:
		dialog.root_subfolder = "./"
	dialog.show()

func _on_native_file_dialog_file_selected(path: String) -> void:
	var dir := path.substr(0, path.rfind("/") + 1)
	GlobalSettings.last_save_location = dir
	
	if !path.ends_with(".gif"):
		path += ".gif"
	var sprite_frames : SpriteFrames = %Sprite.sprite_frames
	var animation : String = %Sprite.animation
	
	var extents := Vector2i()
	for idx in sprite_frames.get_frame_count(animation):
		var tex = sprite_frames.get_frame_texture(animation, idx)
		extents.x = maxi(extents.x, tex.get_width())
		extents.y = maxi(extents.y, tex.get_height())
	
	var viewports : Array[SubViewport] = []
	var durations : PackedFloat32Array = []
	
	for idx in sprite_frames.get_frame_count(animation):
		var viewport := SubViewport.new()
		viewport.size = extents * GlobalSettings.export_scale
		viewport.disable_3d = true
		viewport.transparent_bg = true
		viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		var camera := Camera2D.new()
		viewport.add_child(camera)
		var sprite := Sprite2D.new()
		sprite.texture = sprite_frames.get_frame_texture(animation, idx).duplicate()
		sprite.scale = Vector2(GlobalSettings.export_scale, GlobalSettings.export_scale)
		sprite.material = %Sprite.material.duplicate()
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		viewport.add_child(sprite)
		viewports.push_back(viewport)
		durations.push_back(sprite_frames.get_frame_duration(animation, idx))
		add_child(viewport)
	
	var thread = Thread.new()
	thread.start(_save_gif.bind(viewports, durations, path), Thread.PRIORITY_HIGH)

func _save_gif(viewports: Array[SubViewport], durations: PackedFloat32Array, path: String) -> void:
	await RenderingServer.frame_post_draw
	
	var extents := viewports[0].size
	var exporter := GifExporter.new(extents.x, extents.y)
	for idx in viewports.size():
		var img := viewports[idx].get_texture().get_image()
		img.convert(Image.FORMAT_RGBA8)
		exporter.add_frame(img, durations[idx], MediumCutQuantization)
		remove_child(viewports[idx])
		
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(exporter.export_file_data())
	file.close()
	
	print("done")
	
