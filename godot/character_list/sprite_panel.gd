extends PanelContainer

@export var label: Label
@export var vbox: VBoxContainer
@export var sprite: AnimatedSprite2D

var character: Character :
	set(value):
		character = value
		label.text = character.id
		_setup_sprite()

func _setup_sprite() -> void:
	var sprite_frames := SpriteFrames.new()
	if character.texture != null:
		if character.texture.animated:
			var frames = RotmgAtlases.get_animated_sprite_textures_export(character.texture.file_name, character.texture.index)
			for frame in frames:
				sprite_frames.add_frame("default", frame)
		elif character.texture.texture != null:
			sprite_frames.add_frame("default", character.texture.texture)
	else:
		print("erm")
	sprite.sprite_frames = sprite_frames
	sprite.play()
	sprite.get_parent()._resize_to_animation.call_deferred()

func _on_button_pressed() -> void:
	get_tree().get_first_node_in_group("sidebar").character = character
