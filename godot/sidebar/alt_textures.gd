extends VBoxContainer

@export var range: HSlider

var character: Character :
	set(value):
		character = value
		visible = character.alt_textures.size() != 0
		if visible:
			_update_spin_box()
			_update_sprite()

func _ready() -> void:
	GlobalSettings.export_setting_changed.connect(_update_sprite)

func _update_spin_box() -> void:
	range.value = 0
	range.tick_count = character.alt_textures.size()
	range.max_value = character.alt_textures.size() - 1

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
	%Sprite.animation = str(int(value))
