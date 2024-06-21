class_name SimpleXmlParser extends Object

var parser: XMLParser

static func from_parser(p: XMLParser) -> SimpleXmlParser:
	var sp = SimpleXmlParser.new()
	sp.parser = p
	return sp

# Overrides

func open(file: String) -> Error:
	return parser.open(file)

func get_node_name() -> String:
	return parser.get_node_name()

func get_node_offset() -> int:
	return parser.get_node_offset()

func skip_section() -> void:
	parser.skip_section()

func seek(offset: int) -> void:
	parser.seek(offset)

# New

func get_attribute_value(name: String) -> String:
	for idx in parser.get_attribute_count():
		if parser.get_attribute_name(idx) == name:
			return parser.get_attribute_value(idx)
	#push_warning("Couldn't find attribute with name: ", name)
	return ""

func get_node_data_as_int() -> int:
	return parser.get_node_data().to_int()

func get_node_data_as_float() -> float:
	return parser.get_node_data().to_float()

func get_node_data_as_hex() -> int:
	return parser.get_node_data().hex_to_int()

func get_node_data() -> String:
	return parser.get_node_data()

func is_element() -> bool:
	return parser.get_node_type() == XMLParser.NODE_ELEMENT
	
func is_element_end() -> bool:
	return parser.get_node_type() == XMLParser.NODE_ELEMENT_END

# Reads

func read() -> void:
	assert(parser.read() != ERR_FILE_EOF)
	while !(parser.get_node_type() == XMLParser.NODE_ELEMENT || parser.get_node_type() == XMLParser.NODE_ELEMENT_END):
		assert(parser.read() != ERR_FILE_EOF)

func read_whitespace() -> void:
	assert(parser.read() != ERR_FILE_EOF)
	while !(parser.get_node_type() == XMLParser.NODE_ELEMENT || parser.get_node_type() == XMLParser.NODE_ELEMENT_END || parser.get_node_type() == XMLParser.NODE_TEXT):
		assert(parser.read() != ERR_FILE_EOF)

func read_possible_end() -> bool:
	if parser.read() == ERR_FILE_EOF:
		return false
	while !(parser.get_node_type() == XMLParser.NODE_ELEMENT || parser.get_node_type() == XMLParser.NODE_ELEMENT_END):
		if parser.read() == ERR_FILE_EOF:
			return false
	return true
