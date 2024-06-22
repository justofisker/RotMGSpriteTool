extends PanelContainer

@export var label: Label
@export var vbox: VBoxContainer

var character_id: String

func _on_button_pressed() -> void:
	get_tree().get_first_node_in_group("animation_panel").current_character = character_id
