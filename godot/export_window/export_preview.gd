extends Node2D

@onready var sprite_area: Node2D = $SpriteArea
@onready var grid: Node2D = $Grid
@onready var camera: Camera2D = $Camera
@onready var background: ColorRect = $Camera/Background

@export var shader_material: ShaderMaterial
@export var sprite_container_script: Script

func _ready() -> void:
	GlobalSettings.setting_changed.connect(_set_shader)

func _get_padding() -> int:
	var expand_size := maxi(GlobalSettings.export_outline_size, GlobalSettings.export_shadow_size)
	if expand_size == 0:
		return 0
	return ceili(float(expand_size) / GlobalSettings.export_scale)

func _clear_sprites() -> void:
	for child in sprite_area.get_children():
		sprite_area.remove_child(child)

func _set_shader() -> void:
	shader_material.set_shader_parameter("outline_color", GlobalSettings.export_outline_color)
	shader_material.set_shader_parameter("outline_size", GlobalSettings.export_outline_size)
	shader_material.set_shader_parameter("scale", GlobalSettings.export_scale)
	shader_material.set_shader_parameter("shadow_size", GlobalSettings.export_shadow_size)
	shader_material.set_shader_parameter("shadow_color", GlobalSettings.export_shadow_color)

func _resize_texture(texture: Texture2D) -> Texture2D:
	var padding := _get_padding()
	var atlas_tex : AtlasTexture = texture.duplicate()
	atlas_tex.region.size += Vector2(padding * 2, padding * 2)
	atlas_tex.region.position -= Vector2(padding, padding)
	return atlas_tex

func _resize_textures(textures: Array[RotmgSprite]) -> Array[Texture2D]:
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
			var atlas_tex: AtlasTexture = RotmgAtlases.get_texture(textures[idx])
			atlas_tex.region.size += Vector2(padding * 2, padding * 2)
			atlas_tex.region.position -= Vector2(padding, padding)
			out_textures.append(atlas_tex)
	
	return out_textures

func _texture_to_sprite(texture: Texture2D) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.scale = Vector2(GlobalSettings.export_scale, GlobalSettings.export_scale)
	sprite.material = shader_material
	sprite.centered = false
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return sprite

func _animated_textures_to_sprite_container(animated_sprites: Array[RotmgAnimatedSprite]) -> Control:
	var textures : Array[AtlasTexture] = []
	for sprite in animated_sprites:
		textures.push_back(RotmgAtlases.get_animated_texture(sprite))
	return _textures_to_sprite_container(textures)

func _textures_to_sprite_container(textures: Array[Texture2D], durations: PackedFloat32Array = []) -> Control:
	if durations.size() == 0:
		durations.resize(textures.size())
		durations.fill(1.0 / durations.size())
	var sprite := AnimatedSprite2D.new()
	var sprite_frames := SpriteFrames.new()
	var resized_textures := _resize_textures(textures)
	for idx in resized_textures.size():
		sprite_frames.add_frame("default", resized_textures[idx], durations[idx])
	sprite.sprite_frames = sprite_frames
	sprite.scale = Vector2(GlobalSettings.export_scale, GlobalSettings.export_scale)
	sprite.play()
	sprite.material = shader_material
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.speed_scale = 0.2
	var sprite_container := Control.new()
	sprite_container.set_script(sprite_container_script)
	sprite_container.add_child(sprite)
	sprite_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return sprite_container

func setup_animation(frames: Array[RotmgTexture], durations: PackedFloat32Array) -> void:
	_clear_sprites()
	_set_shader()
	if GlobalSettings.export_animated:
		var sprite_container := _textures_to_sprite_container(frames, durations)
		sprite_container.centered_h = true
		sprite_area.add_child(sprite_container)
		await RenderingServer.frame_pre_draw
		sprite_container.position = -sprite_container.size / 2
		var width := sprite_container.size.x
		var height := sprite_container.size.y
		camera.extents = Vector4(-width / 2.0, -height / 2.0, width / 2.0, height / 2.0)
	else:
		var resized_textures := _resize_textures(frames)
		var sprites : Array[Sprite2D] = []
		var max_size := Vector2()
		for tex in resized_textures:
			var sprite := Sprite2D.new()
			sprite.texture = tex
			sprite.material = shader_material
			sprite.scale = Vector2(GlobalSettings.export_scale, GlobalSettings.export_scale)
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			max_size.x = maxf(max_size.x, tex.get_width())
			max_size.y = maxf(max_size.y, tex.get_height())
			sprites.append(sprite)
		max_size *= GlobalSettings.export_scale
		
		var width := max_size.x * sprites.size()
		var height := max_size.y
		
		for idx in sprites.size():
			var sprite = sprites[idx]
			sprite_area.add_child(sprite)
			sprite.position.x = -width / 2.0 + max_size.x * (idx + 0.5)
			sprite.position.y = (height - sprite.texture.get_height() * GlobalSettings.export_scale) / 2.0
		
		camera.extents = Vector4(-width / 2.0, -height / 2.0, width / 2.0, height / 2.0)

func setup_texture(texture: RotmgTexture) -> void:
	_clear_sprites()
	_set_shader()
	var sprite := Sprite2D.new()
	sprite.texture = _resize_texture(texture.texture)
	sprite.scale = Vector2(GlobalSettings.export_scale, GlobalSettings.export_scale)
	sprite.material = shader_material
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite_area.add_child(sprite)
	await RenderingServer.frame_pre_draw
	var width := sprite.texture.get_width()
	var height := sprite.texture.get_height()
	camera.extents = Vector4(-width / 2.0, -height / 2.0, width / 2.0, height / 2.0)

func setup_animated_texture(sprites: Array[RotmgAnimatedSprite]) -> void:
	_clear_sprites()
	_set_shader()
	
	var get_key = func(action: int, direction: int) -> int:
		var key = action & 0xFF
		key |= (direction & 0xFF) << 16
		return key
	
	var texture_dict = {}
	
	var actions : PackedInt32Array = []
	var directions : PackedInt32Array = []
	
	for idx in sprites.size():
		var action := sprites[idx].action
		var direction := sprites[idx].direction
		var key : int = get_key.call(action, direction)
		if !actions.has(action):
			actions.push_back(action)
		if !directions.has(direction):
			directions.push_back(direction)
		if !texture_dict.has(key):
			texture_dict[key] = []
		texture_dict[key].push_back(idx)
	
	actions.sort()
	directions.sort()
	
	# For some reason some character has their idle frame as the first frame of the walk animation
	for direction in directions:
		if texture_dict.has(get_key.call(1, direction)) && texture_dict.has(get_key.call(2, direction)):
			var walk : PackedInt32Array = texture_dict[get_key.call(1, direction)]
			var attack_size : int = texture_dict[get_key.call(2, direction)].size()
			if walk.size() == attack_size + 1:
				texture_dict[get_key.call(1, direction)] = walk.slice(1)
	
	var max_size := Vector2i()
	var resized_textures : Array[Texture2D] = []
	for sprite in sprites:
		var tex := _resize_texture(texture.texture.texture)
		max_size.x = maxi(max_size.x, tex.get_width())
		max_size.y = maxi(max_size.y, tex.get_height())
		resized_textures.push_back(tex)
	max_size *= GlobalSettings.export_scale
	
	if GlobalSettings.export_animated:
		var rows : Array[Array] = []
		for direction in directions:
			var row : Array[Control] = []
			for action in actions:
				var key : int = get_key.call(action, direction)
				if texture_dict.has(key):
					var anm_textures : Array[RotmgAnimatedTexture] = []
					for tex in texture_dict[key]:
						anm_textures.push_back(textures[tex])
					row.push_back(_animated_textures_to_sprite_container(anm_textures))
			rows.push_back(row)
		var y_offset : int = 0
		for row in rows:
			for idx in row.size():
				var container : Control = row[idx]
				sprite_area.add_child(container)
				container.position.x = idx * max_size.x
				container.position.y = y_offset
			y_offset += max_size.y
		var width : int = 0
		for row in rows:
			width = maxi(width, max_size.x * row.size())
		for child in sprite_area.get_children():
			child.position.x -= width / 2.0
			child.position.y -= y_offset / 2.0
		camera.extents = Vector4(-width / 2.0, -y_offset / 2.0, width / 2.0, y_offset / 2.0)
	else:
		var y_offset : int = 0
		for action in actions:
			for direction in directions:
				var key = get_key.call(action, direction)
				if !texture_dict.has(key):
					continue
				var row : Array = texture_dict[key]
				for idx in row.size():
					var sprite := _texture_to_sprite(resized_textures[row[idx]])
					sprite_area.add_child(sprite)
					sprite.position.x = idx * max_size.x
					sprite.position.y = y_offset
				y_offset += max_size.y
		var width = 0
		for row in texture_dict.values():
			width = maxi(width, max_size.x * row.size())
		for child in sprite_area.get_children():
			child.position.x -= width / 2.0
			child.position.y -= y_offset / 2.0
		camera.extents = Vector4(-width / 2.0, -y_offset / 2.0, width / 2.0, y_offset / 2.0)
	
