class_name CharacterAnimation extends Resource

var prob: float
var period: int
var id: String

var frames: Array[TextureXml]
var frame_durations: Array[float]

static func parse(p: SimpleXmlParser) -> CharacterAnimation:
	var a := CharacterAnimation.new()
	a.id = p.get_attribute_value("id")
	if a.id == "":
		a.id = ""
	a.prob = p.get_attribute_value("prob").to_float()
	a.period = p.get_attribute_value("period").to_int()
	var offset := p.get_node_offset()
	p.read()
	
	while !p.is_element_end():
		match p.get_node_name():
			"Frame":
				a.frame_durations.append(p.get_attribute_value("time").to_float())
				p.read()
				a.frames.append(TextureXml.parse(p))
				p.skip_section()
		p.skip_section()
		p.read()
	
	p.seek(offset)
	return a
