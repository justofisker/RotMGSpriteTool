extends Node

@export var sprite_panel: PackedScene
@export var xml_selector: NativeFileDialog

const ObjectParser = preload("res://parsers/objects/object_parser.gd")

func _ready() -> void:
	xml_selector.file_selected.connect(_on_native_file_dialog_file_selected)
	if DirAccess.dir_exists_absolute("./assets/xml/"):
		xml_selector.root_subfolder = "./assets/xml/"
	else:
		xml_selector.root_subfolder = "./"
	xml_selector.add_filter("*.xml", "RotMG Object XML (*.xml)")
	xml_selector.show()

func _on_native_file_dialog_file_selected(path: String) -> void:
	var children := get_parent().get_children(false)
	children.remove_at(children.find(self))
	for child in children:
		get_parent().remove_child(child)
	var parser := ObjectParser.new()
	var characters := parser.parse_objects(path)
	
	for c in characters:
		var panel = sprite_panel.instantiate()
		panel.character = c
		get_parent().add_child.call_deferred(panel)

func _on_sidebar_open_new_file() -> void:
	xml_selector.show()
