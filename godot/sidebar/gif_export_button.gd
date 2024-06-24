extends Button

@onready var dialog: NativeFileDialog = $NativeFileDialog

@export_enum("GIF Image", "WebP Image") var file_type = 0

func _ready() -> void:
	pressed.connect(_on_pressed)
	match file_type:
		0:
			dialog.add_filter("*.gif", "GIF Image (*.gif)")
		1:
			dialog.add_filter("*.webp", "WebP Image (*.webp)")

func _on_pressed() -> void:
	if DirAccess.dir_exists_absolute(GlobalSettings.last_save_location):
		dialog.root_subfolder = GlobalSettings.last_save_location
	else:
		dialog.root_subfolder = "./"
	dialog.show()

func _on_native_file_dialog_file_selected(path: String) -> void:
	var dir := path.substr(0, path.rfind("/") + 1)
	GlobalSettings.last_save_location = dir
	
	match file_type:
		0:
			save_as_gif(path)
		1:
			save_as_webp_animation(path)

func save_as_webp_animation(path: String):
	if !path.ends_with(".webp"):
		path += ".webp"
	
	_setup_export(_save_webp_animation.bind(path))

func save_as_gif(path: String) -> void:
	if !path.ends_with(".gif"):
		path += ".gif"
	
	_setup_export(_save_gif.bind(path))
	
func _setup_export(save_func: Callable) -> void:
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
		sprite.position.y = (extents.y - sprite.texture.get_height()) / 2 * GlobalSettings.export_scale
		viewport.add_child(sprite)
		viewports.push_back(viewport)
		durations.push_back(sprite_frames.get_frame_duration(animation, idx))
		add_child(viewport)
	
	var thread = Thread.new()
	thread.start(save_func.bind(viewports, durations), Thread.PRIORITY_HIGH)

func _save_gif(viewports: Array[SubViewport], durations: PackedFloat32Array, path: String,) -> void:
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

func _save_webp_animation(viewports: Array[SubViewport], durations: PackedFloat32Array, path: String,) -> void:
	await RenderingServer.frame_post_draw
	
	var webp := WebpExporter.new()
	var extents := viewports[0].size
	webp.setup_with_size(extents.x, extents.y)
	
	var timestamp : int = 0
	
	for idx in viewports.size():
		var img := viewports[idx].get_texture().get_image()
		img.convert(Image.FORMAT_RGBA8)
		webp.add_frame(img, timestamp)
		timestamp += int(1000 * durations[idx])
		remove_child(viewports[idx])
	
	webp.finalize_and_write(timestamp, path)
	
	print("done")
	
