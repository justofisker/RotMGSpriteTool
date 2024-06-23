extends VBoxContainer

var character: Character :
	set(value):
		character = value
		_update_sprite()

func _ready() -> void:
	GlobalSettings.export_setting_changed.connect(_update_sprite)

func _update_sprite() -> void:
	visible = true
	if character == null || !is_instance_valid(character.texture):
		visible = false
		return
	if character.texture.animated:
		var sprite_frames := SpriteFrames.new()
		var frames := RotmgAtlases.get_animated_sprite_textures_export(character.texture.file_name, character.texture.index)
		for frame in frames:
			sprite_frames.add_frame("default", frame)
		%Sprite.sprite_frames = sprite_frames
		%Sprite.play()
	elif is_instance_valid(character.texture.texture):
		var sprite_frames := SpriteFrames.new()
		sprite_frames.add_frame("default", character.texture.texture_export)
		%Sprite.sprite_frames = sprite_frames
	else:
		visible = false
		return
