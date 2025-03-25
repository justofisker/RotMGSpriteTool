extends VBoxContainer

@onready var button: Button = $Button

var character: Character :
	set(value):
		character = value
		_update_sprite()

func _update_sprite() -> void:
	visible = true
	if character == null || !is_instance_valid(character.texture):
		visible = false
		return
	if character.texture.animated:
		var sprite_frames := SpriteFrames.new()
		var frames := RotmgAtlases.get_animated_sprites(character.texture.file_name, character.texture.index)
		for frame in frames:
			sprite_frames.add_frame("default", RotmgAtlases.get_animated_texture(frame))
		%Sprite.sprite_frames = sprite_frames
		%Sprite.play()
		button.export_data = ExportData.from_animated_textures(RotmgAtlases.get_animated_textures(character.texture.file_name, character.texture.index))
	elif is_instance_valid(character.texture.texture):
		var sprite_frames := SpriteFrames.new()
		sprite_frames.add_frame("default", character.texture.texture_export)
		button.export_data = ExportData.from_texture(RotmgAtlases.get_texture(character.texture.file_name, character.texture.index))
		%Sprite.sprite_frames = sprite_frames
	else:
		visible = false
		return
