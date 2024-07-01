extends SpriteSheetDeserializer

func get_animated_sprite_textures_export(sprite_sheet: String, index: int) -> Array[Texture2D]:
	var frames : Array[RotmgAnimatedTexture] = get_animated_textures(sprite_sheet, index)
	
	var out : Array[Texture2D] = []
	
	var outline_size := 1
	var export_scale := 5
	
	for frame in frames:
		if !is_instance_valid(frame.texture) || !is_instance_valid(frame.texture.texture):
			push_error("Invalid texture!")
			continue
		var tex : AtlasTexture = frame.texture.texture.duplicate()
		if outline_size != 0:
			tex.region.position.x -= ceilf(float(outline_size) / export_scale)
			tex.region.position.y -= ceilf(float(outline_size) / export_scale)
			tex.region.size.x += ceilf(float(outline_size) / export_scale) * 2
			tex.region.size.y += ceilf(float(outline_size) / export_scale) * 2
		out.push_back(tex)
	
	return out

func get_texture_export(sprite_sheet: String, index: int) -> AtlasTexture:
	var rotmg_texture : RotmgTexture = get_texture(sprite_sheet, index)
	if !is_instance_valid(rotmg_texture) || !is_instance_valid(rotmg_texture.texture):
			push_error("Invalid texture!")
			return null
	var tex := rotmg_texture.texture
	var outline_size := 1
	var export_scale := 5
	if outline_size != 0:
		tex.region.position.x -= ceilf(float(outline_size) / export_scale)
		tex.region.position.y -= ceilf(float(outline_size) / export_scale)
		tex.region.size.x += ceilf(float(outline_size) / export_scale) * 2
		tex.region.size.y += ceilf(float(outline_size) / export_scale) * 2
	return tex
