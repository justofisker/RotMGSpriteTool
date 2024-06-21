extends Panel

@export var anim_sprite: AnimatedSprite2D
@export var animation_selector: OptionButton
@export var label: Label
@export var png_dialog: NativeFileDialog
@export var gif_dialog: NativeFileDialog
@export var gif_button: Button
@export var png_button: Button

@onready var v_box: VBoxContainer = $MarginContainer/VBoxContainer

@onready var scale_spin: SpinBox = $MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/SpinBox
@onready var outline_spin: SpinBox = $MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer2/SpinBox


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
	gif_dialog.show()

func _on_png_export_button_pressed() -> void:
	png_dialog.show()

func _on_save_png_dialog_file_selected(path: String) -> void:
	pass # Replace with function body.

func _on_save_gif_dialog_file_selected(path: String) -> void:
	var SCALE : int = int(scale_spin.value)
	var OUTLINE_SIZE: int = int(outline_spin.value)
	
	var extents := Vector2i()
	var sprite_frames = anim_sprite.sprite_frames
	var animation_name = anim_sprite.animation
	for idx in sprite_frames.get_frame_count(animation_name):
		var tex := sprite_frames.get_frame_texture(animation_name, idx)
		extents.x = maxi(extents.x, tex.get_width())
		extents.y = maxi(extents.y, tex.get_height())
	var exporter := GifExporter.new(extents.x * SCALE + OUTLINE_SIZE * 2, extents.y * SCALE + OUTLINE_SIZE * 2)
	
	for idx in sprite_frames.get_frame_count(animation_name):
		var tex := sprite_frames.get_frame_texture(animation_name, idx)
		var scaled_img := Image.create(extents.x, extents.y, false, tex.get_image().get_format())
		scaled_img.blit_rect(tex.get_image(), Rect2i(Vector2i(), scaled_img.get_size()), Vector2i((extents.y - tex.get_width()) / 2, extents.y - tex.get_height()))
		scaled_img.convert(Image.FORMAT_RGBA8)
		scaled_img.resize(extents.x * SCALE, extents.y * SCALE, Image.INTERPOLATE_NEAREST)
		
		var outline_img = Image.create(extents.x * SCALE + OUTLINE_SIZE * 2, extents.y * SCALE + OUTLINE_SIZE * 2, false, Image.FORMAT_RGBA8)
		outline_img.blit_rect(scaled_img, Rect2i(Vector2i(), scaled_img.get_size()), Vector2i(OUTLINE_SIZE, OUTLINE_SIZE))
		
		for x in outline_img.get_width():
			for y in outline_img.get_height():
				if outline_img.get_pixel(x, y).a8 == 0:
					# TODO: Make this a viewport thing and shader to not make this take forever
					var get_pixel_safe := func(img: Image, x: int, y: int) -> bool:
						x -= OUTLINE_SIZE
						y -= OUTLINE_SIZE
						if x < 0 || x >= img.get_width() || y < 0 || y >= img.get_height():
							return false
						return img.get_pixel(x, y).a8 > 0
					
					var w : bool =  get_pixel_safe.call(scaled_img, x - OUTLINE_SIZE, y               )
					var n : bool =  get_pixel_safe.call(scaled_img, x               , y - OUTLINE_SIZE)
					var e : bool =  get_pixel_safe.call(scaled_img, x + OUTLINE_SIZE, y               )
					var s : bool =  get_pixel_safe.call(scaled_img, x               , y + OUTLINE_SIZE)
					var nw : bool = get_pixel_safe.call(scaled_img, x - OUTLINE_SIZE, y - OUTLINE_SIZE)
					var sw : bool = get_pixel_safe.call(scaled_img, x - OUTLINE_SIZE, y + OUTLINE_SIZE)
					var ne : bool = get_pixel_safe.call(scaled_img, x + OUTLINE_SIZE, y - OUTLINE_SIZE)
					var se : bool = get_pixel_safe.call(scaled_img, x + OUTLINE_SIZE, y + OUTLINE_SIZE)
					if w || n || e || s || nw || sw || ne || se:
						outline_img.set_pixel(x, y, Color.BLACK)
		
		exporter.add_frame(outline_img, sprite_frames.get_frame_duration(animation_name, idx), MediumCutQuantization)
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(exporter.export_file_data())
	file.close()
