extends VBoxContainer

@export var slider: HSlider
@export var button: Button

var character: Character :
	set(value):
		character = value
		visible = character.alt_textures.size() != 0
		if visible:
			_update_slider()
			_update_sprite()

func _ready() -> void:
	GlobalSettings.export_setting_changed.connect(_update_sprite)

func _update_slider() -> void:
	slider.value = 0
	slider.tick_count = character.alt_textures.size()
	slider.max_value = character.alt_textures.size() - 1
	_on_alt_tex_value_changed(0)

func _update_sprite() -> void:
	if character == null:
		return
	var sprite_frames = SpriteFrames.new()
	
	for idx in character.alt_textures.size():
		var texture = character.alt_textures[idx]
		sprite_frames.add_animation(str(idx))
		if texture.animated:
			var frames := RotmgAtlases.get_animated_sprite_textures_export(texture.file_name, texture.index)
			for frame in frames:
				sprite_frames.add_frame(str(idx), frame)
		elif is_instance_valid(texture):
			sprite_frames.add_frame(str(idx), texture.texture_export)
			
		%Sprite.sprite_frames = sprite_frames
		%Sprite.animation = "0"
		%Sprite.play()

func _on_alt_tex_value_changed(value: float) -> void:
	var texture := character.alt_textures[int(value)]
	%Sprite.animation = str(int(value))
	if texture.animated:
		button.export_data = ExportData.from_animated_textures(RotmgAtlases.get_animated_textures(texture.file_name, texture.index))
	else:
		button.export_data = ExportData.from_texture(RotmgAtlases.get_texture(texture.file_name, texture.index))
