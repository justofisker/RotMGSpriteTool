class_name TextureXml extends Resource

var file_name: String
var index: int
var animated: bool
var texture: Texture2D :
	get:
		if is_instance_valid(texture):
			return texture
		texture = RotmgAtlases.get_texture(file_name, index)
		return texture

var texture_export: Texture2D :
	get:
		return RotmgAtlases.get_texture_export(file_name, index)

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
					t.index = p.get_node_data_as_hex()
			p.skip_section()
		p.read()
	
	p.seek(offset)
	return t
