extends Panel

@export var anim_sprite: AnimatedSprite2D
@export var animation_selector: OptionButton
@export var label: Label
@export var png_dialog: NativeFileDialog
@export var gif_dialog: NativeFileDialog
@export var gif_button: Button
@export var png_button: Button
@export var sprite_control: Control

@onready var scale_spin: SpinBox = $MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/ScaleSpin
@onready var outline_spin: SpinBox = $MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer2/OutlineSpin
@onready var outline_color: ColorPickerButton = $MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer3/OutlineColor

var characters: Array[Character]

var current_character: String :
	set(value):
		for c in characters:
			if c.id == value:
				label.text = c.id
				current_character = value
				animation_selector.clear()
				var sprite_frames := SpriteFrames.new()
				for a in c.animations:
					animation_selector.add_item(a.id)
					sprite_frames.add_animation(a.id)
					for idx in a.frames.size():
						sprite_frames.add_frame(a.id, a.frames[idx].texture, a.frame_durations[idx])
				anim_sprite.sprite_frames = sprite_frames
				if c.animations.size() != 0:
					_on_animation_selector_item_selected(0)
					gif_button.disabled = false
					png_button.disabled = false
					sprite_control.custom_minimum_size = get_sprite_max_size()
				else:
					gif_button.disabled = true
					png_button.disabled = true
				break

func _on_animation_selector_item_selected(index: int) -> void:
	anim_sprite.play(animation_selector.get_item_text(index))

func _ready() -> void:
	gif_dialog.file_mode = NativeFileDialog.FILE_MODE_SAVE_FILE
	gif_dialog.add_filter("*.gif", "GIF Image (*.gif)")
	png_dialog.file_mode = NativeFileDialog.FILE_MODE_SAVE_FILE
	png_dialog.add_filter("*.png", "PNG Image (*.png)")

func _on_gif_export_button_pressed() -> void:
	#_on_save_gif_dialog_file_selected("res://test.gif")
	gif_dialog.show()

func _on_png_export_button_pressed() -> void:
	png_dialog.show()

func _on_save_png_dialog_file_selected(path: String) -> void:
	pass # Replace with function body.

func _on_save_gif_dialog_file_selected(path: String) -> void:
	var texture_scale : int = int(scale_spin.value)
	var outline_size: int = int(outline_spin.value)
	var outline_color := outline_color.color
	
	var extents := Vector2i()
	var sprite_frames = anim_sprite.sprite_frames
	var animation_name = anim_sprite.animation
	for idx in sprite_frames.get_frame_count(animation_name):
		var tex := sprite_frames.get_frame_texture(animation_name, idx)
		extents.x = maxi(extents.x, tex.get_width())
		extents.y = maxi(extents.y, tex.get_height())
	extents *= texture_scale
	extents += Vector2i(outline_size * 2, outline_size * 2)
	var exporter := GifExporter.new(extents.x, extents.y)
	
	var mat := preload("res://outline_preview_material.tres")
	mat.set_shader_parameter("outline_color", outline_color)
	mat.set_shader_parameter("outline_size", outline_size)
	mat.set_shader_parameter("scale", texture_scale)
	
	for idx in sprite_frames.get_frame_count(animation_name):
		var tex : AtlasTexture = sprite_frames.get_frame_texture(animation_name, idx).duplicate()
		tex.region.position.x -= ceilf(float(texture_scale) / outline_size)
		tex.region.position.y -= ceilf(float(texture_scale) / outline_size)
		tex.region.size.x += ceilf(float(texture_scale) / outline_size) * 2
		tex.region.size.y += ceilf(float(texture_scale) / outline_size) * 2
		
		var viewport := SubViewport.new()
		viewport.size = extents
		viewport.disable_3d = true
		viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
		viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		viewport.transparent_bg = true
		
		var sprite = Sprite2D.new()
		sprite.texture = tex
		sprite.material = mat
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.scale *= texture_scale
		viewport.add_child(sprite)
		
		var camera := Camera2D.new()
		viewport.add_child(camera)
		#camera.make_current()
		
		add_child(viewport)
		
		await RenderingServer.frame_post_draw
		
		var img := viewport.get_texture().get_image()
		img.convert(Image.FORMAT_RGBA8)
		exporter.add_frame(img, sprite_frames.get_frame_duration(animation_name, idx), MediumCutQuantization)
		remove_child(viewport)
	
	print("done!")
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(exporter.export_file_data())
	file.close()

func get_sprite_max_size() -> Vector2i:
	var sprite_frames := anim_sprite.sprite_frames
	var animation_name := anim_sprite.animation
	var extents := Vector2i() 
	for idx in sprite_frames.get_frame_count(animation_name):
		var tex := sprite_frames.get_frame_texture(animation_name, idx)
		if !is_instance_valid(tex):
			continue
		extents.x = maxi(extents.x, tex.get_width())
		extents.y = maxi(extents.y, tex.get_height())
	extents *= scale_spin.value
	extents += Vector2i(outline_spin.value * 2, outline_spin.value * 2)
	return extents

func _on_scale_spin_value_changed(value: float) -> void:
	anim_sprite.scale = Vector2(value, value)
	sprite_control.custom_minimum_size = get_sprite_max_size()
	sprite_control.size = Vector2()
	anim_sprite.material.set_shader_parameter("scale", value)

func _on_outline_spin_value_changed(value: float) -> void:
	anim_sprite.material.set_shader_parameter("outline_size", value)

func _on_outline_color_color_changed(color: Color) -> void:
	anim_sprite.material.set_shader_parameter("outline_color", color)
