extends Object

var p := SimpleXmlParser.from_parser(XMLParser.new())

func parse_objects(path: String) -> Array[Character]:
	var err := p.open(path)
	if err != OK:
		push_error("Error while attempting to parse \"", path, "\": ", error_string(err))
		return []
	p.read()
	assert(p.is_element())
	if p.get_node_name() != "Objects":
		return []
	
	if !p.read_possible_end():
		return []
	
	var chars : Array[Character] = []
	
	while !p.is_element_end():
		var id := p.get_attribute_value("id")
		#var type := p.get_attribute_value("type").to_int()
		
		var offset := p.get_node_offset()
		p.read()
		var object_class : String
		var object_class_set := false
		while !p.is_element_end():
			if p.get_node_name() == "Class":
				p.read_whitespace()
				object_class = p.get_node_data()
				object_class_set = true
				break
			p.skip_section()
			p.read()
		p.seek(offset)
		
		if object_class_set:
			match object_class:
				"Wall":
					pass
				"Projectile":
					pass
				"GameObject":
					pass
				"Portal":
					pass
				"Character":
					var c = Character.parse(p)
					chars.append(c)
				"InteractiveInfoObject":
					pass
				_:
					print(id)
					push_warning("Unknown object class: ", object_class)
		
		p.skip_section()
		if !p.read_possible_end():
			break
		
	return chars
