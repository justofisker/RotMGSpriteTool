class_name TextureXml extends Resource

var file_name: String
var index: int
var animated: bool
var sprite: RotmgSprite :
	get:
		if animated:
			push_error("Tried to get Sprite for an AnimatedTexture (%s:%d)" % [ file_name, index ])
			return null
		if is_instance_valid(sprite):
			return sprite
		sprite = RotmgAtlases.get_sprite(file_name, index)
		return sprite
var animated_sprites: Array[RotmgAnimatedSprite] :
	get:
		if !animated:
			push_error("Tried to get AnimatedSprite for an Texture (%s:%d)" % [ file_name, index ])
			return []
		if is_instance_valid(animated_sprites):
			return animated_sprites
		animated_sprites = RotmgAtlases.get_animated_sprites(file_name, index)
		return animated_sprites

static func parse(p: SimpleXmlParser) -> TextureXml:
	var t := TextureXml.new()
	
	var offset := p.get_node_offset()
	t.animated = p.get_node_name() == "AnimatedTexture"
	
	p.read()
	while !p.is_element_end():
		if p.is_element():
			match p.get_node_name():
				"File":
					p.read_whitespace()
					t.file_name = p.get_node_data()
				"Index":
					p.read_whitespace()
					var index_string := p.get_node_data()
					if index_string.begins_with("0x"):
						t.index = p.get_node_data_as_hex()
					else:
						t.index = p.get_node_data_as_int()
			p.skip_section()
		p.read()
	
	p.seek(offset)
	return t
