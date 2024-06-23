extends VBoxContainer

@export var animation_selector: OptionButton

var character: Character :
	set(value):
		character = value
		_setup_animations()

func _setup_animations() -> void:
	animation_selector.selected = 0
	_setup_animation_selector()
	_add_frames()
	animation_selector.item_selected.emit(0)

func _setup_animation_selector() -> void:
	animation_selector.clear()
	for idx in character.animations.size():
		var anim : CharacterAnimation = character.animations[idx]
		var animation := anim.id
		if animation == "":
			animation = str(idx)
		animation_selector.add_item(animation)

func _add_frames() -> void:
	var sprite_frames := SpriteFrames.new()
	var outline_size : int = %ExportOptions.outline_size
	var export_scale : int = %ExportOptions.export_scale
	for idx in character.animations.size():
		var anim : CharacterAnimation = character.animations[idx]
		var animation := anim.id
		if animation == "":
			animation = str(idx)
		sprite_frames.add_animation(animation)
		for jdx in anim.frames.size():
			var tex : AtlasTexture = anim.frames[jdx].texture.duplicate()
			if outline_size != 0:
				tex.region.position.x -= ceilf(float(outline_size) / export_scale)
				tex.region.position.y -= ceilf(float(outline_size) / export_scale)
				tex.region.size.x += ceilf(float(outline_size) / export_scale) * 2
				tex.region.size.y += ceilf(float(outline_size) / export_scale) * 2
			sprite_frames.add_frame(animation, tex, anim.frame_durations[jdx])
	%Sprite.sprite_frames = sprite_frames
	animation_selector.select(animation_selector.selected)

func _on_animation_selector_item_selected(index: int) -> void:
	%Sprite.play(animation_selector.get_item_text(animation_selector.selected))
