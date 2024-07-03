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
		if GlobalSettings.export_shadow_size > 0 && !GlobalSettings.export_background_enabled:
			var old_shadow_size := GlobalSettings.export_shadow_size
			GlobalSettings.export_shadow_size = 0
			await get_tree().process_frame
			get_tree().process_frame.connect(func(): GlobalSettings.export_shadow_size = old_shadow_size, CONNECT_ONE_SHOT)
	
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
	
	var frame_timestamps_ms: Array[PackedInt32Array] = []
	var max_duration : int = 0
	
	for sprite in sprites:
		var timestamps_ms : PackedInt32Array = []
		var animation_length_ms: = 0
		for frame_idx in sprite.sprite_frames.get_frame_count("default"):
			animation_length_ms += roundi(sprite.sprite_frames.get_frame_duration("default", frame_idx) * 1000)
			if frame_idx + 1 != sprite.sprite_frames.get_frame_count("default"):
				timestamps_ms.push_back(animation_length_ms)
		frame_timestamps_ms.push_back(timestamps_ms)
		max_duration = maxi(max_duration, animation_length_ms)
	
	for sprite in sprites:
		sprite.set_frame_and_progress(0, 0.0)
	
	var viewports: Array[Viewport] = []
	var viewport_timestamps_ms : PackedInt32Array = []
	
	var first_frame_viewport := base_viewport.duplicate()
	add_child(first_frame_viewport)
	viewports.push_back(first_frame_viewport)
	viewport_timestamps_ms.push_back(0)
	
	var current_time_ms := 0
	var current_frames : PackedInt32Array = []
	current_frames.resize(sprites.size())
	current_frames.fill(0)
	while true:
		var update_indices := []
		var min_timestamp_ms: int = 9223372036854775807 # max int
		for idx in current_frames.size():
			if frame_timestamps_ms[idx].size() == 0 || current_frames[idx] + 1 >= sprites[idx].sprite_frames.get_frame_count("default"):
				continue
			var timestamp = frame_timestamps_ms[idx][current_frames[idx]]
			if timestamp < min_timestamp_ms:
				update_indices = [ idx ]
				min_timestamp_ms = timestamp
			elif absi(timestamp - min_timestamp_ms) <= 1: # 999 and 1000 are basically the same thing
				update_indices.append(idx)
		if update_indices.size() == 0:
			break
		
		for idx in update_indices:
			current_frames[idx] += 1
			sprites[idx].frame = current_frames[idx]
		
		var viewport = base_viewport.duplicate()
		add_child(viewport)
		viewports.push_back(viewport)
		viewport_timestamps_ms.push_back(min_timestamp_ms)
		current_time_ms = min_timestamp_ms 
	
	viewport_timestamps_ms.push_back(max_duration)
	
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
			exporter.add_frame(img, (viewport_timestamps_ms[idx + 1] - viewport_timestamps_ms[idx]) / 1000.0, MediumCutQuantization)
			remove_child(viewports[idx])

		
		var file := FileAccess.open(path, FileAccess.WRITE)
		file.store_buffer(exporter.export_file_data())
		file.close()
