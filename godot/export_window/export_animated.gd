extends Button

@export_enum("WebP", "GIF") var export_type : int = 0

@onready var dialog: NativeFileDialog = $NativeFileDialog

func _ready() -> void:
	if export_type == 0:
		dialog.add_filter("*.webp", "WebP Image (*.webp)")
	else:
		dialog.add_filter("*.gif", "GIF Image (*.gif)")
	GlobalSettings.export_setting_changed.connect(_on_export_setting_changed)
	_on_export_setting_changed()

func _on_export_setting_changed() -> void:
	visible = GlobalSettings.export_animated

func _on_pressed() -> void:
	if DirAccess.dir_exists_absolute(GlobalSettings.last_save_location):
		dialog.root_subfolder = GlobalSettings.last_save_location
	else:
		dialog.root_subfolder = "./"
	dialog.show()

func _on_dialog_file_selected(path: String) -> void:
	var dir := path.substr(0, path.rfind("/") + 1)
	GlobalSettings.last_save_location = dir
	if export_type == 0:
		if !path.to_lower().ends_with(".webp"):
			path += ".webp"
	else:
		if !path.to_lower().ends_with(".gif"):
			path += ".gif"
	
	var base_viewport := SubViewport.new()
	base_viewport.size = Vector2(%ExportPreview.camera.extents.z - %ExportPreview.camera.extents.x, %ExportPreview.camera.extents.w - %ExportPreview.camera.extents.y)
	base_viewport.disable_3d = true
	base_viewport.transparent_bg = true
	base_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	base_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	var camera := Camera2D.new()
	base_viewport.add_child(camera)
	base_viewport.add_child(%ExportPreview.background.duplicate())
	
	var sprites: Array[AnimatedSprite2D] = []
	
	for sprite_container in %ExportPreview.sprite_area.get_children():
		var dup_container : Control = sprite_container.duplicate()
		base_viewport.add_child(dup_container)
		sprites.push_back(dup_container.get_child(0))
	
	var frame_timestamps: Array = []
	var viewports: Array[Viewport] = []
	var viewport_timestamps_ms : PackedInt32Array = []
	var max_duration : int = 0
	
	for sprite in sprites:
		var times : PackedInt32Array = []
		var animation_length: = 0
		for frame_idx in sprite.sprite_frames.get_frame_count("default"):
			var frame_time := int(sprite.sprite_frames.get_frame_duration("default", frame_idx) * 1000)
			times.push_back(animation_length + frame_time)
			animation_length += frame_time
		frame_timestamps.push_back(times)
		max_duration = maxi(max_duration, animation_length)
	
	for sprite in sprites:
		sprite.set_frame_and_progress(0, 0.0)
	
	var first_vp = base_viewport.duplicate()
	viewports.push_back(first_vp)
	add_child(first_vp)
	viewport_timestamps_ms.push_back(0)
	
	var current_time := 0
	var current_frames : PackedInt32Array = []
	current_frames.resize(sprites.size())
	current_frames.fill(0)
	while current_time < max_duration:
		var update_indices := []
		var min_frame_timestamp: int = 9223372036854775807 # max int
		for idx in current_frames.size():
			if current_frames[idx] >= sprites[idx].sprite_frames.get_frame_count("default"):
				continue
			var timestamp = frame_timestamps[idx][current_frames[idx]]
			if timestamp < min_frame_timestamp:
				update_indices = [ idx ]
				min_frame_timestamp = timestamp
			elif timestamp == min_frame_timestamp:
				update_indices.append(idx)
		
		for idx in update_indices:
			current_frames[idx] += 1
			sprites[idx].frame = current_frames[idx]
		
		var viewport = base_viewport.duplicate()
		add_child(viewport)
		viewports.push_back(viewport)
		viewport_timestamps_ms.push_back(min_frame_timestamp)
		
		current_time = min_frame_timestamp 
	
	await RenderingServer.frame_post_draw
	
	if export_type == 0:
		var webp = WebpExporter.new()
		webp.setup_with_size(base_viewport.size.x, base_viewport.size.y)
		
		for idx in viewports.size():
			webp.add_frame(viewports[idx].get_texture().get_image(), viewport_timestamps_ms[idx])
			remove_child(viewports[idx])
		
		webp.finalize_and_write(max_duration, path)
	else:
		var exporter := GifExporter.new(base_viewport.size.x, base_viewport.size.y)
		var last_timestamp := 0
		for idx in viewports.size():
			var img := viewports[idx].get_texture().get_image()
			img.convert(Image.FORMAT_RGBA8)
			exporter.add_frame(img, (viewport_timestamps_ms[idx] - last_timestamp) / 1000.0, MediumCutQuantization)
			last_timestamp = viewport_timestamps_ms[idx]
			remove_child(viewports[idx])
		
		var file := FileAccess.open(path, FileAccess.WRITE)
		file.store_buffer(exporter.export_file_data())
		file.close()
