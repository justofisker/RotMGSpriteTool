extends AnimatedSprite2D

var direction: int :
	set(dir):
		direction = dir
		_update_sprite()

var action: int :
	set(act):
		action = act
		_update_sprite()

var texture: TextureXml :
	set(tex):
		texture = tex
		direction = 0
		action = 0
		_update_sprite()

signal avaliable_directions(directions: Array[int])

func _update_sprite():
	if !texture:
		return
	var frames : Array[Texture2D]
	var sprites := texture.animated_sprites
	var av_directions : Array[int]
	for sprite in sprites:
		if av_directions.find(sprite.direction) == -1:
			av_directions.push_back(sprite.direction)
		if sprite.direction == direction && sprite.action == action:
			frames.push_back(RotmgAtlases.get_animated_texture(sprite, true))
	print(av_directions)
	avaliable_directions.emit(av_directions)
	# Sometimes you need to remove a frame from walking animation idk
	sprite_frames = SpriteFrames.new()
	for frame in frames:
		sprite_frames.add_frame("default", frame, 1.0 / frames.size())
	play()
