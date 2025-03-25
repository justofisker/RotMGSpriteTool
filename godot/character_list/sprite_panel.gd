extends PanelContainer

@export var label: Label
@export var vbox: VBoxContainer
@export var sprite: TextureRect
@onready var background_selected: NinePatchRect = $BackgroundSelected

var character: Character :
	set(value):
		character = value
		label.text = character.id
		_setup_sprite()

func _setup_sprite() -> void:
	if !is_instance_valid(character.texture):
		return
	
	if character.texture.animated:
		for animated_sprite in character.texture.animated_sprites:
			if animated_sprite.action == 0 && animated_sprite.direction == 0:
				sprite.texture = RotmgAtlases.get_animated_texture(animated_sprite, true)
		if !sprite.texture:
			sprite.texture = RotmgAtlases.get_animated_texture(character.texture.animated_sprites[0], true)
	else:
		sprite.texture = RotmgAtlases.get_texture(character.texture.sprite, true)
	
	if sprite.texture:
		sprite.custom_minimum_size = sprite.texture.get_size() * 5

func _on_button_pressed() -> void:
	get_tree().get_first_node_in_group("Sidebar").character = character

func _on_button_focus_entered() -> void:
	background_selected.visible = true

func _on_button_focus_exited() -> void:
	background_selected.visible = false
