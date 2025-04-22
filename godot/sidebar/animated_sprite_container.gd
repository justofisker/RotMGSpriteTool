extends Container

@onready var sprite : AnimatedSprite2D = get_child(0)

func _ready() -> void:
	sprite.sprite_frames_changed.connect(_on_sprite_frames_changed)
	sprite.frame_changed.connect(_reposition_hflip)
	sprite.animation_changed.connect(_reposition_hflip)

var max_size := Vector2i.ZERO
func _on_sprite_frames_changed() -> void:
	max_size = Vector2i.ZERO
	for anim_name in sprite.sprite_frames.get_animation_names():
		for idx in range(0, sprite.sprite_frames.get_frame_count(anim_name)):
			var tex = sprite.sprite_frames.get_frame_texture(anim_name, idx)
			max_size.x = maxi(max_size.x, tex.get_width())
			max_size.y = maxi(max_size.y, tex.get_height())
	var uniform_scale := minf(size.x / max_size.x, size.y / max_size.y)
	sprite.scale = Vector2(uniform_scale, uniform_scale)
	sprite.position = (size - sprite.scale * Vector2(max_size)) / 2.0
	_reposition_hflip()

func _reposition_hflip() -> void:
	if sprite.flip_h:
		var tex = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
		sprite.position.x = (max_size.x - tex.get_width()) * sprite.scale.x
		return
	sprite.position = (size - sprite.scale * Vector2(max_size)) / 2.0
