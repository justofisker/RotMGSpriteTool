extends AnimatedSprite2D

@onready var sprite_preview_controls: MarginContainer = $"../../SpritePreviewControls"

var direction: int :
	set(dir):
		direction = dir
		if sprite_frames && sprite_frames.has_animation("A%dD%d" % [action, direction]):
			play("A%dD%d" % [action, direction])

var action: int :
	set(act):
		action = act
		if sprite_frames && sprite_frames.has_animation("A%dD%d" % [action, direction]):
			play("A%dD%d" % [action, direction])

var texture: TextureXml :
	set(tex):
		texture = tex
		direction = 0
		action = 0
		_update_sprite()

func _update_sprite():
	if !texture:
		return
	if texture.animated:
		var sprites := texture.animated_sprites
		var animations := {}
		var directions := {}
		for sprite in sprites:
			var cur_frames : Array = animations.get_or_add("A%dD%d" % [sprite.action, sprite.direction], [])
			cur_frames.push_back(RotmgAtlases.get_animated_texture(sprite, true))
			animations["A%dD%d" % [sprite.action, sprite.direction]] = cur_frames
			directions[sprite.direction] = null
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
		if frames.has_animation("A0D0"):
			play("A0D0")
		else:
			play(frames.get_animation_names()[0])
		sprite_preview_controls.visible = true
		direction = directions.keys()[0]
	else:
		var frames := SpriteFrames.new()
		frames.add_frame("default", RotmgAtlases.get_texture(texture.sprite, true))
		sprite_frames = frames
		play("default")
		sprite_preview_controls.visible = false
