extends Node2D

@onready var sprite_area: Node2D = $SpriteArea
@onready var grid: Node2D = $Grid
@onready var camera: Camera2D = $Camera
@onready var background: ColorRect = $Camera/Background

func _get_padding() -> int:
	var expand_size := maxi(GlobalSettings.export_outline_size, GlobalSettings.export_shadow_size)
	if expand_size == 0:
		return 0
	return ceilf(float(expand_size) / GlobalSettings.export_scale)

func _clear_sprites() -> void:
	for child in sprite_area.get_children():
		sprite_area.remove_child(child)

func _set_shader() -> void:
	var material := preload("res://export_window/outline_preview_material.tres")
	material.set_shader_parameter("outline_color", GlobalSettings.export_outline_color)
	material.set_shader_parameter("outline_size", GlobalSettings.export_outline_size)
	material.set_shader_parameter("scale", GlobalSettings.export_scale)
	material.set_shader_parameter("shadow_size", GlobalSettings.export_shadow_size)
	material.set_shader_parameter("shadow_color", GlobalSettings.export_shadow_color)

func _resize_texture(texture: Texture2D) -> Texture2D:
	var padding := _get_padding()
	var atlas_tex : AtlasTexture = texture.duplicate()
	atlas_tex.region.size += Vector2(padding * 2, padding * 2)
	atlas_tex.region.position -= Vector2(padding, padding)
	return atlas_tex

func _resize_textures(textures: Array[RotmgTexture]) -> Array[Texture2D]:
	var padding := _get_padding()
	var extents := Vector2i()
	for texture in textures:
		if is_instance_valid(texture):
			extents.x = maxi(extents.x, texture.texture.get_width())
			extents.y = maxi(extents.y, texture.texture.get_height())
	extents.x += padding
	extents.y += padding
	
	var out_textures : Array[Texture2D] = []
	
	for idx in textures.size():
		if is_instance_valid(textures[idx]):
			var atlas_tex: AtlasTexture = textures[idx].texture.duplicate()
			atlas_tex.region.size += Vector2(padding * 2, padding * 2)
			atlas_tex.region.position -= Vector2(padding, padding)
			out_textures.append(atlas_tex)
	
	return out_textures

func _animated_textures_to_sprite_container(animated_textures: Array[RotmgAnimatedTexture]) -> Control:
	var textures : Array[RotmgTexture] = []
	for texture in animated_textures:
		textures.push_back(texture.texture)
	return _textures_to_sprite_container(textures)

func _textures_to_sprite_container(textures: Array[RotmgTexture], durations: PackedFloat32Array = []) -> Control:
	if durations.size() == 0:
		durations.resize(textures.size())
		durations.fill(1.0 / durations.size())
	var sprite := AnimatedSprite2D.new()
	var sprite_frames := SpriteFrames.new()
	var resized_textures := _resize_textures(textures)
	for idx in resized_textures.size():
		sprite_frames.add_frame("default", resized_textures[idx], durations[idx] * 5.0)
	sprite.sprite_frames = sprite_frames
	sprite.scale = Vector2(GlobalSettings.export_scale, GlobalSettings.export_scale)
	sprite.play()
	sprite.material = preload("res://export_window/outline_preview_material.tres")
	var sprite_container := Control.new()
	sprite_container.set_script(preload("res://sidebar/animated_sprite_container.gd"))
	sprite_container.add_child(sprite)
	sprite_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return sprite_container

func setup_animation(frames: Array[RotmgTexture], durations: PackedFloat32Array) -> void:
	_clear_sprites()
	_set_shader()
	var sprite_container := _textures_to_sprite_container(frames, durations)
	sprite_container.centered_h = true
	sprite_area.add_child(sprite_container)
	await RenderingServer.frame_pre_draw
	sprite_container.position = -sprite_container.size / 2
	var width := sprite_container.size.x
	var height := sprite_container.size.y
	camera.extents = Vector4(-width / 2.0, -height / 2.0, width / 2.0, height / 2.0)

func setup_texture(texture: RotmgTexture) -> void:
	_clear_sprites()
	_set_shader()
	var sprite := Sprite2D.new()
	sprite.texture = _resize_texture(texture.texture)
	sprite.scale = Vector2(GlobalSettings.export_scale, GlobalSettings.export_scale)
	sprite.material = preload("res://export_window/outline_preview_material.tres")
	sprite.centered = false
	sprite_area.add_child(sprite)
	await RenderingServer.frame_pre_draw
	var width := sprite.texture.get_width()
	var height := sprite.texture.get_height()
	camera.extents = Vector4(-width / 2.0, -height / 2.0, width / 2.0, height / 2.0)

func setup_animated_texture(textures: Array[RotmgAnimatedTexture]) -> void:
	_clear_sprites()
	_set_shader()
	
	var action_0 : Array[RotmgAnimatedTexture] = []
	var action_1 : Array[RotmgAnimatedTexture] = []
	var action_2 : Array[RotmgAnimatedTexture] = []
	
	for texture in textures:
		match texture.action:
			0:
				action_0.push_back(texture)
			1:
				action_1.push_back(texture)
			2:
				action_2.push_back(texture)
			_:
				push_error("Unknown action")
	
	var container_0 := _animated_textures_to_sprite_container(action_0)
	var container_1 := _animated_textures_to_sprite_container(action_1)
	var container_2 := _animated_textures_to_sprite_container(action_2)
	sprite_area.add_child(container_0)
	sprite_area.add_child(container_1)
	sprite_area.add_child(container_2)
	await RenderingServer.frame_pre_draw
	var width := container_0.size.x + container_1.size.x + container_2.size.x
	var height := maxf(container_0.size.y, maxf(container_1.size.y, container_2.size.y))
	container_0.position.y = -container_0.size.y / 2.0
	container_0.position.x = - width / 2
	container_1.position.y = -container_1.size.y / 2.0
	container_1.position.x = - width / 2 + container_0.size.x
	container_2.position.y = -container_2.size.y / 2.0
	container_2.position.x = width / 2 - container_2.size.x
	camera.extents = Vector4(-width / 2.0, -height / 2.0, width / 2.0, height / 2.0)
