extends Control

var character : Character :
	set(new_character):
		character = new_character
		%Preview.texture = character.texture

signal open_new_file()

func _on_xml_open_button_pressed() -> void:
	open_new_file.emit()
