class_name Character extends XmlObject

var texture: TextureXml
var animations: Array[CharacterAnimation]
var display_id: String
var alt_textures: Array[TextureXml]

static func parse(p: SimpleXmlParser) -> Character:
	var c := Character.new()
	c.id = p.get_attribute_value("id")
	c.type = p.get_attribute_value("type").to_int()
	var offset := p.get_node_offset()
	p.read()
	
	while !p.is_element_end():
		match p.get_node_name():
			"Texture":
				c.texture = TextureXml.parse(p)
			"AnimatedTexture":
				c.texture = TextureXml.parse(p)
			"Animation":
				c.animations.append(CharacterAnimation.parse(p))
			"DisplayId":
				p.read_whitespace()
				c.display_id = p.get_node_data()
			"Presentation":
				pass
			"AltTexture":
				_parse_alt_texture(c, p)
		p.skip_section()
		p.read()
	
	p.seek(offset)
	return c

static func _parse_alt_texture(c: Character, p: SimpleXmlParser) -> void:
	var offset := p.get_node_offset()
	
	var _id := p.get_attribute_value("id")
	
	p.read()
	while  !p.is_element_end():
		match p.get_node_name():
			"AnimatedTexture":
				c.alt_textures.push_back(TextureXml.parse(p))
			"Texture":
				c.alt_textures.push_back(TextureXml.parse(p))
		p.skip_section()
		p.read()
	
	p.seek(offset)
