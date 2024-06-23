extends Control

var sprite: AnimatedSprite2D

func _ready() -> void:
	for child in get_children():
		if child is AnimatedSprite2D:
			sprite = child
			sprite.centered = false
			sprite.sprite_frames_changed.connect(_on_sprite_frames_changed)
			sprite.animation_changed.connect(_on_animated_changed)
			sprite.frame_changed.connect(_on_frame_changed)
			break
	if !is_instance_valid(sprite):
		push_warning("No AnimatedSprite2D is child of sprite container")
	_resize_to_animation()
	_reposition_frame()

func _resize_to_animation() -> void:
	if !is_instance_valid(sprite):
		return
	var sprite_frames = sprite.sprite_frames
	var animation := sprite.animation
	custom_minimum_size = Vector2()
	if !is_instance_valid(sprite.sprite_frames):
		return
	for idx in sprite_frames.get_frame_count(animation):
		var frame = sprite_frames.get_frame_texture(animation, idx)
		custom_minimum_size.x = maxf(custom_minimum_size.x, frame.get_width())
		custom_minimum_size.y = maxf(custom_minimum_size.y, frame.get_height())
	custom_minimum_size *= sprite.scale

func _reposition_frame() -> void:
	if !is_instance_valid(sprite.sprite_frames):
		return
	var frame := sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	if !is_instance_valid(frame):
		return
	sprite.position.x = (custom_minimum_size.x - frame.get_width() * sprite.scale.x) / 2.0
	sprite.position.y = custom_minimum_size.y - frame.get_height() * sprite.scale.y

func _on_sprite_frames_changed() -> void:
	_resize_to_animation()
	_reposition_frame()

func _on_animated_changed() -> void:
	_resize_to_animation()
	_reposition_frame()

func _on_frame_changed() -> void:
	_reposition_frame()
