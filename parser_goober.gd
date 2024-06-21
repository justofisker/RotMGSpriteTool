extends Node

const ObjectParser = preload("res://parsers/objects/object_parser.gd")

@export var container: Control

func _ready() -> void:
	var parser := ObjectParser.new()
	var characters := parser.parse_objects("res://assets/xml/theShattersObjects.xml")
	#var characters := parser.parse_objects("res://assets/xml/abyssOfDemonsObjects.xml")
	#var characters := parser.parse_objects("res://assets/xml/moonlightVillageObjects.xml")
	
	get_tree().get_first_node_in_group("animation_panel") .characters = characters
	
	for c in characters:
		if c.texture != null:
			var panel := preload("res://sprite_panel.tscn").instantiate()
			panel.character_id = c.id
			panel.label.text = c.id
			
			if !c.texture.animated:
				if c.texture.texture == null:
					push_error("Something")
					continue
				var texrect = TextureRect.new()
				texrect.texture = c.texture.texture
				texrect.texture.region.position.x -= 1
				texrect.texture.region.position.y -= 1
				texrect.texture.region.size.x += 2
				texrect.texture.region.size.y += 2
				texrect.custom_minimum_size = texrect.texture.get_size() * 5
				texrect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
				texrect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
				texrect.material = preload("res://outline_material.tres")
				panel.vbox.add_child(texrect)
				panel.vbox.move_child(texrect, 0)
				container.add_child(panel)
			else:
				var anim_sprite := RotmgAtlases.get_animated_sprite(c.texture.file_name, c.texture.index)
				anim_sprite.scale = Vector2(5, 5)
				anim_sprite.centered = false
				anim_sprite.play("default")
				anim_sprite.material = preload("res://outline_material.tres")
				var control := Control.new()
				for idx in anim_sprite.sprite_frames.get_frame_count("default"):
					var tex : AtlasTexture = anim_sprite.sprite_frames.get_frame_texture("default", idx)
					tex.region.position.x -= 1
					tex.region.position.y -= 1
					tex.region.size.x += 2
					tex.region.size.y += 2
					control.custom_minimum_size.x = maxf(control.custom_minimum_size.x, tex.get_width())
					control.custom_minimum_size.y = maxf(control.custom_minimum_size.y, tex.get_height())
				control.custom_minimum_size *= 5.0
				control.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
				control.add_child(anim_sprite)
				panel.vbox.add_child(control)
				panel.vbox.move_child(control, 0)
				container.add_child(panel)
		else:
			push_warning("Texture is null")
