extends Node

@export var sprite_panel: PackedScene

const ObjectParser = preload("res://parsers/objects/object_parser.gd")

func _ready() -> void:
	var parser := ObjectParser.new()
	var characters := parser.parse_objects("res://assets/xml/theShattersObjects.xml")
	
	for c in characters:
		var panel = sprite_panel.instantiate()
		panel.character = c
		get_parent().add_child.call_deferred(panel)
