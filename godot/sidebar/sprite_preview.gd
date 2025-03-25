extends AnimatedSprite2D

var direction: int :
	set(dir):
		direction = dir
		play("A%dD%d" % [action, direction])

var action: int :
	set(act):
		action = act
		play("A%dD%d" % [action, direction])

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
	var sprites := texture.animated_sprites
	var animations := {}
	for sprite in sprites:
		var cur_frames : Array = animations.get_or_add("A%dD%d" % [sprite.action, sprite.direction], [])
		cur_frames.push_back(RotmgAtlases.get_animated_texture(sprite, true))
		animations["A%dD%d" % [sprite.action, sprite.direction]] = cur_frames
	# Evil and fucked up extra walk animation
	for d in [0, 2, 3]:
		if animations.has("A1D%d" % d) && animations.has("A2D%d" % d):
			var walk : Array = animations["A1D%d" % d]
			var attack : Array = animations["A2D%d" % d]
			while walk.size() > attack.size():
				walk.pop_front()
	var frames = SpriteFrames.new()
	for anim_name in animations.keys():
		frames.add_animation(anim_name)
		var anim : Array = animations[anim_name]
		for tex in anim:
			frames.add_frame(anim_name, tex, 1.0 / anim.size())
	sprite_frames = frames
	play("A%dD%d" % [action, direction])
