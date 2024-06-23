extends SpriteSheetDeserializer
 
func get_animated_sprite_textures_export(sprite_sheet: String, index: int, default: bool = false) -> Array[Texture2D]:
	var frames = get_animated_sprite_textures(sprite_sheet, index)
	
	var out : Array[Texture2D]
	
	var outline_size := GlobalSettings.export_outline_size
	var export_scale := GlobalSettings.export_scale
	if default:
		outline_size = 1
		export_scale = 5
	
	for frame in frames:
		var tex : AtlasTexture = frame.duplicate()
		if outline_size != 0:
			tex.region.position.x -= ceilf(float(outline_size) / export_scale)
			tex.region.position.y -= ceilf(float(outline_size) / export_scale)
			tex.region.size.x += ceilf(float(outline_size) / export_scale) * 2
			tex.region.size.y += ceilf(float(outline_size) / export_scale) * 2
		out.push_back(tex)
	
	return out

func get_texture_export(sprite_sheet: String, index: int, default: bool = false) -> AtlasTexture:
	var tex : AtlasTexture = get_texture(sprite_sheet, index)
	var outline_size := GlobalSettings.export_outline_size
	var export_scale := GlobalSettings.export_scale
	if default:
		outline_size = 1
		export_scale = 5
	if outline_size != 0:
		tex.region.position.x -= ceilf(float(outline_size) / export_scale)
		tex.region.position.y -= ceilf(float(outline_size) / export_scale)
		tex.region.size.x += ceilf(float(outline_size) / export_scale) * 2
		tex.region.size.y += ceilf(float(outline_size) / export_scale) * 2
	return tex
